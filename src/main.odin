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

	// Lumen drop pool — up to LUMEN_DROP_MAX residues on the map at once
	drops: [game.LUMEN_DROP_MAX]game.Lumen_Drop

	// Three Void species — Drifter 漂魂, Lurker 潛影, Gnasher 噬獸
	entities: [3]game.Void_Entity
	entities[0] = game.make_void_entity(.Drifter, &tile_map, player.pos)
	entities[1] = game.make_void_entity(.Lurker, &tile_map, player.pos)
	entities[2] = game.make_void_entity(.Gnasher, &tile_map, player.pos)

	for !rl.WindowShouldClose() {
		if rl.IsKeyPressed(.ESCAPE) do break

		dt := rl.GetFrameTime()
		// Collect drops spawned in previous frames before any new ones are added,
		// so newly spawned drops (kills, structure burnout) require physical traversal.
		game.collect_lumen_drops(drops[:], &player)
		game.update_player(&player, &tile_map, dt)
		for &e in entities {
			game.update_void_entity(&e, &tile_map, player.pos, structures[:], dt)
		}
		for &s in structures {
			game.update_structure(&s, entities[:], drops[:], dt)
		}
		if rl.IsKeyPressed(.SPACE) do game.try_flare(&player, entities[:], drops[:])

		// Structure placement — E: 燈柱, Q: 守夜燈, R: 閃點
		// Deducts Lumen cost; no-op if wallet is insufficient or all 4 slots are full.
		if rl.IsKeyPressed(.E) do _try_place(&structures, .Beacon_Pillar, &player)
		if rl.IsKeyPressed(.Q) do _try_place(&structures, .Vigil_Lamp, &player)
		if rl.IsKeyPressed(.R) do _try_place(&structures, .Flashpoint, &player)

		// F — refuel nearest structure within range, else refuel lantern
		if rl.IsKeyPressed(.F) do _refuel_nearby(&player, structures[:])

		rl.BeginDrawing()
		rl.ClearBackground(game.VOID_BLACK)
		game.draw_world(&renderer, &player, entities[:], structures[:], drops[:], &tile_map) // Layer 1: lit 3D world
		render.draw_overlays(&player, SCREEN_W, SCREEN_H) // Layer 2: full-screen FX
		render.draw_hud(
			&player,
			entities[:],
			structures[:],
			drops[:],
			&tile_map,
			SCREEN_W,
			SCREEN_H,
		) // Layer 3: UI / HUD
		rl.EndDrawing()
	}
}

@(private = "file")
_try_place :: proc(
	structures: ^[game.MAX_STRUCTURES]game.Structure,
	kind: game.Structure_Kind,
	p: ^game.Player_2D,
) {
	cost := game.structure_cost(kind)
	if p.lumen_carried < cost do return
	for &s in structures {
		if !s.active {
			p.lumen_carried -= cost
			game.place_structure(&s, kind, p.pos)
			return
		}
	}
}

@(private = "file")
_refuel_nearby :: proc(p: ^game.Player_2D, structures: []game.Structure) {
	// Find the nearest active (non-Flashpoint) structure within refuel range.
	// Uses squared distance to avoid importing core:math in main.
	REFUEL_RANGE_SQ :: f32(1.5 * 1.5)
	nearest_i := -1
	nearest_d2 := f32(1e30)
	for i in 0 ..< len(structures) {
		s := &structures[i]
		if !s.active || s.kind == .Flashpoint do continue
		dx := s.pos.x - p.pos.x
		dy := s.pos.y - p.pos.y
		d2 := dx * dx + dy * dy
		if d2 < REFUEL_RANGE_SQ && d2 < nearest_d2 {
			nearest_d2 = d2
			nearest_i = i
		}
	}
	if nearest_i >= 0 {
		game.refuel_structure(&structures[nearest_i], p)
	} else {
		game.refuel_lantern(p)
	}
}
