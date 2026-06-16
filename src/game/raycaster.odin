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

MINI_TILE :: i32(5)
MINI_PAD  :: i32(8)

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

// draw_scene renders one full frame inside an already-open BeginDrawing block.
draw_scene :: proc(r: ^Renderer, p: ^Player_2D, d: ^Drifter, a: ^Amber, m: ^Tile_Map, sw, sh: i32) {
	rl.ClearBackground(VOID_BLACK)

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

	_draw_minimap(p, d, m, sw, sh)

	// Flare flash overlay
	if p.flare_flash > 0 {
		alpha := u8(200.0 * p.flare_flash / FLARE_FLASH_DURATION)
		rl.DrawRectangle(0, 0, sw, sh, rl.Color{0xFF, 0xFF, 0xCC, alpha})
	}
}

@(private = "file")
_draw_minimap :: proc(p: ^Player_2D, d: ^Drifter, m: ^Tile_Map, sw, sh: i32) {
	ox := MINI_PAD
	oy := sh - i32(MAP_ROWS) * MINI_TILE - MINI_PAD

	for r in 0 ..< MAP_ROWS {
		for c in 0 ..< MAP_COLS {
			tile_col: rl.Color = {0x44, 0x44, 0x44, 0xCC}
			if is_solid(m, r, c) do tile_col = rl.Color{0xAA, 0x88, 0x44, 0xCC}
			rl.DrawRectangle(ox + i32(c) * MINI_TILE, oy + i32(r) * MINI_TILE, MINI_TILE, MINI_TILE, tile_col)
		}
	}

	px := ox + i32(p.pos.x * f32(MINI_TILE))
	py := oy + i32(p.pos.y * f32(MINI_TILE))
	rl.DrawRectangle(px - 2, py - 2, 4, 4, rl.WHITE)
	rl.DrawLine(px, py, px + i32(math.cos(p.angle) * 8), py + i32(math.sin(p.angle) * 8), rl.WHITE)

	if d.alive {
		dmx := ox + i32(d.pos.x * f32(MINI_TILE))
		dmy := oy + i32(d.pos.y * f32(MINI_TILE))
		rl.DrawRectangle(dmx - 2, dmy - 2, 4, 4, DRIFTER_COL)
	}
}
