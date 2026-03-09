# PROJECT_NAME

Bun/TypeScript project with sandboxed Claude Code, powered by [Superclaude](https://github.com/Laged/superclaude).

## Getting Started

```bash
direnv allow          # load the dev environment (or: nix develop --impure)
claude                # start Claude Code (sandboxed)
```

### One-Command Terminal (optional)

Launch a fully configured [Ghostty](https://ghostty.org) terminal — Nix fetches it automatically:

```bash
nix run .#terminal
```

This opens Ghostty with the project config, zsh, starship prompt, and the full dev environment. No manual install needed.

## Commands

| Command | Description |
|---------|-------------|
| `bun test` | Run tests |
| `bun run dev` | Run the project |
| `bun run check` | Lint check |
| `bun run format` | Auto-fix lint + format |
| `claude` | Start Claude Code |
| `nix run .#terminal` | Launch Ghostty with full dev environment |

## Project Structure

```
src/                  # Source code
  __tests__/          # Tests (co-located)
.claude/              # Claude Code config
  settings.json       # Sandbox configuration
  CLAUDE.md           # Environment docs for Claude
.claude-skills/       # Claude skills (TDD, debugging, code review)
starship.toml         # Starship prompt config
.ghostty              # Ghostty terminal config (reference)
CLAUDE.md             # Project conventions for Claude
```

## Stack

- **Runtime:** [Bun](https://bun.sh)
- **Language:** TypeScript (strict mode)
- **Linting:** [Biome](https://biomejs.dev)
- **Dev environment:** [Nix](https://nixos.org) + [devenv](https://devenv.sh)
- **AI assistant:** [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (sandboxed)
- **Prompt:** [Starship](https://starship.rs) (auto-configured)
- **Shell:** zsh (available via devenv)

## Terminal

`nix run .#terminal` launches [Ghostty](https://ghostty.org) with the project config (`.ghostty`). Nix handles the install — no brew or manual setup needed.

To use Ghostty as your default terminal, copy the config:

```bash
cp .ghostty ~/.config/ghostty/config
```

The dev environment works in any terminal — Ghostty just provides a consistent look across machines.
