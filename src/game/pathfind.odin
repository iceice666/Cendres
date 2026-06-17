// A* pathfinding on the tile grid — GDD §9.6
package game

import pq "core:container/priority_queue"

_Astar_Node :: struct {
	row, col: i16,
	f:        f32,
}

@(private = "file")
_astar_less :: proc(a, b: _Astar_Node) -> bool {return a.f < b.f}

// astar_fill computes the shortest path from (sr,sc) to (gr,gc) on m.
// Writes (row,col) waypoints into out[], starting from the step after the
// start tile, ending at the goal tile.  Returns the number of steps written.
// Returns 0 if already at goal or no path exists.
astar_fill :: proc(m: ^Tile_Map, sr, sc, gr, gc: int, out: [][2]i16) -> int {
	if sr == gr && sc == gc do return 0

	INF :: f32(1e30)
	g: [MAP_ROWS][MAP_COLS]f32
	par: [MAP_ROWS][MAP_COLS][2]i16
	closed: [MAP_ROWS][MAP_COLS]bool

	for r in 0 ..< MAP_ROWS {
		for c in 0 ..< MAP_COLS {
			g[r][c] = INF
			par[r][c] = {-1, -1}
		}
	}
	g[sr][sc] = 0

	open: pq.Priority_Queue(_Astar_Node)
	pq.init(&open, _astar_less, pq.default_swap_proc(_Astar_Node))
	defer pq.destroy(&open)
	pq.push(&open, _Astar_Node{i16(sr), i16(sc), 0})

	DR := [4]int{-1, 1, 0, 0}
	DC := [4]int{0, 0, -1, 1}
	found := false

	for pq.len(open) > 0 {
		cur := pq.pop(&open)
		r, c := int(cur.row), int(cur.col)
		if closed[r][c] do continue
		closed[r][c] = true
		if r == gr && c == gc {found = true; break}

		for i in 0 ..< 4 {
			nr := r + DR[i]
			nc := c + DC[i]
			if nr < 0 || nr >= MAP_ROWS || nc < 0 || nc >= MAP_COLS do continue
			if is_solid(m, nr, nc) || closed[nr][nc] do continue
			ng := g[r][c] + 1
			if ng < g[nr][nc] {
				g[nr][nc] = ng
				par[nr][nc] = {i16(r), i16(c)}
				h := f32(abs(nr - gr) + abs(nc - gc))
				pq.push(&open, _Astar_Node{i16(nr), i16(nc), ng + h})
			}
		}
	}

	if !found do return 0

	// Count path length (walk back from goal to start)
	count := 0
	{
		r, c := gr, gc
		for !(r == sr && c == sc) {
			count += 1
			p := par[r][c]
			r, c = int(p[0]), int(p[1])
		}
	}
	if count > len(out) do count = len(out)

	// Write path in forward order (start+1 … goal)
	r, c := gr, gc
	for i in 0 ..< count {
		out[count - 1 - i] = {i16(r), i16(c)}
		p := par[r][c]
		r, c = int(p[0]), int(p[1])
	}
	return count
}
