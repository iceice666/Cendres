// 光源結構 tick、放置、拆除 — GDD §9.2 Light_Structure, §6
// Phase 1: single Amber structure; full structure roster in later milestones.
package game

AMBER_RADIUS :: f32(4.0) // light radius in tiles
AMBER_DRAIN :: f32(0.05) // fuel/second drained from player's lantern while active

Amber :: struct {
	pos:    [2]f32,
	active: bool,
}

place_amber :: proc(a: ^Amber, pos: [2]f32) {
	a.pos = pos
	a.active = true
}

update_amber :: proc(a: ^Amber, p: ^Player_2D, dt: f32) {
	if !a.active do return
	p.lantern_fuel = max(p.lantern_fuel - AMBER_DRAIN * dt, 0.0)
	if p.lantern_fuel <= 0 do a.active = false
}
