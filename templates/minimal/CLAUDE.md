# Project Guidelines

## Security — Non-Negotiable
- NEVER commit secrets, API keys, tokens, or credentials to git
- NEVER write .env files with real values — use .env.example with placeholders
- NEVER expose internal URLs, IPs, or infrastructure details in code or comments
- ALWAYS check `git diff --staged` before every commit for accidental secret inclusion
- NEVER read or access ~/.ssh, ~/.gnupg, ~/.aws — the sandbox blocks this, but don't try

## Code Quality
- Bun is the runtime and package manager — not npm, yarn, or pnpm
- TypeScript strict mode is mandatory — no `any`, no `@ts-ignore`, no `@ts-expect-error`
- Format and lint with Biome — no Prettier, no ESLint
- Tests go in `__tests__/` directories co-located with source files
- Use `bun test` for testing — no Jest, no Vitest

## Git Discipline
- Conventional commits: `feat:`, `fix:`, `chore:`, `docs:`, `refactor:`, `test:`
- One logical change per commit — small, focused commits
- Never force-push to main or shared branches
- Never amend commits that have been pushed
- Write commit messages that explain WHY, not just WHAT

## Architecture Principles
- Keep it simple — no premature abstractions
- Prefer flat file structures over deep nesting
- Co-locate related files (component + test + types in same directory)
- No unused code — delete it, don't comment it out
- No barrel files (index.ts re-exports) unless there's a clear public API boundary

## When Stuck
- Read the full error message before guessing at fixes
- Check existing code for patterns before inventing new ones
- Ask the user rather than making assumptions about requirements
- Run the tests before and after every change
