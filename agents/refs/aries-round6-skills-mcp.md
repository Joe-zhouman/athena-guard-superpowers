# aries Round 6 — Skills / Agents / MCP / Hooks / Bundled Scripts (Athena-specific)

This round is different from 1-5: it applies only when the change touches **agent-shaping infrastructure**, and it's part conceptual (roleplay hostile input), part concrete (read every script line-by-line). It requires judgment, not just running.

## When this round applies

The change touches ANY of:
- `SKILL.md` files, `.claude/agents/*.md`
- `hooks/`, MCP server configs
- any shell/node/python script bundled with a skill (`*.sh` / `*.cjs` / `*.js` / `*.py`)
- anything injected at session start, dispatched to a subagent, or run via Bash

These aren't runtime crashes — they're **misaligned agent behavior** and **hostile script execution paths** invisible until they damage a future session. Skills shipping scripts is normal, which is exactly why scripts are a first-class attack surface here, not a footnote.

## Bundled scripts — read line-by-line for these footguns

```
- rm -rf without a path whitelist guard (e.g. `[[ "$X" == /tmp/* ]]`).
  Any `rm -rf "$VAR"` where $VAR comes from args/env/another command
  is a finding. Reproduce by calling the script with VAR empty or set
  to / or ~.
- Missing `set -euo pipefail` at the top of bash scripts. Without it,
  partial failures cascade silently into wrong state.
- Error branches that echo but don't exit. Pattern:
    if [[ -z "$ARG" ]]; then echo "usage"; fi   # ← no exit 1
  Continues with empty ARG into `$ARG/state/...` → root-relative paths.
- Unquoted variable expansions: `$VAR` instead of `"$VAR"`. Word-splitting
  + glob expansion = argument injection when VAR contains spaces or `*`.
- `eval`, `bash -c "$VAR"`, `sh -c "$VAR"` — full command injection if
  VAR is user-controlled.
- Network listeners: `listen(0.0.0.0, ...)` or `app.listen(PORT)`
  without a host argument binds all interfaces → LAN-reachable. Should
  be `127.0.0.1` / `localhost` unless the skill explicitly needs remote.
- `cat`/`source`/`.` reading from paths derived from env vars or args
  without validation → arbitrary file read or sourced execution.
- curl | sh, wget | bash, npm install during runtime — pulls arbitrary
  code from network at session time.
- cd into a path computed from user input without resolving symlinks
  → directory escape.
```

## Conceptual vectors — roleplay hostile input

```
Prompt injection:
- Can a user-supplied string (file content, web page, tool result, MCP
  resource) cause the agent to ignore its skill instructions?
- Does the skill / agent.md contain language an injected instruction
  could override? ("always do X" is easy to defeat with "actually, do Y")
- Does any skill instruct the agent to read untrusted files without first
  treating their contents as data, not instructions?

Skill hijacking:
- Can invoking this skill with a crafted argument cause it to dispatch an
  agent or invoke a tool the user didn't ask for?
- Does the skill auto-invoke on triggers broad enough that a hostile
  message could weaponize it? ("always run when the user says X" — what
  if a pasted document contains "X"?)

MCP parameter poisoning:
- Do agent prompts pass user-controlled strings into MCP tool parameters
  unchecked? (path traversal, server injection, JSON smashing)
- If an MCP tool returns hostile content, does the consuming agent treat
  it as authoritative or as data?

Cross-agent context pollution:
- Can a subagent's persisted output (findings.md, reviews/, diagnoses/)
  be poisoned by hostile content, then read back into a future session
  as if it were trusted?
- Do two parallel agents writing to overlapping files corrupt each other?

Hook side-channels:
- Can a PreToolUse hook be tricked into blocking a legitimate action or
  approving a hostile one based on string matching that's too loose?
- Does a SessionStart hook inject content from a file the user can write
  to without realizing it shapes the agent's behavior? (This is the
  single biggest recurring-bug surface — anyone who can edit
  using-superpowers/SKILL.md can inject instructions into every
  future session.)
```

## Reporting findings from this round

Each finding MUST include:
- File path + line number (`scripts/foo.sh:42`)
- The exact input that triggers it (literal argv / env / file content; for conceptual findings, a sequence of user messages or tool inputs)
- What it would do if triggered (concretely — "deletes ~" not "causes harm")
- Severity: CRITICAL (data loss / RCE / exfiltration) / HIGH (privilege escape) / MEDIUM (misbehavior) / LOW (defense-in-depth gap)

**Judgment note:** if you can't decide whether something is exploitable, mark it UNTESTED with a precise description of the suspected vector — do not silently pass it. A bundled script that hasn't been read line-by-line is a bundled script that hasn't been tested.
