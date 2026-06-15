# 資源與經濟系統

## 8.7 Dye 系統（生產鏈）

### 資源流

```
原始 Lumen（Void 死亡掉落）
  ↓ 自動流入周邊 Refiner

Refiner（依 recipe 設定）
  ↓ 產出對應 Dye

Converter（自動混合）
  ↓ Dye + 原始 Lumen → Dyed Lumen
  ↓ 自動輸出至周邊 Light Structure

Light Structure
  ├─ 偏好 Dye → 效率紅利
  ├─ 非偏好 Dye → 正常效率
  └─ 純 Lumen → 基準效率（永遠可用）
```

整條鏈自動化。玩家決策集中在結構佈局：誰靠近誰、Refiner 位置能否同時受保護又覆蓋到 Converter。

### Dye 類型

**基礎 Dye（來自 Void 物種）：**

| Dye | 主要來源 | 效果方向 |
|---|---|---|
| **Ember** | Drifter | 持燃、面積傷害 |
| **Frost** | Gnasher | 減速、射程延長 |
| **Void** | Lurker | 偵測隱形、觸發範圍 |
| **Weave** | Weave 生成者 | 耐久、結構護盾 |
| **Ash** | Behemoth | 全結構消耗降低（稀有；需累積 Behemoth 見證次數才得） |

**複合 Dye（需 recipe 解鎖）：**

| Dye | 配方 | 效果 |
|---|---|---|
| **Cinder** | Ember + Frost | 兼有傷害 + 減速，效率略低於純 Dye |
| **Eclipse** | Void + Weave | 偵測範圍 + 結構護盾疊加 |
| **Remnant** | Ash + 任意 | 效果依玩家記憶深度而定（記憶路線專屬；刻意不在 UI 說明） |

### Refiner Recipe 系統

同一桶 Lumen，依 recipe 不同產出不同 Dye——類比石油精煉。

- 基礎 recipe（Ember、Frost）在解鎖 Refiner 時附帶
- 進階 recipe 透過 Fragment 樹解鎖
- 每個 Refiner 同一時間只執行一個 recipe；更換 recipe 需短暫停機

### 主題層

燃燒路線玩家看到的是「一座精煉廠」——高效、自動化、可擴展。
記憶路線玩家看到的是「一套更精緻的靈魂消耗機器」。
越複雜的機器，越不像在做壞事。Fragment 解鎖 Refiner / Converter，讓記憶路線玩家有能力看透自己在做什麼；純燃燒路線玩家只看到更高效的產線，直到結局 C 的揭示。

---

## 8.8 活體轉化路徑

在 **Reflection 空間**，走近 Garden 生物 + 長按轉化輸入（和補充燃料使用**不同按鍵**，刻意區分）。

這是燃燒路線的終極形式：不是燃燒匿名掉落的 Lumen，而是在 Beacon 面前，親手處理一個你認識的存在。

### 產出

| 生物狀態 | 產出 |
|---|---|
| 無名、無 Codex 條目 | 對應物種基礎 Dye，標準量 |
| 已命名、Codex 中層 | 基礎 Dye × 1.5，附帶少量 Ash Dye |
| 命名、Codex 最深層解鎖 | 高純度 Dye + 可觸發 Remnant 配方 |

**設計諷刺：你記得越多，燒掉它越划算。** 記憶本身成為可變現的資產——記憶路線玩家的最大誘惑，也是這個選擇之所以有重量的原因。

### Beacon 反應

Beacon 在 Reflection 空間，看著這件事發生。它不評判，不阻止。

若轉化的是**已命名且 Codex 完整的生物**，下次 run 開始前 Beacon 說一句話——每個物種不同，永遠是陳述而非評判。設計原則同 §11 死亡台詞：從不以明顯方式給予安慰。

### 轉化上限：遞減回報

無硬性次數限制。以 `conversions_this_reflection`（每次 Reflection 歸零）追蹤本輪已轉化次數：

```
yield = base_yield × conversion_decay ^ conversions_this_reflection
```

- 第 1 次：完整 `base_yield`（`conversions_this_reflection` = 0，decay^0 = 1）
- 第 2 次：約一半（decay ≈ 0.55）
- 第 3 次：約四分之一
- 連續轉化迅速趨近無效，自然阻止掃光 Garden

**記憶深度加成在衰減前作用：** §8.8 的加成（×1.5 + Ash Dye、最深層 → 高純度 + Remnant 配方）作用於 `base_yield`，然後才乘以 decay 係數。因此「第一個燒掉深度記憶生物」是最大化收益的時機——高風險的單一選擇維持其重量，大量轉化自我限制。

相關常數見 §9.2（`conversion_decay`、`dark_period_floor` 等）。

### 待解問題

- Beacon 活體轉化台詞：每物種各一句（共 5 句）——獨立敘事寫作任務

---

## 8.9 黑暗侵蝕（Fog Erosion）

### 核心模型

每個結構除了 `fuel` 之外，新增三個欄位：

```odin
Light_Structure :: struct {
    // …既有欄位…
    capacity:          f32,           // 燃料容量上限；霧侵蝕會降低此值
    activation_pct:    f32,           // 激活門檻 = capacity × activation_pct
    corrosion_stage:   Corrosion_Stage, // 當前廢蝕階段
    fog_erosion_rate:  f32,           // 霧接觸時 capacity 每秒下降量
}

Corrosion_Stage :: enum { Healthy, Draining, Degraded, Corroded }
```

### 廢蝕三階段

霧侵蝕是漸進過程，分三個可識別的階段：

```
階段 I — 儲量流失（Draining）
  觸發：霧接觸結構
  效果：capacity 緩慢下降，fuel 被優先抽取（stored Lumen 流失）
  視覺：結構邊緣出現微弱黑色紋路
  自動修復仍運作

階段 II — 停滯損壞（Degraded）
  觸發：capacity 跌至初始值 50% 以下
  效果：輸出效率降至 60%；靜默修復站（§8.14）對此結構停止作用
  視覺：光源色溫偏冷、輸出光明顯縮小
  玩家必須手動介入才能阻止繼續惡化

階段 III — 腐蝕重置（Corroded）
  觸發：capacity 跌至初始值 20% 以下，或 fuel 穿越激活門檻
  效果：結構功能退回基礎狀態（無 Dye 加成、無特殊效果）
         必須手動修復才能回到 100% 效能
  視覺：結構外觀出現明顯裂紋，光幾乎熄滅
```

激活門檻（`capacity × activation_pct`）動態縮放——capacity 被蝕到接近零時結構進入永久死狀態。

### 燼之潮汐（Tide of Embers）— 反掛機懲罰

```
觸發條件（同時滿足）：
  - 光照覆蓋範圍 / 強度在 T 分鐘內無提升
  - 玩家在 T 分鐘內無任何手動驅散 / 補燃操作

表現：
  - 迷霧邊緣開始呼吸脈動，音效變低沉
  - 迷霧獲得「主動侵略性」

懲罰效果：
  - 霧直接從建築核心或邊緣建築吸取「儲存 Lumen」
  - 安全區光照半徑暫時縮小
  - 直到玩家恢復主動操作後，效果在 30 秒內消退
```

設計意圖：強迫玩家在波次中持續介入，不能把結構放著讓它們自動跑。

### 恢復途徑（三軌）

| 方式 | 速度 | 代價 | 適合場景 |
|---|---|---|---|
| **Lumen_Well 壓制** | 慢，持續 | 佈陣空間 + 一個額外結構的燃料 | 預防性保護；放在最重要的結構旁 |
| **靜默修復站（§8.14）** | 中，自動 | 修復站需燃料維持 | 階段 I 的長期防護；階段 II 後失效 |
| **玩家手動修復** | 快，即時 | 攜帶 Lumen + 走到結構的風險 | 波次中緊急搶救，是唯一能從階段 III 恢復的方式 |

### Cascade 風險

外圍結構進入 Corroded 狀態 → 光覆蓋縮減 → 內層暴露於霧 → 內層開始 Draining。

設計約束：
- 霧侵蝕速率有上限（多重霧源疊加不超過 cap）
- 玩家主動拆除衰竭結構（收回 40% 燃料）可打斷 cascade 鏈
