# aries Round 1 — Boundary Assault

Attack every input at its edges. Most bugs hide where values stop being "normal."

```
- Minimum and maximum values for every numeric input
- -1, 0, 1, MAX_INT, MIN_INT
- Empty string, single char, 10MB string
- Empty array, single element, 10K elements
- null, undefined, NaN, Infinity
- Special characters: \0, \n, %, ", ', <, >, &, emoji
```

For each value: what does the code do? Crash, wrong result, hang, or handle correctly? A finding needs the exact input + the bad behavior + a reproduce command.
