// Package core — 跨套件共用型別 / cross-cutting types
// Holds structs shared by game, render, narrative, garden, save to avoid Odin
// import-cycle errors. Deferred: no cycle forces extraction yet; types currently
// live in the package that owns them (game, render, …).
//
// Key types planned (GDD §9.2, §9.7):
//   Player, Light_Source, Void_Entity, Light_Structure, Game_State, Game_Phase
//   LLM_Context, LLM_Config, Lumen_Color, Void_Species, ...
//
// TODO(Phase 2): port shared types here when cross-package coupling demands it.
package core
