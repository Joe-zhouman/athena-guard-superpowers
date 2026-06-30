# athena-superpowers

Personal fork of [obra/superpowers](https://github.com/obra/superpowers) 5.1.0.

**What changed from upstream:**
- 8 guardian subagents live in `.claude/agents/` (capricorn / scorpio / taurus / libra / virgo / sagittarius / aries / pisces)
- superpowers skill dispatch points rewired to call them (no more `general-purpose`)
- 4 core guardians (capricorn/scorpio/taurus/libra) auto-invoked by superpowers flow; 4 on-demand (virgo/sagittarius/aries/pisces) dispatched by the main agent when needed
- All cross-platform scaffolding (codex/cursor/gemini/copilot/antigravity/pi) removed — this fork is Claude Code only

See `docs/athena/` for the full agent catalog and usage guide.
