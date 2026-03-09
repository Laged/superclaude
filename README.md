# Superclaude

Sandboxed Claude Code environments for Bun/TypeScript development, powered by Nix.

## Quick Start

```bash
# Install Nix (if needed)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Create a new project
nix run github:Laged/superclaude -- init my-project

# Enter the project
cd my-project
direnv allow    # or: nix develop --impure
claude          # start Claude Code
```

## What You Get

- **Bun + TypeScript** with strict mode, Biome linting, and `bun test`
- **Claude Code** from [numtide/llm-agents.nix](https://github.com/numtide/llm-agents.nix) with daily auto-updates
- **Sandboxed execution** via Claude's built-in sandbox configured through `.claude/settings.json`
- **Bundled skills** for TDD, debugging, and code review
- **Reproducible dev environment** via [Nix](https://nixos.org) + [devenv](https://devenv.sh)
- **Pre-commit hooks** for secret detection and Biome formatting

## Requirements

- [Nix](https://nixos.org) with flakes enabled (the [Determinate Systems installer](https://determinate.systems/nix-installer/) enables flakes by default)
- [direnv](https://direnv.net) + [nix-direnv](https://github.com/nix-community/nix-direnv) (recommended, not required)

## Documentation

- [Setup Guide](docs/setup-guide.md) — detailed installation and configuration
- [Design Document](docs/plans/2026-03-09-superclaude-design.md) — architecture and decisions

## How It Works

`nix run github:Laged/superclaude -- init <name>` copies a minimal template and substitutes the project name. The generated project is a standalone Nix flake — no runtime dependency on this repo.

The template includes:
- `flake.nix` + `devenv.nix` — reproducible dev shell with all tools
- `.claude/settings.json` — sandbox configuration (auto-allow mode, filesystem/network restrictions)
- `.claude-skills/` — bundled Claude skills
- `CLAUDE.md` — project conventions for Claude
- `package.json`, `tsconfig.json`, `biome.json` — TypeScript/Biome stack
- `src/` — minimal starter code with a passing test

> **Note:** `nix flake init -t github:Laged/superclaude` also works but won't substitute the project name. Use the init script for best results.
