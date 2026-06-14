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

玩家與結構互動方式：**補充燃料**（走近，按住互動——消耗攜帶的 Lumen）、**重新定位**（僅限 Prep Phase）、**主動拆除**（故意摧毀衰竭的結構，立即回收 40% 燃料）。

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
