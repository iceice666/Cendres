# 核心資料結構

## 9.2 核心資料結構

```odin
// === 光源 ===
Lumen_Color :: enum { Amber, Ash, Ember, Void_Tamed }

Light_Source :: struct {
    pos:        rl.Vector2,
    radius:     f32,      // 照明範圍 = 攻擊範圍
    intensity:  f32,      // 傷害 / 減速倍率
    fuel:       f32,      // 消耗資源
    color:      Lumen_Color,
    is_player:  bool,     // Lantern 是特殊光源
}

// === Void 生物 ===
Void_Species :: enum { Drifter, Gnasher, Lurker, Weave, Remnant, Behemoth }

Temperament :: enum { Feral, Timid, Curious, Territorial }

Void_Entity :: struct {
    species:           Void_Species,
    base_temperament:  Temperament,      // 生成時擲定的基礎傾向（Curious / Timid / Territorial）
    temperament:       Temperament,      // 當前氣質；可被暫時覆寫為 Feral
    temperament_timer: f32,              // >0 表示 Feral 暫時覆寫生效中；歸 0 時回復 base_temperament
    pos:               rl.Vector2,
    hp:                f32,
    light_tolerance:   f32,             // 0.0 在光中受傷，1.0 完全免疫
    mutation:          Maybe(Mutation),
    lore_name:         Maybe(string),   // 有名字的個體
    is_capturable:     bool,            // hp < 25% 且在光源內（Behemoth 恆為 false）
}

// === 光源結構（塔）===
Structure_Kind :: enum {
    Beacon_Pillar,      // Amber，大範圍 AoE
    Flashpoint,         // Ember，近炸
    Vigil_Lamp,         // Ash，長射程單體
    Void_Mirror,        // Void_Tamed，需要馴化 Void 燃料
    Lumen_Well,         // 無色，被動補充相鄰結構；可緩慢恢復鄰近結構的 capacity
    Refiner,            // Fragment 樹中期解鎖；消耗 Lumen → 依 recipe 產出 Dye
    Converter,          // Fragment 樹中期解鎖（Refiner 之後）；混入 Dye + Lumen → Dyed Lumen，自動輸出至周邊戰鬥結構
    Charge_Turret,      // 充能炮臺；傷害依充能量縮放，charge 滿而無目標時損耗 Lumen（見 §8.10）
    Vigilance_Lens,     // 360° 旋轉掃描，偵測 Void 位置；配合隨身 client device + 頻率調音（見 §8.11）
    Echo_Marker,        // 記錄歷史波次進入方向，Prep Phase 顯示熱區（見 §8.12）
    Silent_Repair_Unit, // 自動回復鄰近結構 capacity；廢蝕階段 II+ 時失效（見 §8.14）
    Shield_Emitter,     // 偵測鄰近結構受攻擊時自動投射保護場，消耗大量 fuel（見 §8.15）
    // 注意：Tether_Line 另存為獨立結構體，不屬於 Light_Structure（見 §8.13）
}

Light_Structure :: struct {
    kind:               Structure_Kind,
    pos:                rl.Vector2,
    fuel:               f32,
    capacity:           f32,            // 燃料容量上限；霧侵蝕降低此值，可由 Silent_Repair_Unit 或手動修復恢復
    activation_pct:     f32,            // 啟動門檻比例；fuel < capacity × activation_pct 時關機
    activation_timer:   f32,            // >0 表示處於放置／移動後的暗期；歸 0 前結構不作用（見 §8.3）
    corrosion_stage:    Corrosion_Stage, // 廢蝕階段（見 §8.9）
    durability:         f32,
    passive_drain_rate: f32,
    attack_fuel_cost:   f32,
    is_being_attacked:  bool,
    fog_erosion_rate:   f32,            // 霧接觸時 capacity 每秒下降量（見 §8.9）
    // Charge_Turret 專用（其他種類忽略）
    charge:             f32,
    max_charge:         f32,
    charge_rate:        f32,
    fire_threshold:     f32,
    idle_decay_rate:    f32,
    // Vigilance_Lens 專用
    scan_radius:        f32,
    scan_rpm:           f32,
    // Silent_Repair_Unit 專用
    capacity_restore_rate: f32,
    repair_radius:         f32,
    // Shield_Emitter 專用
    shield_duration:    f32,
    shield_fuel_cost:   f32,
    cooldown_duration:  f32,
    shield_radius:      f32,
    // Echo_Marker 專用
    history_waves:      u32,
}

Corrosion_Stage :: enum { Healthy, Draining, Degraded, Corroded }

// === 傳導線（獨立於 Light_Structure）===
Tether_Material :: enum { Raw_Lumen, Weave, Ash, Ember }

Tether_Line :: struct {
    pos_a:       rl.Vector2,
    pos_b:       rl.Vector2,
    material:    Tether_Material,
    throughput:  f32,             // Lumen/s，由 material 決定
    durability:  f32,
    active_dye:  Maybe(Lumen_Color), // 當前流通的 Dyed Lumen 類型；影響線體行為
    is_severed:  bool,
}

// === Garden／Reflection 狀態（跨 run 持久；Phase 0 後移入 garden/ 套件）===
// 活體轉化遞減機制（見 §8.8）：
//   yield = base_yield * conversion_decay ^ conversions_this_reflection
//   memory-depth 加成作用於 base_yield（衰減前）
dark_period_floor:              f32 : 1.0   // 暗期最低時長（秒）；適用所有結構
dark_period_scale:              f32 : 0.015 // 每單位 capacity 增加的暗期長度（秒）
feral_duration:                 f32 : 5.0   // 捕捉中斷後 Feral 持續時長（秒）
conversion_decay:               f32 : 0.55  // 活體轉化遞減係數（起始值，可調整）

// conversions_this_reflection: u32  // 本次 Reflection 已轉化次數；每次 Reflection 歸零
//   → 當 Garden / Run struct 建立時移入對應套件

// === 玩家提燈 ===
Lantern_Kind :: enum { Amber_Core, Ash_Prism, Ember_Wick, Void_Tempered }
Lantern_Ability :: enum { Illuminate, Flare, Tether, Surge, Dim }

// === 玩家狀態 ===
// 視角由 Raylib Camera3D 管理（FIRST_PERSON 模式），不存在 Player struct 中
Player :: struct {
    pos:            rl.Vector3,  // 3D 世界座標（Y 固定為眼部高度）
    lantern_fuel:   f32,
    lantern_type:   Lantern_Kind,
    lumen_carried:  f32,
    tether_charges: u32,
    active_ability: Maybe(Lantern_Ability),
}
```
