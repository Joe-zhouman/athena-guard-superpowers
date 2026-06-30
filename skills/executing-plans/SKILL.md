---
name: executing-plans
description: Use when you have a written implementation plan to execute in a separate session with review checkpoints
---

# Executing Plans

## Overview

Load plan, review critically, execute all tasks, report when complete.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

**Note:** Tell your human partner that Superpowers works much better with access to subagents. The quality of its work will be significantly higher if run on a platform with subagent support (such as Claude Code or Codex). If subagents are available, use superpowers:subagent-driven-development instead of this skill.

## The Process

### Step 1: Load and Review Plan
1. Read plan file
2. Review critically - identify any questions or concerns about the plan
3. If concerns: Raise them with your human partner before starting
4. If no concerns: Create TodoWrite and proceed

**Why review a plan you're about to execute, not just follow it:** a plan is a prediction made under incomplete information — written before the code existed, before the real file shapes were visible, before any of it ran. By execution time you have ground truth the planner didn't: the actual code, the actual errors, the actual friction. A step that looked reasonable in planning may turn out to assume something false, depend on something missing, or solve the wrong sub-problem now that you can see the real one. Critically reviewing first means you catch the plan's stale assumptions at the cheapest moment — before you've built on them. Blindly following a plan that's wrong is just a more disciplined way of doing the wrong thing. The plan is a guide, not a contract with the universe.

### Step 2: Execute Tasks

For each task:
1. Mark as in_progress
2. Follow each step exactly (plan has bite-sized steps)
3. Run verifications as specified
4. Mark as completed

### Step 3: Complete Development

After all tasks complete and verified:
- Announce: "I'm using the finishing-a-development-branch skill to complete this work."
- **REQUIRED SUB-SKILL:** Use superpowers:finishing-a-development-branch
- Follow that skill to verify tests, present options, execute choice

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test fails, instruction unclear)
- Plan has critical gaps preventing starting
- You don't understand an instruction
- Verification fails repeatedly

**Ask for clarification rather than guessing.**

**Why stop beats guess:** a guess at a blocker doesn't resolve the blocker — it produces work that *looks* like progress and silently entrenches the wrong assumption. You'll implement around the guess, the next task builds on that, and by the time the guess is revealed wrong, unwinding it touches everything downstream. Stopping costs one human round-trip; guessing costs a re-do of however much you built on the guess before it surfaced. The instinct to "not bother the human" is backwards — the human would far rather answer a 30-second question now than debug a guessed-into-existence architecture later. Stopping is the faster path; it just doesn't feel like it in the moment.

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on your feedback
- Fundamental approach needs rethinking

**Don't force through blockers** - stop and ask.

## Remember
- Review plan critically first
- Follow plan steps exactly
- Don't skip verifications
- Reference skills when plan says to
- Stop when blocked, don't guess
- Never start implementation on main/master branch without explicit user consent

## Integration

**Required workflow skills:**
- **superpowers:using-git-worktrees** - Ensures isolated workspace (creates one or verifies existing)
- **superpowers:writing-plans** - Creates the plan this skill executes
- **superpowers:finishing-a-development-branch** - Complete development after all tasks
