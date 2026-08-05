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
- Shared domain language lives in `CONTEXT-MAP.md` and `C:\Software Projects\inventree-plugin-ai-toolkit\docs\reference\inventree-bom-build-buy-suite\`.
- Devin-specific skills live in `.devin/skills/` at the toolkit root. Shared/legacy skills remain in `.agents/skills/`.
- `reference/` contains the `inventree-source` and `plugin-creator` submodules; use them as live source code and pattern reference when implementing plugins.
- Use the devcontainer for consistent development and testing.

## Tooling and permissions

### Git

- One `Exec` call = one `git` command. No exceptions. (Per-subcommand approval scopes live in `.devin/config.json`. The `git_guard.py` PreToolUse hook that used to enforce this is archived under `.devin/archive/`.)
- The command string must be exactly `git <command> [args]` and nothing else. Do not run `git` alongside any other command, `git` or otherwise.
- Do not chain with `&&`, `;`, `|`, line breaks, subshells, or command substitution.
- The permission UI matches the whole command string; combining commands forces an all-or-nothing allow/deny decision on multiple git operations.
- If a sequence is needed (e.g. `git add` then `git commit`), run `git add` first, wait for the user response, then run `git commit` separately.
- Write commit messages inline with repeated `-m` flags so the user can read them in the approval prompt. Never write a scratch message file and use `-F`.
- The `Exec` working directory always resets to the toolkit root, so `cd` does not persist. To work in a plugin repo use `git -C plugins\<repo-name> <subcommand>` with that exact repo-relative form; `.devin/config.json` auto-approves `status`, `diff`, `log`, and `add` for it. Anything else prompts, which is intended.
- Use `git add -A` or `git add .` instead of listing specific file paths. The permission prefix matcher and the Windsurf linkifier both struggle with multi-argument paths that contain spaces or forward slashes.
- `git push` is most reliable as bare `git push` when an upstream is set. Explicit `git push origin <branch>` forms can hang the approval UI because Windsurf tries to turn the branch name or remote URL into a `cci:` file link.
- The `.devin/config.json` `ask` list was removed because `ask` permission cards did not render in Windsurf. Destructive git commands now fall back to the default prompt, which does render.

## Chat/file references

Do not use `<ref_file>` or `<ref_snippet>` XML citation tags. They are rendered as `cci://file://...` links by Devin Desktop / Windsurf, but those links are broken when Windows paths contain spaces (possible Devin Desktop / Windsurf bug; no exact known issue, but see Exafunction/codeium#327 for a related Windows file-link problem).

Use plain backtick paths instead. Safe forms:
- Simple filenames relative to the repo root: `AGENTS.md`
- Absolute Windows paths: `C:\Software Projects\inventree-plugin-ai-toolkit\CONTEXT.md`

Avoid forward-slash relative paths like `docs/agents/domain.md`; the IDE auto-links those and produces the same broken `cci:` links.

This also applies to command strings and assistant thoughts: if Windsurf tries to auto-link a path inside a `Command git` card or a thought, the malformed `cci:` link can freeze the approval prompt before it appears. Keep command strings free of absolute paths and forward-slash relative paths; use repo-relative backslash paths or simple filenames.
