# Run 結構與輪間流程

## 7.1 單次 Run 節拍圖

```
BEACON REFLECTION（pre-run）
  ↓  Beacon 說話（run 數對應對話）
  ↓  玩家照顧 Void Garden
  ↓  玩家花 Lumen 解鎖 Beacon Memory 節點
  ↓  玩家選擇起始配置（結構 + Lantern 類型）

PREP PHASE  [90 秒]
  ↓  第一人稱：佈置結構、設定光源覆蓋
  ↓  確認 Lumen 儲量
  ↓  傾聽——第一批聲音線索揭示即將到來的波次物種

WAVE PHASE  [不定長]
  ↓  Void 生物從黑暗邊緣進入
  ↓  玩家作戰：重新定位、補充燃料、主動使用 Lantern
  ↓  受傷的 Void 可以被 Tether 捕捉
  ↓  結構退化，可能損毀

SALVAGE PHASE  [60–90 秒]
  ↓  在 Beacon 附近收集殘影
  ↓  可選：進入 Dimming Boundary 獲取稀有掉落
  ↓  計時器可見——下次 prep 即將開始

  [重複 N 個波次]

最終波次 — DIMMING SURGE
  ↓  黑暗從所有邊緣推進
  ↓  燃料消耗加快；結構退化更快
  ↓  存活 → run 清除，大量 Lumen 獎勵
  ↓  失敗 → 死亡

死亡狀態
  ↓  淡化為灰色
  ↓  Beacon 說一句話
  ↓  給予 Beacon Memory Shard
  ↓  返回 Reflection
```

---

## 7.2 波次升級模式

```odin
Wave_Config :: struct {
    wave_number:   u32,
    pressure_type: Pressure_Type,
    species_mix:   []Species_Weight,
    has_named_void: bool,  // 稀有：出現有 lore 名字的個體
}

Pressure_Type :: enum {
    Volume,    // 大量 Drifter — 測試覆蓋範圍
    Speed,     // 快速 Gnasher — 測試反應
    Flank,     // Lurker 從意外方向 — 測試空間意識
    Siege,     // Weave 生成者 — 測試優先目標選擇
    Fuel_Drain,// Gnasher 直接攻擊結構 — 測試資源管理
    Composite, // 2+ 種類型組合，僅後期波次
}
```

### Run 長度

- 標準：8–12 波 / run，預估 35–50 分鐘
- Salvage Phase 視窗隨進度縮短：90 秒 → 60 秒 → 40 秒

### 排序規則（加權隨機＋約束）

```
約束條件：
  - 同一 Pressure_Type 不能連出兩波
  - Composite 不出現在前 3 波
  - 一次 run 中 Composite 最多 3 波
  - 第 1 波永遠是 Volume（讓玩家熟悉場地）
  - 最終波永遠是 Dimming Surge（Composite + 全境黑暗推進）
```

| 階段 | Volume | Speed | Flank | Fuel_Drain | Siege | Composite |
|---|---|---|---|---|---|---|
| 早期（1–4 波） | 60% | 30% | 10% | 0% | 0% | 0% |
| 中期（5–8 波） | 17% | 17% | 17% | 17% | 17% | 15% |
| 後期（9+ 波） | 14% | 14% | 14% | 14% | 14% | 30% |

中期 Composite 15% 仍受約束規則限制，實際出現機率低於表面數字。

### 波次 × 生產鏈互動

| Pressure Type | 對生產鏈的具體威脅 |
|---|---|
| Volume | Lumen 掉落豐沛，Refiner 滿載；是囤積 Dye 的最佳視窗 |
| Speed | 快攻壓縮反應時間；Dyed Lumen 效率紅利在此時最有感 |
| Flank | Lurker 繞後，可能直取 Refiner / Converter 後端 |
| Fuel_Drain | Gnasher 優先攻擊結構；Refiner / Converter 是高價值目標 |
| Siege | Weave 生成者製造暗區，切斷 Dyed Lumen 的流通範圍 |
| Composite | 以上多重組合；生產鏈和防線同時承壓 |

---

## 7.3 輪間持續性

| 元素 | 持續？ | 備注 |
|---|---|---|
| Beacon Memory 節點 | ✓ 永久 | 數值升級（燃燒路線） |
| Fragment 解鎖節點 | ✓ 永久 | 機制升級（記憶路線） |
| Void Garden 馴化生物 | ✓ 永久 | 它們從未在 run 裡 |
| Void Codex 條目 | ✓ 永久 | 初次捕捉解鎖；聆聽 / 命名解鎖深層條目 |
| 已找到的 Lore 碎片 | ✓ 永久 | 環境 imprint 保持揭示 |
| Beacon 對話進度 | ✓ 永久 | Run 數永遠遞增 |
| Lumen 儲量 | ✗ 重置 | 死亡時攜帶的 Lumen 消失 |
| 結構佈置 | ✗ 重置 | 每 run 重新建造 |
| Lumen Tether 充能 | ✗ 重置 | 每 run 從基礎數量開始 |
| 波次進度 | ✗ 重置 | 永遠從第 1 波開始 |

**死亡時的 Lumen：** 30% 攜帶的 Lumen 轉化為「grief residue」存入 Beacon，下次 run 可收集。在宇宙觀層面：你帶著的靈魂裡，有一些足夠強，死後還找得回來。

**Void Garden 餵食的視覺線索（揭露前的無聲信號）：**
- Run 1–10：Void 吸收 Lumen，光消失，動物安靜。正常。
- Run 15+：偶爾，一個 Garden 生物在吸收 Lumen 的瞬間動了一下——像認出了什麼。不是進食的動作。
- Run 20+：如果有多隻 Garden 生物，有時兩隻在 Lumen 放入的瞬間同時轉向彼此。
沒有說明。玩家自己解讀。揭露後，他們意識到那些靈魂在餵食中認出了彼此。

---

## 7.4 Void Garden 玩法設計

### 空間

Garden 不是獨立房間——它是 Beacon Reflection 空間裡的一個角落。Beacon 看著你在照顧死者。這個「被看見」的關係是設計的一部分。

### 容量

| 狀態 | 上限 |
|---|---|
| 預設 | 總計 10 隻，每物種最多 3 隻 |
| 解鎖後 | 無上限（每物種仍最多 3 隻） |

**無上限解鎖條件：** 每種物種至少命名一隻（不只捕捉，而是通過 Codex 觀察 + Fragment 收集找出它的名字）。

解鎖時 Beacon 說，只有這一次主動開口：
> 「你記住他們了。我一直不相信有人能做到這件事。」

### Cap 滿時的新捕捉（強制選擇）

沒有 UI 提示，沒有選擇界面。Garden 滿了，新捕捉的 Void 就是沒有位置。

下一次 Reflection，Garden 邊緣有一個短暫的陰影輪廓——那個 Void 的剪影，待幾秒，消失。Beacon 不說話。沒有說明。

### 餵食機制

主動，輕量。走近生物 + 按住互動鍵 = 給 Lumen（和補充結構燃料的動作相同）。

**核心張力：** Reflection 時你決定把多少 Lumen 留給 Garden，把多少帶進 run 作戰。這不是農場管理——這是一個每次出發前的分配時刻：*今晚我要帶多少走，留多少給它們。*

生物狀態沒有數字，只有視覺：毛色、光暈、動作幅度。缺乏照顧 → 生物逐漸退化（行為變少，更空洞），但不死亡。它們永遠在那裡，只是更像遺忘之前的狀態。

### 命名機制（Fragment 樹解鎖）

名字是發現的，不是自由輸入的。

```
捕捉 Void → Garden 新生物（無名，Codex 只有物種資訊）
餵食 / 聆聽模式使用後 → Codex 逐漸出現行為觀察條目
Fragment 樹解鎖「命名」能力 → 走近生物，按住互動
  → 出現片段列表（來自 Codex 觀察和 Fragment 收集）
     「牠一直走向同一個角落。」
     「牠聽到某個音調會停下來。」
     「牠反覆叫著：___。」  ← 收集到足夠 Fragment 才出現
  → 確認命名
```

命名後：
- Codex 深層條目解鎖（從行為觀察 → 身份碎片，生前的習慣、關係痕跡）
- 生物 Garden 行為變得更具體、更像人
- 它對特定 run 結果有反應（帶回同類 Fragment → 它靜止一段時間）

### Garden 的機制回報

同一隻生物，兩種使用方向互斥：

| 路線 | 做法 | 回報 | 代價 |
|---|---|---|---|
| 燃燒路線 | 大量餵食，不命名 | 生物被動產生少量 Lumen | 它逐漸變空洞，Codex 停在表層 |
| 記憶路線 | 命名，投入 Fragment | 波次預警（行為線索）、Beacon 對話提示、Ending C 路徑 | 效率較低，需要時間和 Fragment |

### 「與你同在的 run 數」

Garden 生物有一個隱藏計數（不顯示），影響行為豐富度和 Codex 深度。最老的那隻，Codex 最厚，偶爾停下來看著你。

這讓 Cap 滿時的無聲失去更有重量——你失去的，可能是某個還沒來得及認識的靈魂。

---

## 7.5 Behemoth 捕捉流程

Behemoth 是 Garden 裡唯一不能被 Tether 捕捉的生物。它不是被帶回來的——**它決定走進來**。

### 出現條件

Run 15+ 開始，有機率在 Dimming Surge 最後波次或深層 Dimming Boundary 探索中出現。它比一般 Void 大得多，移動緩慢，不衝向結構——它只走向 Beacon。

Tether 無法觸發（HP 閾值不適用）。唯一的互動方式是 Lantern 聆聽模式。

### 跨 run 見證累積

每次對 Behemoth 維持聆聽模式 20 秒以上（持續照著它，不攻擊）：
- 它停下來
- 那次 Surge 的最後波次靜止
- 然後它離開
- 這次見證記錄下來，跨 run 保存

```
見證 1 次    → Behemoth 在 Surge 中停下來一次
見證 2–3 次  → 它出現時，走得比以前慢
見證 4 次    → 它在你照著它的時候，轉向你（而不是 Beacon）
見證 5 次+   → 某一次 Reflection，它在 Garden 裡
              沒有過場，沒有動畫——它就是在那裡了
              Beacon 說（只有這一次主動開口）：
              「牠進來了。我以為牠永遠不會。」
```

### Behemoth 在 Garden 裡

它幾乎不動。它是 Garden 裡最沉默的存在，也是 Codex 條目最終最長的。它見過 The Dimming 最初的事件。它知道第一個 Tender 的名字。

Ending C 的觸發——Remnant 說出那個名字——需要 Behemoth 的 Codex 達到最深層。你花了那些 run 去見證它，最後它給你的，是讓整個故事說完的那一片拼圖。
