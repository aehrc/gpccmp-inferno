#!/bin/sh
# Bootstrap a new Inferno test kit from the beda-software template.
#
# Usage:
#   ./create.sh                   — prompts for project name
#   ./create.sh my-test-kit       — uses the supplied name
#   ./create.sh my-test-kit --no-wizard  — skip the configuration wizard
#
# Requirements: git (wizard also needs Docker OR local Ruby ≥ 3.1 + thor gem)

set -e

TEMPLATE_REPO="https://github.com/beda-software/inferno-suite-template.git"
TEMPLATE_BRANCH="main"

# ── helpers ──────────────────────────────────────────────────────────────────

info()  { printf '\033[1;34m  → %s\033[0m\n' "$*"; }
ok()    { printf '\033[1;32m  ✓ %s\033[0m\n' "$*"; }
warn()  { printf '\033[1;33m  ! %s\033[0m\n' "$*"; }
die()   { printf '\033[1;31mError: %s\033[0m\n' "$*" >&2; exit 1; }

command -v git >/dev/null 2>&1 || die "git is not installed."

# ── parse arguments ───────────────────────────────────────────────────────────

PROJECT_DIR=""
RUN_WIZARD=true

for arg in "$@"; do
  case "$arg" in
    --no-wizard) RUN_WIZARD=false ;;
    --*)         die "Unknown option: $arg" ;;
    *)           PROJECT_DIR="$arg" ;;
  esac
done

# ── prompt for project name if not supplied ───────────────────────────────────

if [ -z "$PROJECT_DIR" ]; then
  printf 'Project directory name (e.g. my-test-kit): '
  read -r PROJECT_DIR
  [ -z "$PROJECT_DIR" ] && die "Project name cannot be empty."
fi

[ -e "$PROJECT_DIR" ] && die "'$PROJECT_DIR' already exists."

# ── clone ─────────────────────────────────────────────────────────────────────

info "Cloning template into '$PROJECT_DIR'…"
git clone --depth 1 --branch "$TEMPLATE_BRANCH" "$TEMPLATE_REPO" "$PROJECT_DIR"

info "Removing template git history…"
rm -rf "$PROJECT_DIR/.git"
git -C "$PROJECT_DIR" init --quiet
git -C "$PROJECT_DIR" add --all
git -C "$PROJECT_DIR" commit --quiet -m "Initial commit from inferno-suite-template"

ok "Template downloaded to '$PROJECT_DIR'"

# ── run wizard ────────────────────────────────────────────────────────────────

if [ "$RUN_WIZARD" = true ]; then
  printf '\nRun the configuration wizard now? [Y/n] '
  read -r answer
  case "$answer" in
    [nN]*) ;;
    *)
      cd "$PROJECT_DIR"
      if command -v docker >/dev/null 2>&1 && docker info >/dev/null 2>&1; then
        info "Starting wizard via Docker…"
        sh bin/setup.sh
      elif command -v ruby >/dev/null 2>&1; then
        info "Starting wizard via local Ruby…"
        gem install thor --no-document --quiet
        ruby bin/wizard
      else
        warn "Neither Docker nor Ruby found — skipping wizard."
        warn "Run './bin/setup.sh' (Docker) or 'ruby bin/wizard' (Ruby) manually."
      fi
      ;;
  esac
fi

# ── done ──────────────────────────────────────────────────────────────────────

printf '\n'
ok "Done! Next steps:"
printf '    cd %s\n' "$PROJECT_DIR"
printf '    # place your IG package at lib/<kit_name>/igs/<version>.tgz\n'
printf '    make setup   # pull images and run DB migrations\n'
printf '    make run     # start the full stack\n'
printf '\n'
