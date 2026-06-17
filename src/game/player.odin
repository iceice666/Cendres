// Player movement and view rotation — GDD §9.2 Player, §8.2 Lantern
// Phase 1: Player_2D drives Raylib Camera3D with mouse look, WASD, and flare.
// Fuller Lantern component (fuel types, ability set) deferred to later milestones.
package game

import "core:math"
import rl "vendor:raylib"

MOVE_SPEED :: f32(3.0) // tiles per second
ROT_SPEED :: f32(2.5) // radians per second (keyboard fallback)
MOUSE_SENSITIVITY :: f32(0.002) // radians per pixel

// Starting fuel = effective lantern radius in tiles (Phase 0: fuel IS radius, no formula yet).
// Lantern type modifiers come in Phase 1.
MAX_LANTERN_FUEL :: f32(7.0)
LUMEN_DRAIN_RATE :: f32(0.2) // tiles/second; full→dark in ~35 s

FLARE_COST :: f32(1.5) // fuel burned per flare
FLARE_RANGE :: f32(8.0) // max distance to hit target (tiles)
FLARE_AIM_CONE :: f32(math.PI / 5.0) // ±36 degree aim tolerance
FLARE_FLASH_DURATION :: f32(0.12) // screen-flash seconds

STARTING_LUMEN :: f32(20.0) // enough to place ~2 structures at game start

PITCH_LIMIT :: f32(math.PI / 2.5) // ~72 degrees — prevents gimbal flip

// Player_2D holds Phase 1 player state; x/y are tile-space horizontal coords.
Player_2D :: struct {
	pos:           [2]f32,
	angle:         f32, // yaw in radians; 0 = east (+x), PI/2 = south (+y)
	pitch:         f32, // pitch in radians; + = look up, clamped to ±PITCH_LIMIT
	lantern_fuel:  f32, // current fuel; used directly as lantern radius (tiles) this phase
	flare_flash:   f32, // countdown for white screen flash after firing
	lumen_carried: f32, // 靈光 wallet — the player's spendable Lumen balance
}

make_player :: proc() -> Player_2D {
	// Start at row 14, col 9.5 — open area south of Beacon_Core (row 5, col 9).
	return Player_2D {
		pos = {9.5, 14.0},
		angle = -math.PI / 2.0,
		pitch = 0,
		lantern_fuel = MAX_LANTERN_FUEL,
		lumen_carried = STARTING_LUMEN,
	}
}

// refuel_lantern transfers as much Lumen as possible from the player's wallet
// into the lantern fuel, up to MAX_LANTERN_FUEL.  1 Lumen = 1 fuel unit.
refuel_lantern :: proc(p: ^Player_2D) {
	amount := min(MAX_LANTERN_FUEL - p.lantern_fuel, p.lumen_carried)
	if amount <= 0 do return
	p.lantern_fuel += amount
	p.lumen_carried -= amount
}

update_player :: proc(p: ^Player_2D, m: ^Tile_Map, dt: f32) {
	// Mouse look: yaw + pitch
	mouse := rl.GetMouseDelta()
	p.angle += mouse.x * MOUSE_SENSITIVITY
	p.pitch -= mouse.y * MOUSE_SENSITIVITY
	p.pitch = clamp(p.pitch, -PITCH_LIMIT, PITCH_LIMIT)

	// Keyboard yaw fallback
	if rl.IsKeyDown(.LEFT) do p.angle -= ROT_SPEED * dt
	if rl.IsKeyDown(.RIGHT) do p.angle += ROT_SPEED * dt

	cos_a := math.cos(p.angle)
	sin_a := math.sin(p.angle)

	dx, dy: f32
	if rl.IsKeyDown(.W) || rl.IsKeyDown(.UP) {dx += cos_a; dy += sin_a}
	if rl.IsKeyDown(.S) || rl.IsKeyDown(.DOWN) {dx -= cos_a; dy -= sin_a}
	if rl.IsKeyDown(.A) {dx += sin_a; dy -= cos_a} 	// strafe left
	if rl.IsKeyDown(.D) {dx -= sin_a; dy += cos_a} 	// strafe right
	dx *= MOVE_SPEED * dt
	dy *= MOVE_SPEED * dt

	// Passive Lumen drain — radius shrinks to zero over time
	p.lantern_fuel = max(p.lantern_fuel - LUMEN_DRAIN_RATE * dt, 0.0)
	p.flare_flash = max(p.flare_flash - dt, 0.0)

	// Slide collision: test x and y independently with movement-direction margin.
	COLL :: f32(0.25)
	nx := p.pos.x + dx
	ny := p.pos.y + dy
	if !is_solid(m, int(p.pos.y), int(nx + (COLL if dx >= 0 else -COLL))) do p.pos.x = nx
	if !is_solid(m, int(ny + (COLL if dy >= 0 else -COLL)), int(p.pos.x)) do p.pos.y = ny
}

// try_flare fires a flare: costs FLARE_COST fuel regardless of hits.
// Kills every Void_Entity within FLARE_RANGE and within the aim cone;
// each kill spawns a Lumen drop at the entity's position.
try_flare :: proc(p: ^Player_2D, entities: []Void_Entity, drops: []Lumen_Drop) {
	if p.lantern_fuel < FLARE_COST do return
	p.lantern_fuel -= FLARE_COST
	p.flare_flash = FLARE_FLASH_DURATION

	for &e in entities {
		if !e.alive do continue
		ex := e.pos.x - p.pos.x
		ey := e.pos.y - p.pos.y
		dist := math.sqrt(ex * ex + ey * ey)
		if dist > FLARE_RANGE do continue
		da := math.atan2(ey, ex) - p.angle
		for da > math.PI do da -= math.PI * 2
		for da < -math.PI do da += math.PI * 2
		if abs(da) <= FLARE_AIM_CONE {
			spawn_lumen_drop(drops, e.pos, void_lumen_value(e.species))
			e.alive = false
		}
	}
}
