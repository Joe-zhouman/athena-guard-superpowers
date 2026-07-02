---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
---

# Requesting Code Review

Dispatch a code reviewer subagent to catch issues before they cascade. The reviewer gets precisely crafted context for evaluation — never your session's history. This keeps the reviewer focused on the work product, not your thought process, and preserves your own context for continued work.

**Core principle:** Review early, review often.

**Why early and often:** a defect found at task N costs roughly N to fix; the same defect found at merge, or after the next task builds on it, costs N+1 plus the rework of everything stacked on top. Reviewing after each task means the reviewer is judging a small, understandable diff against a fresh intent — which is the regime where review actually catches things. Batching review to "after the whole feature" means the reviewer faces a huge diff with cold intent, defects have already been built upon, and the fixes ripple through work that wouldn't exist if the first defect had been caught. Frequent small reviews aren't more total review time — they're less, because they prevent the expensive late-stage rework.

## When to Request Review

**Mandatory:**
- After each task in subagent-driven development
- After completing major feature
- Before merge to main

**Optional but valuable:**
- When stuck (fresh perspective)
- Before refactoring (baseline check)
- After fixing complex bug

## How to Request

**1. Get git SHAs:**
```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

**2. Dispatch taurus (code-quality reviewer):**

taurus is the dedicated code-quality agent — its discipline (Strengths / Issues by severity / Assessment, every issue citing file:line) is baked into its definition. Dispatch it bare:

```
Agent(subagent_type="taurus",
      description="Code quality review: <task summary>",
      prompt="Review BASE <BASE_SHA> HEAD <HEAD_SHA>.\nPlan/requirements: <PLAN_OR_REQUIREMENTS or path>")
```

taurus reads the diff itself — no need to paste code or fill a template. Pass only the git range and what the work was supposed to do.

**3. Act on feedback:**
- Fix Critical issues immediately
- Fix Important issues before proceeding
- Note Minor issues for later
- Push back if reviewer is wrong (with reasoning)

## Example

```
[Just completed Task 2: Add verification function]

You: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

[Dispatch taurus]
  description: "Code quality review: verifyIndex() and repairIndex()"
  prompt: "Review BASE a7981ec HEAD 3df7661. Task 2 from docs/superpowers/plans/deployment-plan.md"

[taurus returns]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed

You: [Fix progress indicators]
[Continue to Task 3]
```

## Integration with Workflows

**Subagent-Driven Development:**
- Review after EACH task
- Catch issues before they compound
- Fix before moving to next task

**Executing Plans:**
- Review after each task or at natural checkpoints
- Get feedback, apply, continue

**Ad-Hoc Development:**
- Review before merge
- Review when stuck

## Red Flags

**Never:**
- Skip review because "it's simple" — *why: "simple" is your assessment before the review, i.e., at the moment of least information. Simple changes still harbor the defects you can't see in your own work — that's the entire reason review exists. The cost of review scales with diff size, so a "simple" change is also the cheapest possible review to run; skipping it trades a tiny saving for the one class of error (your own blind spot) review uniquely catches.*
- Ignore Critical issues — *why: Critical means "this will break / has broken / is unsafe to merge." Ignoring it doesn't make it go away; it moves the breakage from "found in review" to "found in production," where the same defect costs dramatically more and lands on users.*
- Proceed with unfixed Important issues — *why: Important means "should not ship as-is but not catastrophic." Proceeding accumulates these into a backlog of known-but-shipped defects that each become someone else's problem later — and each one makes the next review harder, because the reviewer can't tell new issues from the accepted-old-ones.*
- Argue with valid technical feedback — *why: if the feedback is valid, arguing delays a fix you're going to make anyway, and burns the review cycle on ego instead of code. The counter-case (pushing back on feedback that's *wrong*) is different and encouraged — but that requires you to have verified it's wrong, not just that you'd prefer it were.*

**If reviewer wrong:**
- Push back with technical reasoning
- Show code/tests that prove it works
- Request clarification

taurus writes its full review to `docs/superpowers/reviews/<task>-quality.md`. Read the file for detail.

**4. Optional: Over-Engineering Audit (dispatch aquarius)**

After taurus approves, consider an adversarial pass with a different lens: not "is this code good?" but "does this code need to exist at all?" Dispatch **aquarius** in Mode B (code existence audit). This is NOT a second code-quality review — it's a deletion audit. aquarius climbs the same decision ladder used in `writing-plans`, but applied in reverse: the code already exists, and the question is whether it should.

**When to dispatch:**
- The diff is larger than expected for the task
- New dependencies appeared (`npm install`, `pip install`)
- Code reinvents something the standard library or codebase already has
- A "simple" task produced a surprisingly large change

```
Agent(subagent_type="aquarius",
      description="Existence audit: <task summary>",
      prompt="Audit BASE <BASE_SHA> HEAD <HEAD_SHA>. Read the right lens ref for this kind of target, then tag everything that shouldn't exist. Write to docs/superpowers/reviews/<task>-overengineering.md.")
```

aquarius writes to `docs/superpowers/reviews/<task>-overengineering.md`. Read it.

**If aquarius found dead code:** route back to capricorn for deletion. These are surgical cuts — each finding says exactly what to delete and what replaces it.

**If aquarius says "Lean. Ship.":** the code survived adversarial deletion review. Proceed.
