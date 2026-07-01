# athena-guard-superpowers

Personal fork of [obra/superpowers](https://github.com/obra/superpowers) (~5.0.x era).

**What changed from upstream:**
- 9 zodiac-personified guardian subagents in `user-agents/` (capricorn / cancer / scorpio / taurus / libra / virgo / sagittarius / aries / pisces), installed to `~/.claude/agents/` as user-level global agents. Named `user-agents/` (not `agents/`) so @skills-dir plugin auto-discovery won't load them as plugin agents.
- superpowers skill dispatch points rewired to call them by name (no more `general-purpose`)
- 5 core guardians (capricorn/scorpio/taurus/libra) auto-invoked by superpowers flow; cancer triggers on bug reports directly; 4 on-demand (virgo/sagittarius/aries/pisces) dispatched by the main agent when needed
- brainstorming merges grill-me interview style + superpowers design flow; spec phase delegated to new `writing-spec` skill
- libra replaces Self-Review at every gate
- All cross-platform scaffolding (codex/cursor/gemini/copilot/antigravity/pi) removed — this fork is Claude Code only
- Pain-point-driven development philosophy: no pain point → no spec → no code

See `docs/athena/` for the full agent catalog and usage guide.
