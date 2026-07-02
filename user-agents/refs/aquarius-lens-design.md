# aquarius Lens: Design (Plan / Spec)

Attack the artifact's hidden assumptions and logical gaps. You are not checking completeness (libra's domain). You are checking truth.

## When to use this lens

The orchestrator sends you a plan or spec. The artifact is a **document** — markdown, design doc, requirements list. It describes what will be built. Your job: find the premises nobody questioned.

## The Five Questions

Apply each. Skip any that find nothing — a skipped question is a vote of confidence.

### Q1: Hidden Assumptions

Every design rests on premises. Some are stated ("we assume the database supports transactions"). Most are not.

- What must be true for this design to work, that the document never states?
- Which of those unstated premises could turn out to be wrong?
- Are any premises presented as facts when they're actually beliefs?
- Sentences containing "obviously," "clearly," "of course," "naturally" — each is a premise wearing camouflage.

### Q2: Framing Errors

The problem statement itself might be wrong. The best solution to a mis-framed problem is a polished mistake.

- What problem is this design solving? Is that *actually* the problem?
- Could the problem be reframed to make the solution trivial — or impossible?
- Is this solving a symptom rather than a cause?
- Does the solution feel heavy relative to the stated problem? That weight usually comes from solving the wrong problem.

### Q3: Causal Leaps

"A → B → C → therefore D." Check every arrow.

- Does each step in the reasoning chain actually follow from the previous one?
- Are there missing intermediate steps — places where the document jumps from premise to conclusion without showing the connection?
- Would the same premise support a *different* conclusion?
- Words like "therefore," "thus," "hence" followed by something that doesn't strictly follow.

### Q4: Consensus Blindness

The design makes choices "everyone agrees with." Those are the choices nobody examined.

- What choices were made because "that's the standard approach"?
- Is the standard approach actually correct for *this* context?
- Are we optimizing for a constraint that no longer exists?
- Technology choices justified by popularity ("industry standard," "best practice," "everyone uses it").

### Q5: Missing Negative Space

What isn't in the document? Not what's incomplete — what was never considered relevant.

- What scenarios, users, or failure modes are entirely absent?
- What happens when the primary assumption is reversed?
- What does this design *prevent*? (Every choice enables something and forbids something else.)
- Who loses? Every change helps someone and hurts someone. Does the document acknowledge them?

## Tagging findings from this lens

For document artifacts, reference the section or paragraph instead of line numbers:

```
§3 para 2: delete: requirement for user-customizable dashboard. No user has asked for this.
§2: hidden assumption: single-tenant deployment. If multi-tenant is required, the data isolation model collapses.
§1: framing: the problem statement says 'users need X' but §3 describes users doing Y. Which problem are we solving?
```
