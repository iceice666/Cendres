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

```
Void HP 低於 25%      →  外緣發光變橙色（視覺提示）
玩家瞄準 Tether       →  Void 必須在任意光源內
按住 Tether 輸入      →  3 秒引導（玩家靜止不動）
其他 Void 在場        →  引導期間玩家脆弱
Tether 成功           →  Void 從場地移除，儲存
                          +小量 Lumen 退款（沒殺死的獎勵）
Tether 中斷           →  Void 恢復至 40% HP，暫時變為 Feral
```

**張力所在：** 最好的捕捉時機也是最危險的——低 HP 的 Void 往往被健康的同伴包圍。玩家必須創造安全捕捉的條件：先清場、用 Surge 創造臨時安全走廊，或用 Dim 讓 Curious 氣質的 Void 變得順從。

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

### 待解問題

- 活體轉化的每 run 次數限制或 CD（防止玩家一次清空 Garden）
- Beacon 活體轉化台詞：每物種各一句（共 5 句）
