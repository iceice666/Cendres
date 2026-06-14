{
  description = "Odin + Raylib game dev environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
        isDarwin = pkgs.stdenv.isDarwin;
        isLinux  = pkgs.stdenv.isLinux;

        # X11-based raylib requires these on Linux
        linuxDeps = with pkgs; [
          libGL
          xorg.libX11
          xorg.libXrandr
          xorg.libXinerama
          xorg.libXcursor
          xorg.libXi
          xorg.libXext
        ];

        # On macOS 26+ (Darwin 25+), odin/ols fail to build from nixpkgs-unstable source
        # because compiler-rt-18 is incompatible with apple-sdk-26. Use homebrew instead:
        #   brew install odin ols
        # On Linux, nix provides everything.
        nativeOdinPkgs = pkgs.lib.optionals isLinux [ pkgs.odin pkgs.ols ];

        mingwPkgs = pkgs.pkgsCross.mingwW64;
      in
      {
        # Native shell — works on macOS, Linux, and NixOS-on-Windows (WSL)
        # macOS: raylib + pkg-config come from nix; odin/ols come from homebrew.
        # Linux: full nix toolchain.
        devShells.default = pkgs.mkShell {
          name = "cendres";

          packages = with pkgs; nativeOdinPkgs ++ [
            raylib
            pkg-config
          ] ++ pkgs.lib.optionals isLinux linuxDeps;

          shellHook = ''
            # macOS: odin/ols are expected from homebrew (brew install odin ols).
            # The nix build of odin is broken on macOS 26 (compiler-rt / apple-sdk-26 mismatch).
            if [ "$(uname)" = "Darwin" ]; then
              BREW_BIN=/opt/homebrew/bin
              [ -d "$BREW_BIN" ] && export PATH="$BREW_BIN:$PATH"
              if ! command -v odin &>/dev/null; then
                echo "⚠  odin not found — run: brew install odin ols"
              fi
            fi
            ODIN_VER=$(odin version 2>/dev/null || echo "not found")
            echo "Odin $ODIN_VER | Raylib ${pkgs.raylib.version}"
          '';
        };

        # Windows cross-compile shell (run from macOS or Linux)
        # Usage: nix develop .#windows
        #   odin build . -target:windows_amd64 -extra-linker-flags:"-L$RAYLIB_WIN -lraylib"
        devShells.windows = pkgs.mkShell {
          name = "cendres-windows";

          packages = [
            pkgs.odin
            pkgs.ols
            mingwPkgs.raylib
            mingwPkgs.stdenv.cc   # x86_64-w64-mingw32-gcc
          ];

          shellHook = ''
            export CC="${mingwPkgs.stdenv.cc}/bin/x86_64-w64-mingw32-gcc"
            export RAYLIB_WIN="${mingwPkgs.raylib}"
            echo "Odin $(odin version) — cross-compile target: windows_amd64"
            echo "Raylib at: $RAYLIB_WIN"
            echo ""
            echo "Build: odin build . -target:windows_amd64 -extra-linker-flags:\"-L\$RAYLIB_WIN/lib -lraylib\""
          '';
        };
      });
}
