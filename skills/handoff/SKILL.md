---
name: handoff
description: 把当前对话压缩成一份交接文档给下一个 agent。输入 /handoff 手动触发。
argument-hint: "What will the next session be used for?"
disable-model-invocation: true
---

Write a handoff document summarising the current conversation so a fresh agent can continue the work. Save to the temporary directory of the user's OS - not the current workspace.

Include a "suggested skills" section in the document, which suggests skills that the agent should invoke.

Do not duplicate content already captured on disk. Reference it by path instead of restating it. This includes the project's own artifacts — `docs/superpowers/glossary.md`, `findings-local.md`, `findings-external.md`, `specs/`, and any `plans/` — plus the usual PRDs, ADRs, issues, commits, and diffs. The handoff should hold only what's NOT already on disk: the current open question, what was decided in-conversation but not yet written down, the next concrete step, and which on-disk artifacts the next agent must read first. *Why: restating disk content in the handoff creates a second source of truth — when the file changes and the handoff doesn't, the next agent sees contradictory facts and trusts the stale one. Pointing at the path keeps a single source.*

Redact any sensitive information, such as API keys, passwords, or personally identifiable information.

If the user passed arguments, treat them as a description of what the next session will focus on and tailor the doc accordingly.
