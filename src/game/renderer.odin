// 3D renderer — GDD §9.3 (Phase 0 prototype)
// Raylib Camera3D + custom GLSL shader for per-pixel lantern falloff.
// Phase 1 will extend this with multi-light support and texture sampling.
package game

import "core:math"
import rl "vendor:raylib"

EYE_HEIGHT :: f32(0.5)

VOID_BLACK  :: rl.Color{0x00, 0x00, 0x00, 0xFF}
WALL_COL    :: rl.Color{0xAA, 0x88, 0x44, 0xFF}
FLOOR_COL   :: rl.Color{0x33, 0x33, 0x33, 0xFF}
DRIFTER_COL :: rl.Color{0xDD, 0xAA, 0xFF, 0xFF}

Renderer :: struct {
	shader:           rl.Shader,
	player_pos_loc:   i32,
	radius_loc:       i32,
	amber_pos_loc:    i32,
	amber_radius_loc: i32,
}

make_renderer :: proc() -> Renderer {
	shader := rl.LoadShader("shaders/light.vs", "shaders/light.fs")
	return Renderer{
		shader           = shader,
		player_pos_loc   = rl.GetShaderLocation(shader, "playerPos"),
		radius_loc       = rl.GetShaderLocation(shader, "lanternRadius"),
		amber_pos_loc    = rl.GetShaderLocation(shader, "amberPos"),
		amber_radius_loc = rl.GetShaderLocation(shader, "amberRadius"),
	}
}

unload_renderer :: proc(r: Renderer) {
	rl.UnloadShader(r.shader)
}

// draw_world renders the lit 3D scene (Layer 1) inside an already-open BeginDrawing block.
// Screen-space overlays and HUD are drawn separately by the render package.
draw_world :: proc(r: ^Renderer, p: ^Player_2D, d: ^Drifter, a: ^Amber, m: ^Tile_Map) {
	// Update per-frame shader uniforms
	player_pos   := rl.Vector3{p.pos.x, EYE_HEIGHT, p.pos.y}
	radius       := max(p.lantern_fuel, 0.001)
	amber_pos    := rl.Vector3{a.pos.x, EYE_HEIGHT, a.pos.y}
	amber_radius := AMBER_RADIUS if a.active else f32(0.0)
	rl.SetShaderValue(r.shader, r.player_pos_loc,   &player_pos,   .VEC3)
	rl.SetShaderValue(r.shader, r.radius_loc,       &radius,       .FLOAT)
	rl.SetShaderValue(r.shader, r.amber_pos_loc,    &amber_pos,    .VEC3)
	rl.SetShaderValue(r.shader, r.amber_radius_loc, &amber_radius, .FLOAT)

	cos_a := math.cos(p.angle)
	sin_a := math.sin(p.angle)
	cos_p := math.cos(p.pitch)
	sin_p := math.sin(p.pitch)

	camera := rl.Camera3D{
		position   = {p.pos.x, EYE_HEIGHT, p.pos.y},
		target     = {p.pos.x + cos_a * cos_p, EYE_HEIGHT + sin_p, p.pos.y + sin_a * cos_p},
		up         = {0, 1, 0},
		fovy       = 60,
		projection = .PERSPECTIVE,
	}

	rl.BeginMode3D(camera)
	rl.BeginShaderMode(r.shader)

	// Floor
	for row in 0 ..< MAP_ROWS {
		for col in 0 ..< MAP_COLS {
			if is_solid(m, row, col) do continue
			rl.DrawPlane({f32(col) + 0.5, 0, f32(row) + 0.5}, {1, 1}, FLOOR_COL)
		}
	}

	// Walls
	for row in 0 ..< MAP_ROWS {
		for col in 0 ..< MAP_COLS {
			if !is_solid(m, row, col) do continue
			rl.DrawCube({f32(col) + 0.5, EYE_HEIGHT, f32(row) + 0.5}, 1, 1, 1, WALL_COL)
		}
	}

	// Drifter
	if d.alive {
		rl.DrawCylinder({d.pos.x, 0, d.pos.y}, 0.3, 0.3, 1.0, 8, DRIFTER_COL)
	}

	// Amber structure
	if a.active {
		rl.DrawCube({a.pos.x, 0.25, a.pos.y}, 0.5, 0.5, 0.5, rl.Color{0xFF, 0xCC, 0x44, 0xFF})
	}

	rl.EndShaderMode()
	rl.EndMode3D()
}
