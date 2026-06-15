# Raycasting 渲染器與場景地圖

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
