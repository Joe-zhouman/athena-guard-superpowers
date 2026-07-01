#!/usr/bin/env bash
# Bootstrap installer for athena-superpowers (linux/macOS).
# You run this BEFORE having the repo — it asks where to clone, clones from
# GitHub, keeps it (git-pullable for updates), then runs the repo's install.sh.
#
# Re-run any time to update (git pull + reinstall).
#
# Usage:
#   bash get.sh                    # interactive: asks for clone folder
#   bash get.sh --clone-root PATH  # non-interactive: clone under PATH

set -uo pipefail

REPO_URL="https://github.com/Joe-zhouman/athena-guard-superpowers.git"

info() { printf '  \033[36m%s\033[0m\n' "$1"; }
ok()   { printf '  \033[32m[ok]\033[0m %s\n' "$1"; }
warn() { printf '  \033[33m[!]\033[0m %s\n' "$1"; }
die()  { printf '  \033[31m[x]\033[0m %s\n' "$1" >&2; exit 1; }

CLONE_ROOT=""
while [[ $# -gt 0 ]]; do
  case "$1" in
    --clone-root) CLONE_ROOT="$2"; shift 2 ;;
    --repo-url)   REPO_URL="$2";   shift 2 ;;
    *) die "unknown arg: $1" ;;
  esac
done

echo
echo "=== athena-superpowers bootstrap ==="
printf '  (clone from GitHub + install into Claude Code)\n'
echo

# --- 0. git ---
command -v git >/dev/null 2>&1 || die "git not found on PATH. Install it and re-run."

# --- 1. ask where to clone (loop until valid) ---
if [[ -z "$CLONE_ROOT" ]]; then
  echo "Step 1 — pick a folder to keep the repo in." | sed 's/^/  /'
  printf '  Paste a folder path you own (e.g. ~ , ~/code, /opt). Empty = use ~ :\n'
  while true; do
    read -r -p "  Folder path (Enter = $HOME): " raw
    raw="${raw/#\~/$HOME}"           # expand leading ~
    raw="${raw//\'/}" ; raw="${raw//\"/}"   # strip quotes from pastes
    [[ -z "$raw" ]] && raw="$HOME"
    if [[ ! -d "$raw" ]]; then
      warn "That folder does not exist: '$raw'"
      printf '      Create it first (mkdir -p), then paste again.\n'
      continue
    fi
    if [[ ! -w "$raw" ]]; then
      warn "Can't write to that folder: '$raw'"
      printf '      Pick a folder you own.\n'
      continue
    fi
    CLONE_ROOT="$raw"
    ok "Using folder: $CLONE_ROOT"
    break
  done
else
  [[ -d "$CLONE_ROOT" && -w "$CLONE_ROOT" ]] || die "--clone-root must be an existing writable folder: '$CLONE_ROOT'"
fi

# --- 2. clone (or update) ---
TARGET="$CLONE_ROOT/athena-superpowers"
echo
echo "Step 2 — get the repo from GitHub." | sed 's/^/  /'

if [[ -d "$TARGET/.git" ]]; then
  info "Found existing clone at $TARGET — updating (git pull)..."
  if ! git -C "$TARGET" pull --ff-only; then
    warn "git pull had conflicts. Left as-is."
    printf '      Resolve in %s, or delete it and re-run to start fresh.\n' "$TARGET"
  fi
else
  info "Cloning into $TARGET ..."
  if ! git clone "$REPO_URL" "$TARGET"; then
    die "git clone failed. Check network / path, then re-run."
  fi
  ok "Cloned"
fi

# --- 3. run the repo's install.sh ---
INSTALL_SCRIPT="$TARGET/install.sh"
[[ -f "$INSTALL_SCRIPT" ]] || die "install.sh not found in $TARGET — clone may be incomplete. Delete $TARGET and re-run."
echo
echo "Step 3 — install into Claude Code (symlink plugin + copy agents)." | sed 's/^/  /'
chmod +x "$INSTALL_SCRIPT"
if ! bash "$INSTALL_SCRIPT"; then
  echo
  die "install.sh failed. Fix the issue above, then re-run — your clone at $TARGET is kept."
fi

echo
ok "Done. The repo is kept at $TARGET — re-run this command any time to update (git pull + reinstall)."
printf '  Start a NEW Claude Code session to load hooks + skills + agents.\n'
echo
warn "Before dispatching sagittarius: its router is tailored to Joe's MCP setup."
printf '     The main agent will walk you through rebuilding it. Structure is\n'
printf '     universal, tool names are not.\n'
echo
