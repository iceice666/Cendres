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

## 9.3 模組切分

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

## 9.4 Game State Machine

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
