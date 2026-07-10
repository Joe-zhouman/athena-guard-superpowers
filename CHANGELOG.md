# Changelog

All notable changes to **athena-superpowers** are recorded here.
This is a personal fork of [obra/superpowers](https://github.com/obra/superpowers) (~5.1.0 era), Claude Code only.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [0.2.0] — 2026-07-10

First consciously-versioned release. Covers the full history from the initial fork through today's sagittarius redesign and the session-start security reconsideration.

### Added
- **10 zodiac-personified guardian subagents** (`user-agents/`): capricorn / cancer / scorpio / taurus / libra / virgo / sagittarius / aries / aquarius / pisces — installed as user-level global agents (not plugin agents, so they keep full capabilities like `acceptEdits` / `mcp__doc`).
- **Personality-first agent design**: each agent leads with nature/voice, rules after; the agent body carries only persona + self-router, execution flow lives in per-mode `refs/` files (progressive disclosure).
- **aquarius** — the existence auditor ("should this even exist?"), the 10th guardian; one instinct, five tags, dual-lens self-routing ref. Inspired by ponytail.
- **Self-routing ref pattern** (àries round1–6, pisces 2-lens, aquarius, sagittarius QUICK/DEEP): agent judges which lens/mode applies and reads only that ref — the dispatcher doesn't carry method.
- **glossary workflow** (`docs/superpowers/glossary.md`): terms get pinned to disk the moment they crystallize; subagents whose output affects terminology read it; the orchestrator injects terms rather than each agent re-reading.
- **Pain-point-driven development**: no pain point → no spec → no code. `brainstorming` merges grill-me interview style + superpowers design flow, delegates spec to the new `writing-spec` skill.
- **Skills** (forked & adapted): TDD, systematic-debugging, diagnosing-bugs, writing-plans, executing-plans, verification-before-completion, requesting/receiving-code-review, dispatching-parallel-agents, using-git-worktrees, subagent-driven-development, brainstorming, writing-spec, finishing-a-development-branch, prototype. Every core principle and Iron Law now carries a **Why** (the failure mode it guards against).
- **Install scripts**: `install.sh` (Linux) + `get.sh`/`get.ps1` curl bootstrap; agents copied (full caps), plugin symlinked (@skills-dir auto-loads hooks + skills). Idempotent; `uninstall.sh` for Linux + Windows.
- **Matt Pocock complementary skills** bundled (mix-and-match), with corrected attribution.
- **Slash commands**: `/grill-me`, `/discuss-first` — discuss-first is the default posture; grill-me is manual-only.
- **Persistence layer**: virgo → `findings-local.md`, sagittarius → `findings-external.md`, scorpio/taurus/aries/aquarius → `docs/superpowers/reviews/`, cancer → `docs/superpowers/diagnoses/`. Orchestrator specifies paths; agents obey (no hardcoded paths).

### Changed
- **sagittarius split into QUICK / DEEP tiers**: was running its full multi-source research pipeline on every dispatch (a one-line lookup took half an hour). Body slimmed to persona + self-router only (zero execution flow); two self-contained mode refs (`sagittarius-quick.md`, `sagittarius-deep.md`), agent reads only the one it needs. Dispatch instructions (`brainstorming`, `using-superpowers`) now tell the main agent to tag the tier (`quick`/`deep`). *(e758c79)*
- **Review order reversed**: aquarius first (design logic), libra as the final gate (task decomposition only) — libra no longer does spec review. *(defe988, c44ca94, 6c01fd7)*
- **scorpio dispatch slimmed**: stop inlining the full spec/plan into the dispatch prompt. *(4d967b9)*
- **capricorn made stateless** per upstream: stops reading glossary; the orchestrator injects terminology. *(76a8834)*
- **scorpio + taurus moved from per-task to once-at-end** for performance. *(123d4ea)*
- **Chinese-first** for user-facing skill prose (grill-me, discuss-first, handoff); descriptions bilingual where it aids routing.
- **virgo / sagittarius** deliver a structured findings block and have **no Write permission** — the main agent owns persistence. *(e69c2e4, 8e6d6bf, a3f5c45)*
- **sagittarius search router** rewritten as a capability-based router (survives toolset changes); concrete tool calls live in `sagittarius-tools.md` ref, tailored to a personalized MCP setup — the agent walks the user through rebuilding it on first use, never silently overwrites.

### Removed
- **session-start hash-pin guard** (added in c5734d4, removed 02b06db): the guard refused to inject `SKILL.md` when its hash didn't match `hooks/.skill-hash`. **Maintainer decision (2026-07-10): accepted risk.** On a single-user dev machine the threat model doesn't hold (whoever can write `SKILL.md` can also re-pin the hash), and the maintenance cost — re-pinning on every legitimate edit or the hook silently drops skills — outweighed the benefit. Unused `update-skill-hash` / `.skill-hash` kept on disk for reference. See `docs/superpowers/reviews/scripts-audit-adversarial.md` (C1 finding).
- **writing-skills skill** — replaced by the global `skill-creator-plus`.
- **All cross-platform scaffolding** (codex/cursor/gemini/copilot/antigravity/pi) — this fork is Claude Code only. (Cursor/Copilot JSON output paths kept in `session-start` for the few who run it there.)
- **Upstream assets** not relevant to the fork.

### Fixed
- `stop-server.sh` symlink escape via `/tmp/*` whitelist (H1) and related local-attack-surface issues (H2) — from the adversarial scripts audit. *(c5734d4)*
- `brainstorming` "Read the room" now reads `plans/`, distinguishing in-progress vs completed. *(b805915)*
- Handoff no longer copies already-persisted content; completes the superpowers artifacts inventory. *(7cc5e38)*
- scorpio dispatch no longer embeds inline callout in `sagittarius.md`. *(da7ea06)*
- Stale `findings.md` → `findings-local.md` references in virgo + aries ref. *(a49f145)*
- Gemini role corrected (wild-card idea guy, not PM). *(867e27e, e8ba854)*

---

## [0.1.0] — implicit (pre-release development)

The `plugin.json` shipped at `0.1.0` throughout pre-release development (commit `d71ae30`: "version reset, fix stale meta"). No git tag was cut. All work above landed during this period; `0.2.0` is the first tagged release.

---

### History before this fork

This project forked from `obra/superpowers` at the **5.1.0** tag (`8cf5fe3`: "Initial commit: athena-superpowers fork from obra/superpowers 5.1.0"). Everything in this changelog is changes *on top of* that upstream baseline. For upstream history, see the original repository.
