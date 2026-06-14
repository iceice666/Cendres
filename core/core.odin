// Package core — 跨套件共用型別 / cross-cutting types
// Holds structs shared by game, render, narrative, garden, save to avoid Odin
// import-cycle errors. Fills in during Phase 0.
//
// Key types (GDD §9.2, §9.7):
//   Player, Light_Source, Void_Entity, Light_Structure, Game_State, Game_Phase
//   LLM_Context, LLM_Config, Lumen_Color, Void_Species, ...
//
// TODO(Phase 0): port GDD §9.2 and §9.7 data structures here.
package core
