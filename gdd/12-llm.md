# LLM 文本生成系統

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
