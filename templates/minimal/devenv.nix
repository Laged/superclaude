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

    # Shell & prompt
    zsh
    starship

    # Claude Code (from numtide/llm-agents.nix, auto-updated daily)
    inputs.llm-agents.packages.${pkgs.system}.claude-code
  ];

  # TypeScript language support (adds tsc, tsserver to PATH)
  languages.typescript.enable = true;

  # Environment variables
  env = {
    # Bun cache inside devenv state (not polluting home directory)
    BUN_INSTALL_CACHE_DIR = "${config.env.DEVENV_STATE}/bun-cache";
    # Use project-local starship config
    STARSHIP_CONFIG = "${config.env.DEVENV_ROOT}/starship.toml";
  };

  # Shell hook: init starship + welcome message
  enterShell = ''
    # Initialize starship prompt for the current shell
    if command -v starship &>/dev/null; then
      shell_name="$(basename "$SHELL" 2>/dev/null || echo bash)"
      case "$shell_name" in
        zsh)  eval "$(starship init zsh)" ;;
        bash) eval "$(starship init bash)" ;;
        fish) starship init fish | source ;;
      esac
    fi

    echo ""
    echo "superclaude dev environment"
    echo "  bun:      $(bun --version 2>/dev/null || echo 'unavailable')"
    echo "  tsc:      $(tsc --version 2>/dev/null || echo 'unavailable')"
    echo "  biome:    $(biome --version 2>/dev/null || echo 'unavailable')"
    echo "  claude:   $(claude --version 2>/dev/null || echo 'unavailable')"
    echo "  starship: $(starship --version 2>/dev/null | head -1 || echo 'unavailable')"
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
