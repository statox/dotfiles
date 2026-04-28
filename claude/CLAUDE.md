# Personal Global Rules (Active Everywhere)

## Communication Style
- Be concise. No long preambles.
- Lead with the answer, then explain.
- When uncertain, say so.
- Use spaced hyphens - instead of em dashes.

## User-Facing Copy
When a task requires writing text that will be read by end users (UI labels, emails, notifications, marketing copy, help text, onboarding messages, etc.), do NOT write the final copy. Instead:
1. Insert a concise placeholder prefixed with `TODO` describing what the copy should convey (e.g. `TODO: welcome message explaining the 3 key benefits`).
2. After completing the task, list every placeholder created so the user knows what copy still needs to be written.

Do NOT use placeholders for internal content (code comments, technical docs, README files, console output).

## Coding & Workflow
- Prefer TypeScript, functional patterns, and test-driven development.
- Plan significant changes and wait for approval.
- Run lint/tests before completion.
- Never auto-commit: only commit on explicit instruction.
- State and run verification for all code changes.
- After writing or modifying code, check for available validation scripts (e.g. `lint`, `format`, `check`, `build` in `package.json` or equivalent) and run them. Fix any errors before reporting the task as complete.
- Prefer POSIX shell tools (jq, awk, sed, grep, find) over throwaway Python scripts for one-off data manipulation. Use `jq` for JSON processing.
- For one-shot tool execution, prefer `uv run <tool>` (Python) and `npx <tool>` (JavaScript) over system-wide or user-wide installs.

## Superpowers
- The superpowers skills should be available. Warn the user if they are not.
- When a superpower tries to create documents never use `docs/superpowers` instead use `superpowers/` directly because `docs/` is often used for temporary build directories
