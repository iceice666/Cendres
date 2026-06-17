// Light_Source 管理、疊加計算 — GDD §9.2 Light_Source, §9.3
// Phase 1: collect_lights packs player Lantern + active structures into the
// multi-light array expected by shaders/light.fs.
package game

MAX_LIGHTS :: 8

Light_Source :: struct {
	pos:       [2]f32, // tile-space XY; maps to world XZ in the shader
	radius:    f32,    // illumination range (tiles)
	intensity: f32,    // additive brightness multiplier
}

// collect_lights fills out[0..count-1] from all active light sources and returns count.
collect_lights :: proc(p: ^Player_2D, a: ^Amber, out: ^[MAX_LIGHTS]Light_Source) -> i32 {
	count: i32 = 0

	// Player Lantern — always present while any fuel remains
	if p.lantern_fuel > 0 {
		out[count] = Light_Source{
			pos       = p.pos,
			radius    = max(p.lantern_fuel, 0.001),
			intensity = 1.0,
		}
		count += 1
	}

	// Amber structure — second light source when placed and fuelled
	if a.active && count < MAX_LIGHTS {
		out[count] = Light_Source{
			pos       = a.pos,
			radius    = AMBER_RADIUS,
			intensity = 1.0,
		}
		count += 1
	}

	return count
}
