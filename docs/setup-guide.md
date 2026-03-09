# Superclaude Setup Guide

## Prerequisites

- macOS (Apple Silicon or Intel), Linux (x86_64 or aarch64), or WSL2
- Terminal access
- An Anthropic API key (for Claude Code)

## 1. Install Nix

Use the Determinate Systems installer. It enables flakes by default, is written in Rust, and supports clean uninstall.

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

After installation, restart your shell or run `source /etc/bashrc` (bash) / `source /etc/zshrc` (zsh).

Verify:

```bash
nix --version
```

**What the Determinate installer provides over the official installer:**
- Flakes and the `nix` command enabled by default (no manual config)
- Clean uninstall: `/nix/nix-installer uninstall`
- Rust-based — no dependency on Perl or shell script fragility
- Works on macOS, Linux, and WSL2

## 2. Install direnv

direnv auto-loads the dev environment when you `cd` into the project.

```bash
nix profile install nixpkgs#direnv
```

Then add the shell hook. Pick your shell:

**bash** — add to `~/.bashrc`:
```bash
eval "$(direnv hook bash)"
```

**zsh** — add to `~/.zshrc`:
```bash
eval "$(direnv hook zsh)"
```

**fish** — add to `~/.config/fish/config.fish`:
```fish
direnv hook fish | source
```

Restart your shell after adding the hook.

## 3. Create a New Project

```bash
nix run github:laged/superclaude -- init my-project
```

This scaffolds a complete project directory, initializes git, and sets file permissions.

## 4. What the Generated Project Contains

```
my-project/
├── .claude/
│   ├── settings.json     # Sandbox configuration (chmod 600)
│   └── CLAUDE.md         # Dev environment docs + skill creation guide
├── .claude-skills/       # Deployed skills (populated by skills-install-local)
├── CLAUDE.md             # Project conventions (security, code quality, git)
├── .envrc                # direnv config — loads the Nix dev shell
├── .gitignore            # Nix, Node, editor, OS artifacts
├── devenv.nix            # Dev environment: Bun, TS, Biome, Claude Code, etc.
├── devenv.yaml           # nixpkgs input for devenv
└── flake.nix             # Nix flake wiring devenv + llm-agents.nix
```

**Key files:**

- **`flake.nix`** — Defines inputs (nixpkgs, devenv, llm-agents.nix) and outputs (the dev shell). This is what Nix evaluates.
- **`devenv.nix`** — Lists all packages in the dev shell: bun, git, ripgrep, fd, jq, biome, claude-code. Also configures TypeScript language support, environment variables, and pre-commit hooks.
- **`.claude/settings.json`** — Configures Claude Code's sandbox: filesystem restrictions, allowed network domains, excluded commands, and denied operations.
- **`CLAUDE.md`** — Root-level project conventions that Claude reads automatically. Covers security rules, code quality, git discipline, and architecture principles.
- **`.claude/CLAUDE.md`** — Claude-specific context: available tools, sandbox boundaries, and how to create skills.

## 5. Enter the Dev Environment

```bash
cd my-project
direnv allow
```

direnv will build the Nix dev shell on first entry. Subsequent entries are cached and instant.

Without direnv:

```bash
cd my-project
nix develop --impure
```

## 6. Using Claude Code with Sandbox

Claude Code runs inside the dev shell with sandboxing configured via `.claude/settings.json`.

### Sandbox Modes

The template ships with `autoAllow` mode — Claude can run sandboxed commands without prompting, but unsandboxed commands are blocked or require approval.

Key settings in `.claude/settings.json`:

| Setting | Value | Effect |
|---------|-------|--------|
| `sandbox.enabled` | `true` | Sandbox is active |
| `sandbox.autoAllow` | `true` | Sandboxed commands run without prompts |
| `sandbox.allowUnsandboxedCommands` | `false` | Unsandboxed commands are blocked |

### Filesystem Restrictions

- **Write allowed:** Project directory, `~/.bun`, `~/.cache/biome`, `/tmp`
- **Read denied:** `~/.ssh`, `~/.gnupg`, `~/.aws/credentials`, `~/.config/gh/hosts.yml`
- **Write denied:** `~/.ssh`, `~/.gnupg`, `~/.aws`, `~/.config`

### Network Restrictions

Only these domains are accessible:
- `registry.npmjs.org` — npm packages
- `bun.sh` — Bun downloads
- `api.anthropic.com` — Claude API
- `github.com`, `raw.githubusercontent.com`, `objects.githubusercontent.com` — Git operations

### Excluded Commands

`docker`, `podman`, and `sudo` are excluded from the sandbox (they will prompt for explicit permission).

### Starting Claude Code

```bash
claude
```

Claude reads `CLAUDE.md` and `.claude/CLAUDE.md` automatically for project context.

## 7. Managing Skills

Skills are markdown files that give Claude domain expertise for specific tasks.

### Bundled Skills

The superclaude template includes three curated skills:
- **tdd** — Test-driven development workflow
- **debugging** — Systematic bug diagnosis
- **code-review** — Pre-commit code review checklist

### Creating a New Skill

Create a directory under `skills/` with a `SKILL.md` file:

```
skills/
└── my-skill/
    └── SKILL.md
```

SKILL.md format:

```markdown
---
name: my-skill
description: Use when [describe trigger conditions]
---

# Skill Title

## When to Use
Describe when this skill should be activated.

## Process
Step-by-step instructions for Claude to follow.

## Key Principles
Constraints, rules, and non-negotiables.
```

### Deploying Skills

```bash
nix run .#skills-install-local
```

This copies skills into `.claude-skills/` where Claude Code picks them up automatically.

### Updating Bundled Skills

Pull the latest from the superclaude repo and redeploy:

```bash
nix flake update
nix run .#skills-install-local
```

## 8. Updating Dependencies

### Update All Flake Inputs

```bash
nix flake update
```

This updates nixpkgs, devenv, and llm-agents.nix (which tracks daily Claude Code releases).

### Update a Single Input

```bash
nix flake update llm-agents
```

### Pin a Specific Version

Edit `flake.nix` and change the input URL:

```nix
llm-agents.url = "github:numtide/llm-agents.nix/<commit-or-tag>";
```

Then run `nix flake lock --update-input llm-agents`.

## 9. Troubleshooting

### macOS: sandbox-exec errors

Claude Code uses macOS `sandbox-exec` for filesystem/network sandboxing. If you see permission errors:

1. Check `.claude/settings.json` — ensure paths in `allowWrite` are correct
2. Add missing paths to `filesystem.allowWrite`
3. Restart Claude Code after changing settings

### Linux: bubblewrap not found

On Linux, Claude Code uses bubblewrap (`bwrap`) for sandboxing. If it's not available:

```bash
# NixOS
nix profile install nixpkgs#bubblewrap

# Ubuntu/Debian
sudo apt install bubblewrap

# Fedora
sudo dnf install bubblewrap
```

### direnv not loading

Symptoms: entering the project directory doesn't activate the environment.

1. Verify direnv is installed: `which direnv`
2. Verify the shell hook is in your rc file (`~/.bashrc`, `~/.zshrc`, etc.)
3. Run `direnv allow` in the project directory
4. Check `direnv status` for diagnostics

### Network issues in sandbox

If packages fail to download or git operations fail:

1. Check `network.allowedDomains` in `.claude/settings.json`
2. Add the required domain to the allow list
3. For corporate proxies, you may need to add proxy domains

### Nix build failures

```bash
# Clear and rebuild
nix develop --impure --refresh

# Check flake evaluation
nix flake check

# Show detailed build log
nix log <derivation-path>
```

### WSL2 Notes

- Use WSL2, not WSL1 (Nix requires proper Linux kernel support)
- The Determinate installer works on WSL2 out of the box
- Filesystem performance is best when the project lives on the Linux filesystem (`/home/...`), not the Windows mount (`/mnt/c/...`)
- If you see `max_user_watches` errors, increase the limit:
  ```bash
  echo "fs.inotify.max_user_watches=524288" | sudo tee -a /etc/sysctl.conf
  sudo sysctl -p
  ```
