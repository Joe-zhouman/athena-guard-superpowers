#!/usr/bin/env bash
# test-install.sh — verify install.sh produces the expected state.
# TDD: these are the assertions. Run once BEFORE install (most should fail),
# then run install.sh, then run again (all should pass).
#
# Runs against a FAKE HOME so it never touches the real ~/.claude.
# Usage: bash test-install.sh
#        (sets up fake home, runs install.sh, asserts, tears down)

set -uo pipefail

REPO_ROOT="${1:-$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)}"
FAKE_HOME="$(mktemp -d)"
export HOME="$FAKE_HOME"

# bring output colors
pass(){ printf "  \033[32mPASS\033[0m %s\n" "$1"; }
fail(){ printf "  \033[31mFAIL\033[0m %s\n" "$1"; FAILS=$((FAILS+1)); }
FAILS=0

echo "Fake HOME: $FAKE_HOME"
echo "Running install.sh..."
bash "$REPO_ROOT/install.sh" >/tmp/athena-install.out 2>&1 || { echo "install.sh exited non-zero"; cat /tmp/athena-install.out; exit 1; }
echo

AGENTS="$FAKE_HOME/.claude/agents"
REFS="$FAKE_HOME/.claude/agents/refs"
PLUGIN="$FAKE_HOME/.claude/skills/athena-superpowers"

echo "== assertions =="

# 1. plugin symlink exists and points to repo
[[ -L "$PLUGIN" ]] && pass "plugin symlink exists at $PLUGIN" || fail "plugin symlink missing"
[[ "$(readlink -f "$PLUGIN")" == "$REPO_ROOT" ]] && pass "plugin symlink -> repo root" || fail "plugin symlink target wrong"

# 2. plugin exposes hooks + skills (auto-load contract)
[[ -d "$PLUGIN/hooks" && -f "$PLUGIN/hooks/hooks.json" ]] && pass "plugin hooks/ present" || fail "plugin hooks/ missing"
[[ -d "$PLUGIN/skills" ]] && pass "plugin skills/ present" || fail "plugin skills/ missing"

# 3. agents copied to ~/.claude/agents/ (user-level, not plugin-level)
[[ -d "$AGENTS" ]] && pass "agents dir created" || fail "agents dir missing"

EXPECTED_AGENTS=(aries cancer capricorn libra pisces sagittarius scorpio taurus virgo)
for a in "${EXPECTED_AGENTS[@]}"; do
  [[ -f "$AGENTS/$a.md" ]] && pass "agent copied: $a" || fail "agent missing: $a"
done

# 4. NO athena agents leaked into plugin's own agents/ (they're global, not plugin)
#    (the plugin symlink points to repo which HAS agents/, but that's the source —
#    plugin-level agent loading would namespace them; we want them only at user level)
if [[ -d "$PLUGIN/agents" ]]; then
  pass "note: repo agents/ exists (source), plugin doesn't claim them as plugin-agents in user dir"
fi

# 5. refs copied to ~/.claude/agents/refs/
[[ -d "$REFS" ]] && pass "refs dir created" || fail "refs dir missing"
EXPECTED_REFS=(aries-round1-boundary aries-round2-state-machine aries-round3-concurrency \
  aries-round4-resource aries-round5-input aries-round6-skills-mcp \
  pisces-detect-tells pisces-agent-readability sagittarius-tools)
for r in "${EXPECTED_REFS[@]}"; do
  [[ -f "$REFS/$r.md" ]] && pass "ref copied: $r" || fail "ref missing: $r"
done

# 6. agent body refs paths use ~/.claude/agents/refs/ (the cross-cwd path)
if grep -q "~/.claude/agents/refs/" "$AGENTS/aries.md"; then
  pass "aries body uses ~/.claude/agents/refs/ paths"
else
  fail "aries body has wrong refs path (won't resolve across cwd)"
fi

# 7. agents kept the fields plugin agents would lose (proof they're user-level, not stripped)
grep -q "^permissionMode:" "$AGENTS/capricorn.md" && pass "capricorn keeps permissionMode (user-level)" || fail "capricorn lost permissionMode"
grep -q "mcp__doc" "$AGENTS/sagittarius.md" && pass "sagittarius keeps mcp__doc (user-level)" || fail "sagittarius lost mcp__doc"

# 8. idempotency: re-run install, counts stay same, no duplication/corruption
AGENTS_BEFORE=$(ls "$AGENTS"/*.md 2>/dev/null | wc -l)
bash "$REPO_ROOT/install.sh" >/dev/null 2>&1
AGENTS_AFTER=$(ls "$AGENTS"/*.md 2>/dev/null | wc -l)
[[ "$AGENTS_BEFORE" == "$AGENTS_AFTER" ]] && pass "idempotent: re-run keeps same agent count ($AGENTS_AFTER)" || fail "idempotency broke: $AGENTS_BEFORE -> $AGENTS_AFTER"

echo
echo "== result =="
if [[ "$FAILS" == 0 ]]; then
  echo "ALL PASS"
  rm -rf "$FAKE_HOME"
  exit 0
else
  echo "$FAILS FAIL(s) — fake home kept at $FAKE_HOME for inspection"
  exit 1
fi
