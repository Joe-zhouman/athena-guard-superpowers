# athena-superpowers

Personal fork of [obra/superpowers](https://github.com/obra/superpowers) 5.1.0.

**What changed from upstream:**
- 9 guardian subagents live in `user-agents/` (capricorn / cancer / scorpio / taurus / libra / virgo / sagittarius / aries / pisces), installed to `~/.claude/agents/` as user-level global agents. Renamed from `agents/` to `user-agents/` so @skills-dir plugin auto-discovery won't load them as plugin agents.
- superpowers skill dispatch points rewired to call them (no more `general-purpose`)
- 4 core guardians (capricorn/scorpio/taurus/libra) auto-invoked by superpowers flow; 4 on-demand (virgo/sagittarius/aries/pisces) dispatched by the main agent when needed
- All cross-platform scaffolding (codex/cursor/gemini/copilot/antigravity/pi) removed — this fork is Claude Code only

See `docs/athena/` for the full agent catalog and usage guide.
