// Tile map — GDD §9.4
// Phase 0: 2D tile grid; raycasting 的 DDA substrate。
// Phase 1: 同一份資料轉換為 Raylib 3D 幾何體 + GLSL shader。
package game

MAP_COLS :: 24
MAP_ROWS :: 20
TILE_SIZE :: f32(1.0) // 每格的世界單位長度

Cell_Kind :: enum u8 {
	Empty,
	Wall,
	Structure_Slot, // 可放置塔的位置
	Imprint, // Lore 環境碎片
	Beacon_Core, // 進入觸發 Reflection
	Boundary, // Salvage Phase 的暗區
}

Tile_Map :: [MAP_ROWS][MAP_COLS]Cell_Kind

// make_test_map 產生 Phase 0 原型地圖。
// 佈局：外牆、一個含 Beacon_Core 的內房間（偏北）、南側主走廊（col 10-11）、
// 中段兩組障礙柱讓 raycaster 有幾何可以投影。
// '#' = Wall  '.' = Empty  'B' = Beacon_Core  'S' = Structure_Slot
make_test_map :: proc() -> Tile_Map {
	layout := [MAP_ROWS]string {
		"########################", //  0
		"#......................#", //  1
		"#....##########........#", //  2
		"#....#........#........#", //  3
		"#....#........#........#", //  4
		"#....#...B....#........#", //  5  Beacon_Core at (5, 9)
		"#....#........#........#", //  6
		"#....##..######........#", //  7  南側開口 col 10-11
		"#......................#", //  8
		"##########..############", //  9  主走廊 col 10-11
		"#......................#", // 10
		"#......................#", // 11
		"#......................#", // 12
		"#....####..####........#", // 13
		"#....#..#..#..#........#", // 14
		"#....#..#..#..#........#", // 15
		"#....####..####........#", // 16
		"#......................#", // 17
		"#......................#", // 18
		"########################", // 19
	}
	m: Tile_Map
	for row, r in layout {
		for ch, c in row {
			m[r][c] = _cell_from_char(ch)
		}
	}
	return m
}

// is_solid 供 raycaster DDA march 使用：牆與邊界皆視為實體。
// 範圍外一律視為實體（防止 ray 越界）。
is_solid :: proc(m: ^Tile_Map, row, col: int) -> bool {
	if row < 0 || row >= MAP_ROWS || col < 0 || col >= MAP_COLS do return true
	kind := m[row][col]
	return kind == .Wall || kind == .Boundary
}

// tile_at 安全存取；越界回傳 .Wall。
tile_at :: proc(m: ^Tile_Map, row, col: int) -> Cell_Kind {
	if row < 0 || row >= MAP_ROWS || col < 0 || col >= MAP_COLS do return .Wall
	return m[row][col]
}

@(private = "file")
_cell_from_char :: proc(ch: rune) -> Cell_Kind {
	switch ch {
	case '#':
		return .Wall
	case 'B':
		return .Beacon_Core
	case 'S':
		return .Structure_Slot
	case 'I':
		return .Imprint
	case 'X':
		return .Boundary
	}
	return .Empty
}
