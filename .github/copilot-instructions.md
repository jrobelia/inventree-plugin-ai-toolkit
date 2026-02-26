```instructions
# Workspace Ground Rules

## Who Is the User
- Mechanical engineer, not a software engineer.

## How to Work
- **Build features**: use the **Orchestrator** agent. It manages the full
  lifecycle: understand -> plan -> architect -> branch -> failing tests ->
  build -> review -> manual verify -> commit -> debrief. Do not skip it.
- **Debug problems**: use the **Debug** agent. Systematic 4-phase process.
- **Ad-hoc tasks**: use prompts directly (`/run [prompt-name]`).
- All other pipeline agents (test, code-review) are subagent-only.
- Manual verification is a hard gate -- never commit until the user confirms
  the feature works in the real environment.

## Code Quality
- Apply `.github/instructions/core/design-principles.instructions.md`
  silently and automatically. Explain only if asked.

## Living Documentation
- `docs/roadmap.md` -- feature wish list. Check before planning.
- `docs/architecture.md` -- module map. Update when files change.
- `docs/decisions.md` -- append-only log of non-obvious choices.
```
