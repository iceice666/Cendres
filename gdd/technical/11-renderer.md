# 渲染器與場景地圖

## 9.3 3D 場景 + GLSL 光暗系統

**核心設計洞見保持不變：光源半徑決定可見範圍。**
差別只在實現層：之前是 ray 的到達距離受光源限制；現在是 fragment 的亮度由距光源的距離決定。結果一樣——沒有燃料的地方，玩家什麼也看不見。

### 光暗計算（fragment shader）

```glsl
// shaders/light.fs
#define MAX_LIGHTS 8
uniform vec3  lightPos[MAX_LIGHTS];
uniform float lightRadius[MAX_LIGHTS];
uniform float lightIntensity[MAX_LIGHTS];
uniform int   lightCount;

void main() {
    float total = 0.0;
    for (int i = 0; i < lightCount; i++) {
        vec2  diff = fragWorldPos.xz - lightPos[i].xz;  // XZ 平面距離
        float dist = length(diff);
        if (dist < lightRadius[i]) {
            total += lightIntensity[i] * (1.0 - dist / lightRadius[i]);
        }
    }
    float brightness = clamp(total, 0.0, 1.0);

    // Amber #F5C842 ↔ Void Black #2A2A2A
    vec3 amber     = vec3(0.961, 0.784, 0.259);
    vec3 voidBlack = vec3(0.165, 0.165, 0.165);
    finalColor = vec4(mix(voidBlack, amber, brightness) * fragColor.rgb, 1.0);
}
```

**多光源加法疊加：**
- 玩家 Lantern + 所有附近結構光源同時送入 `lightPos[]`
- 亮度在 `[0, 1]` clamp，防止爆白
- 重疊區域自然比單一光源更亮——強化「補充燃料換取安全」的設計

### world position 傳遞（vertex shader）

```glsl
// shaders/light.vs
uniform mat4 mvp;
uniform mat4 matModel;  // Raylib DrawModel 自動設定，每個 draw call 不同

void main() {
    fragWorldPos = (matModel * vec4(vertexPosition, 1.0)).xyz;
    gl_Position  = mvp * vec4(vertexPosition, 1.0);
}
```

Raylib 的 `DrawModel` 在每次 mesh draw 前自動將 draw call 的 transform 寫入 `shader.locs[SHADER_LOC_MATRIX_MODEL]`（查找 uniform 名稱 `"matModel"`）。因此同一個 wall model 可以在不同位置呼叫 `DrawModel` 多次，每次 fragment shader 都拿到正確的 world position。

### Odin 端 uniform 更新（每 frame）

```odin
// 光源資料打包成連續陣列送給 GPU
positions   : [MAX_LIGHTS][3]f32
radii       : [MAX_LIGHTS]f32
intensities : [MAX_LIGHTS]f32
for i in 0..<int(light_count) {
    positions[i]   = lights[i].pos
    radii[i]       = lights[i].radius
    intensities[i] = lights[i].intensity
}
rl.SetShaderValueV(shader, loc_pos,   cast(rawptr)&positions,   .VEC3,  light_count)
rl.SetShaderValueV(shader, loc_rad,   cast(rawptr)&radii,       .FLOAT, light_count)
rl.SetShaderValueV(shader, loc_int,   cast(rawptr)&intensities, .FLOAT, light_count)
rl.SetShaderValue (shader, loc_count, cast(rawptr)&light_count, .INT)
```

---

## 9.4 場景地圖結構

箱庭場景用 2D tile map 表示，渲染時轉換成 3D 幾何體：

```
地圖結構（俯視邏輯，渲染為 3D）：

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

**幾何映射：**

| Tile | 3D 表示 |
|---|---|
| `Wall` | 1×2×1 cube，原點在 tile 中心，Y = [0, 2] |
| `Empty` | 無 mesh；地板 plane 覆蓋所有 Empty tile |
| `Structure_Slot` | 視覺同 Empty；邏輯層標記可放置 |
| `Imprint` | 環境 sprite billboard，靠近光源才顯現 |
| `Beacon_Core` | 特殊 mesh；進入觸發 Reflection |
| `Boundary` | Salvage Phase 的暗區（無光，shader 輸出純 Void Black） |

**Cell 類型：**

```odin
Cell_Kind :: enum {
    Empty,          // 可通行，無牆
    Wall,           // 阻擋碰撞，有 texture
    Structure_Slot, // 可放置塔的位置（有限）
    Imprint,        // Lore 環境碎片，帶燈靠近才顯示
    Beacon_Core,    // 特殊——進入觸發 Reflection
    Boundary,       // Salvage Phase 的暗區
}
```

**地板 / 天花板：**
- 整張 map 用一個 `GenMeshPlane` 覆蓋（shader 做漸層，不需要分 tile）
- 天花板同尺寸 plane，y = 2；vertex color tint 稍暗以區別地板
