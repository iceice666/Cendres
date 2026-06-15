# 結構規格表

## 8.10 充能炮臺（Charge Turret）

充能炮臺是第一個將激活門檻機制**顯式化**的戰鬥結構：不達門檻無法充能，充能未打完會損耗。

```odin
// Structure_Kind 新增：Charge_Turret
// 在 8.9 的基礎欄位之上加入：

charge:            f32,   // 當前充能量，0 → max_charge
max_charge:        f32,
charge_rate:       f32,   // fuel ≥ 激活門檻時每秒累積
fire_threshold:    f32,   // 最低可發射 charge（傷害 = 此時最低）
idle_decay_rate:   f32,   // charge 已滿但射程內無目標時每秒損失
```

**傷害曲線：** 發射傷害依 `charge / max_charge` 的凸曲線計算——`fire_threshold` 處傷害最低，`max_charge` 處傷害最高，後段增益更陡，讓「等到充滿」的收益明顯高於「剛過門檻就打」。

**核心張力：** 炮臺在有目標時立即發射（charge 達 fire_threshold 即觸發）；如果 Void 不經過射程，charge 累積到 max 後開始損耗——定位錯誤的炮臺不只是廢的，它主動消耗 Lumen。

**與波次類型的互動：**

| 壓力類型 | 炮臺表現 |
|---|---|
| Volume | 最佳解——Void 密集，charge 幾乎無損耗 |
| Speed | 高風險——Gnasher 可能在充滿前穿越射程，低傷打出 |
| Flank | 易廢——Lurker 繞後，正面炮臺 charge 滿而無目標，持續損耗 |
| Fuel_Drain | 高危——炮臺本身是目標；被攻擊到 fuel 跌破門檻即關機 |
| Siege | 機會——Weave 移動慢，charge 有時間追上 max |

---

## 8.11 Vigilance Lens（偵察鏡）

360° 旋轉掃描型結構。不造成傷害；唯一功能是偵測。

### 掃描邏輯

```
Lens 發射旋轉低強度光線（不傷害 Void）
光線打到牆壁 / 地板 → 正常反射，回傳
光線打到 Void → 被吸收，無反射
  → Client device 顯示對應角度的深色塊
```

偵測依據是**異常的暗**，不是主動照亮——Void 所在的暗區比預期背景暗更深、無反射。因此 Vigilance Lens 對任何物種都有效，包括 Lurker。

### Client Device（隨身裝置）

裝置由玩家隨身攜帶，顯示在畫面角落。可「抬起」切換至完整視圖：

```
縮小模式（邊緣角落）：
  可在移動時看到掃描動態，但細節少

抬起模式（遮擋前方部分視野）：
  雷達顯示範圍更清楚
  代價：正前方的第一人稱視野被局部遮擋
```

看雷達的注意力代價是設計的一部分——資訊不是免費的。

### 頻率調音（物種辨識）

Client device 預設顯示所有 Void 的位置（無物種區分）。調整掃描頻率可以辨識特定物種：

```
頻率 A（預設）：顯示所有 Void，不區分物種
頻率 B：過濾出 Lurker 的吸光特徵（移動中的暗弧）
頻率 C：過濾出 Gnasher 的高速位移信號
頻率 D：偵測 Weave 生成者的暗區擴散模式
```

切換頻率需要停止移動約 1 秒（調整需要穩定）。在波次中換頻有注意力代價——這個選擇本身是資訊決策的一部分。

### Lurker 的特殊簽名

Lurker 沿光覆蓋邊緣移動，在雷達上呈現**弧線滑動的深色塊**，而非直線衝入的點。有經驗的玩家能從移動軌跡形狀辨認物種，不需要直接看到它。

### 欄位

```odin
// Structure_Kind 新增：Vigilance_Lens
scan_radius:   f32,   // 偵測半徑
scan_rpm:      f32,   // 旋轉速度（影響更新頻率）
// 無 charge / attack 相關欄位；不消耗 attack_fuel_cost
```

---

## 8.12 Echo Marker（回響標記）

記憶型偵測結構。偵測**過去**，不偵測現在。

### 運作方式

```
每波結束後，記錄本波 Void 的主要進入方向 + 物種組成
累積 history_waves 波的資料（預設 = 3）
下次 Prep Phase 顯示熱區標記：
  走廊顏色深淺 = Void 頻繁程度
  物種圖示     = 本條路線的常見物種（Lurker / Gnasher 等）
```

### 設計限制

Echo Marker 說的是**過去**，不是預言。Composite 波次的組合可能與前幾波完全不同。過度依賴熱區資料的玩家會被突然的路線改變打措手不及。

這個不確定性是刻意保留的——它是資訊工具，不是解法。

### 欄位

```odin
// Structure_Kind 新增：Echo_Marker
history_waves: u32,   // 保留的歷史波次數量（預設 3）
// 不消耗 fuel 進行戰鬥；僅需維持激活門檻以上的基礎燃料
```

---

## 8.13 Tether Line（傳導線）

連接兩個結構節點的供給線，傳輸 Lumen 與 Dyed Lumen。自身無戰鬥能力；可被 Void 攻擊後斷線。

### 傳輸能力

傳輸一切（原始 Lumen、任意 Dyed Lumen）。傳輸速率（throughput）由製作材料決定：

| 材料 | 基礎 throughput | 副特性 |
|---|---|---|
| 原始 Lumen 線 | 低 | 無 |
| Weave 線 | 中 | 耐久高，不易被 Void 斷開 |
| Ash 線 | 中高 | 傳輸損耗低（遠端收到量更完整） |
| Ember 線 | 高 | 耐久低；斷線時短暫爆出傷害脈衝 |

材料透過 Refiner 系統合成，消耗對應 Dye。

### Dyed Lumen 流通效果

流通的 Dyed Lumen 類型改變線體行為：

| 流通類型 | 效果 |
|---|---|
| Ember | 線體發橙光；Timid 氣質 Void 繞開不攻擊（見 §8.1a 氣質系統）|
| Frost | 穿越線體的 Void 受到減速（線成為軟性屏障） |
| Void | 線體幾乎不可見；Void 較難優先瞄準 |
| Weave | 連接兩端結構共享 10% 耐久緩衝 |
| Ash | 傳輸效率再提升，幾乎零損耗 |

### 量子連接效益（Quantum Link Effect）

Tether Line 連接兩個結構後，除燃料傳輸外，另有光照擴張效益：

```
連接狀態下，兩端結構的有效光照半徑各自延伸 +40%
（疊加在 calc_effective_range 的結果上）
斷線後效益立即消失
```

這讓 Tether Line 不只是後勤工具，也直接影響戰術覆蓋範圍——一條供給線可以讓遠端的孤立 Vigil_Lamp 覆蓋到原本夠不到的走廊入口。

### 斷線與修復

```
Void 持續接觸線段達耐久閾值 → 斷線
兩端結構恢復獨立運作（量子連接效益同時消失）
重新連接 = 重新放置，消耗製作材料
```

Weave 生成者（Siege 波次）是最大威脅：它製造暗區、切光覆蓋，現在也可切供給線，讓 Siege 波次同時威脅防線和後勤。

### 欄位

```odin
// Structure_Kind 新增：Tether_Line
Tether_Material :: enum { Raw_Lumen, Weave, Ash, Ember }

// Tether_Line 結構另存為獨立物件（非 Light_Structure 子類）
Tether_Line :: struct {
    pos_a:              rl.Vector2,
    pos_b:              rl.Vector2,
    material:           Tether_Material,
    throughput:         f32,
    durability:         f32,
    active_dye:         Maybe(Lumen_Color),  // 當前流通的 Dyed Lumen 類型
    is_severed:         bool,
    light_radius_bonus: f32,  // 量子連接效益，預設 0.4（+40%）；斷線時歸零
}
```

---

## 8.14 靜默修復站（Silent Repair Unit）

自動維護型支援結構。不造成傷害，不延伸光覆蓋；唯一功能是對鄰近結構持續進行 capacity 回復。

### 運作邏輯

```
修復站激活（fuel ≥ activation threshold）
  → 每秒對半徑內所有結構執行 capacity_restore_rate 回復
  → 若目標結構處於廢蝕階段 II（Degraded）或更嚴重 → 跳過，無效

修復站自身進入廢蝕階段 II → 停止對外修復
  → 玩家需手動修復修復站本身才能恢復功能
```

**設計意圖：** 靜默修復站提供階段 I 的長期防護，但在被霧侵蝕最嚴重的時候（最需要它的時候）自動失效。它是預防工具，不是救援工具——這個設計讓玩家不能純靠修復站忽視霧侵蝕。

### 佈陣策略

修復站需要受到其他結構的光覆蓋（避免自身被霧侵蝕進入 Degraded），同時自身要夠近才能覆蓋目標結構。它的位置是一個受保護但又要夠前線的折衷點。

### 欄位

```odin
// Structure_Kind 新增：Silent_Repair_Unit
capacity_restore_rate: f32,  // 每秒對鄰近結構回復的 capacity 量
repair_radius:         f32,  // 修復覆蓋半徑
// 廢蝕階段 II+ 時 capacity_restore_rate 強制為 0
```

---

## 8.15 緊急盾發射器（Emergency Shield Emitter）

響應型防禦結構。平時不作用，在偵測到鄰近結構受攻擊時自動投射短暫保護場。

### 觸發機制

```
鄰近結構的 is_being_attacked = true
  → Emitter 投射保護場（持續 shield_duration 秒）
  → 保護場期間：目標結構耐久傷害降低 80%
  → 保護場消耗 Emitter 自身大量 fuel（shield_fuel_cost）
  → 冷卻 cooldown_duration 秒後可再次觸發
```

### 戰術定位

**主要反制對象：Fuel_Drain 波次（Gnasher 優先攻擊結構）**

Gnasher 快速衝擊，Shield Emitter 的短暫保護場在此情境最有效——保護場撐住最初的衝擊，讓玩家有時間趕到補充燃料或重新定位。

| 情境 | 表現 |
|---|---|
| Fuel_Drain | 核心反制；每次 Gnasher 衝擊觸發一次保護場 |
| Siege | 有用但次優；Weave 移動慢，耐久損耗速度較慢 |
| Volume / Speed | 效益低；這類波次主要傷害來自燃料消耗，非耐久 |

**代價：** Emitter 的 fuel 消耗在大量觸發時很快，在 Volume 波次後期可能因自身 fuel 耗盡而關機，保護空窗出現時間可能最壞——這是刻意的設計風險。

### 欄位

```odin
// Structure_Kind 新增：Shield_Emitter
shield_duration:      f32,   // 保護場持續秒數
shield_fuel_cost:     f32,   // 每次觸發消耗的 fuel
cooldown_duration:    f32,   // 兩次觸發之間的冷卻
shield_radius:        f32,   // 保護場覆蓋半徑（可覆蓋多個結構）
```
