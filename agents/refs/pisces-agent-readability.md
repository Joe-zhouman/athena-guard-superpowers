# pisces — Writing for an agent reader (reference)

Read this when the doc you're refining is consumed primarily by another agent (or when a human-facing doc needs an agent-readable appendix). pisces's body flags *when* this applies; this file is the full playbook.

## Decide who the reader is — this decides the mode

| Doc type | Primary reader | Mode |
|----------|---------------|------|
| `SKILL.md`, agent definitions, hooks docs, internal `docs/superpowers/*` | Another agent (Read/Grep/Skill tools) | **Agent-readable mode** |
| README for an open-source project, CHANGELOG, user-facing help | A human (often scanning, often skeptical of AI smell) | **Human-readable mode** (de-AI protocol applies fully) |
| PR descriptions, commit messages, code comments | Mixed — humans and agents both | Both modes; prioritize the human reader but keep agent-grepability |

When unclear, default to human-readable and add an agent-readable section at the end (see below).

## How an agent reads (this is what you're optimizing for)

An agent does not read top-to-bottom. It reads like you do:
1. **Grep / scan headings** to locate the relevant section. If a heading doesn't match the words the agent would search for, the section is invisible to it.
2. **Decide whether to read deeper** based on the heading + first line. Vague headings waste the agent's budget.
3. **Read the targeted section**, skipping everything else as noise. Surrounding context is not "helpful setup" — it's tokens that dilute the signal.
4. **Extract instructions**, often by pattern: `Never:`, `Always:`, `When X:`, code blocks, tables. Loose prose is harder to act on than structured directives.
5. **Re-read on every session** — agents have no memory between sessions, so the doc is read fresh each time. Repetition that helps a human remember is pure cost to an agent.

## Agent-readability playbook

When the doc is agent-consumed, apply these on top of (sometimes instead of) the de-AI protocol:

- **Headings are the index.** A heading must contain the search terms an agent would grep for. "Important Stuff" is invisible; "## Aries Gate — when to dispatch aries" is findable. Rename vague headings to their function.
- **Front-load the answer in each section.** First line states what the section is and the decision it enables. The agent reads the first line to decide whether to continue — make it decide correctly.
- **Structure beats prose for directives.** `Never:`, `Always:`, `When X → Y`, tables, and code blocks are easier for an agent to act on than a paragraph explaining the same. Don't prose-ify a rule that fits a one-line directive.
- **Cut cross-references that assume linear reading.** "As mentioned above" / "see the previous section" breaks when the agent jumped straight to this section via grep. Each section should stand alone enough to act on, or carry an explicit path ("see `hooks/session-start`").
- **Repetition is noise, not memory aid.** Humans need things said twice; agents read it twice and pay twice. Say it once, in the place an agent will look. (Exception: a one-line summary at the top of a long doc saves the agent from reading the whole thing — that's a feature, not repetition.)
- **Section order doesn't matter much — findability does.** Because agents grep, a section at the end is as reachable as one at the top. Put the summary up front for the humans, but don't agonize over ordering beyond that; spend the effort on headings and self-contained sections instead.
- **Keep the de-AI basics even for agents.** Agents don't care about "delve," but they *do* suffer from hedging ("may potentially need to consider") — vague directives are as hard for an agent to execute as AI-scented prose is for a human to trust. Precision helps both readers.

## The agent-readable section (for human-primary docs)

When a doc is primarily for humans (README, user guide) but will also be consumed by agents, **append a short agent-readable section at the end** — it doesn't disrupt the human reading flow (humans stop before the appendix; agents grep straight to it). It should contain:
- The machine-actionable facts an agent would need (paths, commands, exit codes, dispatch shapes) stated as structured directives, not prose.
- A heading an agent would grep for (e.g. `## For agents`, `## Machine-readable summary`).

Position at the end is fine — agents reach it by grep regardless of where it sits.
