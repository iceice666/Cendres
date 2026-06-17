// Billboard sprite 渲染 — GDD §9.3 render/sprite.odin
// Note: billboards (DrawBillboard, always facing player) live INSIDE the world 3D pass
// (game.draw_world, inside BeginMode3D) — they are world-space objects, not a composite layer.
// This file will hold the distance-sort logic and per-sprite draw calls called from game.draw_world.
// TODO(Phase 1): distance-sorted billboard draw for Void entities + Imprints.
package render
