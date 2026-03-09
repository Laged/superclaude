{ pkgs, lib, config, inputs, ... }:

{
  # Core development packages
  packages = with pkgs; [
    # Runtime & package management
    bun

    # Development tools
    git
    ripgrep
    fd
    jq
    biome

    # Claude Code (from numtide/llm-agents.nix, auto-updated daily)
    inputs.llm-agents.packages.${pkgs.system}.claude-code
  ];

  # TypeScript language support (adds tsc, tsserver to PATH)
  languages.typescript.enable = true;

  # Environment variables
  env = {
    # Bun cache inside devenv state (not polluting home directory)
    BUN_INSTALL_CACHE_DIR = "${config.env.DEVENV_STATE}/bun-cache";
  };

  # Shell hook: welcome message with tool versions
  enterShell = ''
    echo ""
    echo "superclaude dev environment"
    echo "  bun:    $(bun --version 2>/dev/null || echo 'unavailable')"
    echo "  tsc:    $(tsc --version 2>/dev/null || echo 'unavailable')"
    echo "  biome:  $(biome --version 2>/dev/null || echo 'unavailable')"
    echo "  claude: $(claude --version 2>/dev/null || echo 'unavailable')"
    echo ""
    echo "Commands:"
    echo "  claude              — start Claude Code (sandboxed)"
    echo "  bun test            — run tests"
    echo "  bun run dev         — run the project"
    echo "  biome check .       — lint and format check"
    echo ""
  '';

  # Git hooks (pre-commit)
  git-hooks.hooks = {
    # Detect accidentally committed secrets
    detect-private-keys.enable = true;

    # Biome formatting and linting
    biome = {
      enable = true;
      entry = "${pkgs.biome}/bin/biome check --write --no-errors-on-unmatched";
      types_or = [ "ts" "tsx" "js" "jsx" "json" ];
    };
  };
}
