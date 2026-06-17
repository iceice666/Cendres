// Lumen 經濟、drop/collect system — GDD §8 Progression, §9.2 Player
// 靈光 (Lumen) is the only in-run resource and currency.
// Void deaths spawn physical residue at the death spot; the player banks it by
// moving within LUMEN_COLLECT_RADIUS.  Sources / sinks: gdd/player/16-how-to-play.md.
// Cross-run grief-residue carry-over deferred to the death-state milestone (Phase 1).
package game

import "core:math"
import rl "vendor:raylib"

LUMEN_DROP_MAX :: 32
LUMEN_COLLECT_RADIUS :: f32(0.8) // tiles within which a drop is auto-banked

LUMEN_DROP_COL :: rl.Color{0xFF, 0xAA, 0x22, 0xFF} // warm amber — used by renderer and HUD

Lumen_Drop :: struct {
	pos:    [2]f32,
	amount: f32,
	active: bool,
}

// void_lumen_value returns the residue amount left by a killed Void entity.
// Higher threat → higher reward to offset the danger of venturing out to collect.
void_lumen_value :: proc(s: Void_Species) -> f32 {
	switch s {
	case .Drifter:
		return 3.0
	case .Lurker:
		return 4.0
	case .Gnasher:
		return 5.0
	}
	return 3.0 // required by Odin; all enum cases above are exhaustive
}

// spawn_lumen_drop places a new drop at pos into the first inactive slot.
// Intentional silent data loss when pool is exhausted (LUMEN_DROP_MAX cap):
// callers cannot usefully react this phase; expand the cap if overflow is observed.
spawn_lumen_drop :: proc(drops: []Lumen_Drop, pos: [2]f32, amount: f32) {
	for &d in drops {
		if !d.active {
			d = Lumen_Drop {
				pos    = pos,
				amount = amount,
				active = true,
			}
			return
		}
	}
}

// collect_lumen_drops banks every drop within LUMEN_COLLECT_RADIUS of the player.
collect_lumen_drops :: proc(drops: []Lumen_Drop, p: ^Player_2D) {
	for &d in drops {
		if !d.active do continue
		dx := d.pos.x - p.pos.x
		dy := d.pos.y - p.pos.y
		if math.sqrt(dx * dx + dy * dy) <= LUMEN_COLLECT_RADIUS {
			p.lumen_carried += d.amount
			d.active = false
		}
	}
}
