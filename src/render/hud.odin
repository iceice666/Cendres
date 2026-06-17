// HUD — GDD §9.3 render/hud.odin (Layer 3: UI / HUD)
// Lantern 燃料計 (fuel meter), Lumen 計數 (Lumen counter), minimap, crosshair.
package render

import "core:math"
import game "../game"
import rl "vendor:raylib"

MINI_TILE :: i32(5)
MINI_PAD  :: i32(8)

// draw_hud draws all 2D screen-space UI elements (Layer 3).
// Must be called last, after draw_overlays, so UI always renders on top.
draw_hud :: proc(p: ^game.Player_2D, d: ^game.Drifter, m: ^game.Tile_Map, sw, sh: i32) {
	_draw_minimap(p, d, m, sw, sh)

	// Crosshair
	rl.DrawLine(sw / 2 - 8, sh / 2, sw / 2 + 8, sh / 2, rl.WHITE)
	rl.DrawLine(sw / 2, sh / 2 - 8, sw / 2, sh / 2 + 8, rl.WHITE)

	// TODO(Phase 1): Lantern 燃料計 — depleting fuel bar
	// TODO(Phase 1): Lumen 計數 — accumulated Lumen counter
}

@(private = "file")
_draw_minimap :: proc(p: ^game.Player_2D, d: ^game.Drifter, m: ^game.Tile_Map, sw, sh: i32) {
	ox := MINI_PAD
	oy := sh - i32(game.MAP_ROWS) * MINI_TILE - MINI_PAD

	for r in 0 ..< game.MAP_ROWS {
		for c in 0 ..< game.MAP_COLS {
			tile_col: rl.Color = {0x44, 0x44, 0x44, 0xCC}
			if game.is_solid(m, r, c) do tile_col = rl.Color{0xAA, 0x88, 0x44, 0xCC}
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
		rl.DrawRectangle(dmx - 2, dmy - 2, 4, 4, game.DRIFTER_COL)
	}
}
