// HUD — GDD §9.3 render/hud.odin (Layer 3: UI / HUD)
// Lantern 燃料計 (fuel meter), Lumen 計數 (Lumen counter), minimap, crosshair.
package render

import game "../game"
import "core:math"
import rl "vendor:raylib"

MINI_TILE :: i32(5)
MINI_PAD :: i32(8)

// draw_hud draws all 2D screen-space UI elements (Layer 3).
// Must be called last, after draw_overlays, so UI always renders on top.
draw_hud :: proc(
	p: ^game.Player_2D,
	entities: []game.Void_Entity,
	structures: []game.Structure,
	drops: []game.Lumen_Drop,
	m: ^game.Tile_Map,
	sw, sh: i32,
) {
	_draw_minimap(p, entities, structures, drops, m, sw, sh)

	// Crosshair
	rl.DrawLine(sw / 2 - 8, sh / 2, sw / 2 + 8, sh / 2, rl.WHITE)
	rl.DrawLine(sw / 2, sh / 2 - 8, sw / 2, sh / 2 + 8, rl.WHITE)

	// Lumen counter — 靈光 wallet balance
	rl.DrawText(rl.TextFormat("Lumen: %d", i32(p.lumen_carried)), 10, 10, 20, game.LUMEN_DROP_COL)

	// Lantern fuel bar — depletes passively; recharged via F key
	BAR_W :: i32(200)
	BAR_H :: i32(12)
	fuel_ratio := p.lantern_fuel / game.MAX_LANTERN_FUEL
	bar_fill := i32(f32(BAR_W) * clamp(fuel_ratio, 0, 1))
	rl.DrawRectangle(10, 38, BAR_W, BAR_H, rl.Color{0x44, 0x44, 0x44, 0xAA})
	rl.DrawRectangle(10, 38, bar_fill, BAR_H, rl.Color{0xFF, 0xCC, 0x44, 0xFF})
	rl.DrawText("Lantern", 10, 54, 14, rl.Color{0xAA, 0x88, 0x44, 0xFF})
}

@(private = "file")
_draw_minimap :: proc(
	p: ^game.Player_2D,
	entities: []game.Void_Entity,
	structures: []game.Structure,
	drops: []game.Lumen_Drop,
	m: ^game.Tile_Map,
	sw, sh: i32,
) {
	ox := MINI_PAD
	oy := sh - i32(game.MAP_ROWS) * MINI_TILE - MINI_PAD

	for r in 0 ..< game.MAP_ROWS {
		for c in 0 ..< game.MAP_COLS {
			tile_col: rl.Color = {0x44, 0x44, 0x44, 0xCC}
			if game.is_solid(m, r, c) do tile_col = rl.Color{0xAA, 0x88, 0x44, 0xCC}
			rl.DrawRectangle(
				ox + i32(c) * MINI_TILE,
				oy + i32(r) * MINI_TILE,
				MINI_TILE,
				MINI_TILE,
				tile_col,
			)
		}
	}

	// Active structures — 3×3 filled squares by kind
	for &s in structures {
		if !s.active do continue
		col: rl.Color
		switch s.kind {
		case .Beacon_Pillar:
			col = game.PILLAR_COL
		case .Vigil_Lamp:
			col = game.VIGIL_COL
		case .Flashpoint:
			col = game.FLASHPOINT_COL
		}
		smx := ox + i32(s.pos.x * f32(MINI_TILE))
		smy := oy + i32(s.pos.y * f32(MINI_TILE))
		rl.DrawRectangle(smx - 1, smy - 1, 3, 3, col)
	}

	// Lumen drops — 2×2 amber dots on the minimap
	for &d in drops {
		if !d.active do continue
		dmx := ox + i32(d.pos.x * f32(MINI_TILE))
		dmy := oy + i32(d.pos.y * f32(MINI_TILE))
		rl.DrawRectangle(dmx - 1, dmy - 1, 2, 2, game.LUMEN_DROP_COL)
	}

	// Player dot + direction indicator
	px := ox + i32(p.pos.x * f32(MINI_TILE))
	py := oy + i32(p.pos.y * f32(MINI_TILE))
	rl.DrawRectangle(px - 2, py - 2, 4, 4, rl.WHITE)
	rl.DrawLine(px, py, px + i32(math.cos(p.angle) * 8), py + i32(math.sin(p.angle) * 8), rl.WHITE)

	// Void entity dots — 4×4 in species colour
	for &e in entities {
		if !e.alive do continue
		col: rl.Color
		switch e.species {
		case .Drifter:
			col = game.DRIFTER_COL
		case .Lurker:
			col = game.LURKER_COL
		case .Gnasher:
			col = game.GNASHER_COL
		}
		emx := ox + i32(e.pos.x * f32(MINI_TILE))
		emy := oy + i32(e.pos.y * f32(MINI_TILE))
		rl.DrawRectangle(emx - 2, emy - 2, 4, 4, col)
	}
}
