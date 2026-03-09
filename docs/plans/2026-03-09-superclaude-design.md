# Superclaude Design Document

## Purpose

Nix flake template that bootstraps a sandboxed, skill-equipped Claude Code environment for Bun/TypeScript projects. One command to go from zero to a fully configured AI-assisted development setup.

## User Journey

```
# Install Nix (if not installed)
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install

# Create a new project
nix run github:laged/superclaude -- init my-project
cd my-project
direnv allow

# Start developing with Claude
claude
```

## Architecture

### Two Flakes

1. **superclaude repo flake** (`github:laged/superclaude`): Provides the `init` app, templates, and curated skills
2. **Template flake** (what users get): Standalone project flake with devenv, llm-agents.nix, and agent-skills-nix

### Inputs

| Input | Source | Purpose |
|-------|--------|---------|
| nixpkgs | NixOS/nixpkgs/nixpkgs-unstable | Base packages |
| devenv | cachix/devenv | Development environment framework |
| llm-agents | numtide/llm-agents.nix | Claude Code (daily auto-updates) |
| agent-skills | Kyure-A/agent-skills-nix | Skill discovery + deployment |

### Platform Support

- macOS (aarch64-darwin, x86_64-darwin): Claude's Seatbelt sandbox
- Linux (x86_64-linux, aarch64-linux): Claude's bubblewrap sandbox
- WSL2: bubblewrap (same as Linux)

## Repository Structure

```
superclaude/
├── flake.nix              # Main flake: init app + template outputs
├── flake.lock
├── templates/
│   └── minimal/
│       ├── flake.nix      # Template flake with devenv + llm-agents
│       ├── devenv.nix     # Bun, TS, git, ripgrep, fd, claude-code
│       ├── devenv.yaml    # devenv inputs
│       ├── .envrc         # direnv: use flake
│       ├── .gitignore
│       ├── .claude/
│       │   ├── settings.json  # Sandbox: auto-allow, fs/network rules
│       │   └── CLAUDE.md      # Skill creation guide + project setup
│       ├── CLAUDE.md          # Root project conventions
│       └── .claude-skills/    # Placeholder for deployed skills
├── skills/                    # Curated default skills
│   ├── tdd/SKILL.md
│   ├── debugging/SKILL.md
│   └── code-review/SKILL.md
├── lib/
│   └── init.sh            # Init script
└── docs/
    └── setup-guide.md     # Full setup documentation
```

## Generated Project Structure

```
my-project/
├── flake.nix
├── flake.lock
├── devenv.nix
├── devenv.yaml
├── .envrc
├── .gitignore
├── .claude/
│   ├── settings.json      # chmod 600
│   └── CLAUDE.md
├── CLAUDE.md
└── .claude-skills/
```

## Sandboxing Strategy

Uses Claude Code's **built-in sandbox** configured via `.claude/settings.json`:

- **Mode**: `autoAllow: true` (YOLO-ish — sandboxed commands run without prompts)
- **Escape hatch disabled**: `allowUnsandboxedCommands: false`
- **Filesystem**:
  - Write: project directory, `~/.bun`, `~/.cache/biome`, `/tmp`
  - Deny read: `~/.ssh`, `~/.gnupg`, `~/.aws/credentials`, `~/.config/gh`
  - Deny write: `~/.ssh`, `~/.gnupg`, `~/.aws`, `~/.config`
- **Network**: Allowlist — npm registry, bun.sh, github.com, anthropic API
- **Excluded commands**: `docker` (incompatible with sandbox)

### Security Rules (permissions.deny)

- No destructive operations: `rm -rf /`, `rm -rf ~`, `chmod 777`
- No reading SSH keys or AWS credentials
- No editing SSH/AWS config files

## CLAUDE.md Defaults

Root-level conventions document covering:

- Security: never commit secrets, use .env.example
- Code quality: strict TS, Biome formatting, bun test
- Git discipline: conventional commits, no force-push
- Architecture: simplicity, flat files, co-location
- Error handling: read errors fully, check existing patterns

## Skills Management

- **Framework**: agent-skills-nix (Kyure-A/agent-skills-nix)
- **Bundled defaults**: TDD, systematic debugging, code review
- **Deployment**: `nix run .#skills-install-local` or automatic via devenv shell hook
- **Custom skills**: Users create `skills/<name>/SKILL.md` and deploy

## devenv.nix Configuration

Packages: bun, git, ripgrep, fd, jq, biome, claude-code (from llm-agents)

Languages: `languages.typescript.enable = true`

Pre-commit hooks:
- biome check (ts, tsx, js, jsx, json)
- detect-private-keys

Shell hook: prints versions, deploys skills

## Init Script Behavior

1. Validate project name argument
2. Copy templates/minimal/ to ./project-name/
3. Substitute PROJECT_NAME in flake.nix
4. Set file permissions (600 for settings, 700 for .claude/)
5. Run `git init`
6. Run `nix flake lock`
7. Print next-steps instructions

## Key Design Decisions

1. **Claude built-in sandbox over external wrappers**: Anthropic maintains the sandbox, it handles both macOS (Seatbelt) and Linux (bubblewrap), and it integrates with Claude's permission system natively.

2. **devenv over plain nix develop**: Higher-level abstractions for languages, pre-commit hooks, processes, and environment variables. Less Nix boilerplate.

3. **agent-skills-nix for skill management**: Nix-native discovery, declarative selection, multi-agent support (not just Claude), proper deployment pipeline.

4. **Minimal template**: Users add their own project structure. Superclaude provides the development environment and tooling, not application scaffolding.

5. **Determinate Systems installer**: Flakes enabled by default, clean uninstall, Rust-based reliability, cross-platform.

## References

- [numtide/llm-agents.nix](https://github.com/numtide/llm-agents.nix)
- [Kyure-A/agent-skills-nix](https://github.com/Kyure-A/agent-skills-nix)
- [Claude Code Sandboxing Docs](https://code.claude.com/docs/en/sandboxing)
- [devenv.sh](https://devenv.sh)
- [Determinate Systems Nix Installer](https://determinate.systems/nix-installer/)
- [archie-judd/agent-sandbox.nix](https://github.com/archie-judd/agent-sandbox.nix)
- [Flake Schemas](https://determinate.systems/blog/introducing-flake-schemas/)
- [Claude Code LSP](https://karanbansal.in/blog/claude-code-lsp/)
