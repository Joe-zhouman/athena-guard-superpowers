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

## File Structure

Before defining tasks, map out which files will be created or modified and what each one is responsible for. This is where decomposition decisions get locked in.

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
- Exact file paths always
- Complete code in every step — if a step changes code, show the code
- Exact commands with expected output
- DRY, YAGNI, TDD, frequent commits

## Plan Review (dispatch libra)

You wrote this plan — you are not the best reviewer of it. Dispatch **libra** for an independent read. libra checks only for blocking gaps (missing requirements, contradictions, placeholders, unactionable tasks); its default is APPROVE.

```
Agent(subagent_type="libra",
      description="Review plan: <filename>",
      prompt="Review the plan at docs/superpowers/plans/<filename>.md against its spec at <spec path>. Flag only blockers — missing spec requirements, contradictions, placeholder content, or tasks too vague to act on.")
```

libra writes its verdict to `docs/superpowers/reviews/<plan-name>-plan-review.md`. Read it.

**If libra finds blockers:** fix the plan, then re-dispatch libra (it re-reads from disk — don't summarize the changes, just fix the file and re-dispatch).

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
