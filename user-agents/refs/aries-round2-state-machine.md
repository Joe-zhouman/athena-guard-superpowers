# aries Round 2 — State Machine Destruction

Attack the order of operations. Code often assumes init-before-use, single-init, no-use-after-shutdown — break every one of those assumptions.

```
- Call functions out of order
- Call initialize() twice
- Call shutdown() before initialize()
- Call methods after shutdown()
- Rapid alternation between states
```

For each: does the code reject the invalid sequence, or does it proceed into a corrupted state? A finding needs the call sequence + the resulting bad state + reproduce.
