---
name: code-review
description: Use when reviewing code changes before committing or when asked to review a PR or diff.
---

# Code Review

## When to Use
Before committing changes. When reviewing diffs or PRs.

## Checklist

1. **Security** — no secrets, no injection vectors, no unsafe operations
2. **Correctness** — does it do what it claims? edge cases handled?
3. **Tests** — are changes tested? do existing tests still pass?
4. **Simplicity** — is this the simplest solution? any unnecessary complexity?
5. **Naming** — are names descriptive and consistent with codebase conventions?
6. **Types** — strict TypeScript? no `any`? no type assertions without justification?
7. **Error handling** — are errors handled at the right level? meaningful messages?
8. **Performance** — any obvious N+1 queries, unnecessary re-renders, or memory leaks?

## Key Principles

- Review the DIFF, not the whole file — focus on what changed
- Every comment should be actionable
- Distinguish between "must fix" and "nice to have"
- If you're unsure about a change, say so — don't silently approve
- Check that tests actually test the behavior, not just that they exist
