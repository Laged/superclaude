{
  description = "PROJECT_NAME — Bun/TypeScript project with Superclaude";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    devenv = {
      url = "github:cachix/devenv";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-trusted-public-keys = [
      "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ber+6wFslKYB47VQl1sTpXSqLw="
    ];
    extra-substituters = [
      "https://devenv.cachix.org"
      "https://numtide.cachix.org"
    ];
  };

  outputs = { self, nixpkgs, devenv, llm-agents, ... }@inputs:
    let
      systems = [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" "x86_64-darwin" ];
      forEachSystem = f: nixpkgs.lib.genAttrs systems (system: f {
        pkgs = nixpkgs.legacyPackages.${system};
        inherit system;
      });
    in
    {
      devShells = forEachSystem ({ pkgs, system }: {
        default = devenv.lib.mkShell {
          inherit inputs pkgs;
          modules = [ ./devenv.nix ];
        };
      });

      # nix run .#terminal — launch Ghostty with the full dev environment
      # Linux: Ghostty from nixpkgs (automatic)
      # macOS: Ghostty from app bundle or PATH (brew install ghostty)
      apps = forEachSystem ({ pkgs, ... }: {
        terminal = {
          type = "app";
          program = toString (pkgs.writeShellScript "superclaude-terminal" (
            (if pkgs.stdenv.hostPlatform.isDarwin then ''
              if [ -x "/Applications/Ghostty.app/Contents/MacOS/ghostty" ]; then
                ghostty_bin="/Applications/Ghostty.app/Contents/MacOS/ghostty"
              elif command -v ghostty &>/dev/null; then
                ghostty_bin=ghostty
              else
                echo "[superclaude] Ghostty not found."
                echo ""
                echo "  brew install ghostty"
                echo ""
                echo "Or enter the dev shell without Ghostty:"
                echo "  nix develop --impure --command zsh"
                exit 1
              fi
            '' else ''
              ghostty_bin=${pkgs.ghostty}/bin/ghostty
            '') + ''
              project_dir="$PWD"
              exec "$ghostty_bin" -e nix develop "$project_dir" --impure --command zsh
            ''
          ));
        };
      });
    };
}
