---
name: debugging
description: Use when encountering any bug, test failure, or unexpected behavior. Systematic diagnosis before proposing fixes.
---

# Systematic Debugging

## When to Use
When something isn't working as expected. Before guessing at fixes.

## Process

1. **Reproduce** — get a consistent reproduction case
2. **Read the error** — read the FULL error message, stack trace, and context
3. **Isolate** — narrow down to the smallest failing case
4. **Hypothesize** — form a specific theory about the cause
5. **Verify** — test your hypothesis with a targeted experiment
6. **Fix** — make the minimal change that addresses the root cause
7. **Verify fix** — run the original reproduction case + full test suite

## Key Principles

- NEVER guess-and-check — form a hypothesis first
- Read error messages completely before acting
- Check the most recent change first (git diff, git log)
- Binary search: if unsure where the bug is, bisect
- One change at a time — verify after each change
- Fix the root cause, not the symptom
- Add a regression test for every bug you fix
