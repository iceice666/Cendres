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

	// Up to MAX_STRUCTURES placed structures; slots reused when inactive
	structures: [game.MAX_STRUCTURES]game.Structure

	// Three Void species — Drifter 漂魂, Lurker 潛影, Gnasher 噬獸
	entities: [3]game.Void_Entity
	entities[0] = game.make_void_entity(.Drifter, &tile_map, player.pos)
	entities[1] = game.make_void_entity(.Lurker, &tile_map, player.pos)
	entities[2] = game.make_void_entity(.Gnasher, &tile_map, player.pos)

	for !rl.WindowShouldClose() {
		if rl.IsKeyPressed(.ESCAPE) do break

		dt := rl.GetFrameTime()
		game.update_player(&player, &tile_map, dt)
		for &e in entities {
			game.update_void_entity(&e, &tile_map, player.pos, structures[:], dt)
		}
		for &s in structures {
			game.update_structure(&s, entities[:], dt)
		}
		if rl.IsKeyPressed(.SPACE) do game.try_flare(&player, entities[:])

		// Structure placement — E: 燈柱, Q: 守夜燈, R: 閃點
		// Writes into the first inactive slot; does nothing when all 4 slots are full.
		if rl.IsKeyPressed(.E) do _try_place(&structures, .Beacon_Pillar, player.pos)
		if rl.IsKeyPressed(.Q) do _try_place(&structures, .Vigil_Lamp, player.pos)
		if rl.IsKeyPressed(.R) do _try_place(&structures, .Flashpoint, player.pos)

		rl.BeginDrawing()
		rl.ClearBackground(game.VOID_BLACK)
		game.draw_world(&renderer, &player, entities[:], structures[:], &tile_map) // Layer 1: lit 3D world
		render.draw_overlays(&player, SCREEN_W, SCREEN_H) // Layer 2: full-screen FX
		render.draw_hud(&player, entities[:], structures[:], &tile_map, SCREEN_W, SCREEN_H) // Layer 3: UI / HUD
		rl.EndDrawing()
	}
}

@(private = "file")
_try_place :: proc(
	structures: ^[game.MAX_STRUCTURES]game.Structure,
	kind: game.Structure_Kind,
	pos: [2]f32,
) {
	for &s in structures {
		if !s.active {
			game.place_structure(&s, kind, pos)
			return
		}
	}
}
