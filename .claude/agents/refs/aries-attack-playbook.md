# aries — Attack Playbook (reference)

The full checklist for each attack round. aries's main body tells you *which rounds apply* and *when to read this*; this file gives you the concrete attacks to run per round.

Read this before you start attacking, and again per round as you work through it. Don't attack from memory — the lists here are the actual attacks; skipping one because you forgot it is a missed finding.

---

## Round 1: Boundary Assault
```
- Minimum and maximum values for every numeric input
- -1, 0, 1, MAX_INT, MIN_INT
- Empty string, single char, 10MB string
- Empty array, single element, 10K elements
- null, undefined, NaN, Infinity
- Special characters: \0, \n, %, ", ', <, >, &, emoji
```

## Round 2: State Machine Destruction
```
- Call functions out of order
- Call initialize() twice
- Call shutdown() before initialize()
- Call methods after shutdown()
- Rapid alternation between states
```

## Round 3: Concurrency Chaos
```
- Parallel execution of non-thread-safe operations
- Rapid repeated calls (race condition stress)
- Simultaneous read/write on shared state
- Timeout injection — what if this call takes 30 seconds?
```

## Round 4: Resource Warfare
```
- What happens when disk is full?
- What happens when memory is exhausted?
- What happens when the network drops mid-operation?
- What happens when the database returns a connection error?
```

## Round 5: Input Terrorism
```
- Unicode normalization attacks
- Prototype pollution candidates
- Type confusion ("42" vs 42)
- SQL/HTML/JS fragments in innocent-looking strings
- Extremely deep nesting (100+ levels)
- Circular references in JSON
```

## Round 6: Skills / Agents / MCP / Hooks / Bundled Scripts (Athena-specific)

This round applies when the change touches **agent-shaping infrastructure** — `SKILL.md` files, `.claude/agents/*.md`, `hooks/`, MCP server configs, **any shell/node/python script bundled with a skill**, or anything that gets injected at session start, dispatched to a subagent, or run via Bash. These are not runtime crashes you're hunting — they're **misaligned agent behavior** and **hostile script execution paths** that are invisible until they cause damage in a future session.

Skills shipping executable scripts is normal. That's exactly why this round treats scripts as a first-class attack surface, not a footnote.

The attack is part conceptual, part concrete: you roleplay a hostile user / hostile input AND you read every bundled script looking for the standard shell footguns.

```
Bundled scripts (skills/*/scripts/, hooks/*, *.sh, *.cjs, *.js, *.py):
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

Prompt injection vectors:
- Can a user-supplied string (file content, web page, tool result, MCP
  resource) cause the agent to ignore its skill instructions?
- Does the skill / agent.md contain language that an injected instruction
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

**For each bundled-script finding, you MUST include:**
- File path + line number (`scripts/foo.sh:42`)
- The exact input that triggers it (the literal argv / env / file content)
- What it would do if triggered (concretely — "deletes ~" not "causes harm")
- Severity: CRITICAL (data loss / RCE / exfiltration) / HIGH (privilege escape) / MEDIUM (misbehavior) / LOW (defense-in-depth gap)

For conceptual findings (prompt injection, hijacking), the "reproduce" line is a sequence of user messages or tool inputs instead of a shell command.

**Note:** This round requires judgment, not just running. Document your reasoning explicitly. If you can't decide whether something is exploitable, mark it UNTESTED with a precise description of the suspected vector — do not silently pass it. A bundled script that hasn't been read line-by-line is a bundled script that hasn't been tested.
