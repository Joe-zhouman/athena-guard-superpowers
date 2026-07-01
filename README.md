# athena-guard-superpowers

> Personal fork of [obra/superpowers](https://github.com/obra/superpowers) (~5.0.x era), rebuilt for a multi-model, subagent-first workflow with file persistence and zodiac-personified subagents. Claude Code only. A frankenstein stitched together from superpowers, [grill-me](https://github.com/mattpocock/grill-me), and [Oh-My-OpenCode](https://github.com/oh-my-opencode/oh-my-opencode).

Superpowers is a software development methodology for coding agents — composable skills that activate automatically and guide the agent through design, planning, implementation, and review. Upstream assumes you're using Claude models directly, which are smart enough to need minimal hand-holding. This fork assumes a different reality.

## Why This Fork Exists

Upstream Superpowers was built for a world where the coding agent IS Claude — one model, one session, very smart, very expensive. That's not my world. Here's what drove this fork:

### 1. My primary model isn't Claude

I use **GLM-5.2** as my main driver. It's a domestic (Chinese) model with excellent intelligence, deep understanding, and strong task orchestration. But it has constraints:

- **Rate limits** — I can't send requests at high frequency or for long stretches. Concurrency is limited.
- **Quota is expensive** — every token counts, especially for a long session.
- **Context is precious** — I can't afford to re-derive what we figured out last session.

At the same time, GLM-5.2 is genuinely good at *deciding what to do and who should do it*. It's an excellent orchestrator. The obvious answer: make it one.

### 2. Upstream uses general-purpose subagents. I made them specialized.

Upstream superpowers already has a subagent-driven-development workflow — it dispatches `general-purpose` subagents with inline prompt templates for implementation, review, and testing. This works well when the subagent model is Claude, because Claude models are good at reading a long prompt and intuiting what matters.

My subagents aren't Claude. DeepSeek-V4-Flash and DeepSeek-V4-Pro need clearer direction — they do what you say, not what you mean. So I replaced `general-purpose` with 9 specialized subagents, each with a narrow role and a built-in playbook. This idea came from **Oh-My-OpenCode**, which also uses role-specialized subagents instead of one-size-fits-all.

Each agent carries its own discipline: capricorn knows TDD, scorpio knows how to verify spec compliance, aries knows how to break things. No inline prompt template needed — the agent IS the template.

A tiered-model architecture matches cost to task complexity:

| Role | Model | Why |
|------|-------|-----|
| **Orchestrator** (Opus / Fable) | GLM-5.2 | Smart enough to design, decide, and dispatch. Expensive, so it only does the thinking. |
| **Complex worker** (Sonnet) | DeepSeek-V4-Pro | Handles nuanced tasks that need real intelligence — review, debugging, research. |
| **Fast worker** (Haiku) | DeepSeek-V4-Flash | Handles mechanical work — implementation, file ops, test runs. Cheap, fast, capable. |

The orchestrator thinks, the workers do. This keeps GLM-5.2's quota usage manageable while still getting strong results on every task.

This also means agents need more guidance than upstream provides. Claude models intuit what you mean; DeepSeek models do what you say. Every agent in this fork includes **why** explanations — not just "do X" but "do X because Y." The extra tokens in the agent definition pay for themselves by preventing the subagent from going off-script and burning quota on corrections.

### 3. Upstream brainstorming didn't click for me

I prefer [Matt Pocock's grill-me](https://github.com/mattpocock/grill-me) approach — relentless Socratic interviewing where every question carries a recommended answer and decisions resolve one branch at a time. The athena brainstorming skill merges grill-me's interview discipline with superpowers' design flow, plus `grill-with-docs`-style persistence: as terminology crystallizes, it goes into a glossary immediately. The result is a design conversation that leaves a paper trail.

### 4. Context is ephemeral. Files are forever.

Upstream trusts the conversation. I don't. Sessions restart, contexts get truncated, models change. Anything worth knowing should be on disk:

- `docs/superpowers/findings-local.md` — virgo's codebase maps survive across sessions
- `docs/superpowers/findings-external.md` — sagittarius's research doesn't evaporate
- `docs/superpowers/glossary.md` — terminology pinned down during brainstorming is referenceable by every future agent
- `docs/superpowers/specs/` — design documents with rationale (so you know WHY six months later)
- `docs/superpowers/progress.md` — task tracking persists

Every agent that discovers something writes it down. Every agent that needs context reads from disk first. This is not optional — it's wired into the skill definitions.

## What's Different From Upstream

### 9 zodiac-personified subagents: "Athena's Guardians"

Upstream dispatches `general-purpose` subagents with inline prompt templates. Inspired by **Oh-My-OpenCode**'s specialized subagent naming, I wanted something stranger.

Here's a thing I've noticed: every model has a personality. When you give it a role that fits that personality — rather than forcing a personality onto a role — it performs more consistently. The character doesn't fight itself. So instead of starting from job descriptions, I started from character. And for instantly recognizable character archetypes, nothing beats the zodiac.

Each agent is built on the **stereotype of a zodiac sign** — the personality comes first, and the responsibility **grows out of it**. Aries doesn't test because it was assigned "tester"; Aries tests because Aries is impulsive, aggressive, and loves breaking things. Scorpio doesn't review specs because it was assigned "reviewer"; Scorpio reviews specs because Scorpio is suspicious by nature and trusts nothing at face value.

The name **"Athena's Guardians"** (雅典娜的守卫) comes from *Saint Seiya* (圣斗士星矢) — the twelve zodiac warriors who protect Athena. In this fork, the orchestrator (GLM-5.2) is Athena, and the subagents are the guardians she dispatches.

The 6 prompt-template files were deleted. Each agent IS its own personality and playbook.

**Current roster** — some seats at the table are still empty. That's intentional. Not every role has earned its place in the workflow yet, and forcing one in before the need is clear would be the opposite of personality-first design.

| Guardian | Zodiac | Personality → Role |
|----------|--------|-------------------|
| **capricorn** | 摩羯 | Disciplined, methodical, finishes what it starts → **Implementer**: vertical-slice TDD, self-review, commit |
| **scorpio** | 天蝎 | Suspicious, distrustful, nothing escapes scrutiny → **Spec-compliance reviewer**: reads code independently, doesn't trust the implementer's report |
| **taurus** | 金牛 | Stubborn, uncompromising, holds the line on standards → **Code-quality reviewer**: cites file:line for every claim, no exceptions |
| **libra** | 天秤 | Fair, balanced, defaults to trust unless given reason not to → **Plan & spec reviewer**: default is APPROVE, flags only real blockers |
| **cancer** | 巨蟹 | Protective, precise, fixes what's broken without breaking what works → **Bug-fixer**: reads first, reproduces, minimal surgical fix |
| **virgo** | 处女 | Analytical, meticulous, catalogs everything → **Codebase explorer**: maps architecture, traces flows, persists findings to disk |
| **sagittarius** | 射手 | Curious, relentless hunter of knowledge → **External researcher**: library docs, API behavior, cited sources |
| **aries** | 白羊 | Aggressive, impulsive, loves destruction → **Adversarial tester**: boundary values, concurrency chaos, input terrorism |
| **pisces** | 双鱼 | Sensitive to texture, can't stand things that sound wrong → **Text polisher**: de-AI-ification, human-sounding prose |

**Planned but not yet implemented:**

| Guardian | Zodiac | Personality → Role | Status |
|----------|--------|-------------------|--------|
| **leo** | 狮子 | Performer, showman, commands attention → **Frontend / UI specialist**: layouts, animations, visual polish — the part of development that faces the audience | No pressing need yet, but the personality fit is obvious |
| **gemini** | 双子 | Mercurial, restless, ideas collide and mutate → **Idea generator / brainstorm sparring partner**: throws out angles you didn't consider, pivots mid-sentence, keeps the design conversation from settling too early | Same — I don't have a use case that needs this yet |

**Aquarius (水瓶)** — still thinking. No personality→role click yet.

The roster isn't capped at 12. That's the Gold Saints. *Saint Seiya* has Bronze Saints, Silver Saints, and warriors from entirely different pantheons who show up three arcs later. Same principle here: if a workflow need emerges and I can feel which personality would own it naturally, the seat gets added. Twelve is where the archetypes start, not where they end.

### libra replaces Self-Review

Upstream has the main agent review its own output (Self-Review in brainstorming and writing-plans). This fork dispatches **libra** for independent review at every gate. You wrote it — you're not the best reviewer of it.

### brainstorming = superpowers flow + grill-me discipline

The skill still guides design → approval → spec, but the interview phase follows grill-me rules: one question at a time, every question carries a recommended answer, resolve the decision tree branch by branch. Spec writing is delegated to a separate `writing-spec` skill.

### writing-spec: pain-point-driven spec format

A standalone skill (merged from my global `spec-writer`) that enforces pain-point-driven development: no pain point → no spec → no code. Each section of the spec format exists to answer one question in a chain of reasoning. Design rationale must explain WHY, not just WHAT.

### File persistence is mandatory

All agents write findings to `docs/superpowers/`. All skills read from disk before asking the user. This isn't a suggestion — it's wired into every skill definition.

### How the plugin works (and why it's Claude Code only)

The plugin does exactly one thing: it injects a **SessionStart hook** that forces the agent to read `using-superpowers` at the start of every session. That skill is the bootstrap — it teaches the agent how to find and invoke all other skills. Everything else (the 12 skills, the 9 agents, the workflow) is loaded by the skills system itself once the bootstrap runs.

This means the plugin is actually very thin. If you wanted to use these skills with another coding agent, you wouldn't need to port the plugin — you'd just need to get `using-superpowers` into the agent's context at session start. Two ways to do that:

1. **AGENTS.md / CLAUDE.md** — paste the content of `skills/using-superpowers/SKILL.md` directly into the agent's global instructions file. Crude but effective.
2. **Hook mechanism** — if the agent has a SessionStart or equivalent hook, use it to inject `using-superpowers` the same way the Claude Code plugin does.

That said, **this fork does not support other coding agents.** Upstream superpowers targets Claude Code, Codex, Cursor, Gemini CLI, Copilot, OpenCode, and Factory Droid. All of that scaffolding has been stripped out. The skills assume Claude Code's tool set, agent dispatch model, and `@skills-dir` plugin mechanism. Porting to another agent would mean auditing every SKILL.md for harness-specific assumptions — and that work hasn't been done. If you want superpowers on a different agent, use upstream.

### Skill authoring: skill-creator-plus

Upstream bundles `writing-skills`. I use my own **`skill-creator-plus`** (a global user-level skill) for creating and testing skills. That module is not bundled here.

## Install

First, disable upstream Superpowers (both enabled = double hook injection, conflicting instructions):

```json
// in ~/.claude/settings.json
"enabledPlugins": {
  "superpowers@claude-plugins-official": false
}
```

Then:

```bash
git clone git@github.com:Joe-zhouman/athena-guard-superpowers.git ~/athena-guard-superpowers
cd ~/athena-guard-superpowers
bash install.sh        # linux
# .\install.ps1        # windows
```

`install.sh` does two things:
1. Symlinks the repo into `~/.claude/skills/athena-superpowers/` — hooks and skills auto-load via `@skills-dir`
2. Copies the 9 agents into `~/.claude/agents/` as user-level globals — plugin-level agents lose `permissionMode`/`mcpServers`; athena agents need those

Start a new session. See `docs/athena/INSTALL.md` for verification steps.

To uninstall:

```bash
bash uninstall.sh      # linux
# .\uninstall.ps1      # windows
```

## The Workflow

1. **brainstorming** — Activated before any creative work. Reads prior findings from disk, optionally dispatches virgo/sagittarius for context, then grills you (one question at a time, recommended answers, Socratic interview). Presents design for approval. Delegates to writing-spec.
2. **writing-spec** — Formalizes the design into a pain-point-driven spec. Problem → Design Rationale → Implementation Notes → Acceptance. Dispatches libra for review. User approves. Hands off to writing-plans.
3. **writing-plans** — Breaks the spec into bite-sized tasks (2-5 min each) with exact file paths and verification steps. libra reviews. Hands off for execution.
4. **subagent-driven-development** — Fresh `capricorn` subagent per task, each followed by `scorpio` (spec compliance) then `taurus` (code quality). Fast iteration, isolated context per task.
5. **test-driven-development** — RED-GREEN-REFACTOR enforced at the implementation level. Write failing test, watch it fail, write minimal code, watch it pass, commit.
6. **verification-before-completion** — Evidence before assertions. Run the tests, see them pass, then claim done.

The orchestrator (GLM-5.2) handles steps 1-3 (design, spec, plan). Subagents on cheaper models handle steps 4-6 (implementation, testing, review).

## Agent Model Configuration

The tiered architecture requires configuring subagent models. In `~/.claude/settings.json`:

```json
{
  "subagentModels": {
    "haiku": "deepseek-v4-flash",
    "sonnet": "deepseek-v4-pro",
    "opus": "glm-5.2",
    "fable": "glm-5.2"
  }
}
```

The orchestration skills use `opus`/`fable` for design and review. Implementation agents use `haiku` for mechanical work and `sonnet` for tasks that need more intelligence. Adjust to match your own model availability.

## What's Inside

### Skills

**Design & Planning**
- **brainstorming** — Grill-driven design refinement (merges superpowers flow + grill-me interview style)
- **writing-spec** — Pain-point-driven spec with mandatory libra review
- **writing-plans** — Bite-sized implementation plans for subagent execution

**Implementation**
- **subagent-driven-development** — Fresh subagent per task + two-stage review (scorpio → taurus)
- **executing-plans** — Batch execution with checkpoints
- **dispatching-parallel-agents** — Concurrent subagent workflows for independent tasks
- **test-driven-development** — RED-GREEN-REFACTOR with testing anti-patterns reference

**Quality**
- **requesting-code-review** — Pre-review checklist, dispatches taurus
- **receiving-code-review** — Responding to feedback with technical rigor

**Debugging**
- **systematic-debugging** — 4-phase root cause process
- **verification-before-completion** — Evidence before assertions, always

**Infrastructure**
- **using-git-worktrees** — Isolated workspaces for feature work
- **finishing-a-development-branch** — Merge/PR/cleanup decisions

**Meta**
- **using-superpowers** — Bootstraps the skills system at session start

### Agents

All 9 agents live in `user-agents/` and install to `~/.claude/agents/` as user-level globals. Full catalog: `docs/athena/OVERVIEW.md`.

## Pain-Point-Driven Development

This is the design philosophy behind the `writing-spec` skill and the fork as a whole:

1. **Every line of code must solve a real pain point.** If you can't name the pain, you don't need code. The Problem section of every spec is a gate — if it's empty, stop.
2. **Design rationale must explain WHY.** A spec without rationale is a recipe without reasoning. Future maintainers need to know which constraints were deliberate and which were accidental.
3. **Independent review at every gate.** You can't review your own output. libra, scorpio, and taurus exist because self-review is a blind spot.
4. **Write it down or lose it.** Context is ephemeral; files persist. Every discovery, every decision, every review verdict goes to disk.

## Credits

This is a personal fork of [Jesse Vincent](https://blog.fsck.com)'s [Superpowers](https://github.com/obra/superpowers) (~5.0.x era) by [Joe-zhouman](https://github.com/Joe-zhouman). The upstream is an extraordinary piece of work — this fork exists because my constraints (domestic models, rate limits, quota costs) required a different architecture, not because upstream is wrong.

- Upstream: [github.com/obra/superpowers](https://github.com/obra/superpowers)
- Upstream docs: [blog.fsck.com/2025/10/09/superpowers](https://blog.fsck.com/2025/10/09/superpowers/)
- My fork: [github.com/Joe-zhouman/athena-guard-superpowers](https://github.com/Joe-zhouman/athena-guard-superpowers)

## License

MIT — see LICENSE file.
