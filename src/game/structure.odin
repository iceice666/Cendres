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

// Beacon_Pillar
PILLAR_RADIUS :: f32(5.0)
PILLAR_DRAIN :: f32(0.5) // fuel/second → ~120 s lifespan

// Vigil_Lamp
VIGIL_RADIUS :: f32(8.0)
VIGIL_INTENSITY :: f32(0.6) // dimmer despite larger radius
VIGIL_DRAIN :: f32(1.0) // fuel/second → ~60 s lifespan

// Flashpoint
FLASHPOINT_TRIGGER_RADIUS :: f32(1.0) // Void proximity that detonates
FLASHPOINT_BLAST_RADIUS :: f32(3.5) // kill radius of the explosion

Structure :: struct {
	kind:   Structure_Kind,
	pos:    [2]f32,
	active: bool,
	fuel:   f32,
}

place_structure :: proc(s: ^Structure, kind: Structure_Kind, pos: [2]f32) {
	s.kind = kind
	s.pos = pos
	s.active = true
	s.fuel = STRUCTURE_INITIAL_FUEL
}

// update_structure ticks fuel drain and checks Flashpoint proximity trigger.
// Flashpoint detonation kills every Void_Entity within FLASHPOINT_BLAST_RADIUS.
update_structure :: proc(s: ^Structure, entities: []Void_Entity, dt: f32) {
	if !s.active do return

	switch s.kind {
	case .Beacon_Pillar:
		s.fuel = max(s.fuel - PILLAR_DRAIN * dt, 0.0)
		if s.fuel <= 0 do s.active = false
	case .Vigil_Lamp:
		s.fuel = max(s.fuel - VIGIL_DRAIN * dt, 0.0)
		if s.fuel <= 0 do s.active = false
	case .Flashpoint:
		// Detonates once on the first Void entity within trigger radius;
		// the inner loop then kills everything in blast radius.
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
						e2.alive = false
					}
				}
				s.active = false
				return
			}
		}
	}
}
