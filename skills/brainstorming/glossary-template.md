# Glossary Template

This is the template for a project's `docs/superpowers/glossary.md` — the canonical record of this project's domain language. When you're grilling the user and a term crystallizes (you both just agreed what it means), and `docs/superpowers/glossary.md` doesn't exist yet, **create it from this template**. If it exists, append to the matching section.

The structure is borrowed from Matt Pocock's `CONTEXT.md` and adapted. Three sections, in this order:

## Terms

Each entry: the canonical term, a tight definition (what it IS, not what it DOES or how to build it), and the synonyms to avoid. Only promote a term here once the user has shown they understand it — the glossary is compressed shared knowledge, not a dictionary the user learns from.

```markdown
**<Canonical Term>**:
<1-2 sentences: what it IS. Use terms already in this glossary to define it.>
_Avoid_: <synonym1>, <synonym2>
```

Example (a payment-processing project):
```markdown
**Capture**:
The act of transferring funds the issuer already reserved during **Authorization** into the merchant's account. Happens at fulfillment, not at checkout.
_Avoid_: charge, take payment, finalize
```

## Relationships

How the terms relate. One line each. This is what separates a glossary from a dictionary — the structure between terms is where the domain model lives.

```markdown
- An **Order** contains one or more **Line items**
- A **Line item** references exactly one **SKU**
- **Authorization** precedes **Capture**; **Refund** can only follow **Capture**
```

## Flagged ambiguities

Terms that used to be ambiguous, and how they were resolved. Write an entry every time you and the user untangle a word that was being used two ways — this stops the same drift from recurring next session.

```markdown
- "Payment" was being used to mean both the **Authorization** (reserving funds) and the **Capture** (transferring them). Resolved: "payment" is no longer used as a domain term; use **Authorization** or **Capture** specifically.
```

---

## Rules (apply when writing entries)

- **Add a term only when it's settled.** If the user just heard the word for the first time, it's not ready. Promote it when they can use it correctly.
- **Be opinionated.** When several words exist for the same thing, pick one as canonical and list the rest under `_Avoid_`. This is how language compresses.
- **Keep definitions tight.** One or two sentences. Define what it IS, not what it does or how to make it.
- **Use the glossary's own terms inside definitions.** Once **Authorization** is defined, use it (bolded) inside other definitions — this is what makes later terms easier to grasp.
- **Glossary is terminology only.** No implementation notes, no design decisions, no scratch. Those go in the spec. Test: "is this a term unique to this project's domain?" Yes → glossary. General concept or implementation choice → no.
- **Revise in place.** A definition from week one may be wrong by week six. Update it; don't leave stale entries.

---

## Starter skeleton

When creating `docs/superpowers/glossary.md` fresh, write this skeleton and fill it in as terms settle:

```markdown
# <Project> Glossary

The canonical domain language for <project>. Terms here are settled — use them verbatim in all output, never re-ask what's already defined, and never silently use an `_Avoid_` alias.

## Terms

<!-- **<Term>**:
<definition>
_Avoid_: -->

## Relationships

<!-- - -->

## Flagged ambiguities

<!-- - -->
```
