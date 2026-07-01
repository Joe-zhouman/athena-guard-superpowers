#!/usr/bin/env bash
# install.sh — install athena-superpowers (linux)
#
# What this does:
#   1. Plugins the repo at ~/.claude/skills/athena-superpowers/ via symlink,
#      so CC's @skills-dir mechanism auto-loads the plugin's HOOKS and SKILLS.
#   2. COPIES the agents (+ refs/) into ~/.claude/agents/, as USER-LEVEL
#      global agents — not plugin agents. This is deliberate: plugin agents
#      have hooks/mcpServers/permissionMode stripped for security, and athena
#      agents need those (capricorn's acceptEdits, sagittarius's mcp__doc).
#      Global user-level agents keep full capabilities.
#
# Why copy (not symlink) for agents: file names are stable, so re-running
# this script just overwrites — that IS the update. Copy avoids broken
# symlinks if the user moves or deletes the cloned repo.
#
# Why symlink for the plugin: hooks + skills have no field restrictions,
# and symlink means editing the repo updates the plugin immediately.
#
# Idempotent: safe to re-run. Overwrites agents, refreshes symlink.
# Run from anywhere; resolves the repo root from this script's location.

set -euo pipefail

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

# --- platform guard (win gets its own install.ps1; macOS deferred) ---
OS="$(uname -s)"
if [[ "$OS" != "Linux" ]]; then
  echo "ERROR: this install.sh is for Linux (got $OS)." >&2
  echo "       Windows: use install.ps1. macOS: not yet supported." >&2
  exit 1
fi

echo "Installing athena-superpowers from: $REPO_ROOT"
echo

# --- 1. plugin (hooks + skills) via @skills-dir symlink ---
mkdir -p "$SKILLS_DIR"
if [[ -L "$PLUGIN_LINK" ]]; then
  # existing symlink — repoint to current repo (handles repo moved/relocated)
  rm "$PLUGIN_LINK"
elif [[ -e "$PLUGIN_LINK" ]]; then
  echo "WARNING: $PLUGIN_LINK exists and is not a symlink." >&2
  echo "         Backing it up to ${PLUGIN_LINK}.bak and replacing with symlink." >&2
  mv "$PLUGIN_LINK" "${PLUGIN_LINK}.bak"
fi
ln -s "$REPO_ROOT" "$PLUGIN_LINK"
echo "[plugin]  symlinked $PLUGIN_LINK -> $REPO_ROOT"
echo "          hooks + skills auto-load next session (@skills-dir)"

# --- 2. agents (user-level global, full capabilities) ---
mkdir -p "$AGENTS_DIR" "$AGENTS_REFS_DIR"

agent_count=0
for agent in "$REPO_ROOT"/user-agents/*.md; do
  [[ -f "$agent" ]] || continue
  cp "$agent" "$AGENTS_DIR/"
  agent_count=$((agent_count + 1))
done

ref_count=0
for ref in "$REPO_ROOT"/user-agents/refs/*.md; do
  [[ -f "$ref" ]] || continue
  cp "$ref" "$AGENTS_REFS_DIR/"
  ref_count=$((ref_count + 1))
done

echo "[agents]  copied $agent_count agents -> $AGENTS_DIR"
echo "[refs]    copied $ref_count refs -> $AGENTS_REFS_DIR"
echo "          (user-level: global, no field restrictions)"

echo
echo "Done. To activate:"
echo "  1. Start a NEW Claude Code session (hooks/skills load at session start)."
echo "  2. Verify plugin:    /plugin   (should list athena-superpowers@skills-dir)"
echo "  3. Verify an agent:  dispatch @capricorn or check the agent list."
echo
echo "Update later: git pull && bash install.sh   (re-running overwrites agents)"
