# PROJECT_NAME

Bun/TypeScript project with sandboxed Claude Code, powered by [Superclaude](https://github.com/Laged/superclaude).

## Getting Started

```bash
direnv allow          # load the dev environment (or: nix develop --impure)
claude                # start Claude Code (sandboxed)
```

## Commands

| Command | Description |
|---------|-------------|
| `bun test` | Run tests |
| `bun run dev` | Start dev server |
| `biome check --write .` | Format and lint |
| `claude` | Start Claude Code |

## Project Structure

```
src/                  # Source code
  __tests__/          # Tests (co-located)
.claude/              # Claude Code config
  settings.json       # Sandbox configuration
  CLAUDE.md           # Environment docs for Claude
.claude-skills/       # Claude skills (TDD, debugging, code review)
CLAUDE.md             # Project conventions for Claude
```

## Stack

- **Runtime:** [Bun](https://bun.sh)
- **Language:** TypeScript (strict mode)
- **Linting:** [Biome](https://biomejs.dev)
- **Dev environment:** [Nix](https://nixos.org) + [devenv](https://devenv.sh)
- **AI assistant:** [Claude Code](https://docs.anthropic.com/en/docs/claude-code) (sandboxed)
