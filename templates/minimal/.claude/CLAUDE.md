# Development Environment

This project uses Nix + devenv for reproducible development environments and Claude Code with sandboxed execution.

## Environment

- **Runtime:** Bun (via devenv)
- **Language:** TypeScript (strict mode)
- **Linting/Formatting:** Biome
- **Testing:** bun test
- **Package manager:** bun
- **Sandbox:** Enabled (auto-allow mode) — see .claude/settings.json

## Available Tools in PATH

All tools are provided by devenv. Do not install global packages:
- `bun` — runtime, package manager, test runner, bundler
- `git` — version control
- `rg` (ripgrep) — fast code search
- `fd` — fast file finder
- `jq` — JSON processor
- `biome` — linter and formatter

## Sandbox Boundaries

The sandbox restricts what commands can access:
- **Can write:** project directory, ~/.bun, ~/.cache/biome, /tmp
- **Cannot read:** ~/.ssh, ~/.gnupg, ~/.aws/credentials
- **Cannot write:** ~/.ssh, ~/.gnupg, ~/.aws, ~/.config
- **Network:** only npm registry, bun.sh, github.com, anthropic API
- **Excluded from sandbox:** docker, podman, sudo (will prompt for permission)

## Creating New Skills

Skills are markdown files that give Claude domain expertise for specific tasks.

### Directory Structure

```
skills/
└── my-skill/
    └── SKILL.md
```

### SKILL.md Format

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

### Deploy Skills

```bash
nix run .#skills-install-local
```

Skills are deployed to `.claude-skills/` and automatically picked up by Claude Code.

## File Permissions

- `.claude/settings.json` — chmod 600 (owner read/write only)
- `.claude/` directory — chmod 700 (owner access only)
- These permissions prevent other users/processes from reading sandbox config
