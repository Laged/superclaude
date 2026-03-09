---
name: tdd
description: Use when implementing any feature or fixing any bug. Write failing tests first, then minimal implementation, then refactor.
---

# Test-Driven Development

## When to Use
Before writing ANY implementation code. Every feature, bugfix, or refactor starts with a test.

## Process

1. **Write a failing test** that describes the expected behavior
2. **Run the test** — confirm it fails for the right reason
3. **Write minimal code** to make the test pass — nothing more
4. **Run the test** — confirm it passes
5. **Refactor** if needed — tests must still pass
6. **Commit** — one logical change per commit

## Commands

```bash
bun test                      # Run all tests
bun test --watch              # Watch mode
bun test path/to/test.ts      # Run specific test file
```

## Key Principles

- Red, green, refactor — always in this order
- Tests describe BEHAVIOR, not implementation
- One assertion per test when possible
- Test names read like sentences: "should return empty array when no items match"
- Never write implementation code without a failing test first
- If you can't write a test for it, the design needs to change
