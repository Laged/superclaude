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

# TEMPLATE_DIR is injected by the Nix flake wrapper (points to /nix/store/...templates/minimal)
if [[ -z "${TEMPLATE_DIR:-}" ]]; then
  error "TEMPLATE_DIR not set. This script must be run via 'nix run github:laged/superclaude -- init'"
  exit 1
fi

info "Creating project: $PROJECT_NAME"

# Copy template (Nix store files are read-only, so we make them writable after copy)
cp -r "$TEMPLATE_DIR" "$PROJECT_NAME"
chmod -R u+w "$PROJECT_NAME"

# Substitute project name in flake.nix
sed "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_NAME/flake.nix" > "$PROJECT_NAME/flake.nix.tmp"
mv "$PROJECT_NAME/flake.nix.tmp" "$PROJECT_NAME/flake.nix"

# Substitute project name in README.md
sed "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_NAME/README.md" > "$PROJECT_NAME/README.md.tmp"
mv "$PROJECT_NAME/README.md.tmp" "$PROJECT_NAME/README.md"

# Substitute project name in package.json
sed "s/PROJECT_NAME/$PROJECT_NAME/g" "$PROJECT_NAME/package.json" > "$PROJECT_NAME/package.json.tmp"
mv "$PROJECT_NAME/package.json.tmp" "$PROJECT_NAME/package.json"

# Set file permissions
info "Setting file permissions..."
chmod 700 "$PROJECT_NAME/.claude"
chmod 600 "$PROJECT_NAME/.claude/settings.json"
chmod 644 "$PROJECT_NAME/.claude/CLAUDE.md"
chmod 644 "$PROJECT_NAME/CLAUDE.md"
chmod 644 "$PROJECT_NAME/.envrc"
chmod 644 "$PROJECT_NAME/flake.nix"
chmod 644 "$PROJECT_NAME/devenv.nix"
chmod 644 "$PROJECT_NAME/README.md"
chmod 644 "$PROJECT_NAME/package.json"
chmod 644 "$PROJECT_NAME/tsconfig.json"
chmod 644 "$PROJECT_NAME/biome.json"

# Initialize git
info "Initializing git repository..."
(
  cd "$PROJECT_NAME"
  git init -q

  # Stage only known template files — NEVER use git add -A
  git add \
    .gitignore \
    .envrc \
    flake.nix \
    devenv.nix \
    package.json \
    tsconfig.json \
    biome.json \
    README.md \
    CLAUDE.md \
    .claude/settings.json \
    .claude/CLAUDE.md \
    .claude-skills/ \
    src/

  # Commit with fallback author if git identity isn't configured
  if git config user.email > /dev/null 2>&1 || [ -n "${GIT_AUTHOR_EMAIL:-}" ]; then
    git commit -q -m "feat: initialize $PROJECT_NAME with superclaude"
  else
    git -c user.name="superclaude" -c user.email="superclaude@init" \
      commit -q -m "feat: initialize $PROJECT_NAME with superclaude"
    info "Committed with placeholder identity. Update with:"
    info "  git config user.email 'you@example.com'"
    info "  git config user.name 'Your Name'"
    info "  git commit --amend --reset-author"
  fi
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
