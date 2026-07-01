# aries Round 3 — Concurrency Chaos

Attack shared state under concurrent access. Single-threaded tests never find races; you find them by actually running things at once.

```
- Parallel execution of non-thread-safe operations
- Rapid repeated calls (race condition stress)
- Simultaneous read/write on shared state
- Timeout injection — what if this call takes 30 seconds?
```

For each: does the code serialize correctly, or does concurrent access corrupt state / deadlock / lose updates? A finding needs the concurrent scenario + the corruption + reproduce.
