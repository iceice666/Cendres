// Void entities — GDD §9.6 (Phase 0 prototype)
// Step 6: Drifter type + spawn.
// Step 8: A* pathfinding — recomputes path on each tile boundary crossing.
package game

import "core:math"

DRIFTER_SPEED :: f32(1.5)          // tiles per second
BEACON_POS    :: [2]f32{9.5, 5.5} // center of Beacon_Core tile (row 5, col 9)
BEACON_ROW    :: 5
BEACON_COL    :: 9

PATH_MAX :: 256 // sufficient for any path on 24×20 map

Drifter :: struct {
	pos:       [2]f32,
	alive:     bool,
	path:      [PATH_MAX][2]i16, // (row, col) waypoints
	path_len:  int,
	path_idx:  int,
	last_tile: [2]int, // tile when path was last computed; [row, col]
}

make_drifter :: proc(m: ^Tile_Map, initial_target: [2]f32) -> Drifter {
	d := Drifter{pos = {20.0, 10.0}, alive = true, last_tile = {-1, -1}}
	_recompute_path(&d, m, initial_target)
	return d
}

update_drifter :: proc(d: ^Drifter, m: ^Tile_Map, target: [2]f32, dt: f32) {
	if !d.alive do return

	// Recompute path when crossing into a new tile
	cur_tile := [2]int{int(d.pos.y), int(d.pos.x)} // row, col
	if cur_tile != d.last_tile {
		_recompute_path(d, m, target)
		d.last_tile = cur_tile
	}

	if d.path_idx >= d.path_len do return // at goal or no path

	// Move toward current waypoint center
	wp := d.path[d.path_idx]
	tx := f32(wp[1]) + 0.5 // col → world x
	ty := f32(wp[0]) + 0.5 // row → world y
	dx := tx - d.pos.x
	dy := ty - d.pos.y
	dist := math.sqrt(dx * dx + dy * dy)
	if dist < 0.1 {
		d.path_idx += 1
		return
	}
	d.pos.x += (dx / dist) * DRIFTER_SPEED * dt
	d.pos.y += (dy / dist) * DRIFTER_SPEED * dt
}

@(private = "file")
_recompute_path :: proc(d: ^Drifter, m: ^Tile_Map, target: [2]f32) {
	sr := int(d.pos.y)
	sc := int(d.pos.x)
	gr := int(target.y)
	gc := int(target.x)
	d.path_len = astar_fill(m, sr, sc, gr, gc, d.path[:])
	d.path_idx = 0
}
