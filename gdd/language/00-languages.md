# 通用語言 — 台灣正體中文用語表

> **DDD 通用語言原則：** 設計師、寫手與程式碼之間，只存在一套詞彙。
> GDD 正文以台灣正體中文命名概念；程式碼使用英文識別符，但命名的是同一個概念。
> 本文件是兩端的對照錨點。
> 任何新增的概念，先在這裡命名，再進入程式碼。

---

## 0. 台灣正體中文原生化規則

本文件不是英中翻譯表。它先確立中文概念，再替程式碼、資料欄位與外部工具選擇英文識別符。

### 0.1 中文主詞優先

- 章節標題、企劃正文、玩家可見文字，使用中文術語作主詞：寫「每輪開始於餘映」，不寫「每個 Run 在 Reflection 開始」。
- 英文只在三種地方出現：Odin 識別符、外部技術名、首次建立對照的括號。
- 首次出現格式：`中文術語（English 對照；Odin: code_identifier）`。後文若非討論程式碼，只用中文術語。
- 世界觀專名以中文名承擔情緒重量：**餘燼**、**拾薪者**、**消光**、**靈光**、**虛空**。英文名只供程式與查找。

### 0.2 英文保留條件

| 類型 | 處理方式 | 例子 |
|---|---|---|
| 語言 / 函式庫 / 外部規格 | 保留英文 | Odin、Raylib、GLSL、HTTP、JSON |
| 程式識別符 | 保留原樣，置於 code span | `Game_State`、`Void_Entity`、`run_count` |
| 大語言模型縮寫 | 首次寫「大語言模型（LLM）」，後文技術段可用 LLM | LLM context 寫作「情境快照」；system prompt 寫作「系統提示」 |
| 遊戲概念 | 正文使用中文，英文只作對照 | 輪、餘映、虛空園、虛空典籍、碎片 |
| UI / 玩家導向文字 | 原則上不出英文，除非是按鍵、平台或專有品牌 | 設定、儲存、返回、套用 |

### 0.3 台灣用字與文件語氣

- 使用台灣常見資訊用語：資料、設定、介面、使用者、執行、效能、畫面、音效、儲存、讀取。
- 避免直譯腔：少用「進行 X 的動作」「被某種 X 所影響」「這是一個用來 X 的系統」。
- 定義句要短而準：先說它是什麼，再說用途與邊界。
- 技術段可以精確，但不要把英文名詞串接成中文句子的骨架。

### 0.4 主要概念的中文主詞

| 英文對照 | 中文主詞 | 正文建議用法 |
|---|---|---|
| The Dimming | 消光 | 消光正在侵入邊界。 |
| Lumen | 靈光 | 結構消耗靈光維持燃燒。 |
| Beacon | **餘燼** | **餘燼**在餘映中說話。 |
| Tender | **拾薪者** | 玩家扮演新一任**拾薪者**。 |
| Void | 虛空 / 虛空生物 | 虛空從邊界進入。 |
| Void Entity | 虛空個體 | 單一敵人稱為虛空個體。 |
| Void Garden | 虛空園 | 捕捉後的個體留在虛空園。 |
| Void Codex | 虛空典籍 | 虛空典籍記錄物種條目。 |
| Fragment | 碎片 | 聆聽與見證會留下碎片。 |
| Run | 輪 | 一輪由餘映開始，死亡或結局結束。 |
| Beacon Reflection | **餘映** | **餘映**是輪與輪之間的整備時段。 |
| Prep Phase | 佈置階段 | 佈置階段提供 90 秒放置結構。 |
| Wave Phase | 波次 | 波次是主要防守時段。 |
| Salvage Phase | 拾荒階段 | 拾荒階段收集殘影與補給。 |
| Truth Layer | 真相層 | 真相層限制**餘燼**能暗示的內容。 |
| Beacon Intimacy | **餘溫** | **餘溫**決定**餘燼**的語氣階段。 |

---

## 1. 有界上下文（Bounded Contexts）

```
┌──────────────────────────────────────────────────────────────────────┐
│  世界觀與傳說                                                        │
│  消光 · 靈光 · 餘燼 · 拾薪者 · 虛空（集合名詞）                       │
│  ────────────────────────────────────────────────────────────────── │
│  ┌─────────────────────┐    ┌──────────────────────────────────────┐ │
│  │   戰鬥              │    │   輪迴流程                           │ │
│  │   虛空個體          │    │   輪 · 波次 · 餘映                   │ │
│  │   光源結構          │    │   佈置 · 拾荒 · 消光潮               │ │
│  │   提燈              │    └──────────────────────────────────────┘ │
│  │   染劑 · 靈光       │    ┌──────────────────────────────────────┐ │
│  │   霧侵蝕            │    │   持久層與虛空園                     │ │
│  └─────────────────────┘    │   虛空園 · 虛空典籍                  │ │
│  ┌─────────────────────┐    │   餘念 · 碎片樹                      │ │
│  │   敘事 / 大語言模型 │    │   哀傷殘影 · 有名個體                │ │
│  │   真相層            │    └──────────────────────────────────────┘ │
│  │   餘溫              │                                             │
│  │   死因              │                                             │
│  └─────────────────────┘                                             │
└──────────────────────────────────────────────────────────────────────┘
```

有界上下文定義術語**有效的邊界**。相同詞彙在不同上下文裡意義不同時，以上下文名稱作前綴區分（如 `Combat::Lumen` vs `World::Lumen`）。

---

## 2. 詞彙詳表

每個條目至少要回答三件事：
- 中文術語是什麼，正文應如何使用
- 對應的英文概念或 Odin 識別符是什麼
- 定義、用途範圍、需要特別澄清的歧義

> 整理中的舊表格仍可能先列英文對照；新增或重寫表格一律採「中文術語優先」。

---

### 2.1 世界觀與傳說（World & Lore）

| 術語 | 中文 | Odin 識別符 | 定義 |
|---|---|---|---|
| **The Dimming** | 消光 | — (narrative only) | 世界系統化的哀悼缺失。非熵事件——是幾世紀燃燒靈魂的累積結果。**不是「黑暗」的同義詞**；The Dimming 是名詞專有，指整個現象。 |
| **Lumen** | 靈光 | `f32` (raw fuel) / `Lumen_Color` | 死者離去後留下的殘影——同時是燃料、靈魂與亮度來源。**在 World 上下文中是靈魂；在 Combat / Economy 上下文中是可量化資源。兩者是同一個東西，不是兩種東西。** 「光」是靈光釋放後的可見現象；傷害、耐受、燃料、結構輸出等機制語境，一律以「靈光」為主詞。文學用詞「Spirit」只出現於敘事文本，程式碼一律用 `Lumen`。 |
| **Beacon** | **餘燼** | — (narrative only) | 古老燈塔的意識，遊戲中唯一的 NPC。出處：cendres（法語：灰燼）——最後沒熄的那一點火。在程式碼中不作為 struct 存在；它的對話由 `narrative/beacon.odin` 管理，數值影響存在 `Game_State` 裡。**不要與 `Beacon_Pillar`（結構種類）混淆。** |
| **Tender** | **拾薪者** | — | 玩家角色。出處：《莊子．養生主》「指窮於為薪，火傳也，不知其盡也」——你撿柴，**餘燼**燒。歷史上所有操作過**餘燼**的人都稱為**拾薪者**，不只是這一位。程式碼中以 `Player` struct 表示。 |
| **Void**（集合名詞） | 虛空 / 虛空生物 | `Void_Entity` struct | 被 The Dimming 扭曲的亡靈統稱。**集合名詞用法：Void 不是一個生物，是所有迷失亡靈的統稱。** 個別生物稱 Void Entity，特定種類稱 Void Species。 |
| **Imprint** | 烙印 | — (UI / narrative) | 玩家在環境中發現的 lore 碎片（壁畫、文字）。非 Fragment（見 §2.5）。永久解鎖，跨 run 保留。程式碼中以 `bool` flag 陣列追蹤。 |
| **The Dimming Boundary** | 消光邊界 | — (map term) | 地圖的黑暗邊緣區域。Void 從這裡進入；Salvage Phase 玩家可選擇深入此處。不是可程式化的結構體，是地圖幾何概念。 |

---

### 2.2 虛空實體（Void Entities）

| 術語 | 中文 | Odin 識別符 | 定義 |
|---|---|---|---|
| **Void Entity** | 虛空個體 | `Void_Entity` struct | 戰場上單一的 Void 生物實例。每個實例有 `species`、`temperament`、`hp` 等欄位。 |
| **Void Species** | 虛空物種 | `Void_Species` enum | 物種分類——六個物種，六種結尾，刻意不用統一後綴。物種決定基礎外觀、AI 傾向權重、Dye 來源。 |
| Drifter | 漂魂 | `Void_Species.Drifter` | 漂 = drift，魂 = soul。Void 本質是迷失的亡靈——無目的的殘留。 |
| Gnasher | 噬獸 | `Void_Species.Gnasher` | 噬 = devour，獸 = beast。咬嚙結構的野獸。 |
| Lurker | 潛影 | `Void_Species.Lurker` | 潛 = lurk，影 = shadow。貼著暗區移動——你看到的是影，不是本體。 |
| Weave | 織暗 | `Void_Species.Weave` | 織 = weave，暗 = darkness。製造暗區，如織黑暗。 |
| Remnant（物種） | 殘響 | `Void_Species.Remnant` | 保留人格殘影的特殊物種，擁有名字、會說話。**不要與複合 Dye `Remnant`（見 §2.4）混淆**——兩個術語相同但在不同 Bounded Context。 |
| Behemoth | 巨靈 | `Void_Species.Behemoth` | 唯一無法用 Tether 捕捉的物種。透過「見證」累積跨 run 關係，最終自行走進 Garden。Behemoth 不受 Feral 影響。 |
| **Temperament** | 氣質 | `Temperament` enum | 個體 AI 行為模式。`base_temperament` 是生成時決定的固定傾向（Curious / Timid / Territorial 三種之一）；`temperament` 是當前值，可被暫時覆寫為 Feral。**Feral 不是第四種基礎傾向，是暫時態。** |
| Curious | 趨光 | `Temperament.Curious` | 趨 = move toward。向最近光源漂移；僅在緊鄰或依靠 `light_tolerance` 抵抗靈光傷害時攻擊。 |
| Timid | 畏光 | `Temperament.Timid` | 畏 = fear。貼暗區移動，繞開光源半徑。與「趨光」成對立。 |
| Territorial | 據守 | `Temperament.Territorial` | 據 = hold，守 = guard。生成時鎖定一個目標結構，直線推進，寸步不讓。 |
| Feral | 狂化 | `Temperament.Feral` | Tether 捕捉被中斷後的暫時狂暴狀態。`temperament_timer` 倒數後回復 `base_temperament`。**只有 Timid 被逼無路時也可觸發。Behemoth 免疫 Feral。** |
| **Named Void** | 有名個體 | `lore_name: Maybe(string)` | 擁有 lore 名字的罕見 Void Entity。在波次中偶爾出現（`has_named_void` flag）；命名另指 Garden 生物的命名行為（見 §2.5）。 |

**Mutation（突變）**

| 術語 | 中文 | Odin 識別符 | 定義 |
|---|---|---|---|
| **Mutation** | 突變 | `Mutation` enum | Void Entity 的罕見個體修飾。大多數個體無 Mutation（`Maybe(Mutation)` 為 `nil`）。**與 Named Void 互斥**——有名字的個體不帶 Mutation。 |
| `Echoing` | 迴響 | `Mutation.Echoing` | 死亡時在原地留下短暫暗區。敘事方向：聲音比本體活得長。 |
| `Phasing` | 透光 | `Mutation.Phasing` | 每 N 秒短暫免疫靈光傷害。敘事方向：被燒過，學會閃躲。 |
| `Crystallized` | 結晶 | `Mutation.Crystallized` | 靈光耐受度偏高，移速降低。敘事方向：在 The Dimming 中存在太久，開始硬化。 |
| `Fractured` | 裂魂 | `Mutation.Fractured` | 死亡時分裂為兩個半血小體，分裂個體無 Mutation。敘事方向：一個靈魂裝了兩段未完的記憶。 |
| `Lucid` | 醒覺 | `Mutation.Lucid` | 聆聽模式觸發更快，Fragment 品質更高。敘事方向：永遠站在門口，永遠想起不來。**與 Named Void 的差異：Named Void 突破了；Lucid 沒有。** |

**物種 × Mutation 有效組合（v1.0）**

Mutation 的發生需要物種特性作為土壤；下表以外的組合不存在於初始設計，
可隨後續敘事需求擴充（版本標注以利追蹤）。

| | Echoing 迴響 | Phasing 透光 | Crystallized 結晶 | Fractured 裂魂 | Lucid 醒覺 |
|---|---|---|---|---|---|
| Drifter 漂魂 | ✓ | | | ✓ | ✓ |
| Gnasher 噬獸 | | | ✓ | | |
| Lurker 潛影 | | ✓ | | | |
| Weave 織暗 | ✓ | | | | |
| Remnant 殘響 | ✓ | | | ✓ | ✓ |
| Behemoth 巨靈 | | | ✓ | | |

Codex 分支：Tether 聆聽模式對帶有 Mutation 的個體會解鎖物種條目的分支故事頁。具體內容由寫手依上方敘事方向詞撰寫。

---

### 2.3 戰鬥系統（Combat）

**Lantern（提燈）**

| 術語 | 中文 | Odin 識別符 | 定義 |
|---|---|---|---|
| **Lantern** | 提燈 | `lantern_type`, `lantern_fuel` in `Player` | 玩家的主要工具，同時是武器和光源。每 Run 在 Reflection 時選擇。**Lantern 是玩家持有的個人光源，不是泛指所有光源。** |
| **Lantern Type** | 提燈類型 | `Lantern_Kind` enum | 每 Run 選擇的配置，影響各種 Ability 的效率。 |
| Amber Core | 琥珀心 | `Lantern_Kind.Amber_Core` | Illuminate 半徑較大；Flare 消耗更多。 |
| Ash Prism | 灰鏡 | `Lantern_Kind.Ash_Prism` | Surge 更長更窄；Illuminate 半徑減半。 |
| Ember Wick | 焰芯 | `Lantern_Kind.Ember_Wick` | Flare 留燃燒 DoT 區域；Tether 充能減少。 |
| Void-Tempered | 虛鍛 | `Lantern_Kind.Void_Tempered` | Dim 更有效，Curious 幾乎溫馴；基礎半徑低。 |
| **Lantern Ability** | 提燈能力 | `Lantern_Ability` enum | 玩家主動動作。 |
| Illuminate | 映照 | `Lantern_Ability.Illuminate` | 被動——永遠激活，個人視野，持續消耗。 |
| Flare | 閃焰 | `Lantern_Ability.Flare` | 脈衝爆發：對半徑內所有 Void 造成傷害，高燃料消耗。 |
| Tether | 牽引 | `Lantern_Ability.Tether` | 捕捉弱化 Void 或聆聽模式。兩種使用方式，見下方 Tether 澄清。 |
| Surge | 湧光 | `Lantern_Ability.Surge` | 延伸 Lantern 光以橋接兩個結構之間的缺口，約 8 秒。 |
| Dim | 斂光 | `Lantern_Ability.Dim` | 將 Lantern 降至接近零輸出。典故：斂容、斂跡——收斂而不熄。 |

**Tether（牽引）— 特別澄清**

`Tether` 在三種語境下意義不同，不可混用：

| 使用語境 | 意義 | 章節 |
|---|---|---|
| `Lantern_Ability.Tether` | 提燈能力之一，涵蓋兩種使用方式 | §8.2 |
| **Tether Capture**（捕捉流程） | HP < 25% 的 Void 在光源內引導 3 秒拉取；有 Feral 風險 | §8.4 |
| **Tether Listening Mode**（聆聽模式） | 非戰鬥用途；無 HP 門檻，持續照射使 Void 靜止，留下 Fragment | §8.5 |
| `Tether_Line`（傳導線） | 連接結構的物理線體，獨立於 `Light_Structure` 的 struct | §8.13 |

**Light Structures（光源結構）**

| 術語 | 中文 | Odin 識別符 | 定義 |
|---|---|---|---|
| **Light Source** | 光源 | `Light_Source` struct | 任何輸出靈光亮度的實體資料——包含玩家提燈（`is_player = true`）和放置的結構。**「光源」在程式碼中特指此 struct，不可泛稱所有發光事物；機制描述若涉及傷害或耐受，改稱靈光。** |
| **Light Structure** | 光源結構 | `Light_Structure` struct | 玩家在戰場放置的塔。`Light_Source` 是「靈光輸出效果」的資料；`Light_Structure` 是「可放置物件」的資料。兩者是不同 struct，一個 Light_Structure 對應一個 Light_Source，但不是同一個。 |
| **Structure Kind** | 結構種類 | `Structure_Kind` enum | 光源結構的類型。⚠ 以 `10-data-structures.md` 為準（非 `06-combat.md` 舊名）。 |
| Beacon_Pillar | 燈柱 | `Structure_Kind.Beacon_Pillar` | 360° 中距離，通用覆蓋，佈陣骨幹。偏好 Dye：Weave（耐久）、Ember（持燃）。 |
| Flashpoint | 閃點 | `Structure_Kind.Flashpoint` | 近距離觸發爆炸，被動等待。偏好 Dye：Ember（效率 +40%）。 |
| Vigil_Lamp | 守夜燈 | `Structure_Kind.Vigil_Lamp` | 長射程單體，走廊控制。偏好 Dye：Frost（射程延長）、冥（偵測）。 |
| Void_Mirror | 虛鏡 | `Structure_Kind.Void_Mirror` | 近感觸發脈衝，需馴化 Void 燃料。偏好 Dye：冥（觸發範圍加倍）。 |
| Lumen_Well | 靈井 | `Structure_Kind.Lumen_Well` | 無色，被動補充相鄰結構；可緩慢恢復鄰近結構的 capacity。 |
| Refiner | 煉化爐 | `Structure_Kind.Refiner` | 消耗 Lumen → 依 recipe 產出 Dye。Fragment 樹中期節點解鎖。 |
| Converter | 轉化爐 | `Structure_Kind.Converter` | 混入 Dye + Lumen → Dyed Lumen，自動輸出至周邊戰鬥結構。Fragment 樹中期節點解鎖。 |
| Charge_Turret | 充能炮臺 | `Structure_Kind.Charge_Turret` | 充能炮臺；傷害依充能量縮放，charge 滿而無目標時損耗 Lumen（見 §8.10）。 |
| Vigilance_Lens | 偵察鏡 | `Structure_Kind.Vigilance_Lens` | 360° 旋轉掃描，偵測 Void 位置；配合隨身 client device + 頻率調音（見 §8.11）。 |
| Echo_Marker | 回響標記 | `Structure_Kind.Echo_Marker` | 記錄歷史波次進入方向，Prep Phase 顯示熱區（見 §8.12）。 |
| Silent_Repair_Unit | 靜默修復站 | `Structure_Kind.Silent_Repair_Unit` | 自動回復鄰近結構 capacity；廢蝕階段 II+ 時失效（見 §8.14）。 |
| Shield_Emitter | 緊急盾發射器 | `Structure_Kind.Shield_Emitter` | 偵測鄰近結構受攻擊時自動投射保護場，消耗大量 fuel（見 §8.15）。 |
| **Fuel** | 燃料 | `fuel: f32` in `Light_Structure` | 結構儲存的 Lumen 量。**Fuel 就是 Lumen——放進結構裡的 Lumen 稱為 Fuel，強調其「可消耗」的功能角色。** |
| **Capacity** | 容量 | `capacity: f32` | 結構的最大燃料上限。霧侵蝕會降低；可由 `Silent_Repair_Unit` 或手動修復恢復。 |
| **Activation Threshold** | 啟動門檻 | `activation_pct: f32` | `fuel < capacity × activation_pct` 時結構關機。動態門檻（隨 capacity 縮放）。 |
| **Dark Period** | 暗期 | `activation_timer: f32` | 結構放置或移動後的不激活時間，`activation_timer > 0` 時有效。**僅放置／移動觸發，補燃料不觸發。** |
| **Corrosion Stage** | 廢蝕階段 | `Corrosion_Stage` enum | 霧侵蝕狀態。Degraded 後靜默修復站失效；Corroded 後只有手動修復能恢復。 |
| Healthy | 完好 | `Corrosion_Stage.Healthy` | 結構無損，所有功能正常。 |
| Draining | 侵蝕 | `Corrosion_Stage.Draining` | 霧開始侵入，capacity 持續下降。 |
| Degraded | 劣化 | `Corrosion_Stage.Degraded` | 靜默修復站對此結構失效。 |
| Corroded | 蝕毀 | `Corrosion_Stage.Corroded` | 結構功能退回基礎狀態，必須手動修復。 |
| **Fog Erosion** | 霧侵蝕 / 黑暗侵蝕 | `fog_erosion_rate: f32` | The Dimming 的迷霧接觸結構時，持續降低 `capacity`。驅動 Corrosion Stage 推進。 |

**波次系統**

| 術語 | 中文 | Odin 識別符 | 定義 |
|---|---|---|---|
| **Pressure Type** | 壓力類型 | `Pressure_Type` enum | 波次的組成模式（物種比例、進攻方向）。決定「哪些東西來」，不決定「個體怎麼行動」（個體行為由 Temperament 決定）。 |
| Volume | 潮湧 | `Pressure_Type.Volume` | 大量漂魂——測試覆蓋範圍。 |
| Speed | 疾襲 | `Pressure_Type.Speed` | 快速噬獸——測試反應。 |
| Flank | 側襲 | `Pressure_Type.Flank` | 潛影從意外方向——測試空間意識。 |
| Siege | 圍困 | `Pressure_Type.Siege` | 織暗生成者——測試優先目標選擇。 |
| Fuel_Drain | 蝕源 | `Pressure_Type.Fuel_Drain` | 噬獸直接攻擊結構——測試資源管理。蝕 = erode，源 = source。 |
| Composite | 複合 | `Pressure_Type.Composite` | 2+ 種類型組合，僅後期波次。 |
| **Dimming Surge** | 消光潮 | — (wave config) | 每個 Run 的最終波次。黑暗從所有邊緣推進，Composite 壓力類型，燃料與結構退化加快。 |

**玩家動作**

| 術語 | 中文 | Odin 識別符 | 定義 |
|---|---|---|---|
| **Witness Action** | 見證動作 | — (input event) | Void 消散動畫 1.5 秒內按住互動鍵。無 HP 門檻要求。使 Void 留下更完整的 Fragment。**揭露前無 UI 提示，一直存在。** |
| **Light Tolerance** | 靈光耐受度 | `light_tolerance: f32` | 虛空個體對靈光傷害的耐受程度。0.0 = 在靈光中完全受傷；1.0 = 完全免疫。 |

---

### 2.4 資源與經濟（Economy）

| 術語 | 中文 | Odin 識別符 | 定義 |
|---|---|---|---|
| **Dye** | 染劑 | `Lumen_Color` enum（部分）、Dye system | Refiner 從 Lumen 提煉的物種特性化資源。基礎染劑用單字命名（取物種本質）；複合染劑用二字詞。 |
| **基礎 Dye** | | | |
| Ember | 熾 | — | 來源：漂魂。熾 = blazing。熾熱、熾盛。火之意象。 |
| Frost | 凜 | — | 來源：噬獸。凜 = piercing cold。凜冽、凜冬。 |
| Void | 冥 | — | 來源：潛影。冥 = dark, of the nether。幽冥。**刻意與「虛空」區分**——虛是世界概念，冥是提煉物質。 |
| Weave | 縷 | — | 來源：織暗。縷 = thread, strand。一絲一縷，織物之本。 |
| Ash | 灰 | — | 來源：巨靈。灰 = ash。簡潔直接。 |
| **複合 Dye**（需 recipe 解鎖） | | | |
| Cinder | 熾霜 | — | 配方：熾 + 凜。兼有傷害 + 減速，效率略低於純 Dye。 |
| Eclipse | 冥蝕 | — | 配方：冥 + 縷。偵測範圍 + 結構護盾疊加。冥 = dark，蝕 = eclipse。 |
| Remnant | 餘音 | — | 配方：灰 + 任意。效果依玩家記憶深度而定。典故：餘音繞樑（《列子．湯問》）。**刻意與物種「殘響」區分**——不同字，不同 Bounded Context。 |
| **Dyed Lumen** | 染色靈光 | — | Converter 輸出的混合資源（Dye + raw Lumen）。自動流入周邊 Light Structure，若符合偏好 Dye 則獲得效率紅利。 |
| **Lumen Color** | 靈光色 | `Lumen_Color` enum | 原始 Lumen 的顏色類型，決定了 Lumen 的基本屬性。部分值與 Dye 共用單字名。 |
| Amber | 琥珀 | `Lumen_Color.Amber` | 預設靈光色。與提燈類型「琥珀心」一致。 |
| Ash | 灰 | `Lumen_Color.Ash` | 來自巨靈。與灰染劑一致。 |
| Ember | 熾 | `Lumen_Color.Ember` | 來自漂魂。與熾染劑一致。 |
| Void_Tamed | 馴虛 | `Lumen_Color.Void_Tamed` | 馴 = tamed，虛 = Void。被馴化的虛空之光。 |
| **Grief Residue** | 哀傷殘影 | `grief_residue: f32` in `Game_State` | 玩家死亡時，攜帶 Lumen 的 30% 保留至下次 Run 可收集。宇宙觀層面：夠強的靈魂，死了還找得回來。 |
| **Conversion Decay** | 轉化遞減 | `conversion_decay: f32` | 活體轉化時每次產出的遞減係數（`base_yield × decay ^ conversions_this_reflection`）。自然限制 Garden 一次清空。 |
| **Tether Material** | 傳導線材質 | `Tether_Material` enum | Tether Line 的製作材料。透過 Refiner 系統合成，消耗對應 Dye。材質名 = [染劑名] + 線。 |
| Raw_Lumen | 原光線 | `Tether_Material.Raw_Lumen` | 基礎 throughput 低，無副特性。 |
| Weave | 織線 | `Tether_Material.Weave` | 耐久高，不易被 Void 斷開。 |
| Ash | 灰線 | `Tether_Material.Ash` | 傳輸損耗低（遠端收到量更完整）。 |
| Ember | 熾線 | `Tether_Material.Ember` | 耐久低；斷線時短暫爆出傷害脈衝。 |

---

### 2.5 輪迴流程（Run Loop）

| 術語 | 中文 | Odin 識別符 | 定義 |
|---|---|---|---|
| **Run** | 輪 | `run_count: u32` | 一次完整的遊玩循環：**餘映** → Prep + Wave（重複）→ 死亡 / 清關。`run_count` 永久遞增，跨 Run 保留。 |
| **Beacon Reflection** | **餘映** | `Game_Phase.Reflection` | Run 開始前，在**餘燼**旁對話、Garden 照料、升級選擇。光的映照 + 心的省思——雙重意義。 |
| **Prep Phase** | 佈置階段 | `Game_Phase.Prep` | 每個 Wave 前 90 秒的結構佈置視窗。 |
| **Wave Phase** | 波次 | `Game_Phase.Wave` | 主戰鬥階段。Void 從邊界進入；玩家防守。 |
| **Salvage Phase** | 拾荒階段 | `Game_Phase.Salvage` | Wave 後 60–90 秒收集殘影；可選擇深入 Dimming Boundary。 |
| **Death** | 死亡 | `Game_Phase.Death` | 淡化為灰色，**餘燼**說一句話，給予 **餘念**碎片，返回 Reflection。 |
| **Ending** | 結局 | `Game_Phase` 結局變體 | Run 29+ 觸發。四個結局，共同點：不解釋、不解決 The Dimming、以靜默結束。 |
| Ending_A | 最後的拾薪者 | `Game_Phase.Ending_A` | 「留下來。再一個夜晚。」回到防禦場，戰至最後一盞光。 |
| Ending_B | 熄滅 | `Game_Phase.Ending_B` | 「讓它熄滅吧。」走向**餘燼**核心，熄滅第一口 Lumen Well。 |
| Ending_C | 歸園 | `Game_Phase.Ending_C` | 隱藏。典故：陶淵明〈歸園田居〉——在虛空園中找到歸宿。 |
| Ending_D | **餘燼** | `Game_Phase.Ending_D` | 隱藏。最隱密的結局，就是這個遊戲本身的名字。點題，首尾相扣。 |

---

### 2.6 持久層與虛空園（Persistence & Garden）

| 術語 | 中文 | Odin 識別符 | 定義 |
|---|---|---|---|
| **Void Garden** | 虛空園 | `garden/` package | 跨 Run 持久的馴化生物收藏空間。位於 Reflection 空間一角。生物在 Wave 中永不出現。 |
| **Void Codex** | 虛空典籍 | `narrative/codex.odin` | 生物百科。捕捉解鎖物種條目；聆聽 / 命名解鎖深層條目。跨 Run 永久保留。 |
| **Fragment** | 碎片 | — | Tether 聆聽模式或見證動作取得的身份碎片。**不是 Lumen；不是燃料。** 用於填入 Codex 深層條目、命名 Garden 生物、解鎖 Fragment Tree 節點。 |
| **Beacon Memory** | **餘念** | `memory_nodes: bit_set[Memory_Node]` | 燃燒路線的跨 Run 升級樹。記憶是燒出來的疤——**餘燼**記得的事，轉化為數值強化。花費 Lumen 解鎖。 |
| **Fragment Tree** | 碎片樹 | — | 記憶路線的跨 Run 升級樹。花費 Fragment 解鎖機制能力（聆聽模式 UI 提示、命名能力、聆聽安撫模式等）。 |
| **Memory Node** | 記憶節點 | `Memory_Node` enum | **餘念**樹的單一節點。 |

---

### 2.7 敘事系統（Narrative / LLM）

| 術語 | 中文 | Odin 識別符 | 定義 |
|---|---|---|---|
| **Truth Layer** | 真相層 | `truth_layer: u8` (1–3) | **餘燼**被允許暗示的知識深度，對應 run 數區間。**1 = run 1–10；2 = run 11–22；3 = run 23–28。Run 29 的台詞手寫，不走 LLM，不受 truth_layer 控制。** |
| **Beacon Intimacy** | **餘溫** | `Beacon_Intimacy` enum | **餘燼**語氣的關係階段。燼的本質是溫度，關係的度量是暖度。注入 LLM system prompt 調整語氣。 |
| Formal | 疏離 | `Beacon_Intimacy.Formal` | Run 1–5：不說「我」。不直呼「你」。最克制。 |
| Warming | 漸暖 | `Beacon_Intimacy.Warming` | Run 6–15：開始說「你」。開始有溫度。 |
| Familiar | 相知 | `Beacon_Intimacy.Familiar` | Run 16–25：說「我」。說「記得」。像跟老友說話。 |
| Breaking | 將熄 | `Beacon_Intimacy.Breaking` | Run 26–29：句子變長一點。靜默更多。典故：將熄未熄——快要滅了，但還沒有。 |
| **Death Cause** | 死因 | `Death_Cause` enum | 本次死亡的類別，決定 fallback 台詞 pool。 |
| Fuel_Empty | 油盡 | `Death_Cause.Fuel_Empty` | 典故：油盡燈枯——油燒盡了，燈就枯了。 |
| Structure_Destroyed | 構毀 | `Death_Cause.Structure_Destroyed` | 構 = structure，毀 = destroy。 |
| Void_Contact | 虛噬 | `Death_Cause.Void_Contact` | 虛 = Void，噬 = devour。被虛空吞噬。 |
| Overwhelmed | 覆沒 | `Death_Cause.Overwhelmed` | 典故：全軍覆沒——全軍覆滅。 |
| **Critical Run** | 關鍵輪 | `CRITICAL_LINES` map | Run 11、17、24、29 及所有結局。**永遠手寫台詞，永遠不走 LLM。** fallback pool 必須覆蓋所有 Death Cause × Critical Run 組合。 |
| **LLM Context** | LLM 情境快照 | `LLM_Context` struct | 每次 LLM 呼叫時送出的遊戲狀態結構體。只包含 LLM 被允許知道的資訊（不含具體 Imprint 內容，只含計數）。 |

---

## 3. 禁止的模糊使用

以下詞彙日常對話中很自然，但 GDD 和程式碼中必須以精確術語替代：

| 禁止用法 | 問題 | 應改用 |
|---|---|---|
| 「光」（bare noun） | 可指 Lumen、Light_Source、Lantern、或廣義照明 | 視上下文明確指定其中之一 |
| 「黑暗」（bare noun） | 可指 The Dimming、Fog Erosion、Dark Period、或字面暗區 | 視上下文明確指定其中之一 |
| 「捕捉」（未指明方式） | 可指牽引捕捉（§8.4）或聆聽模式（§8.5） | 明確說「牽引捕捉流程」或「牽引的聆聽模式」 |
| 「靈魂」（soul） | 敘事文學詞，程式碼裡不使用 | 程式碼中一律用 `Lumen` |
| 「精力 / 能量」（energy） | 含糊；可能指 Lumen、Fuel、或 Capacity | 明確說 Lumen（原料）、Fuel（儲量）、Capacity（上限） |
| 「Tether」（未指明語境） | 三種不同意義（見 §2.3） | 說清楚是牽引能力、牽引捕捉、聆聽模式、或傳導線 |
| 「tower」 | 英文俗稱，GDD 沒有此詞 | 統一用「光源結構」 |

### 3.1 禁止英文主詞殘留

以下句型會讓 GDD 看起來像英翻中。除非正在討論程式碼識別符，正文一律改成中文主詞。

| 避免寫法 | 改寫方向 |
|---|---|
| Void 從邊界進來。 | 虛空從邊界進來。 |
| Run 開始時選 Lantern。 | 每輪開始時選擇提燈。 |
| Reflection 可以餵 Garden。 | 餘映中可以照料虛空園。 |
| Codex 會解鎖 Fragment。 | 虛空典籍會記錄碎片帶來的條目。 |
| LLM 決定 Beacon 台詞。 | 大語言模型只潤飾**餘燼**台詞，不決定敘事。 |
| Structure 被 Void 攻擊。 | 光源結構遭虛空個體攻擊。 |
| Phase 結束後進入 Salvage。 | 波次結束後進入拾荒階段。 |
| Dimming Boundary 變得更危險。 | 消光邊界變得更危險。 |

---

## 4. 命名規則（程式模型對齊）

DDD 的「模型程式碼對齊」原則：GDD 術語和 Odin 識別符一一對應，不引入第三套詞彙。

```
Odin 命名慣例（對應 GDD 統一術語）：
  Ada_Case    → 型別 / Enum        Light_Source, Void_Entity, Lumen_Color
  snake_case  → 程序 / 變數        tick_structure, apply_light_effect
  UPPER_SNAKE → 常數               dark_period_floor, conversion_decay
```

跨語言對照速查：

| 概念 | GDD 中文 | GDD 英文 | Odin 識別符 |
|---|---|---|---|
| 世界系統化的哀悼缺失 | 消光 | The Dimming | — (narrative only) |
| 死者殘影 / 燃料 | 靈光 | Lumen | `f32` (量), `Lumen_Color` (種類) |
| 有意識的燈塔 NPC | **餘燼** | Beacon | — (narrative only) |
| 玩家角色 | **拾薪者** | Tender | `Player` struct |
| 個別虛空生物 | 虛空個體 | Void Entity | `Void_Entity` |
| 虛空物種分類 | 虛空物種 | Void Species | `Void_Species` enum |
| 罕見個體修飾（與 Named Void 互斥） | 突變 | Mutation | `Mutation` enum |
| 突變：迴響 | 迴響 | Echoing | `Mutation.Echoing` |
| 突變：透光 | 透光 | Phasing | `Mutation.Phasing` |
| 突變：結晶 | 結晶 | Crystallized | `Mutation.Crystallized` |
| 突變：裂魂 | 裂魂 | Fractured | `Mutation.Fractured` |
| 突變：醒覺 | 醒覺 | Lucid | `Mutation.Lucid` |
| 物種：漂魂 | 漂魂 | Drifter | `Void_Species.Drifter` |
| 物種：噬獸 | 噬獸 | Gnasher | `Void_Species.Gnasher` |
| 物種：潛影 | 潛影 | Lurker | `Void_Species.Lurker` |
| 物種：織暗 | 織暗 | Weave | `Void_Species.Weave` |
| 物種：殘響 | 殘響 | Remnant | `Void_Species.Remnant` |
| 物種：巨靈 | 巨靈 | Behemoth | `Void_Species.Behemoth` |
| AI 行為模式 | 氣質 | Temperament | `Temperament` enum |
| 氣質：趨光 | 趨光 | Curious | `Temperament.Curious` |
| 氣質：畏光 | 畏光 | Timid | `Temperament.Timid` |
| 氣質：據守 | 據守 | Territorial | `Temperament.Territorial` |
| 氣質：狂化（暫時態） | 狂化 | Feral | `Temperament.Feral` |
| 玩家持有的光源工具 | 提燈 | Lantern | `Lantern_Kind`, `lantern_fuel` |
| 提燈類型 | 提燈類型 | Lantern Type | `Lantern_Kind` enum |
| 琥珀心 | 琥珀心 | Amber Core | `Lantern_Kind.Amber_Core` |
| 灰鏡 | 灰鏡 | Ash Prism | `Lantern_Kind.Ash_Prism` |
| 焰芯 | 焰芯 | Ember Wick | `Lantern_Kind.Ember_Wick` |
| 虛鍛 | 虛鍛 | Void-Tempered | `Lantern_Kind.Void_Tempered` |
| 提燈能力 | 提燈能力 | Lantern Ability | `Lantern_Ability` enum |
| 映照 | 映照 | Illuminate | `Lantern_Ability.Illuminate` |
| 閃焰 | 閃焰 | Flare | `Lantern_Ability.Flare` |
| 牽引 | 牽引 | Tether | `Lantern_Ability.Tether` |
| 湧光 | 湧光 | Surge | `Lantern_Ability.Surge` |
| 斂光 | 斂光 | Dim | `Lantern_Ability.Dim` |
| 任何輸出靈光亮度的資料 | 光源 | Light Source | `Light_Source` |
| 放置在戰場的塔 | 光源結構 | Light Structure | `Light_Structure` |
| 結構種類 | 結構種類 | Structure Kind | `Structure_Kind` enum |
| 燈柱 | 燈柱 | Beacon_Pillar | `Structure_Kind.Beacon_Pillar` |
| 閃點 | 閃點 | Flashpoint | `Structure_Kind.Flashpoint` |
| 守夜燈 | 守夜燈 | Vigil_Lamp | `Structure_Kind.Vigil_Lamp` |
| 虛鏡 | 虛鏡 | Void_Mirror | `Structure_Kind.Void_Mirror` |
| 靈井 | 靈井 | Lumen_Well | `Structure_Kind.Lumen_Well` |
| 煉化爐 | 煉化爐 | Refiner | `Structure_Kind.Refiner` |
| 轉化爐 | 轉化爐 | Converter | `Structure_Kind.Converter` |
| 充能炮臺 | 充能炮臺 | Charge Turret | `Structure_Kind.Charge_Turret` |
| 偵察鏡 | 偵察鏡 | Vigilance Lens | `Structure_Kind.Vigilance_Lens` |
| 回響標記 | 回響標記 | Echo Marker | `Structure_Kind.Echo_Marker` |
| 靜默修復站 | 靜默修復站 | Silent Repair Unit | `Structure_Kind.Silent_Repair_Unit` |
| 緊急盾發射器 | 緊急盾發射器 | Shield Emitter | `Structure_Kind.Shield_Emitter` |
| 燃料（結構中的 Lumen） | 燃料 | Fuel | `fuel: f32` |
| 燃料上限 | 容量 | Capacity | `capacity: f32` |
| 霧侵蝕狀態 | 廢蝕階段 | Corrosion Stage | `Corrosion_Stage` enum |
| 物種特性化燃料 | 染劑 | Dye | `Lumen_Color` enum 成員 |
| 染劑：熾 | 熾 | Ember (Dye) | — |
| 染劑：凜 | 凜 | Frost | — |
| 染劑：冥 | 冥 | Void (Dye) | — |
| 染劑：縷 | 縷 | Weave (Dye) | — |
| 染劑：灰 | 灰 | Ash (Dye) | — |
| 複合染劑：熾霜 | 熾霜 | Cinder | — |
| 複合染劑：冥蝕 | 冥蝕 | Eclipse | — |
| 複合染劑：餘音 | 餘音 | Remnant (Dye) | — |
| Dye + Lumen 混合輸出 | 染色靈光 | Dyed Lumen | — |
| 靈光色 | 靈光色 | Lumen Color | `Lumen_Color` enum |
| 死亡後殘留的 Lumen | 哀傷殘影 | Grief Residue | `grief_residue: f32` |
| 傳導線材質 | 傳導線材質 | Tether Material | `Tether_Material` enum |
| 每輪遊玩 | 輪 | Run | `run_count: u32` |
| 波次組成模式 | 壓力類型 | Pressure Type | `Pressure_Type` enum |
| AI 行為模式 | 氣質 | Temperament | `Temperament` enum |
| 燃料上限 | 容量 | Capacity | `capacity: f32` |
| 霧侵蝕狀態 | 廢蝕階段 | Corrosion Stage | `Corrosion_Stage` enum |
| 關係階段 | **餘溫** | Beacon Intimacy | `Beacon_Intimacy` enum |
| 死亡類別 | 死因 | Death Cause | `Death_Cause` enum |
| 結局 | 結局 | Ending | `Game_Phase.Ending_*` |
