// Light structures — GDD §9.2 Light_Structure, §6, §8
// Phase 1: Beacon_Pillar 燈柱, Vigil_Lamp 守夜燈, Flashpoint 閃點
package game

import "core:math"

MAX_STRUCTURES :: 4 // max simultaneously placed structures on the map

Structure_Kind :: enum u8 {
	Beacon_Pillar, // 燈柱 — steady omnidirectional medium light
	Vigil_Lamp, // 守夜燈 — long-range, lower intensity; directional cone deferred to Phase 2
	Flashpoint, // 閃點 — no persistent light; detonates on Void contact
}

STRUCTURE_INITIAL_FUEL :: f32(60.0) // fuel units; drain rate determines lifetime
STRUCTURE_SHATTER_RESIDUE :: f32(2.0) // Lumen dropped when a Pillar / Vigil burns out

// Beacon_Pillar 燈柱
PILLAR_RADIUS :: f32(5.0)
PILLAR_DRAIN :: f32(0.5) // fuel/second → ~120 s lifespan
PILLAR_COST :: f32(10.0) // Lumen cost to place

// Vigil_Lamp 守夜燈
VIGIL_RADIUS :: f32(8.0)
VIGIL_INTENSITY :: f32(0.6) // dimmer despite larger radius
VIGIL_DRAIN :: f32(1.0) // fuel/second → ~60 s lifespan
VIGIL_COST :: f32(8.0) // Lumen cost to place

// Flashpoint 閃點
FLASHPOINT_TRIGGER_RADIUS :: f32(1.0) // Void proximity that detonates
FLASHPOINT_BLAST_RADIUS :: f32(3.5) // kill radius of the explosion
FLASHPOINT_COST :: f32(6.0) // Lumen cost to place

// structure_cost returns the Lumen required to place a structure of the given kind.
structure_cost :: proc(kind: Structure_Kind) -> f32 {
	switch kind {
	case .Beacon_Pillar:
		return PILLAR_COST
	case .Vigil_Lamp:
		return VIGIL_COST
	case .Flashpoint:
		return FLASHPOINT_COST
	}
	return 0 // required by Odin; all enum cases above are exhaustive
}

Structure :: struct {
	kind:   Structure_Kind,
	pos:    [2]f32,
	active: bool,
	fuel:   f32,
}

// refuel_structure transfers as much Lumen as possible from the player's wallet
// into the structure's fuel tank, up to STRUCTURE_INITIAL_FUEL.  1 Lumen = 1 fuel unit.
// Flashpoint uses a proximity trigger (not fuel drain), so refueling is a no-op for it.
refuel_structure :: proc(s: ^Structure, p: ^Player_2D) {
	if !s.active do return
	if s.kind == .Flashpoint do return
	amount := min(STRUCTURE_INITIAL_FUEL - s.fuel, p.lumen_carried)
	if amount <= 0 do return
	s.fuel += amount
	p.lumen_carried -= amount
}

place_structure :: proc(s: ^Structure, kind: Structure_Kind, pos: [2]f32) {
	s.kind = kind
	s.pos = pos
	s.active = true
	s.fuel = STRUCTURE_INITIAL_FUEL
}

// update_structure ticks fuel drain and checks Flashpoint proximity trigger.
// Flashpoint detonation kills every Void_Entity within FLASHPOINT_BLAST_RADIUS
// and spawns a Lumen drop per kill; Pillar / Vigil emit shatter residue on burnout.
update_structure :: proc(s: ^Structure, entities: []Void_Entity, drops: []Lumen_Drop, dt: f32) {
	if !s.active do return

	switch s.kind {
	case .Beacon_Pillar:
		s.fuel = max(s.fuel - PILLAR_DRAIN * dt, 0.0)
		if s.fuel <= 0 {
			spawn_lumen_drop(drops, s.pos, STRUCTURE_SHATTER_RESIDUE)
			s.active = false
		}
	case .Vigil_Lamp:
		s.fuel = max(s.fuel - VIGIL_DRAIN * dt, 0.0)
		if s.fuel <= 0 {
			spawn_lumen_drop(drops, s.pos, STRUCTURE_SHATTER_RESIDUE)
			s.active = false
		}
	case .Flashpoint:
		// Detonates once on the first Void entity within trigger radius;
		// the inner loop then kills everything in blast radius and drops Lumen per kill.
		for &e in entities {
			if !e.alive do continue
			dx := e.pos.x - s.pos.x
			dy := e.pos.y - s.pos.y
			if math.sqrt(dx * dx + dy * dy) <= FLASHPOINT_TRIGGER_RADIUS {
				for &e2 in entities {
					if !e2.alive do continue
					dx2 := e2.pos.x - s.pos.x
					dy2 := e2.pos.y - s.pos.y
					if math.sqrt(dx2 * dx2 + dy2 * dy2) <= FLASHPOINT_BLAST_RADIUS {
						spawn_lumen_drop(drops, e2.pos, void_lumen_value(e2.species))
						e2.alive = false
					}
				}
				s.active = false
				return
			}
		}
	}
}
