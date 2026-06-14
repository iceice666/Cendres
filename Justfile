set shell := ["bash", "-uc"]

# ── Cendres dev recipes ─────────────────────────────────────────────────────
# Toolchain (odin, raylib, ols, odinfmt) lives inside the Nix devShell.
# Run `direnv allow` once, or prefix any command with `nix develop --command`.
# ────────────────────────────────────────────────────────────────────────────

# List all recipes
default:
    @just --list

# Build the native binary
build:
    mkdir -p build
    odin build . -out:build/cendres

# Build and run (opens the Raylib window)
run: build
    ./build/cendres

# Release build (optimised)
build-release:
    mkdir -p build
    odin build . -out:build/cendres -o:speed

# Windows cross-compile (run from macOS/Linux)
# Requires: nix develop .#windows
# See flake.nix devShells.windows for full instructions.
build-windows:
    nix develop .#windows --command odin build . \
        -target:windows_amd64 \
        -out:build/cendres.exe \
        -extra-linker-flags:"-L$RAYLIB_WIN/lib -lraylib"

# Type-check main package only
check:
    odin check .

# Type-check every sub-package (stubs are validated here, not via main).
# Uses -build-mode:lib so non-main packages don't need an entry point.
check-all:
    #!/bin/bash
    set -euo pipefail
    TMP=/tmp/cendres-check-pkg.a
    for pkg in core game render narrative "narrative/llm" garden save; do
        echo "--- odin check $pkg ---"
        odin build "$pkg" -build-mode:lib -out:$TMP || exit 1
        rm -f "$TMP"
    done
    echo "All packages OK."

# Format all .odin files in-place.
# Requires odinfmt (not bundled by homebrew odin/ols on macOS 26).
# Build it: git clone https://github.com/DanielGavin/ols && cd ols && odin build odinfmt -out:../odinfmt
# Then put the resulting binary on PATH.
fmt:
    @command -v odinfmt >/dev/null 2>&1 || { echo "odinfmt not found — see Justfile comment above"; exit 1; }
    odinfmt -w .

# Run tests (placeholder — no tests yet, recipe in place for Phase 0+)
test:
    #!/bin/bash
    set -euo pipefail
    for pkg in core game render narrative "narrative/llm" garden save; do
        echo "--- odin test $pkg ---"
        odin test "$pkg"
    done

# Remove build artefacts
clean:
    rm -rf build
