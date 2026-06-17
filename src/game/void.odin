// Void entities — GDD §6 Combat, §9.2 Void_Entity
// Phase 1: three species with distinct AI behaviours.
//   Drifter 漂魂 — Curious;    chases player
//   Lurker  潛影 — Timid;      flanks toward Beacon from a side spawn
//   Gnasher 噬獸 — Territorial; beelines to structures (Amber → Beacon)
package game

import "core:math"

PATH_MAX :: 256 // sufficient for any shortest path on the current 24×20 prototype map

BEACON_POS :: [2]f32{9.5, 5.5} // world {x=col=9.5, y=row=5.5} centre of Beacon_Core tile

// Per-species movement speeds (tiles/second)
DRIFTER_SPEED :: f32(1.5)
LURKER_SPEED :: f32(1.0)
GNASHER_SPEED :: f32(2.2)

Void_Species :: enum u8 {
	Drifter, // 漂魂 — drawn to light, harasses player
	Lurker, // 潛影 — goes for the core via flank spawn; player-avoidance TODO(Phase 2)
	Gnasher, // 噬獸 — ignores player, charges structures
}

Void_Entity :: struct {
	species:   Void_Species,
	pos:       [2]f32,
	alive:     bool,
	speed:     f32,
	path:      [PATH_MAX][2]i16, // (row, col) waypoints from A*
	path_len:  int,
	path_idx:  int,
	last_tile: [2]int, // tile at last path recompute; [row, col]
}

// make_void_entity spawns an entity at its species-appropriate map edge.
make_void_entity :: proc(species: Void_Species, m: ^Tile_Map, player_pos: [2]f32) -> Void_Entity {
	spawn: [2]f32
	speed: f32
	switch species {
	case .Drifter:
		spawn = {20.5, 10.5} // east mid-map (tile centre)
		speed = DRIFTER_SPEED
	case .Lurker:
		spawn = {22.5, 1.5} // northeast corner — flanks toward Beacon
		speed = LURKER_SPEED
	case .Gnasher:
		spawn = {1.5, 18.5} // southwest corner — charges across map
		speed = GNASHER_SPEED
	}

	e := Void_Entity {
		species   = species,
		pos       = spawn,
		alive     = true,
		speed     = speed,
		last_tile = {-1, -1},
	}

	target: [2]f32
	switch species {
	case .Drifter:
		target = player_pos
	case .Lurker:
		target = BEACON_POS
	case .Gnasher:
		target = BEACON_POS
	}
	_recompute_path(&e, m, target)
	return e
}

// update_void_entity advances one entity by dt seconds.
// Target selection varies by species; all navigate with A*.
update_void_entity :: proc(
	e: ^Void_Entity,
	m: ^Tile_Map,
	player_pos: [2]f32,
	structures: []Structure,
	dt: f32,
) {
	if !e.alive do return

	target: [2]f32
	switch e.species {
	case .Drifter:
		target = player_pos // relentlessly follows the player
	case .Lurker:
		target = BEACON_POS // goes for the core; distinct flank spawn angle
	case .Gnasher:
		// Charges the nearest active structure; falls back to Beacon_Core
		target = BEACON_POS
		nearest := f32(1e30)
		for &s in structures {
			if !s.active do continue
			dx := s.pos.x - e.pos.x
			dy := s.pos.y - e.pos.y
			dist := math.sqrt(dx * dx + dy * dy)
			if dist < nearest {
				nearest = dist
				target = s.pos
			}
		}
	}

	cur_tile := [2]int{int(e.pos.y), int(e.pos.x)} // row, col
	if cur_tile != e.last_tile || e.path_idx >= e.path_len {
		_recompute_path(e, m, target)
		e.last_tile = cur_tile
	}
	if e.path_idx >= e.path_len do return

	wp := e.path[e.path_idx]
	tx := f32(wp[1]) + 0.5 // col → world x
	ty := f32(wp[0]) + 0.5 // row → world y
	dx := tx - e.pos.x
	dy := ty - e.pos.y
	dist := math.sqrt(dx * dx + dy * dy)
	if dist < 0.1 {
		e.path_idx += 1
		return
	}
	e.pos.x += (dx / dist) * e.speed * dt
	e.pos.y += (dy / dist) * e.speed * dt
}

@(private = "file")
_recompute_path :: proc(e: ^Void_Entity, m: ^Tile_Map, target: [2]f32) {
	sr := int(e.pos.y)
	sc := int(e.pos.x)
	gr := int(target.y)
	gc := int(target.x)
	e.path_len = astar_fill(m, sr, sc, gr, gc, e.path[:])
	e.path_idx = 0
}
