---
name: brainstorming
description: "You MUST use this before any creative work - creating features, building components, adding functionality, or modifying behavior. Explores user intent, requirements and design before implementation."
---

# Brainstorming Ideas Into Designs

Help turn ideas into fully formed designs and specs through natural collaborative dialogue.

Start by understanding the current project context, then ask questions one at a time to refine the idea. Once you understand what you're building, present the design and get user approval.

<HARD-GATE>
Do NOT invoke any implementation skill, write any code, scaffold any project, or take any implementation action until you have presented a design and the user has approved it. This applies to EVERY project regardless of perceived simplicity.
</HARD-GATE>

**Why the gate exists:** once code exists, the conversation shifts from "what should we build?" to "is this what you meant?" — and the latter is a much weaker position to design from. Code that's already written exerts gravity: it reframes the discussion around *its* shape, makes the user evaluate specifics instead of intent, and turns every design doubt into a "change this" rather than a "should we even do this." The user approves a design far more honestly when there's nothing concrete to react to yet — they're judging the approach, not defending or critiquing an artifact. Writing code before design isn't a head start; it's locking in assumptions you never got to test. The gate forces the cheap, fast conversation (about intent) to happen before the expensive one (about code).

## Anti-Pattern: "This Is Too Simple To Need A Design"

Every project goes through this process. A todo list, a single-function utility, a config change — all of them. "Simple" projects are where unexamined assumptions cause the most wasted work. The design can be short (a few sentences for truly simple projects), but you MUST present it and get approval.

## Checklist

You MUST create a task for each of these items and complete them in order:

1. **Read the room** — read `docs/superpowers/glossary.md`, `findings-local.md`, `findings-external.md`, and any prior `specs/` if they exist. These reconstruct context from previous sessions. Skip files that don't exist yet.
2. **Explore (dispatch virgo / sagittarius)** — based on what the task needs and what you already know, decide: dispatch virgo for local codebase mapping, sagittarius for external research, both in parallel for cross-domain projects, or neither if you already have enough context. They write to `findings-local.md` / `findings-external.md` respectively.
3. **Offer visual companion** (if topic will involve visual questions) — this is its own message, not combined with a grill question. See the Visual Companion section below.
4. **Grill the user** — relentless interview to sharpen the idea, one question at a time, each with a recommended answer. Resolve terminology into `glossary.md` as it crystallizes. See the Grill section below.
5. **Propose 2-3 approaches** — with trade-offs and your recommendation
6. **Present design** — in sections scaled to their complexity, get user approval after each section
7. **Write spec (invoke writing-spec)** — formalize the approved design into a problem-driven spec document. writing-spec handles the spec format, libra review, user review gate, and handoff to writing-plans.

## Process Flow

```dot
digraph brainstorming {
    "Read the room\n(glossary, findings, specs)" [shape=box];
    "Dispatch virgo / sagittarius?\n(based on task + what you know)" [shape=diamond];
    "Visual questions ahead?" [shape=diamond];
    "Offer Visual Companion\n(own message, no other content)" [shape=box];
    "Grill the user\n(one Q at a time, recommend,\nresolve terms → glossary)" [shape=box];
    "Propose 2-3 approaches" [shape=box];
    "Present design sections" [shape=box];
    "User approves design?" [shape=diamond];
    "Invoke writing-spec skill\n(spec libra user plans)" [shape=doublecircle];

    "Read the room\n(glossary, findings, specs)" -> "Dispatch virgo / sagittarius?\n(based on task + what you know)";
    "Dispatch virgo / sagittarius?\n(based on task + what you know)" -> "Visual questions ahead?" [label="virgo and/or\nsagittarius return"];
    "Dispatch virgo / sagittarius?\n(based on task + what you know)" -> "Visual questions ahead?" [label="skip (already\nhave context)"];
    "Visual questions ahead?" -> "Offer Visual Companion\n(own message, no other content)" [label="yes"];
    "Visual questions ahead?" -> "Grill the user\n(one Q at a time, recommend,\nresolve terms → glossary)" [label="no"];
    "Offer Visual Companion\n(own message, no other content)" -> "Grill the user\n(one Q at a time, recommend,\nresolve terms → glossary)";
    "Grill the user\n(one Q at a time, recommend,\nresolve terms → glossary)" -> "Propose 2-3 approaches";
    "Propose 2-3 approaches" -> "Present design sections";
    "Present design sections" -> "User approves design?";
    "User approves design?" -> "Present design sections" [label="no, revise"];
    "User approves design?" -> "Invoke writing-spec skill\n(spec libra user plans)" [label="yes"];
}
```

**The terminal state is invoking writing-spec.** Do NOT invoke writing-plans or any implementation skill directly. The ONLY skill you invoke after brainstorming is writing-spec (which then owns the spec → review → plan chain).

## The Process

**Read the room first (mandatory):**

Before doing anything else, read these files if they exist (skip silently if not):
- `docs/superpowers/glossary.md` — the project's canonical terminology. Every term here is settled; do NOT re-ask what's already defined, and use these exact terms in all your output.
- `docs/superpowers/findings-local.md` — virgo's prior local codebase maps
- `docs/superpowers/findings-external.md` — sagittarius's prior external research
- Any `docs/superpowers/specs/*.md` for prior work on the same topic

A fresh session with these files restored has the context of every prior session that wrote to them. Don't waste the user's questions re-deriving what's already on disk.

**Assess scope before exploring or grilling:**

Before asking detailed questions, assess scope: if the request describes multiple independent subsystems (e.g., "build a platform with chat, file storage, billing, and analytics"), flag this immediately. Don't spend questions refining details of a project that needs to be decomposed first.

If the project is too large for a single spec, help the user decompose into sub-projects: what are the independent pieces, how do they relate, what order should they be built? Then brainstorm the first sub-project through the normal design flow. Each sub-project gets its own spec → plan → implementation cycle.

**Explore (dispatch virgo / sagittarius — your call):**

Based on what the task needs and what you already know, decide:
- **Local codebase unfamiliar or large** → dispatch **virgo** (writes `findings-local.md`)
- **External library / API / best practice needed** → dispatch **sagittarius** (writes `findings-external.md`)
- **Cross-domain large project** → dispatch **both in parallel** (they write separate files, no conflict)
- **You already have enough context** → skip exploration, go straight to grilling

Do NOT auto-dispatch both for every task. Virgo and sagittarius cost a round-trip each; only spend them when the gap is real.

```
Agent(subagent_type="virgo",
      description="Map <area> for <task>",
      prompt="<What map do you need? e.g. 'Trace the auth flow: where login is handled, how sessions are persisted, what middleware checks them. Anchor every claim to file:line. Write to docs/superpowers/findings-local.md.'>")

Agent(subagent_type="sagittarius",
      description="Research <library/topic>",
      prompt="<What do you need to know? e.g. 'How does library X handle Y? Cite primary sources, signal confidence. Append to docs/superpowers/findings-external.md.'>")
```

When both are dispatched, do it in a single message with two `Agent` calls so they run concurrently.

**Grill the user (replaces "ask clarifying questions"):**

Interview the user relentlessly about every aspect of the idea until you reach shared understanding. Walk down each branch of the decision tree, resolving dependencies between decisions one-by-one.

The grill rules:
- **One question at a time.** Multiple questions in one message is bewildering. Wait for the answer before asking the next. *Why: the answer to one question often changes which question should come next, or changes what the right options are. Asking Q2 before Q1's answer is in means you're asking Q2 against a guess, and the user is juggling a queue of open questions instead of resolving one. One-at-a-time lets each answer actually inform the next question.*
- **Every question comes with a recommended answer.** Not "what do you want for X?" but "for X I'd recommend Y because Z — does that hold up?" An empty question is a missed recommendation. *Why: a bare "what do you want?" forces the user to do your job — to enumerate options and trade-offs you've had longer to think about. A recommendation with reasoning gives them something concrete to accept, reject, or refine, which is far less effort than generating the answer from scratch. You're not abdicating the decision; you're making the default explicit so their input is a delta, not a draft.*
- **Walk the decision tree, don't jump around.** Resolve one branch before moving to the next. Note dependencies between decisions explicitly. *Why: decisions have dependencies — the answer to "sync or async" changes what "how do we retry" even means. Jumping around means you collect answers to questions whose framing depends on unanswered others, and you have to re-ask them once the dependency resolves. Tree order means each answer stands.*
- **If a question can be answered from disk, answer it from disk.** Read `findings-local.md`, `findings-external.md`, `glossary.md`, the codebase, prior specs. Only ask the user what only they know. *Why: every question you ask the user costs their attention, which is the scarcest resource in the session. If virgo already mapped the auth flow, or sagittarius already researched the library, asking the user "how does auth work?" is burning their time to re-derive what's on disk. Reserve the user for things only they know: intent, preference, constraints only they hold.*
- **Resolve terminology into `glossary.md` as it crystallizes.** When a fuzzy term gets pinned down, write it to `docs/superpowers/glossary.md` right then — don't batch. Use the format below. *Why: a term that just got pinned down is at peak clarity in this exact moment — both of you just agreed what it means. If you wait to batch-write it later, you'll reconstruct the meaning from memory, which is exactly how definitions drift. Writing it immediately also makes it referenceable for the very next question, so you don't re-litigate it five minutes later in the same session.*
- **Challenge conflicts immediately.** If the user uses a term in a way that contradicts `glossary.md`, call it out: "Your glossary defines 'cancellation' as X, but you seem to mean Y — which is it?" Don't silently pick one. *Why: silently picking one means you've let the term fork — the glossary says X, the user means Y, and every subsequent answer is ambiguous about which is in play. The mismatch only surfaces later as a bug in the design ("wait, I thought cancellation meant..."). Surfacing it now costs one clarification; surfacing it after you've built on the wrong meaning costs a re-design.*

Glossary entry format (canonical term + definition + `_Avoid_` aliases):
```markdown
**<Canonical Term>**:
<1-2 sentences: what it IS, not what it DOES>
_Avoid_: <synonym1>, <synonym2>
```

The glossary is **only terminology** — never implementation notes, scratch, or design decisions. Those go in the spec. If you can't decide whether something belongs in the glossary, ask: is this a *term unique to this project's domain*? If yes, glossary. If it's a general concept or an implementation choice, no.

End the grill when every load-bearing decision has a resolved answer (either from the user, from disk, or from glossary) and the design space is clear enough to propose approaches.

**Exploring approaches:**

- Propose 2-3 different approaches with trade-offs
- Present options conversationally with your recommendation and reasoning
- Lead with your recommended option and explain why

**Presenting the design:**

- Once you believe you understand what you're building, present the design
- Scale each section to its complexity: a few sentences if straightforward, up to 200-300 words if nuanced
- Ask after each section whether it looks right so far
- Cover: architecture, components, data flow, error handling, testing
- Be ready to go back and clarify if something doesn't make sense

**Design for isolation and clarity:**

- Break the system into smaller units that each have one clear purpose, communicate through well-defined interfaces, and can be understood and tested independently
- For each unit, you should be able to answer: what does it do, how do you use it, and what does it depend on?
- Can someone understand what a unit does without reading its internals? Can you change the internals without breaking consumers? If not, the boundaries need work.
- Smaller, well-bounded units are also easier for you to work with - you reason better about code you can hold in context at once, and your edits are more reliable when files are focused. When a file grows large, that's often a signal that it's doing too much.

**Working in existing codebases:**

- Explore the current structure before proposing changes. Follow existing patterns.
- Where existing code has problems that affect the work (e.g., a file that's grown too large, unclear boundaries, tangled responsibilities), include targeted improvements as part of the design - the way a good developer improves code they're working in.
- Don't propose unrelated refactoring. Stay focused on what serves the current goal.

## After the Design

Once the user approves the design, invoke the **writing-spec** skill to formalize it:

```
Skill("athena-superpowers:writing-spec")
```

writing-spec handles everything downstream: writing the problem-driven spec document, dispatching libra for independent review, the user review gate, and the handoff to writing-plans.

Do NOT write the spec inline. Do NOT dispatch libra yourself. Do NOT invoke writing-plans directly. Delegate to writing-spec — it owns the spec → review → plan chain.

## Key Principles

- **Read before asking.** If the answer is on disk (findings, glossary, specs, code), don't burn a user question on it.
- **Every grill question carries a recommendation.** "What do you want?" is a missed recommendation.
- **Resolve terminology inline.** When a term crystallizes, write it to `glossary.md` immediately.
- **YAGNI ruthlessly** - Remove unnecessary features from all designs
- **Explore alternatives** - Always propose 2-3 approaches before settling
- **Incremental validation** - Present design, get approval before moving on
- **Be flexible** - Go back and clarify when something doesn't make sense

## Visual Companion

A browser-based companion for showing mockups, diagrams, and visual options during brainstorming. Available as a tool — not a mode. Accepting the companion means it's available for questions that benefit from visual treatment; it does NOT mean every question goes through the browser.

**Offering the companion:** When you anticipate that upcoming questions will involve visual content (mockups, layouts, diagrams), offer it once for consent:
> "Some of what we're working on might be easier to explain if I can show it to you in a web browser. I can put together mockups, diagrams, comparisons, and other visuals as we go. This feature is still new and can be token-intensive. Want to try it? (Requires opening a local URL)"

**This offer MUST be its own message.** Do not combine it with clarifying questions, context summaries, or any other content. The message should contain ONLY the offer above and nothing else. Wait for the user's response before continuing. If they decline, proceed with text-only brainstorming.

**Per-question decision:** Even after the user accepts, decide FOR EACH QUESTION whether to use the browser or the terminal. The test: **would the user understand this better by seeing it than reading it?**

- **Use the browser** for content that IS visual — mockups, wireframes, layout comparisons, architecture diagrams, side-by-side visual designs
- **Use the terminal** for content that is text — requirements questions, conceptual choices, tradeoff lists, A/B/C/D text options, scope decisions

A question about a UI topic is not automatically a visual question. "What does personality mean in this context?" is a conceptual question — use the terminal. "Which wizard layout works better?" is a visual question — use the browser.

If they agree to the companion, read the detailed guide before proceeding:
`skills/brainstorming/visual-companion.md`
