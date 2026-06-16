package main

// Cendres — first-person tower-defence / roguelite (Odin + Raylib, 3D prototype)
// See: gdd/index.md for the full design map.
// See: gdd/meta/14-development.md for phase roadmap. Current state: Phase 0, Step 9.

import game "game"
import rl "vendor:raylib"

SCREEN_W :: i32(1280)
SCREEN_H :: i32(720)

main :: proc() {
	rl.InitWindow(SCREEN_W, SCREEN_H, "Cendres")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)
	rl.DisableCursor()
	defer rl.EnableCursor()

	tile_map := game.make_test_map()
	player   := game.make_player()
	drifter  := game.make_drifter(&tile_map, player.pos)
	renderer := game.make_renderer()
	defer game.unload_renderer(renderer)
	amber: game.Amber

	for !rl.WindowShouldClose() {
		if rl.IsKeyPressed(.ESCAPE) do break

		dt := rl.GetFrameTime()
		game.update_player(&player, &tile_map, dt)
		game.update_drifter(&drifter, &tile_map, player.pos, dt)
		game.update_amber(&amber, &player, dt)
		if rl.IsKeyPressed(.SPACE) do game.try_flare(&player, &drifter)
		if rl.IsKeyPressed(.E)     do game.place_amber(&amber, player.pos)

		rl.BeginDrawing()
		game.draw_scene(&renderer, &player, &drifter, &amber, &tile_map, SCREEN_W, SCREEN_H)
		// Crosshair
		rl.DrawLine(SCREEN_W / 2 - 8, SCREEN_H / 2, SCREEN_W / 2 + 8, SCREEN_H / 2, rl.WHITE)
		rl.DrawLine(SCREEN_W / 2, SCREEN_H / 2 - 8, SCREEN_W / 2, SCREEN_H / 2 + 8, rl.WHITE)
		rl.EndDrawing()
	}
}
