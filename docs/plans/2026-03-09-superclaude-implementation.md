# Superclaude Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Build a Nix flake template that bootstraps sandboxed, skill-equipped Claude Code for Bun/TS projects via `nix run github:laged/superclaude -- init my-project`.

**Architecture:** Two-flake design — the superclaude repo provides an init app and flake template. The generated project flake pulls in devenv (Bun/TS tooling), numtide/llm-agents.nix (Claude Code), and agent-skills-nix (skill management). Sandboxing uses Claude's built-in sandbox configured via settings.json.

**Tech Stack:** Nix flakes, devenv, Bun, TypeScript, Claude Code, agent-skills-nix

---

### Task 1: Root .gitignore

**Files:**
- Create: `.gitignore`

**Step 1: Write .gitignore**

```gitignore
result
result-*
.direnv/
.devenv/
.devenv.flake.nix
devenv.lock
.pre-commit-config.yaml
node_modules/
*.log
.env
.env.local
```

**Step 2: Commit**

```bash
git add .gitignore
git commit -m "chore: add root .gitignore"
```

---

### Task 2: Template .gitignore

**Files:**
- Create: `templates/minimal/.gitignore`

**Step 1: Write template .gitignore**

This is the .gitignore that ships with generated projects. It covers Nix, devenv, Bun, Node, and common editor artifacts.

```gitignore
# Nix
result
result-*
.direnv/
.devenv/
.devenv.flake.nix
devenv.lock
.pre-commit-config.yaml

# Dependencies
node_modules/
bun.lockb

# Environment
.env
.env.local
.env.*.local

# Build
dist/
out/
build/
*.tsbuildinfo

# OS
.DS_Store
Thumbs.db

# Editor
.idea/
.vscode/
*.swp
*.swo
*~

# Test
coverage/

# Logs
*.log
npm-debug.log*
```

**Step 2: Commit**

```bash
git add templates/minimal/.gitignore
git commit -m "chore: add template .gitignore"
```

---

### Task 3: Template CLAUDE.md (root project conventions)

**Files:**
- Create: `templates/minimal/CLAUDE.md`

**Step 1: Write CLAUDE.md**

This is the root-level conventions file that teaches Claude (and newcomers) how to work in this project. Every rule here is a sane default that doubles as documentation.

```markdown
# Project Guidelines

## Security — Non-Negotiable
- NEVER commit secrets, API keys, tokens, or credentials to git
- NEVER write .env files with real values — use .env.example with placeholders
- NEVER expose internal URLs, IPs, or infrastructure details in code or comments
- ALWAYS check `git diff --staged` before every commit for accidental secret inclusion
- NEVER read or access ~/.ssh, ~/.gnupg, ~/.aws — the sandbox blocks this, but don't try

## Code Quality
- Bun is the runtime and package manager — not npm, yarn, or pnpm
- TypeScript strict mode is mandatory — no `any`, no `@ts-ignore`, no `@ts-expect-error`
- Format and lint with Biome — no Prettier, no ESLint
- Tests go in `__tests__/` directories co-located with source files
- Use `bun test` for testing — no Jest, no Vitest

## Git Discipline
- Conventional commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`
- One logical change per commit — small, focused commits
- Never force-push to main or shared branches
- Never amend commits that have been pushed
- Write commit messages that explain WHY, not just WHAT

## Architecture Principles
- Keep it simple — no premature abstractions
- Prefer flat file structures over deep nesting
- Co-locate related files (component + test + types in same directory)
- No unused code — delete it, don't comment it out
- No barrel files (index.ts re-exports) unless there's a clear public API boundary

## When Stuck
- Read the full error message before guessing at fixes
- Check existing code for patterns before inventing new ones
- Ask the user rather than making assumptions about requirements
- Run the tests before and after every change
```

**Step 2: Commit**

```bash
git add templates/minimal/CLAUDE.md
git commit -m "feat: add template CLAUDE.md with project conventions"
```

---

### Task 4: Template .claude/settings.json (sandbox config)

**Files:**
- Create: `templates/minimal/.claude/settings.json`

**Step 1: Write settings.json**

This configures Claude Code's built-in sandbox for auto-allow mode with restrictive filesystem and network rules.

```json
{
  "sandbox": {
    "enabled": true,
    "autoAllow": true,
    "allowUnsandboxedCommands": false,
    "filesystem": {
      "allowWrite": [
        "~/.bun",
        "~/.cache/biome",
        "//tmp"
      ],
      "denyRead": [
        "~/.ssh",
        "~/.gnupg",
        "~/.aws/credentials",
        "~/.config/gh/hosts.yml"
      ],
      "denyWrite": [
        "~/.ssh",
        "~/.gnupg",
        "~/.aws",
        "~/.config"
      ]
    },
    "network": {
      "allowedDomains": [
        "registry.npmjs.org",
        "bun.sh",
        "api.anthropic.com",
        "github.com",
        "raw.githubusercontent.com",
        "objects.githubusercontent.com"
      ]
    },
    "excludedCommands": [
      "docker",
      "podman",
      "sudo"
    ]
  },
  "permissions": {
    "deny": [
      "Bash(rm -rf /)",
      "Bash(rm -rf ~)",
      "Bash(chmod 777 *)",
      "Bash(:(){ :|:& };:)",
      "Edit(~/.ssh/*)",
      "Edit(~/.aws/*)",
      "Edit(~/.gnupg/*)",
      "Edit(~/.bashrc)",
      "Edit(~/.zshrc)",
      "Read(~/.ssh/id_*)",
      "Read(~/.aws/credentials)"
    ]
  }
}
```

**Step 2: Commit**

```bash
git add templates/minimal/.claude/settings.json
git commit -m "feat: add sandbox settings.json with auto-allow + restrictive rules"
```

---

### Task 5: Template .claude/CLAUDE.md (skill creation guide)

**Files:**
- Create: `templates/minimal/.claude/CLAUDE.md`

**Step 1: Write .claude/CLAUDE.md**

This file provides Claude with project-specific context about the development environment and how to create skills.

```markdown
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
```

**Step 2: Commit**

```bash
git add templates/minimal/.claude/CLAUDE.md
git commit -m "feat: add .claude/CLAUDE.md with environment docs and skill guide"
```

---

### Task 6: Template .envrc

**Files:**
- Create: `templates/minimal/.envrc`

**Step 1: Write .envrc**

```bash
if ! has nix_direnv_version || ! nix_direnv_version 3.0.6; then
  source_url "https://raw.githubusercontent.com/nix-community/nix-direnv/3.0.6/direnvrc" "sha256-RYcUJaRMf8oF49ylagY9iRerV7g0hfhE0wjY1FTMVUQ="
fi

use flake . --impure
```

**Step 2: Commit**

```bash
git add templates/minimal/.envrc
git commit -m "feat: add .envrc for direnv integration"
```

---

### Task 7: Template devenv.nix

**Files:**
- Create: `templates/minimal/devenv.nix`

**Step 1: Write devenv.nix**

This is the core development environment configuration. It provides all tools needed for Bun/TS development plus Claude Code.

```nix
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
    echo "  bun run dev         — start dev server (if configured)"
    echo "  biome check --write — format and lint"
    echo ""
  '';

  # Pre-commit hooks
  pre-commit.hooks = {
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
```

**Step 2: Commit**

```bash
git add templates/minimal/devenv.nix
git commit -m "feat: add devenv.nix with Bun/TS toolchain and Claude Code"
```

---

### Task 8: Template flake.nix (what users get)

**Files:**
- Create: `templates/minimal/flake.nix`

**Step 1: Write template flake.nix**

This is the flake that generated projects get. It wires together devenv, llm-agents.nix, and agent-skills-nix.

```nix
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
```

**Step 2: Commit**

```bash
git add templates/minimal/flake.nix
git commit -m "feat: add template flake.nix with devenv + llm-agents"
```

---

### Task 9: Template devenv.yaml

**Files:**
- Create: `templates/minimal/devenv.yaml`

**Step 1: Write devenv.yaml**

devenv.yaml is an alternative to flake inputs for specifying devenv dependencies. Since we're using flakes directly, this file is minimal.

```yaml
inputs:
  nixpkgs:
    url: github:NixOS/nixpkgs/nixpkgs-unstable
```

**Step 2: Commit**

```bash
git add templates/minimal/devenv.yaml
git commit -m "feat: add template devenv.yaml"
```

---

### Task 10: Curated Default Skills

**Files:**
- Create: `skills/tdd/SKILL.md`
- Create: `skills/debugging/SKILL.md`
- Create: `skills/code-review/SKILL.md`

**Step 1: Write TDD skill**

```markdown
---
name: tdd
description: Use when implementing any feature or fixing any bug. Write failing tests first, then minimal implementation, then refactor.
---

# Test-Driven Development

## When to Use
Before writing ANY implementation code. Every feature, bugfix, or refactor starts with a test.

## Process

1. **Write a failing test** that describes the expected behavior
2. **Run the test** — confirm it fails for the right reason
3. **Write minimal code** to make the test pass — nothing more
4. **Run the test** — confirm it passes
5. **Refactor** if needed — tests must still pass
6. **Commit** — one logical change per commit

## Commands

```bash
bun test                      # Run all tests
bun test --watch              # Watch mode
bun test path/to/test.ts      # Run specific test file
```

## Key Principles

- Red, green, refactor — always in this order
- Tests describe BEHAVIOR, not implementation
- One assertion per test when possible
- Test names read like sentences: "should return empty array when no items match"
- Never write implementation code without a failing test first
- If you can't write a test for it, the design needs to change
```

**Step 2: Write debugging skill**

```markdown
---
name: debugging
description: Use when encountering any bug, test failure, or unexpected behavior. Systematic diagnosis before proposing fixes.
---

# Systematic Debugging

## When to Use
When something isn't working as expected. Before guessing at fixes.

## Process

1. **Reproduce** — get a consistent reproduction case
2. **Read the error** — read the FULL error message, stack trace, and context
3. **Isolate** — narrow down to the smallest failing case
4. **Hypothesize** — form a specific theory about the cause
5. **Verify** — test your hypothesis with a targeted experiment
6. **Fix** — make the minimal change that addresses the root cause
7. **Verify fix** — run the original reproduction case + full test suite

## Key Principles

- NEVER guess-and-check — form a hypothesis first
- Read error messages completely before acting
- Check the most recent change first (git diff, git log)
- Binary search: if unsure where the bug is, bisect
- One change at a time — verify after each change
- Fix the root cause, not the symptom
- Add a regression test for every bug you fix
```

**Step 3: Write code-review skill**

```markdown
---
name: code-review
description: Use when reviewing code changes before committing or when asked to review a PR or diff.
---

# Code Review

## When to Use
Before committing changes. When reviewing diffs or PRs.

## Checklist

1. **Security** — no secrets, no injection vectors, no unsafe operations
2. **Correctness** — does it do what it claims? edge cases handled?
3. **Tests** — are changes tested? do existing tests still pass?
4. **Simplicity** — is this the simplest solution? any unnecessary complexity?
5. **Naming** — are names descriptive and consistent with codebase conventions?
6. **Types** — strict TypeScript? no `any`? no type assertions without justification?
7. **Error handling** — are errors handled at the right level? meaningful messages?
8. **Performance** — any obvious N+1 queries, unnecessary re-renders, or memory leaks?

## Key Principles

- Review the DIFF, not the whole file — focus on what changed
- Every comment should be actionable
- Distinguish between "must fix" and "nice to have"
- If you're unsure about a change, say so — don't silently approve
- Check that tests actually test the behavior, not just that they exist
```

**Step 4: Commit**

```bash
git add skills/
git commit -m "feat: add curated default skills (TDD, debugging, code review)"
```

---

### Task 11: Init Script

**Files:**
- Create: `lib/init.sh`

**Step 1: Write init.sh**

This is the script that `nix run github:laged/superclaude -- init my-project` executes.

```bash
#!/usr/bin/env bash
set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

info() { echo -e "${BLUE}${BOLD}[superclaude]${NC} $1"; }
success() { echo -e "${GREEN}${BOLD}[superclaude]${NC} $1"; }
error() { echo -e "${RED}${BOLD}[superclaude]${NC} $1" >&2; }

usage() {
  echo "Usage: superclaude init <project-name>"
  echo ""
  echo "Create a new Bun/TypeScript project with sandboxed Claude Code."
  echo ""
  echo "Arguments:"
  echo "  project-name    Name for the new project directory (required)"
  echo ""
  echo "Examples:"
  echo "  superclaude init my-api"
  echo "  superclaude init cool-app"
  exit 1
}

# Parse arguments
COMMAND="${1:-}"
PROJECT_NAME="${2:-}"

if [[ "$COMMAND" != "init" ]]; then
  error "Unknown command: $COMMAND"
  usage
fi

if [[ -z "$PROJECT_NAME" ]]; then
  error "Project name is required"
  usage
fi

# Validate project name (alphanumeric, hyphens, underscores)
if [[ ! "$PROJECT_NAME" =~ ^[a-zA-Z][a-zA-Z0-9_-]*$ ]]; then
  error "Invalid project name: $PROJECT_NAME"
  echo "  Must start with a letter, contain only letters, numbers, hyphens, underscores"
  exit 1
fi

# Check target directory doesn't exist
if [[ -d "$PROJECT_NAME" ]]; then
  error "Directory '$PROJECT_NAME' already exists"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../templates/minimal"

if [[ ! -d "$TEMPLATE_DIR" ]]; then
  error "Template directory not found: $TEMPLATE_DIR"
  exit 1
fi

info "Creating project: $PROJECT_NAME"

# Copy template
cp -r "$TEMPLATE_DIR" "$PROJECT_NAME"

# Substitute project name in flake.nix
sed -i.bak "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_NAME/flake.nix"
rm -f "$PROJECT_NAME/flake.nix.bak"

# Set file permissions
info "Setting file permissions..."
chmod 700 "$PROJECT_NAME/.claude"
chmod 600 "$PROJECT_NAME/.claude/settings.json"
chmod 644 "$PROJECT_NAME/.claude/CLAUDE.md"
chmod 644 "$PROJECT_NAME/CLAUDE.md"
chmod 644 "$PROJECT_NAME/.envrc"
chmod 644 "$PROJECT_NAME/flake.nix"
chmod 644 "$PROJECT_NAME/devenv.nix"

# Create .claude-skills placeholder
mkdir -p "$PROJECT_NAME/.claude-skills"

# Initialize git
info "Initializing git repository..."
(
  cd "$PROJECT_NAME"
  git init -q
  git add -A
  git commit -q -m "feat: initialize $PROJECT_NAME with superclaude"
)

success "Project created: $PROJECT_NAME"
echo ""
echo "Next steps:"
echo ""
echo "  cd $PROJECT_NAME"
echo "  direnv allow          # load the dev environment"
echo "  claude                # start Claude Code (sandboxed)"
echo ""
echo "If you don't have direnv, run:"
echo "  nix develop --impure  # enter the dev shell manually"
echo ""
echo "To install Nix (if needed):"
echo "  curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install"
```

**Step 2: Commit**

```bash
git add lib/init.sh
git commit -m "feat: add init script for project scaffolding"
```

---

### Task 12: Root flake.nix (superclaude repo)

**Files:**
- Create: `flake.nix`

**Step 1: Write flake.nix**

This is the main flake for the superclaude repository. It exposes the init app and templates.

```nix
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
            text = builtins.readFile ./lib/init.sh;
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
```

**Step 2: Commit**

```bash
git add flake.nix
git commit -m "feat: add root flake.nix with init app and templates"
```

---

### Task 13: Setup Guide Documentation

**Files:**
- Create: `docs/setup-guide.md`

**Step 1: Write setup-guide.md**

Complete onboarding documentation from zero to working environment.

The content should cover:
1. Installing Nix via Determinate Systems
2. Installing direnv
3. Creating a new project with `nix run github:laged/superclaude -- init`
4. What the generated project contains
5. Using Claude Code with sandbox
6. Managing skills
7. Updating dependencies
8. Troubleshooting common issues (macOS sandbox-exec, Linux bubblewrap, direnv, network)

Refer to the design doc Section 4 for the full content.

**Step 2: Commit**

```bash
git add docs/setup-guide.md
git commit -m "docs: add comprehensive setup guide"
```

---

### Task 14: Lock the Flake and Verify

**Step 1: Run nix flake lock**

```bash
nix flake lock
```

Expected: Creates `flake.lock` pinning nixpkgs, flake-utils, and llm-agents.

**Step 2: Verify flake evaluates**

```bash
nix flake check
```

Expected: No errors. The flake should evaluate cleanly.

**Step 3: Test the init command**

```bash
cd /tmp
nix run path:/Users/matti.parkkila/Codings/laged/superclaude -- init test-project
ls -la test-project/
ls -la test-project/.claude/
cat test-project/flake.nix | head -5
rm -rf /tmp/test-project
```

Expected: Project created with correct structure, permissions, and substituted project name.

**Step 4: Commit lock file**

```bash
git add flake.lock
git commit -m "chore: lock flake inputs"
```

---

### Task 15: Final Commit and Tag

**Step 1: Review all files**

```bash
git log --oneline
git status
```

**Step 2: Tag initial release**

```bash
git tag -a v0.1.0 -m "Initial release: superclaude template for Bun/TS with sandboxed Claude Code"
```
