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
    };
}
