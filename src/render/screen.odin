// 螢幕空間合成 — GDD §9.3 render/screen.odin (Layer 2)
// Full-screen screen-space effects composited over the world layer.
// Future home for: The Dimming vignette (消光), run-transition fades.
package render

import game "../game"
import rl "vendor:raylib"

// draw_overlays draws full-screen screen-space effects (Layer 2).
// Must be called after game.draw_world and before render.draw_hud.
draw_overlays :: proc(p: ^game.Player_2D, sw, sh: i32) {
	// Flare flash — full-screen warm tint that fades after SPACE is pressed
	if p.flare_flash > 0 {
		alpha := u8(200.0 * p.flare_flash / game.FLARE_FLASH_DURATION)
		rl.DrawRectangle(0, 0, sw, sh, rl.Color{0xFF, 0xFF, 0xCC, alpha})
	}
}
