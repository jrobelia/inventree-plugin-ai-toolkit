## Agent skills

### Issue tracker

Track issues/PRDs in GitHub. See `docs/agents/issue-tracker.md`.

### Triage labels

Use the five canonical labels. See `docs/agents/triage-labels.md`.

### Domain docs

Multi-context: root `CONTEXT.md`/`CONTEXT-MAP.md`, shared reference contexts, and per-plugin `CONTEXT.md`/`docs/adr/`. See `docs/agents/domain.md`.

### Skill discipline
A skill is a mode (planning, research, grilling, implementation). While a skill is active, obey it literally and default to **planning and asking**, not doing.

- Follow the active skill's explicit instructions (plan-only, HITL, stop-after-X).
- Don't write implementation code during planning or research.
- Stop between skill steps and wait for the user before continuing.
- Ask and wait during HITL workflows (`/grilling`, `/prototype`, `/domain-modeling`).
- If a step could be planning or doing, ask before writing/editing files.
- Wayfinder: one ticket per session; research yields decision notes; map charting starts with `/grilling` + `/domain-modeling`.

## Session and handoff boundaries

- Stop when a skill says a phase is one session's work.
- "Continue" means continue the current step only, not the next ticket/phase.
- Stop on correction; fix the process and ask whether to resume or restart.
- Keep scratch work out of the repo unless agreed.

## User interaction

- The user is a mechanical engineer and domain expert; explain what you are doing.
- If a request is ambiguous or next steps are unclear, do not guess. Ask follow-up questions and wait.

## Toolkit context

- This repository is the InvenTree Plugin AI Toolkit.
- `plugins/` contains independent git repositories, one per plugin.
- Each plugin has its own `AGENTS.md` and `docs/agents/`; respect them when working inside a plugin directory.
- Shared domain language lives in `CONTEXT-MAP.md` and `docs/reference/inventree-plugin-trilogy/`.
- Agent skills live in `.agents/skills/` at the toolkit root.
- Use the devcontainer for consistent development and testing.

## Tooling and permissions

- Run `git` commands one at a time in separate `Exec` calls.
- Do not chain git commands with `&&`, `;`, or pipelines in a single `Exec` call.
- The permission UI matches the whole command string; chaining forces an all-or-nothing allow/deny decision on every git command in the chain.
- If a sequence is needed (e.g. `git add` then `git commit`), run `git add` first, wait for the user response, then run `git commit` separately.

## Chat/file references

Do not use `<ref_file>` or `<ref_snippet>` XML citation tags. They render as broken `cci:4://file://` links in Devin Desktop / Windsurf when Windows paths contain spaces. Use plain backtick paths (e.g. `C:\Software Projects\inventree-plugin-ai-toolkit\CONTEXT.md`) instead.
