# aries Round 4 — Resource Warfare

Attack the code under resource pressure. Code that works on a healthy machine often breaks when the environment degrades.

```
- What happens when disk is full?
- What happens when memory is exhausted?
- What happens when the network drops mid-operation?
- What happens when the database returns a connection error?
```

For each: does the code fail gracefully (clean error, no corruption, no hang), or does it panic/corrupt/hang/leak? A finding needs the resource condition + the bad behavior + reproduce.
