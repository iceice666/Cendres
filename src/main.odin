package main

// Cendres — first-person tower-defence / roguelite (Odin + Raylib, 3D prototype)
// See: gdd/index.md for the full design map.
// See: gdd/meta/14-development.md for phase roadmap. Current state: Phase 1.

import game "game"
import render "render"
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
	player := game.make_player()
	renderer := game.make_renderer()
	defer game.unload_renderer(renderer)
	amber: game.Amber

	// Three Void species — Drifter 漂魂, Lurker 潛影, Gnasher 噬獸
	entities: [3]game.Void_Entity
	entities[0] = game.make_void_entity(.Drifter, &tile_map, player.pos)
	entities[1] = game.make_void_entity(.Lurker, &tile_map, game.BEACON_POS)
	entities[2] = game.make_void_entity(.Gnasher, &tile_map, game.BEACON_POS)

	for !rl.WindowShouldClose() {
		if rl.IsKeyPressed(.ESCAPE) do break

		dt := rl.GetFrameTime()
		game.update_player(&player, &tile_map, dt)
		for &e in entities {
			game.update_void_entity(&e, &tile_map, player.pos, &amber, dt)
		}
		game.update_amber(&amber, &player, dt)
		if rl.IsKeyPressed(.SPACE) do game.try_flare(&player, entities[:])
		if rl.IsKeyPressed(.E) do game.place_amber(&amber, player.pos)

		rl.BeginDrawing()
		rl.ClearBackground(game.VOID_BLACK)
		game.draw_world(&renderer, &player, entities[:], &amber, &tile_map) // Layer 1: lit 3D world
		render.draw_overlays(&player, SCREEN_W, SCREEN_H) // Layer 2: full-screen FX
		render.draw_hud(&player, entities[:], &tile_map, SCREEN_W, SCREEN_H) // Layer 3: UI / HUD
		rl.EndDrawing()
	}
}
