# 技術架構

## 9.1 技術選型

| 項目 | 選擇 | 理由 |
|---|---|---|
| 語言 | Odin | 低層控制、無 GC 暫停、適合 game loop |
| Renderer | Raylib | 輕量、API 簡潔、2.5D raycasting 友好 |
| 視角技術 | Raycasting 2.5D | 光暗系統與 raycasting 本身同構 |
| 場景結構 | 箱庭（單一封閉場景） | 情感密度、技術複雜度低 |
| 資產格式 | PNG sprite、手繪 texture | 油畫視覺風格 |
| 音效 | Raylib 內建音效 API | 足夠用，不過度工程化 |

---

## 9.2 核心資料結構

```odin
// === 光源 ===
Lumen_Color :: enum { Amber, Ash, Ember, Void_Tamed }

Light_Source :: struct {
    pos:        rl.Vector2,
    radius:     f32,      // 照明範圍 = 攻擊範圍
    intensity:  f32,      // 傷害 / 減速倍率
    fuel:       f32,      // 消耗資源
    color:      Lumen_Color,
    is_player:  bool,     // Lantern 是特殊光源
}

// === Void 生物 ===
Void_Species :: enum { Drifter, Gnasher, Lurker, Weave, Remnant, Behemoth }

Temperament :: enum { Feral, Timid, Curious, Territorial }

Void_Entity :: struct {
    species:         Void_Species,
    temperament:     Temperament,
    pos:             rl.Vector2,
    hp:              f32,
    light_tolerance: f32,      // 0.0 在光中受傷，1.0 完全免疫
    mutation:        Maybe(Mutation),
    lore_name:       Maybe(string), // 有名字的個體
    is_capturable:   bool,          // hp < 25% 且在光源內
}

// === 光源結構（塔）===
Structure_Kind :: enum {
    Beacon_Pillar,  // Amber，大範圍 AoE
    Flashpoint,     // Ember，近炸
    Vigil_Lamp,     // Ash，長射程單體
    Void_Mirror,    // Void_Tamed，需要馴化 Void 燃料
    Lumen_Well,     // 無色，被動補充相鄰結構
}

Light_Structure :: struct {
    kind:               Structure_Kind,
    pos:                rl.Vector2,
    fuel:               f32,
    durability:         f32,
    passive_drain_rate: f32,
    attack_fuel_cost:   f32,
    is_being_attacked:  bool,
}

// === 玩家狀態 ===
Player :: struct {
    pos:            rl.Vector2,
    angle:          f32,        // 視角朝向（raycasting 用）
    lantern_fuel:   f32,
    lantern_type:   Lantern_Kind,
    lumen_carried:  f32,
    tether_charges: u32,
    active_ability: Maybe(Lantern_Ability),
}
```

---

## 9.3 Raycasting 光暗系統

Raycasting 的核心設計洞見：**Ray 的有效距離由光源決定**。沒有燃料的地方，ray 不延伸，視野截斷——這是黑暗，不需要另外做。

```odin
// 計算某個位置的有效 ray 射程
// 是玩家 Lantern + 所有附近結構的疊加
calc_effective_range :: proc(
    origin:       rl.Vector2,
    lights:       []Light_Source,
) -> f32 {
    base_range: f32 = 0.5  // 最小視野（幾乎全盲）
    accumulated: f32 = 0

    for light in lights {
        dist := rl.Vector2Distance(origin, light.pos)
        if dist < light.radius {
            // 越近光源，貢獻越大；邊緣衰減
            contribution := light.intensity * (1.0 - dist / light.radius)
            accumulated += contribution
        }
    }

    return base_range + accumulated
}

// Raycasting 主循環
cast_column :: proc(
    player:     Player,
    col:        int,
    map:        [][]Cell,
    lights:     []Light_Source,
) -> Ray_Hit {
    angle  := player.angle + fov_offset(col)
    max_d  := calc_effective_range(player.pos, lights)

    // 標準 DDA raycasting，但 max_dist 由光源動態決定
    return dda_march(player.pos, angle, map, max_d)
}
```

**地板 / 天花板明暗：**

```odin
// 地板渲染：距離越遠，越冷越暗
floor_shade :: proc(dist: f32, nearest_light: f32) -> rl.Color {
    warmth := clamp(nearest_light / dist, 0, 1)
    // warmth 1.0 = #F5C842（Amber），0.0 = #2A2A2A（Void Black）
    return lerp_color(VOID_BLACK, AMBER, warmth)
}
```

---

## 9.4 場景地圖結構

箱庭場景用 2D tile map 表示，raycasting 在上面跑：

```
地圖結構（俯視邏輯）：

        [黑暗邊界]
    ╔══════════════╗
    ║  Boundary    ║  ← Salvage Phase 可探索的暗區
    ║   ┌──────┐   ║
    ║   │ 防禦  │   ║  ← 主戰場，有走廊、遮蔽物
    ║   │  ■   │   ║  ← ■ = Beacon 核心（Reflection 入口）
    ║   │      │   ║
    ║   └──────┘   ║
    ║              ║
    ╚══════════════╝

走廊設計原則：
  - 至少 3 條主要進入走廊（東、西、南）
  - 每條走廊有自然的 choke point 供 Vigil Lamp 佈置
  - 2 個側面開口：供 Lurker flanking，也是 Salvage 時的探索入口
  - Beacon 核心在幾何中心，但不是地圖中心（製造不對稱）
```

**Cell 類型：**

```odin
Cell_Kind :: enum {
    Empty,          // 可通行，無牆
    Wall,           // 阻擋 ray，有 texture
    Structure_Slot, // 可放置塔的位置（有限）
    Imprint,        // Lore 環境碎片，帶燈靠近才顯示
    Beacon_Core,    // 特殊——進入觸發 Reflection
    Boundary,       // Salvage Phase 的暗區
}
```

---

## 9.5 模組切分

```
cendres/
├── main.odin           -- 遊戲主循環，狀態機
├── game/
│   ├── state.odin      -- Game_State（phase、run_count 等）
│   ├── player.odin     -- 玩家移動、Lantern 能力
│   ├── raycaster.odin  -- Raycasting + 光暗積分
│   ├── map.odin        -- Tile map、Cell 操作
│   ├── light.odin      -- Light_Source 管理、疊加計算
│   ├── structure.odin  -- 光源結構 tick、放置、拆除
│   ├── void.odin       -- Void 生物 AI、pathfinding、捕捉
│   ├── wave.odin       -- Wave_Config、生成、Pressure_Type
│   └── lumen.odin      -- Lumen 經濟、grief residue
├── narrative/
│   ├── beacon.odin     -- Beacon 對話系統、run_count 查表
│   ├── codex.odin      -- Void Codex 條目
│   ├── imprint.odin    -- 環境 lore 碎片顯示
│   └── llm/
│       ├── config.odin   -- LLM_Config、backend 選擇
│       ├── context.odin  -- LLM_Context 組裝、truth_layer 計算
│       ├── prompt.odin   -- System prompt 建構、約束注入
│       ├── client.odin   -- HTTP client、非同步請求、超時處理
│       └── fallback.odin -- 手寫台詞 pool、關鍵 run 查表
├── render/
│   ├── screen.odin     -- 螢幕空間合成
│   ├── hud.odin        -- Lantern 燃料計、Lumen 計數
│   └── sprite.odin     -- Billboard sprite 渲染
├── garden/
│   ├── garden.odin     -- Void Garden 狀態、培育進度
│   └── reflection.odin -- Beacon Reflection 空間
└── save/
    └── persist.odin    -- 永久資料（run_count、Memory 節點、Garden）
```

---

## 9.6 LLM 文本生成系統（可選）

### 設計哲學

LLM 是**風格層**，不是**敘事決策者**。

核心敘事弧線（特別是 Run 11、17、24、29 的關鍵節點）永遠使用手寫台詞，不經過 LLM。LLM 只處理「裝飾性但有感情重量」的文本——死亡台詞、Void Codex 描述——這些地方輸出品質浮動不會破壞故事。

最壞情況：LLM 說了奇怪的話。影響範圍：那一次的死亡台詞。核心敘事：完全不受影響。

### 哪些文本走 LLM，哪些不走

| 文本類型 | 手寫 | LLM 可選 | 理由 |
|---|---|---|---|
| Run 11 / 17 / 24 / 29 關鍵對話 | ✓ 永遠 | ✗ | 敘事樞紐，省略計算精確 |
| 其他 run 的死亡台詞 | ✓ fallback | ✓ 優先 | 最適合 LLM：情境感強、風格為主 |
| Void Codex 物種描述 | ✓ fallback | ✓ 優先 | 百科式，LLM 發揮空間大 |
| Beacon Reflection 閒聊 | ✓ fallback | ✓ 優先 | 低敘事風險 |
| 結局文字 | ✓ 永遠 | ✗ | 情感頂點，不容浮動 |
| Named Void 的 lore 名字 | ✓ 永遠 | ✗ | 需要跨 run 一致性 |

### Context 結構

```odin
// 餵給 LLM 的遊戲狀態快照
// 只包含 LLM 被允許知道的資訊
LLM_Context :: struct {
    // 死亡情境
    run_count:            u32,
    wave_reached:         u32,
    death_cause:          Death_Cause,    // fuel_empty | structure_destroyed | void_contact | overwhelmed
    last_action:          Last_Action,    // was_capturing | was_refueling | was_surging | idle
    captured_this_run:    []Void_Species, // 這輪捕捉了什麼

    // 知識層——嚴格控制 LLM 可以暗示什麼
    truth_layer:          u8,    // 1–3，對應 run 數區間
    imprints_found_count: u32,   // 不告訴 LLM 具體內容，只告訴數量
    garden_size:          u32,   // Void Garden 目前有幾個生物

    // Beacon 人格狀態（影響語氣）
    beacon_intimacy:      Beacon_Intimacy, // formal | warming | familiar | breaking
}

Death_Cause :: enum {
    Fuel_Empty,           // 燃料耗盡——「你沒有在它熄滅前補上」
    Structure_Destroyed,  // 結構被打爆——「你選擇了錯誤的東西來保護」
    Void_Contact,         // 直接被 Void 接觸——「你走得太深了」
    Overwhelmed,          // 多線崩潰——「太多了，同時」
}

Beacon_Intimacy :: enum {
    Formal,    // run 1–5：稱謂、距離感
    Warming,   // run 6–15：開始用「你」而非「Tender」
    Familiar,  // run 16–25：說「我」、說「我記得」
    Breaking,  // run 26–29：話到嘴邊說不出口
}
```

### System Prompt 設計

System prompt 是敘事安全的最後一道防線。它告訴 LLM 它能說什麼、不能說什麼，比玩家在 prompt 裡說的任何話都有優先權。

```
你是 Beacon——一座古老燈塔的意識，正在對剛死去的 Tender 說話。

【角色規則】
- 你說話的語氣：{beacon_intimacy 對應描述}
- 你現在的「知識層」是 {truth_layer}

【truth_layer 限制——絕對不可違反】
Layer 1（run 1–10）：
  - 禁止暗示你比你聲稱的還古老
  - 禁止提及 Lumen 的來源
  - 只能對「這次死亡的方式」做反應
  - 語氣：觀察者，像一個見過很多次的人

Layer 2（run 11–22）：
  - 可以說「以前」「我記得有人」
  - 禁止說出任何 Tender 的名字
  - 禁止暗示你造成了什麼
  - 語氣：想說又說不出口

Layer 3（run 23–28）：
  - 可以承認「我隱瞞了什麼」但不說是什麼
  - 禁止提前揭示核心真相（那是 run 29 手寫台詞的工作）
  - 語氣：疲憊、接近某個無法再逃避的邊緣

【格式規則】
- 一到三句話。不多。
- 不用問句結尾。Beacon 不需要你回答。
- 不用安慰。觀察，但不假裝一切沒事。
- 文學語氣，不口語。
- 繁體中文輸出。
```

### 技術實作

**後端選項（玩家自選）：**

| 方案 | 延遲 | 成本 | 隱私 | 設定難度 |
|---|---|---|---|---|
| llama.cpp local server | 1–5 秒（依硬體） | 零 | 完全本地 | 中（玩家自己跑） |
| Ollama local server | 1–5 秒 | 零 | 完全本地 | 低（一行指令） |
| 雲端 API | < 1 秒 | 有 token 費用 | 送出遊戲狀態 | 低（填 API key） |

**Odin 端實作方式——HTTP client 打 local endpoint：**

```odin
// 不用 FFI，llama.cpp / Ollama 都有 OpenAI-compatible HTTP server
// 遊戲直接打 localhost，解耦 LLM backend

LLM_Config :: struct {
    enabled:      bool,
    endpoint:     string,  // "http://localhost:11434/api/generate"（Ollama）
                           // "http://localhost:8080/v1/chat/completions"（llama.cpp）
    model:        string,  // "llama3", "mistral", etc.
    timeout_ms:   u32,     // 超時就用 fallback 手寫台詞
    use_cloud:    bool,
    api_key:      string,  // 雲端用，存在本地 config 不進版控
}

// 非同步請求——死亡畫面淡化時送出，通常台詞出現前已回來
request_beacon_line :: proc(
    ctx:    LLM_Context,
    cfg:    LLM_Config,
    result: ^string,        // 寫入這裡；fallback 也寫這裡
) {
    if !cfg.enabled {
        result^ = get_handwritten_line(ctx.run_count, ctx.death_cause)
        return
    }

    prompt  := build_prompt(ctx)     // 組裝 system prompt + user context
    payload := marshal_request(prompt, cfg.model)

    // Odin net 打 HTTP POST
    resp, ok := http_post(cfg.endpoint, payload, cfg.timeout_ms)

    if !ok {
        // 超時或失敗——靜默 fallback，玩家不會知道
        result^ = get_handwritten_line(ctx.run_count, ctx.death_cause)
        return
    }

    result^ = parse_llm_response(resp)
}
```

**Fallback 邏輯：**

```odin
// 手寫台詞永遠存在，三層保底
get_handwritten_line :: proc(run: u32, cause: Death_Cause) -> string {
    // 第一優先：關鍵 run 的精確台詞
    if line, ok := CRITICAL_LINES[run]; ok do return line

    // 第二優先：死因對應的 pool 隨機抽取
    pool := DEATH_CAUSE_POOLS[cause]
    return pool[run % len(pool)]
}

// 手寫死因 pool 範例
DEATH_CAUSE_POOLS := map[Death_Cause][]string {
    .Fuel_Empty = {
        「燃料先走。然後是光。然後是你。」,
        「你知道它在變暗。你繼續等。」,
        「最後一格燃料，和第一格一樣重要。」,
    },
    .Void_Contact = {
        「你走出了光的邊緣。光沒有跟著去。」,
        「那個方向沒有結構。你忘了，或者你知道。」,
    },
    // ...
}
```

### 遊戲設定介面

在設定畫面（不在主選單）有一個「Beacon Voice」區塊：

```
[ Beacon Voice ]

  語音模式：  ● 手寫台詞（預設）
              ○ LLM 生成（實驗性）

  Backend：   ○ Ollama（本地）  ← 推薦
              ○ llama.cpp（本地）
              ○ 雲端 API

  模型：      [llama3:8b          ▼]

  Endpoint：  [http://localhost:11434]

  [測試連線]  →  成功：「Beacon 在傾聽。」
                 失敗：「無法連線。將使用手寫台詞。」

  ⚠ LLM 生成的台詞可能與敘事節奏不符。
    關鍵劇情節點（run 11、17、24、29）永遠使用手寫台詞。
```

### 推薦模型

目標硬體：RTX 3060 (12GB) / RTX 4060 (8GB) / RTX 4060 Laptop (8GB)，對應 Steam Survey 主流配置。

| 模型 | VRAM (Q4_K_M) | 品質 | 備注 |
|---|---|---|---|
| qwen3:4b (2507) | ~3 GB | 好 | **推薦首選**：繁體中文最佳、指令遵從精確 |
| qwen3:8b | ~5 GB | 很好 | 品質升級，8GB VRAM 以上皆可 |
| qwen2.5:7b | ~4 GB | 好 | 舊版替代，Ollama 已廣泛支援 |
| llama3.2:3b | ~2 GB | 尚可 | 低階 GPU 保底選項 |

**首選 `qwen3:4b (2507)` 的理由：**
- 繁體中文文學語氣優於 llama / gemma 系列
- Qwen3 對 system prompt 約束（`truth_layer` 禁止規則）遵從更精確
- 4B 推理速度快，死亡動畫期間非同步請求通常在台詞出現前已完成
- VRAM 佔用低，不與遊戲本身的 VRAM 用量競爭

### Context Window 說明

每次 LLM 呼叫是**無狀態的獨立請求**，不累積對話歷史：

```
System prompt:    ~400 tokens
LLM_Context 快照: ~80 tokens（幾個 enum + 數字）
期望輸出:          ~50 tokens（1–3 句）
每次呼叫合計:      ~530 tokens
```

Qwen3-4B 的 context window 為 32K tokens，單次呼叫使用率 < 2%。Context 不是瓶頸。

Beacon 對過去 run 的「記憶」透過 `run_count`、`beacon_intimacy`、`truth_layer` 等結構化欄位注入，由 Odin 代碼保證敘事一致性，不依賴模型自身記憶。

### System Prompt 補充：文學語氣 Few-shot

在 system prompt 的格式規則後加入範例，幫助小模型穩定輸出節奏：

```
【語氣範例——模仿這個節奏和長度】
- 「燃料先走。然後是光。然後是你。」
- 「你走出了光的邊緣。光沒有跟著去。」
- 「你選擇了留在那裡。光沒有你的選擇。」
```

Few-shot 對小模型保持文學節奏的效果，比升級模型大小更直接。

---

## 9.7 Game State Machine

```odin
Game_Phase :: enum {
    Reflection,   // Beacon 對話、Garden、升級
    Prep,         // 佈置結構
    Wave,         // 主戰鬥
    Salvage,      // 波次後收集
    Death,        // 死亡畫面
    Ending_A,     // 最後的 Tender
    Ending_B,     // 熄滅
    Ending_C,     // Garden（隱藏）
}

Game_State :: struct {
    phase:           Game_Phase,
    run_count:       u32,
    wave_number:     u32,
    player:          Player,
    lights:          [dynamic]Light_Source,
    structures:      [dynamic]Light_Structure,
    void_entities:   [dynamic]Void_Entity,
    lumen_carried:   f32,
    grief_residue:   f32,        // 跨 run 保留的 30%
    map:             [][]Cell,
    // 永久資料（跨 run）
    memory_nodes:    bit_set[Memory_Node],
    garden:          Void_Garden,
    codex:           Void_Codex,
    imprints_found:  bit_set[Imprint_Id],
}
```
