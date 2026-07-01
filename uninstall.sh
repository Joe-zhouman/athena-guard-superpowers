#!/usr/bin/env bash
# uninstall.sh — uninstall athena-superpowers (linux)
#
# What this does:
#   1. Removes the ~/.claude/skills/athena-superpowers/ symlink (plugin).
#   2. Removes the 9 athena agents from ~/.claude/agents/ (user-level globals).
#   3. Removes the athena refs from ~/.claude/agents/refs/.
#
# What this does NOT touch:
#   - Other agents or refs you've added to ~/.claude/agents/.
#   - The cloned repo itself (this script lives in it).
#   - Backed-up files (${PLUGIN_LINK}.bak) — you delete those manually.
#
# Idempotent: safe to re-run. Already-removed files are silently skipped.
# Run from anywhere; resolves the repo root from this script's location.

set -uo pipefail

# --- locate repo root (this script lives at repo root) ---
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"

# --- sanity: must be the athena repo ---
if [[ ! -f "$REPO_ROOT/.claude-plugin/plugin.json" ]] || [[ ! -d "$REPO_ROOT/user-agents" ]]; then
  echo "ERROR: $REPO_ROOT does not look like the athena-superpowers repo" >&2
  echo "       (expected .claude-plugin/plugin.json and user-agents/)" >&2
  exit 1
fi

CLAUDE_HOME="${HOME}/.claude"
SKILLS_DIR="$CLAUDE_HOME/skills"
PLUGIN_LINK="$SKILLS_DIR/athena-superpowers"
AGENTS_DIR="$CLAUDE_HOME/agents"
AGENTS_REFS_DIR="$AGENTS_DIR/refs"

# --- platform guard ---
OS="$(uname -s)"
if [[ "$OS" != "Linux" ]]; then
  echo "ERROR: this uninstall.sh is for Linux (got $OS)." >&2
  exit 1
fi

# --- confirmation ---
echo "This will remove:"
echo "  • plugin symlink:  $PLUGIN_LINK"
echo "  • athena agents:   $AGENTS_DIR/{aries,cancer,capricorn,libra,pisces,sagittarius,scorpio,taurus,virgo}.md"
echo "  • athena refs:     $AGENTS_REFS_DIR/{aries-round[1-6]-*,pisces-*,sagittarius-*}.md"
echo "  (other agents/refs in ~/.claude/agents/ are left untouched)"
echo
read -r -p "Proceed? [y/N] " confirm
if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
  echo "Aborted."
  exit 0
fi
echo

removed=0
skipped=0

# --- 1. remove plugin symlink ---
if [[ -L "$PLUGIN_LINK" ]]; then
  rm "$PLUGIN_LINK"
  echo "[plugin]  removed symlink $PLUGIN_LINK"
  removed=$((removed + 1))
elif [[ -e "$PLUGIN_LINK" ]]; then
  echo "WARNING: $PLUGIN_LINK exists but is not a symlink (not removing)." >&2
  skipped=$((skipped + 1))
else
  echo "[plugin]  symlink already gone (nothing to do)"
  skipped=$((skipped + 1))
fi

# --- 2. remove agents (only the ones installed by install.sh) ---
agent_count=0
agent_skipped=0
for agent in "$REPO_ROOT"/user-agents/*.md; do
  [[ -f "$agent" ]] || continue
  agent_name="$(basename "$agent")"
  target="$AGENTS_DIR/$agent_name"
  if [[ -f "$target" ]]; then
    rm "$target"
    agent_count=$((agent_count + 1))
  else
    agent_skipped=$((agent_skipped + 1))
  fi
done
echo "[agents]  removed $agent_count agent(s) from $AGENTS_DIR ($agent_skipped already gone)"

# --- 3. remove refs (only the ones installed by install.sh) ---
ref_count=0
ref_skipped=0
for ref in "$REPO_ROOT"/user-agents/refs/*.md; do
  [[ -f "$ref" ]] || continue
  ref_name="$(basename "$ref")"
  target="$AGENTS_REFS_DIR/$ref_name"
  if [[ -f "$target" ]]; then
    rm "$target"
    ref_count=$((ref_count + 1))
  else
    ref_skipped=$((ref_skipped + 1))
  fi
done
echo "[refs]    removed $ref_count ref(s) from $AGENTS_REFS_DIR ($ref_skipped already gone)"

# --- 4. clean up empty refs dir if we emptied it ---
if [[ -d "$AGENTS_REFS_DIR" ]]; then
  if [[ -z "$(ls -A "$AGENTS_REFS_DIR" 2>/dev/null)" ]]; then
    rmdir "$AGENTS_REFS_DIR"
    echo "[refs]    removed empty directory $AGENTS_REFS_DIR"
  fi
fi

echo
echo "Done. To complete:"
echo "  1. Start a NEW Claude Code session (or /reload-plugins if available)."
echo "  2. Verify: /plugin should no longer list athena-superpowers."
echo "  3. The cloned repo at $REPO_ROOT is still on disk — delete it manually if you want."
echo
echo "To reinstall:  bash install.sh"
