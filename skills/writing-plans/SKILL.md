---
name: writing-plans
description: Use when you have a spec or requirements for a multi-step task, before touching code
---

# Writing Plans

## Overview

Write comprehensive implementation plans assuming the engineer has zero context for our codebase and questionable taste. Document everything they need to know: which files to touch for each task, code, testing, docs they might need to check, how to test it. Give them the whole plan as bite-sized tasks. DRY. YAGNI. TDD. Frequent commits.

Assume they are a skilled developer, but know almost nothing about our toolset or problem domain. Assume they don't know good test design very well.

**Why this pessimism is the point:** the executor is often a fresh subagent with no conversation history, or a future session with no memory of this one, or a human who hasn't built the mental model you have right now. Any of them will fill the gaps in your plan with *their* assumptions — which are wrong, because they weren't here when you made the decisions. Every unspecified detail becomes a place where the executor guesses, and the guesses compound: a wrong path here, a missed edge case there, and the plan produces something that looks like what you meant but isn't. Writing the plan as if the reader knows nothing isn't insulting them — it's making the plan executable without telepathy. The detail you omit because "it's obvious" is the detail that will be done wrong.

**Announce at start:** "I'm using the writing-plans skill to create the implementation plan."

**Context:** If working in an isolated worktree, it should have been created via the `superpowers:using-git-worktrees` skill at execution time.

**Save plans to:** `docs/superpowers/plans/YYYY-MM-DD-<feature-name>.md`
- (User preferences for plan location override this default)

## Scope Check

If the spec covers multiple independent subsystems, it should have been broken into sub-project specs during brainstorming. If it wasn't, suggest breaking this into separate plans — one per subsystem. Each plan should produce working, testable software on its own.

## The Decision Ladder — Before You Design Any Task

**Climb this ladder for every requirement before you write a single task.** The implementer (capricorn) will build whatever the plan says. If the plan says "install flatpickr and write a date picker component," that's what gets built. If the plan says `<input type="date">`, that's what gets built. The implementer does not question the plan — you do. Now.

This is not about writing less code for its own sake. It's about not writing code that doesn't need to exist. Every line you don't write is a line that can't have a bug, can't need a test, can't drift out of date, and can't burn GLM-5.2 quota maintaining it. The plan is the cheapest place to delete code — before anyone writes it.

Stop at the **first rung that holds**. Two rungs both work? Take the higher one.

### Rung 1: Does this need to exist at all?

The most expensive code is the code that solves a problem nobody has.

- Is this requirement solving a **real, confirmed** need, or a speculative one?
- "We might need it later" → skip it. Later can build it for itself, with real requirements.
- "The user might want..." → skip it. Wait for the user to want it.
- If the answer is no: **strike the requirement from the plan.** Don't design a task for it. Say so in one line in the plan: "Skipped: speculative need, add when [specific trigger]."

### Rung 2: Already in this codebase?

Re-implementing what's a few files over is the most common form of bloat.

- Is there a helper, util, type, or pattern that already does this?
- Has someone else on the team solved this before?
- **Read the codebase before you answer.** Grep for the concept. Check imports. The function you're about to reinvent is probably in `utils/` with a slightly different name.
- If yes: the plan says "use existing `foo()` from `src/utils/bar.py`" — not "write a new one."

### Rung 3: Standard library does it?

Your language's stdlib is older than most npm packages and better tested than all of them.

- Check: `pathlib` not `os.path`, `dataclasses` not hand-rolled `__init__`, `itertools` not manual loops, `functools.lru_cache` not a custom cache class.
- The implementer may not know the stdlib has this. The plan must name it explicitly.
- If yes: the plan names the exact stdlib function, with an import line.

### Rung 4: Native platform feature covers it?

Browsers and operating systems have been accumulating features for decades. Most "components" are wrappers around something that already works.

- `<input type="date">` over a date picker library. `<details>` over a collapsible component. CSS `grid` over a layout library. Database constraints over application validation code.
- If yes: the plan says "use native `<input type='date'>`" — and the task has zero npm install steps.

### Rung 5: Already-installed dependency solves it?

Adding a dependency is not free. Every new package is a supply-chain risk, a version conflict waiting to happen, and a thing that will break when the ecosystem moves on. But if the dependency is **already installed**, it's already paid for.

- Check `package.json` / `requirements.txt` / `Cargo.toml` — is there already a package that does this?
- If not: be extremely reluctant to add one. A new dependency for what 20 lines can do is a bad trade.
- If yes: the plan uses it. No new installs.

### Rung 6: Can it be one line?

One line has no branches, no edge cases hiding between the lines, no maintenance surface.

- A list comprehension instead of a loop-and-append.
- A `dict.get(key, default)` instead of an `if key in dict` block.
- A generator expression instead of building an intermediate list.
- If yes: the plan shows the one line. The task becomes "add this line at `file:line`."

### Rung 7: Only then — write the minimum that works.

If you've fallen through all six rungs, the code genuinely needs to exist. Now write it — but write the **minimum**:

- No interface with one implementation. No factory for one product. No config for a value that never changes.
- No scaffolding "for later." Later can scaffold for itself.
- One file unless two are genuinely justified. Shortest working diff, not shortest line count — a seven-line function with clear error handling beats a one-liner that silently corrupts data.

### The ladder is a reflex, not a research project

You climb it for every requirement, but you don't spend five minutes per rung. Most requirements die at rung 1 or survive to rung 3 or 4 — you'll know within seconds. The rungs exist so you don't skip the obvious question because you were too busy designing the implementation.

### What the plan inherits from the ladder

By the time you write a task, the ladder decision is already baked in:

| If the ladder stopped at... | The task says... |
|------------------------------|------------------|
| Rung 1 (doesn't need to exist) | No task. Requirement struck with a one-line note. |
| Rung 2 (codebase has it) | "Use `foo()` from `src/utils/bar.py`" — exact import path. |
| Rung 3 (stdlib) | "Use `functools.lru_cache`" — exact function, with import. |
| Rung 4 (native platform) | "Use `<input type='date'>`" — no code to write. |
| Rung 5 (existing dependency) | Task names the dependency, shows the import, no `npm install`. |
| Rung 6 (one line) | Task shows the one line, the exact file, the exact line number. |
| Rung 7 (must write it) | Normal task — but minimal. |

The implementer should never see a task that says "add a date picker" and have to decide whether to install flatpickr. That decision was yours. You made it at plan time. The task says `<input type="date">` or it says `npm install flatpickr` — never "figure out date input."

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. The decision ladder has already eliminated some requirements and pointed others at existing code — now design the files for what remains.

- Design units with clear boundaries and well-defined interfaces. Each file should have one clear responsibility.
- You reason best about code you can hold in context at once, and your edits are more reliable when files are focused. Prefer smaller, focused files over large ones that do too much.
- Files that change together should live together. Split by responsibility, not by technical layer.
- In existing codebases, follow established patterns. If the codebase uses large files, don't unilaterally restructure - but if a file you're modifying has grown unwieldy, including a split in the plan is reasonable.

This structure informs the task decomposition. Each task should produce self-contained changes that make sense independently.

## Bite-Sized Task Granularity

**Each step is one action (2-5 minutes):**
- "Write the failing test" - step
- "Run it to make sure it fails" - step
- "Implement the minimal code to make the test pass" - step
- "Run the tests and make sure they pass" - step
- "Commit" - step

**Why 2-5 minutes, not "implement the feature":** a step is a verification boundary — the point where you run something and confirm it worked before moving on. A large step bundles multiple changes with one verification at the end, so when the verification fails you can't tell which change broke it, and you debug instead of executing. Small steps mean each one is independently verifiable: write test → see it fail (proves the test is wired) → write code → see it pass (proves the code works) → commit (proves it's saved). The granularity exists so failure localizes to one action, not one feature.

## Plan Document Header

**Every plan MUST start with this header:**

```markdown
# [Feature Name] Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** [One sentence describing what this builds]

**Architecture:** [2-3 sentences about approach]

**Tech Stack:** [Key technologies/libraries]

---
```

## Task Structure

````markdown
### Task N: [Component Name]

**Files:**
- Create: `exact/path/to/file.py`
- Modify: `exact/path/to/existing.py:123-145`
- Test: `tests/exact/path/to/test.py`

- [ ] **Step 1: Write the failing test**

```python
def test_specific_behavior():
    result = function(input)
    assert result == expected
```

- [ ] **Step 2: Run test to verify it fails**

Run: `pytest tests/path/test.py::test_name -v`
Expected: FAIL with "function not defined"

- [ ] **Step 3: Write minimal implementation**

```python
def function(input):
    return expected
```

- [ ] **Step 4: Run test to verify it passes**

Run: `pytest tests/path/test.py::test_name -v`
Expected: PASS

- [ ] **Step 5: Commit**

```bash
git add tests/path/test.py src/path/file.py
git commit -m "feat: add specific feature"
```
````

## No Placeholders

Every step must contain the actual content an engineer needs. These are **plan failures** — never write them:
- "TBD", "TODO", "implement later", "fill in details"
- "Add appropriate error handling" / "add validation" / "handle edge cases"
- "Write tests for the above" (without actual test code)
- "Similar to Task N" (repeat the code — the engineer may be reading tasks out of order)
- Steps that describe what to do without showing how (code blocks required for code steps)
- References to types, functions, or methods not defined in any task

**Why placeholders are failures, not stubs:** a placeholder looks like the plan is 90% done when it's actually missing the 10% that does the work. The executor can't implement "appropriate error handling" — they don't know which errors, what's appropriate for this codebase, or what the caller expects. So they either guess (producing code that diverges from your intent) or stall (because the step isn't actionable). A plan with placeholders isn't an incomplete plan, it's a non-executable one — and because the placeholders are scattered through otherwise-complete-looking tasks, the plan *reads* as ready and the gap only surfaces at execution time, when rework is most expensive. If you can't write the real content, the design isn't done yet; go back to brainstorming, don't ship a placeholder.

## Remember
- **Climb the decision ladder for every requirement** before designing its tasks. The plan is the cheapest place to delete code.
- Exact file paths always
- Complete code in every step — if a step changes code, show the code
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent commits
- The implementer does not question the plan. Every decision you defer becomes a decision they guess. Guess wrong.

## Plan Review (dispatch aquarius, then libra)

You wrote this plan — you are not the best reviewer of it. Review happens in two passes, ordered by cost of failure:

**Pass 1 — aquarius (adversarial design review).** aquarius attacks the plan at the highest level: does it inherit flawed premises from the spec? Are there hidden assumptions, causal gaps, or consensus-blind choices? If the plan is built on sand, no amount of completeness checking will save it. Find that out first.

```
Agent(subagent_type="aquarius",
      description="Existence audit: <filename>",
      prompt="Audit the plan at docs/superpowers/plans/<filename>.md. Read the right lens ref for this kind of target, then tag everything that shouldn't exist. Write to docs/superpowers/reviews/<plan-name>-adversarial-plan.md.")
```

aquarius writes its verdict to `docs/superpowers/reviews/<plan-name>-adversarial-plan.md`. Read it.

**If aquarius finds an unchallenged premise that could collapse the design:** do NOT patch the plan. Return to **writing-plans** and rewrite. aquarius found a foundational problem — tweaking a task won't fix a cracked premise. Rewrite the plan from the corrected assumptions.

**If aquarius says "Lean. Ship.":** proceed to Pass 2.

**Pass 2 — libra (completeness gate).** libra is the final checkpoint — the last pair of eyes before capricorn starts building. Only dispatch after aquarius has confirmed the plan is logically sound. libra checks for blocking gaps; its default is APPROVE.

```
Agent(subagent_type="libra",
      description="Review plan: <filename>",
      prompt="Review the plan at docs/superpowers/plans/<filename>.md against its spec at <spec path>. Flag only blockers — missing spec requirements, contradictions, placeholder content, or tasks too vague to act on.")
```

libra writes its verdict to `docs/superpowers/reviews/<plan-name>-plan-review.md`. Read it.

**If libra finds blockers:** fix the plan, then re-dispatch libra (it re-reads from disk — don't summarize the changes, just fix the file and re-dispatch). If the fixes are substantial, consider re-dispatching aquarius — major rewrites can introduce new assumptions.

**If libra approves:** proceed to execution handoff.

## Execution Handoff

After saving the plan, offer execution choice:

**"Plan complete and saved to `docs/superpowers/plans/<filename>.md`. Two execution options:**

**1. Subagent-Driven (recommended)** - I dispatch a fresh subagent per task, review between tasks, fast iteration

**2. Inline Execution** - Execute tasks in this session using executing-plans, batch execution with checkpoints

**Which approach?"**

**If Subagent-Driven chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:subagent-driven-development
- Fresh subagent per task + two-stage review

**If Inline Execution chosen:**
- **REQUIRED SUB-SKILL:** Use superpowers:executing-plans
- Batch execution with checkpoints for review
