// 永久資料（跨 run） — GDD §9.5 save/persist.odin
// Persists: run_count, Memory_Node bit_set, Void_Garden, Void_Codex, imprints_found.
// grief_residue (30% Lumen carry-over) also persists across runs.
// TODO(Phase 1): minimal persist (run_count + death state); Phase 2: full save.
package save
