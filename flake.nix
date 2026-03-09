{
  description = "Superclaude — sandboxed Claude Code for Bun/TypeScript development";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    flake-utils.url = "github:numtide/flake-utils";
    llm-agents.url = "github:numtide/llm-agents.nix";
  };

  outputs = { self, nixpkgs, flake-utils, llm-agents, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};
      in
      {
        packages = {
          # The init script as a Nix package
          superclaude-init = pkgs.writeShellApplication {
            name = "superclaude";
            runtimeInputs = with pkgs; [ coreutils gnused git ];
            text = ''
              TEMPLATE_DIR="${./templates/minimal}"
            '' + builtins.readFile ./lib/init.sh;
          };

          # Re-export claude-code for convenience
          claude-code = llm-agents.packages.${system}.claude-code;
        };

        # `nix run github:laged/superclaude -- init my-project`
        apps.default = {
          type = "app";
          program = "${self.packages.${system}.superclaude-init}/bin/superclaude";
        };

        # `nix run github:laged/superclaude#new-with-env -- my-project`
        # Creates a project and opens Ghostty with the dev environment
        apps.new-with-env = {
          type = "app";
          program = toString (pkgs.writeShellScript "superclaude-new-with-env" ''
            set -euo pipefail

            if [ -z "''${1:-}" ]; then
              echo "Usage: nix run github:laged/superclaude#new-with-env -- <project-name>"
              exit 1
            fi

            project_name="$1"

            # Create the project
            ${self.packages.${system}.superclaude-init}/bin/superclaude init "$project_name"

            project_dir="$PWD/$project_name"

            # Find Ghostty
            ${if pkgs.stdenv.hostPlatform.isDarwin then ''
              if [ -x "/Applications/Ghostty.app/Contents/MacOS/ghostty" ]; then
                ghostty_bin="/Applications/Ghostty.app/Contents/MacOS/ghostty"
              elif command -v ghostty &>/dev/null; then
                ghostty_bin=ghostty
              else
                echo ""
                echo "Ghostty not found. Enter the dev shell manually:"
                echo "  cd $project_name && direnv allow"
                exit 0
              fi
            '' else ''
              ghostty_bin=${pkgs.ghostty}/bin/ghostty
            ''}

            # Launch Ghostty with the dev environment
            exec "$ghostty_bin" -e nix develop "$project_dir" --impure --command zsh
          '');
        };
      }
    ) // {
      # Flake templates
      templates = {
        default = {
          path = ./templates/minimal;
          description = "Minimal Bun/TypeScript project with sandboxed Claude Code";
        };
        minimal = {
          path = ./templates/minimal;
          description = "Minimal Bun/TypeScript project with sandboxed Claude Code";
        };
      };
    };
}
