# Cendres — Agent Guide

Cendres is a first-person tower-defence / roguelite game built in **Odin + Raylib**,
using a raycasting 2.5D renderer where the light/dark mechanic is the core combat system.
The player (Tender) tends a Beacon, places light structures, and fends off Void entities
across 29+ runs that build toward three distinct endings.

Full design documentation is in **`gdd/`** (Traditional Chinese). Start with
[`gdd/index.md`](gdd/index.md) for the map; [`gdd/09-technical.md`](gdd/09-technical.md)
for architecture; [`gdd/14-development.md`](gdd/14-development.md) for phase roadmap.

**Current state:** scaffold / pre-Phase 0. No game logic exists yet.

---

## ⚠ Toolchain setup (macOS 26 / Darwin 25+)

The dev environment is Nix-based, but **on macOS 26 the nix build of `odin`/`ols` is
currently broken** (compiler-rt-18 fails to compile with apple-sdk-26). The workaround:

| Tool | Source | Notes |
|------|--------|-------|
| `odin` | homebrew | `brew install odin` — bottle available |
| `ols` (LSP) | homebrew | `brew install ols` |
| `odinfmt` | build from source | not bundled by homebrew; see below |
| `raylib` | nix devShell | 6.0 from nix, provided via `nix develop` |
| `pkg-config` | nix devShell | wires raylib into the build |

```bash
# One-time setup:
brew install odin ols          # odin 2026-06, ols 2026-05
direnv allow                   # enters the nix devShell on cd; adds homebrew to PATH

# If direnv is not installed:
nix develop                    # manual devShell entry
export PATH="/opt/homebrew/bin:$PATH"  # make brew odin visible inside the shell
```

**`odinfmt` (optional — for `just fmt`):**
```bash
git clone https://github.com/DanielGavin/ols /tmp/ols-src
cd /tmp/ols-src
odin build odinfmt -out:/usr/local/bin/odinfmt   # or ~/.local/bin/
```

Any agent that runs `odin` without first confirming it's on PATH will get
`command not found`. Always verify with `command -v odin` before proceeding.

---

## Build & Run

All recipes are in the [`Justfile`](Justfile). Use `just --list` to see them.

```bash
just build        # compile → build/cendres
just run          # build + launch the window
just check        # type-check main package
just check-all    # type-check every sub-package (validates stubs too)
just fmt          # odinfmt -w . (format in-place)
just clean        # rm -rf build
just build-release        # optimised build
just build-windows        # Windows cross-compile (see Justfile for flags)
```

The build command used inside `just build` is (verified on macOS 26 / aarch64):

```bash
odin build . -out:build/cendres
```

The homebrew `odin` distribution ships the `vendor:raylib` *bindings* (Odin API wrapper)
but NOT the raylib static lib. The nix devShell sets `NIX_LDFLAGS` so the linker finds
the nix-provided `raylib 6.0` automatically — this is why a plain `odin build .` works
when inside `nix develop` / direnv. Do not run `odin build` outside the devShell.

---

## Package Architecture

One Odin package per directory — Odin forbids import cycles, so cross-cutting
types will live in `core` once Phase 0 begins:

```
main.odin              package main   — entry point (Raylib window)
core/                  package core   — shared types: Player, Light_Source,
                                        Void_Entity, Game_State, LLM_Context, …
game/                  package game   — state, player, raycaster, map, light,
                                        structure, void, wave, lumen
render/                package render — screen compositor, HUD, billboard sprites
narrative/             package narrative — Beacon dialogue, Void Codex, imprints
narrative/llm/         package llm   — LLM config, context assembly, prompt builder,
                                        HTTP client, handwritten fallback pool
garden/                package garden — Void Garden state, Beacon Reflection space
save/                  package save  — cross-run persistence
```

Each stub file currently contains only its `package` declaration + a GDD-section comment
and a `TODO(Phase N)` marker. They are validated via `just check-all`, not via `main`.

GDD module mapping: **`gdd/09-technical.md` §9.5**.

---

## Conventions

- **Naming:** `Ada_Case` for types / enums, `snake_case` for procedures and variables —
  matches the GDD code samples throughout `gdd/09-technical.md`.
- **Comments:** may be bilingual (English + zh-Hant), matching the GDD style.
- **Format:** always `just fmt` before committing.
- **Imports:** `import rl "vendor:raylib"` for Raylib; use `core` package for any type
  shared between packages (avoids import cycles).

---

## LLM system — design constraints (do not violate)

The LLM is a **style layer**, never a narrative decision-maker. Any agent touching
`narrative/llm/` must understand:

| Rule | Detail |
|------|--------|
| Critical-run lines are **always** handwritten | Runs 11, 17, 24, 29 and all three endings bypass the LLM entirely — never route them through LLM generation |
| `truth_layer` constraints are absolute | The system prompt in `narrative/llm/prompt.odin` encodes what Beacon is allowed to imply per run range (1–10 / 11–22 / 23–28). Never generate code that leaks Layer 3 information in Layer 1. Red-team this before Phase 2 ships. |
| Fallback is always present | `narrative/llm/fallback.odin`'s `get_handwritten_line` must cover every `Death_Cause` × every `run_count`. LLM failure is silent; the player never sees an error. |
| API keys / local config are **never committed** | `LLM_Config.api_key` is stored in a local file (e.g. `config.local.toml`) that is `.gitignore`d. Do not add it to any tracked file. |

---

## Git hygiene

- `flake.lock` **is** tracked — commit it alongside `flake.nix` changes.
- `build/` is in `.gitignore`.
- Local LLM config (`config.local.*`) is in `.gitignore`.
- Use Conventional Commits: `feat:`, `fix:`, `build:`, `docs:`, `chore:`.
