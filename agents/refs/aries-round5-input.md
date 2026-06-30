# aries Round 5 — Input Terrorism

Attack the parser/validator with hostile payloads. Trusting input is the classic failure; this round finds where trust is misplaced.

```
- Unicode normalization attacks
- Prototype pollution candidates
- Type confusion ("42" vs 42)
- SQL/HTML/JS fragments in innocent-looking strings
- Extremely deep nesting (100+ levels)
- Circular references in JSON
```

For each: does the code reject/escape/sanitize correctly, or does the payload inject, overflow, or confuse? A finding needs the payload + the injection/confusion + reproduce.
