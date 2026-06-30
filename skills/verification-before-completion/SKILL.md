---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output before making any success claims; evidence before assertions always
---

# Verification Before Completion

## Overview

Claiming work is complete without verification is dishonesty, not efficiency.

**Core principle:** Evidence before claims, always.

**Why:** A completion claim is a *prediction* — that the code behaves as you intend across every case, not just the one you ran in your head. You cannot make that prediction from the code alone, because the gap between "what you intended" and "what you wrote" is exactly what bugs are, and you can't see it from inside the intent. Verification is the only thing that closes that gap: it tests the actual code against the actual requirement, not your memory of either. Claiming completion without it isn't optimistic, it's a claim about reality made without checking reality — which is what "dishonesty" means here, regardless of intent.

**Violating the letter of this rule is violating the spirit of this rule.**

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you haven't run the verification command in this message, you cannot claim it passes.

**Why "in this message" / "fresh":** code changes between sessions, between edits, between you and the last person who touched it. A verification result from an earlier turn, an earlier session, or a teammate is evidence about *different code* — the code as it was then. State drifts: a passing test yesterday proves nothing about the code today after the refactor you just did. "Fresh" means the evidence and the claim describe the same artifact. Reusing stale evidence is the same logical error as not verifying, just better-disguised.

## The Gate Function

```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete)
3. READ: Full output, check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim

Skip any step = lying, not verifying
```

**Why step 3 (READ the full output) matters as much as step 2 (RUN):** a command exiting 0 can still have failed — test runners report skips as passes, builds warn-but-succeed on broken paths, exit codes get swallowed by wrappers. "I ran it" without reading the output is performing verification without doing it; the evidence is in the output, not in the fact that the command returned. The discipline is: run *and* confirm the output actually says what you're about to claim.

## Common Failures

| Claim | Requires | Not Sufficient |
|-------|----------|----------------|
| Tests pass | Test command output: 0 failures | Previous run, "should pass" |
| Linter clean | Linter output: 0 errors | Partial check, extrapolation |
| Build succeeds | Build command: exit 0 | Linter passing, logs look good |
| Bug fixed | Test original symptom: passes | Code changed, assumed fixed |
| Regression test works | Red-green cycle verified | Test passes once |
| Agent completed | VCS diff shows changes | Agent reports "success" |
| Requirements met | Line-by-line checklist | Tests passing |

## Red Flags - STOP

- Using "should", "probably", "seems to"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!", etc.)
- About to commit/push/PR without verification
- Trusting agent success reports
- Relying on partial verification
- Thinking "just this once"
- Tired and wanting work over
- **ANY wording implying success without having run verification**

## Rationalization Prevention

| Excuse | Reality | Why |
|--------|---------|-----|
| "Should work now" | RUN the verification | "Should" is a prediction, and the prediction is exactly what verification exists to check. Stating it as a claim before checking converts a guess into an assertion — the guess might be right, but you've now told someone it's right without knowing. |
| "I'm confident" | Confidence ≠ evidence | Confidence measures your feeling about the code, not the code's behavior. The two correlate imperfectly: you're most confident right when you've stopped thinking about edge cases, which is when you're most likely to have missed one. Evidence is independent of your feeling; confidence is not. |
| "Just this once" | No exceptions | "Just this once" is how the rule dies — each one-off exemption feels reasonable in isolation, and the rule that was supposed to be a floor becomes a suggestion. The cost of verifying once is minutes; the cost of the rule eroding is every future claim becoming untrustworthy. |
| "Linter passed" | Linter ≠ compiler | A linter checks style and common pitfalls; it does not check that the code compiles, links, or behaves correctly. Different tools verify different things, and one passing doesn't imply the others. "Linter passed" proves the linter passed — that's all it proves. |
| "Agent said success" | Verify independently | An agent's "success" is its own prediction about whether its changes work, subject to the same gap-between-intent-and-code this skill exists to close. Trusting it moves the unverfied claim one layer away, which feels safer but isn't — you've just outsourced the same error. The VCS diff and the test output are the evidence; the agent's report is a claim. |
| "I'm tired" | Exhaustion ≠ excuse | Exhaustion is a reason claims need *more* verification, not less — tired work has more bugs, and tired judgment is more likely to declare done-too-early. The feeling that you can't face running the tests is itself a signal that you're about to ship something you haven't checked. |
| "Partial check is enough" | Partial proves nothing | A partial check verifies the part you checked and says nothing about the rest. Claiming "tests pass" when you ran a subset is claiming coverage you didn't perform — the unchecked parts are exactly where the bug you'll ship lives. Partial verification produces full-sounding claims, which is worse than no verification because it feels like enough. |
| "Different words so rule doesn't apply" | Spirit over letter | The rule isn't a phrase-detector; it's a discipline about claims-without-evidence. Rephrasing "done" as "wrapped up" or "should be good" doesn't change whether you verified — it just routes around the wording. If the claim communicates completion without evidence behind it, the rule applies, however you worded it. |

## Key Patterns

**Tests:**
```
✅ [Run test command] [See: 34/34 pass] "All tests pass"
❌ "Should pass now" / "Looks correct"
```

**Regression tests (TDD Red-Green):**
```
✅ Write → Run (pass) → Revert fix → Run (MUST FAIL) → Restore → Run (pass)
❌ "I've written a regression test" (without red-green verification)
```

**Build:**
```
✅ [Run build] [See: exit 0] "Build passes"
❌ "Linter passed" (linter doesn't check compilation)
```

**Requirements:**
```
✅ Re-read plan → Create checklist → Verify each → Report gaps or completion
❌ "Tests pass, phase complete"
```

**Agent delegation:**
```
✅ Agent reports success → Check VCS diff → Verify changes → Report actual state
❌ Trust agent report
```

## Why This Matters

From 24 failure memories:
- your human partner said "I don't believe you" - trust broken
- Undefined functions shipped - would crash
- Missing requirements shipped - incomplete features
- Time wasted on false completion → redirect → rework
- Violates: "Honesty is a core value. If you lie, you'll be replaced."

## When To Apply

**ALWAYS before:**
- ANY variation of success/completion claims
- ANY expression of satisfaction
- ANY positive statement about work state
- Committing, PR creation, task completion
- Moving to next task
- Delegating to agents

**Rule applies to:**
- Exact phrases
- Paraphrases and synonyms
- Implications of success
- ANY communication suggesting completion/correctness

## The Bottom Line

**No shortcuts for verification.**

Run the command. Read the output. THEN claim the result.

This is non-negotiable.
