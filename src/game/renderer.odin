// 3D renderer — GDD §9.3 (Phase 1)
// Raylib Camera3D + multi-light GLSL shader (shaders/light.fs).
// Supports up to MAX_LIGHTS additive light sources per frame.
package game

import "core:math"
import rl "vendor:raylib"
import rlgl "vendor:raylib/rlgl"

EYE_HEIGHT :: f32(0.5)

VOID_BLACK :: rl.Color{0x00, 0x00, 0x00, 0xFF}
WALL_COL :: rl.Color{0xAA, 0x88, 0x44, 0xFF}
FLOOR_COL :: rl.Color{0x33, 0x33, 0x33, 0xFF}
CEILING_COL :: rl.Color{0x22, 0x22, 0x22, 0xFF} // slightly darker than floor
DRIFTER_COL :: rl.Color{0xDD, 0xAA, 0xFF, 0xFF} // 漂魂 — warm magenta
LURKER_COL :: rl.Color{0x55, 0x44, 0x88, 0xFF} // 潛影 — dark indigo
GNASHER_COL :: rl.Color{0xCC, 0x44, 0x22, 0xFF} // 噬獸 — rust red

Renderer :: struct {
	shader:        rl.Shader,
	loc_pos:       i32, // lightPos[MAX_LIGHTS]
	loc_radius:    i32, // lightRadius[MAX_LIGHTS]
	loc_intensity: i32, // lightIntensity[MAX_LIGHTS]
	loc_count:     i32, // lightCount
}

make_renderer :: proc() -> Renderer {
	shader := rl.LoadShader("shaders/light.vs", "shaders/light.fs")
	return Renderer {
		shader = shader,
		loc_pos = rl.GetShaderLocation(shader, "lightPos"),
		loc_radius = rl.GetShaderLocation(shader, "lightRadius"),
		loc_intensity = rl.GetShaderLocation(shader, "lightIntensity"),
		loc_count = rl.GetShaderLocation(shader, "lightCount"),
	}
}

unload_renderer :: proc(r: Renderer) {
	rl.UnloadShader(r.shader)
}

// draw_world renders the lit 3D scene (Layer 1) inside an already-open BeginDrawing block.
// Screen-space overlays and HUD are drawn separately by the render package.
draw_world :: proc(r: ^Renderer, p: ^Player_2D, entities: []Void_Entity, a: ^Amber, m: ^Tile_Map) {
	// Collect all active light sources and pack into contiguous GPU arrays
	lights: [MAX_LIGHTS]Light_Source
	count := collect_lights(p, a, &lights)

	positions: [MAX_LIGHTS][3]f32
	radii: [MAX_LIGHTS]f32
	intensities: [MAX_LIGHTS]f32
	for i in 0 ..< int(count) {
		positions[i] = {lights[i].pos.x, EYE_HEIGHT, lights[i].pos.y}
		radii[i] = lights[i].radius
		intensities[i] = lights[i].intensity
	}

	rl.SetShaderValueV(r.shader, r.loc_pos, rawptr(&positions), .VEC3, count)
	rl.SetShaderValueV(r.shader, r.loc_radius, rawptr(&radii), .FLOAT, count)
	rl.SetShaderValueV(r.shader, r.loc_intensity, rawptr(&intensities), .FLOAT, count)
	rl.SetShaderValue(r.shader, r.loc_count, rawptr(&count), .INT)

	cos_a := math.cos(p.angle)
	sin_a := math.sin(p.angle)
	cos_p := math.cos(p.pitch)
	sin_p := math.sin(p.pitch)

	camera := rl.Camera3D {
		position   = {p.pos.x, EYE_HEIGHT, p.pos.y},
		target     = {p.pos.x + cos_a * cos_p, EYE_HEIGHT + sin_p, p.pos.y + sin_a * cos_p},
		up         = {0, 1, 0},
		fovy       = 60,
		projection = .PERSPECTIVE,
	}

	rl.BeginMode3D(camera)
	rl.BeginShaderMode(r.shader)

	// Floor + ceiling — per non-solid tile; ceiling drawn with backface culling disabled
	// so the underside of the plane is visible from below.
	rlgl.DisableBackfaceCulling()
	for row in 0 ..< MAP_ROWS {
		for col in 0 ..< MAP_COLS {
			if is_solid(m, row, col) do continue
			cx := f32(col) + 0.5
			cz := f32(row) + 0.5
			rl.DrawPlane({cx, 0, cz}, {1, 1}, FLOOR_COL)
			rl.DrawPlane({cx, 2.0, cz}, {1, 1}, CEILING_COL)
		}
	}
	rlgl.EnableBackfaceCulling()

	// Walls
	for row in 0 ..< MAP_ROWS {
		for col in 0 ..< MAP_COLS {
			if !is_solid(m, row, col) do continue
			rl.DrawCube({f32(col) + 0.5, EYE_HEIGHT, f32(row) + 0.5}, 1, 1, 1, WALL_COL)
		}
	}

	// Void entities — shape and size distinguish species at a glance
	for &e in entities {
		if !e.alive do continue
		switch e.species {
		case .Drifter:
			rl.DrawCylinder({e.pos.x, 0, e.pos.y}, 0.30, 0.30, 1.0, 8, DRIFTER_COL)
		case .Lurker:
			rl.DrawCylinder({e.pos.x, 0, e.pos.y}, 0.15, 0.15, 1.5, 6, LURKER_COL)
		case .Gnasher:
			rl.DrawCylinder({e.pos.x, 0, e.pos.y}, 0.45, 0.45, 0.8, 6, GNASHER_COL)
		}
	}

	// Amber structure
	if a.active {
		rl.DrawCube({a.pos.x, 0.25, a.pos.y}, 0.5, 0.5, 0.5, rl.Color{0xFF, 0xCC, 0x44, 0xFF})
	}

	rl.EndShaderMode()
	rl.EndMode3D()
}
