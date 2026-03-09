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
