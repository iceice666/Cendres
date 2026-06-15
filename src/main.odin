package main

import rl "vendor:raylib"

// Cendres — 第一人稱塔防 / Roguelite (Odin + Raylib, raycasting 2.5D)
// See: gdd/index.md for the full game design map.
// See: gdd/09-development.md for phase roadmap. Current state: scaffold (pre-Phase 0).

main :: proc() {
	rl.InitWindow(1280, 720, "Cendres")
	defer rl.CloseWindow()
	rl.SetTargetFPS(60)

	for !rl.WindowShouldClose() {
		rl.BeginDrawing()
		// Void Black (#2A2A2A) background — GDD §2 visual language
		rl.ClearBackground(rl.Color{0x2A, 0x2A, 0x2A, 0xFF})
		// Amber (#F5C842) text — GDD §9.2 Lumen_Color.Amber
		rl.DrawText("Cendres — scaffold", 24, 24, 24, rl.Color{0xF5, 0xC8, 0x42, 0xFF})
		rl.DrawText("Phase 0 not yet started — see gdd/09-development.md", 24, 56, 18, rl.Color{0xAA, 0xAA, 0xAA, 0xFF})
		rl.EndDrawing()
	}
}
