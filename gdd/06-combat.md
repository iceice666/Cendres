# 戰鬥系統

## 8.1 戰鬥哲學

Cendres 不是射擊遊戲。玩家沒有力量優勢。Lantern 是工具，不是安慰武器——主動使用它會消耗燃料。結構撐起主要防線；玩家延伸並修補它。

**雙層戰鬥模型：**
```
第一層：結構覆蓋（預先規劃、被動執行）
  光源結構在 Lumen 預算內自動處理其半徑內的 Void。
  玩家的工作：波次前設定覆蓋，波次中維持燃料。

第二層：玩家 Lantern（主動、有代價）
  玩家直接介入——填補缺口、處理突破口、捕捉。
  所有動作從 Lantern 個人儲量消耗 Lumen。
```

---

## 8.1a 氣質系統（Temperament System）

氣質決定每隻 Void 在場上的個體行為模式。它是戰術讀取的基礎——同一物種可能有截然不同的應對方式。

### 模型

每隻 Void 在生成時擲定 `base_temperament`（Curious / Timid / Territorial 三種傾向之一）。`temperament` 欄位記錄當前氣質，可被暫時覆寫為 **Feral**，通過 `temperament_timer` 計時後回復。**Feral 是唯一的暫時態**，不是第四種基礎傾向。

### 物種基礎權重

物種決定氣質的生成機率（起始值，可調整）：

| 物種 | Dye | 氣質權重 | 原型 |
|---|---|---|---|
| Drifter | Ember | 70% Curious / 20% Territorial / 10% Timid | 游走者，受光源吸引 |
| Gnasher | Frost | 70% Territorial / 20% Curious / 10% Timid | 結構咬擊者 |
| Lurker | Void | 70% Timid / 20% Territorial / 10% Curious | 潛伏暗殺者 |
| Weave | Weave | 60% Territorial / 30% Timid / 10% Curious | 生成區守衛 |
| Remnant | （記憶） | 80% Curious / 20% Timid | 「認出」你的存在 |
| Behemoth | Ash | 特殊——恆定 Territorial，**免疫 Feral** | 緩慢不可阻擋的 boss |

### 傾向 AI 行為

**Curious**
向最近光源漂移；僅在緊鄰或依靠 `light_tolerance` 存活時攻擊。**Dim → 靠近但停止攻擊**（現有規則）；Void-Tempered Lantern 讓其幾近馴服。捕捉最友善的傾向。

**Timid**
貼著暗區移動，繞開光源半徑；若有暗路可走不會穿越明亮區域。**Ember Tether Line 驅離，使其繞道**（現有規則，見 §8.13）。從側翼和缺口攻擊；受威脅時（附近 Flare / HP 低）向黑暗逃竄。

> 延伸設計（可調整）：若 Timid Void 無暗路可退，翻轉為 Feral 而非原地凍結。

**Territorial**
生成時鎖定一個目標（最近結構；Fuel_Drain 波次偏向生產結構），直線推進，忽略玩家（除非被攔截）。**免疫 Dim 安撫**（目標鎖定不受影響）；對結構的接觸傷害較高。這是威脅生產鏈的傾向。

**Feral**（暫時態，非基礎傾向）
忽視傾向 AI；衝向最近目標（優先玩家），最大攻擊性和速度，不逃跑，不可安撫。`temperament_timer` 歸零後回復 `base_temperament`。

> 可選：Feral 狀態死亡掉落略多 Lumen（抵消中斷捕捉的風險代價）。

**Feral 觸發條件：**
1. **捕捉中斷**（現有規則）——Void 恢復至 40% HP，Feral 持續 `feral_duration` 秒
2. **Timid 被逼無路**（延伸設計）——無暗路退路時翻轉 Feral

### 工具互動矩陣

| 氣質 | Dim | Flare / 光 | Ember Tether Line | 最佳反制 |
|---|---|---|---|---|
| Curious | 靠近，被安撫（捕捉窗口）| 受傷 | 正常 | Dim → Tether |
| Timid | **受鼓舞**（在暗中推進）| 逃竄 | 繞道（被驅離）| 覆蓋 + Ember 牆引導路線 |
| Territorial | 忽略（目標鎖定）| 受傷，持續推進 | 若有路則繞道 | Shield Emitter 護住目標；Prism 扼喉 / Flare 攔截 |
| Feral | 忽略 | 受傷，衝刺 | 忽略 | Flare 爆發擊倒或牆壁擋住；等計時器 |

> **Dim 是真正的雙刃決策**：安撫 Curious 的同時，在暗中推進的 Timid 反而更危險。這是分離傾向設計的核心回報。

### 與波次壓力類型的關係

`Pressure_Type`（見 §7.2）決定波次**組成**——哪些物種生成、生成比例、方向。氣質決定**個體 AI**。兩者組合，不衝突：

- Fuel_Drain 波次的「結構壓力」來自生成大量 Territorial 權重的 Gnasher，而非一套獨立的瞄準規則
- Flank 波次的「側翼效果」來自生成 Timid 權重的 Lurker，它們本就沿著光源邊緣移動

每種威脅只描述一次——壓力類型層描述組成，氣質層描述行為。

### 視覺可讀性需求（渲染層待實作）

氣質必須能從視覺判讀（公平性要求）：
- Curious：向光源漂移
- Timid：沿暗區邊緣潛行
- Territorial：直線衝向結構
- Feral：紅色調、加速

---

## 8.2 玩家 Lantern — 主動能力

```odin
Lantern_Ability :: enum {
    Illuminate, // 被動——永遠激活，個人視野，持續消耗
    Flare,      // 脈衝爆發：對半徑內所有 Void 造成傷害，高燃料消耗
    Tether,     // 捕捉弱化的 Void——必須在光源內，HP 低於閾值
    Surge,      // 延伸 Lantern 光以橋接兩個結構之間的缺口，~8 秒
    Dim,        // 將 Lantern 降至接近零輸出
                // 效果：Curious 氣質的 Void 靠近而非攻擊
                // 風險：玩家幾乎失明，結構仍在運作
}
```

**Lantern 類型**（每次 run 在 Reflection 選擇一種）：

| Lantern | 專長 | 代價 |
|---|---|---|
| Amber Core | Illuminate 半徑較大 | Flare 消耗更多 |
| Ash Prism | Surge 持續更長，更窄 | Illuminate 半徑減半 |
| Ember Wick | Flare 留下燃燒 DoT 區域 | Tether 充能減少 |
| Void-Tempered | Dim 更有效；Curious Void 幾乎溫馴 | 基礎半徑低 |

---

## 8.3 結構戰鬥行為

```odin
tick_structure :: proc(s: ^Light_Structure, dt: f32, enemies: []Void_Entity) {
    // 永遠在消耗
    s.fuel -= s.passive_drain_rate * dt

    // 攻擊範圍內最近的敵人
    if target, ok := nearest_in_range(enemies, s); ok {
        apply_light_effect(s.color, target)
        s.fuel -= s.attack_fuel_cost
    }

    // Void 接觸結構本體時退化
    if s.is_being_attacked {
        s.durability -= s.contact_damage_rate * dt
    }

    // 損毀：掉落殘影，死亡
    if s.fuel <= 0 || s.durability <= 0 {
        shatter_structure(s) // 生成可收集的殘影
    }
}
```

玩家與結構互動方式：**補充燃料**（走近，按住互動——消耗攜帶的 Lumen）、**任何階段可重新定位**（不限 Prep Phase，但移動後需重新灌注）、**主動拆除**（故意摧毀衰竭的結構，立即回收 40% 燃料）。

**啟動時間作為自然摩擦：** 結構放置或移動後需要 Lumen 灌注才激活，這段暗期是波次中調整的代價。提前在 Prep 階段佈置的自然動機因此成立，而非強制規則。

**暗期規則（Activation Dark-Period）：**
- 觸發時機：**僅放置或移動**觸發——單純補燃料不觸發暗期
- 暗期內：無攻擊、無被動效果、無燃料消耗，但**仍然脆弱**（Void 接觸仍造成耐久傷害）
- 持續時長：`dark_period_floor + capacity × dark_period_scale`（起始值：floor ≈ 1.0 秒；scale 讓大型結構落在 3–5 秒）
  - 小型 Post 快速重激活；大型重要結構是波次中移動的真實代價
- Lumen 灌注的既有激活門檻（`activation_pct`）保留；暗期計時器是**額外的時間門檻**，兩者並行
- 欄位 `activation_timer`：>0 時結構處於暗期（見 §9.2 `Light_Structure`）

### 基礎戰鬥結構（4 種）

| 結構 | 覆蓋形狀 | 戰術用途 | 偏好 Dye |
|---|---|---|---|
| **Post**（燈柱） | 360° 中距離 | 通用覆蓋，佈陣骨幹 | Weave（耐久）、Ember（持燃） |
| **Prism**（稜鏡） | 窄錐形長射程 | 走廊控制、跨距離橋接 | Frost（射程延長）、Void（偵測） |
| **Ember Bed**（炭床） | 短距離大面積慢燃 | 進入區域的 DoT 毯 | Ember（效率 +40%，持燃更久） |
| **Shard**（碎鏡） | 近感觸發脈衝 | 接觸時爆發，被動等待 | Void（偵測隱形、觸發範圍加倍） |

### 生產結構（Fragment 解鎖）

| 結構 | 功能 | 解鎖條件 |
|---|---|---|
| **Refiner** | 消耗 Lumen → 依 recipe 產出 Dye | Fragment 樹中期節點 |
| **Converter** | 混入 Dye + Lumen → Dyed Lumen，自動輸出至周邊戰鬥結構 | Fragment 樹中期節點（Refiner 之後） |

---

## 8.4 捕捉戰鬥流程

本節僅適用 §8.4 拉取捕捉（HP 門檻觸發的 Tether）。**§8.5 Tether 聆聽模式為不同動作（無 HP 門檻、無拉取），不適用以下規則。Behemoth 無法被 Tether 捕捉，本流程對其完全不適用（見 `05-run-structure.md` §7.5）。**

```
Void HP 低於 25%          →  外緣發光變橙色（視覺提示）
玩家瞄準 Tether           →  Void 必須在任意光源內
按住 Tether 輸入          →  3 秒引導

  引導期間：
  - 玩家被定根（無法移動），但可以旋轉瞄準 Lantern
  - Illuminate 光源維持，光半徑線性收縮（開始為完整半徑，結束時收縮至目標方向）
  - 玩家自身光源 + 鄰近結構仍持續傷害進入泡泡的 Void
  - 旋轉可應對側翼威脅——技巧在於站位 + 面向

主動取消（放開輸入）      →  乾淨取消；Void 維持**當前** HP，不觸發 Feral
Tether 成功               →  Void 從場地移除，儲存
                              +小量 Lumen 退款（沒殺死的獎勵）
被中斷（受到攻擊超過傷害閾值）→  Void 恢復至 40% HP，暫時進入 Feral 狀態（見 §8.1a）
```

**張力所在：** 最好的捕捉時機也是最危險的——低 HP 的 Void 往往被健康的同伴包圍。玩家必須創造安全捕捉的條件：先清場、用 Surge 創造臨時安全走廊，用 Dim 讓 Curious 氣質 Void 暫時不攻擊（注意：Dim 同時讓 Timid 氣質 Void 更危險），或在引導中旋轉 Lantern 主動應對進入泡泡的威脅。

---

## 8.5 Tether 聆聽模式（揭露後解鎖）

在玩家通過 Beacon 對話或 Codex 深度解鎖充分理解「Lumen = 靈魂」後，Tether 出現第二種用法：

```
瞄準 Tether（目標不需低 HP） →  Tether 光照在 Void 身上
不拉取，持續照著             →  5–8 秒，Void 逐漸靜止
                                 不攻擊，不逃，像是被認出來了
聆聽成功                     →  Void 不爆出 Lumen
                                 留下一個 Fragment（身份碎片）
                                 比 Lumen 少、比 Lumen 輕，不是燃料
```

**代價：** 波次中佔用 Tether、犧牲防禦效率、消耗持續 Lumen 維持光照。
**回報：** Fragment 可填入 Codex 深層條目，或送入 Garden 讓靈魂更完整。

**揭露前：** 這個行為存在但沒有標示。玩家如果偶然長按 Tether 沒有拉取，Void 的異常靜止只像是動畫 bug。揭露後，他們意識到那一直是一個選項。

---

## 8.6 見證動作

任何 Void 在光源中死亡（被結構消滅或 Flare 擊殺）後，有約 1.5 秒的消散動畫。在這個視窗內，玩家可以按住互動鍵（不移動）。

```
Void 消散動畫中       →  玩家按住「見證」輸入
1.5 秒內完成          →  Void 消散時留下更完整的 Fragment
                          （比正常死亡多 30–50%）
未完成 / 未觸發       →  正常 Lumen 掉落
```

揭露前：這個輸入存在，但沒有 UI 提示。玩家幾乎不會發現。
揭露後：Fragment 樹的早期節點說明這個動作，並提示「它一直都在」。

---

