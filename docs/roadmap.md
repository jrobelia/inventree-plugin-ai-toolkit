# Toolkit Roadmap

**Last updated:** July 23, 2026 (Iteration 2 - status sync)
**Purpose:** Feature wish list for the toolkit itself (not individual plugins)

**Note:** Iteration 1 (February 2026) is archived at
[docs/archive/toolkit/roadmap-2026-02.md](archive/toolkit/roadmap-2026-02.md).
This iteration is a deliberate "v2" reset -- treat everything below as the
current source of truth, not the archived version.

---

## Project North Star

A user tells an agent (or the agent self-selects via a skill) "I want to
build a new plugin" or "I want to improve this existing plugin." The
toolkit runs both workflows inside InvenTree's own official devcontainer,
so the dev environment can't drift out of sync with the host machine the
way the old PowerShell-based setup did. Scaffolding a new plugin means the
agent runs plugin-creator directly in the terminal and answers its prompts
from the plugin's plan docs -- no human sitting through the wizard. Every
code change is checked by one deterministic command that chains a
preflight environment check, unit tests, integration tests against real
InvenTree models, and Playwright tests against the local frontend dev
server (with a known dataset loaded via InvenTree's own
`invoke dev.setup-test`). Verifying a change never again means manually
clicking through a remote staging server.

The toolkit does **not** replace InvenTree's own documentation or judgment
calls on plugin architecture, does not attempt to cover every possible
plugin type equally, and does not require a hosted CI service to be useful
for solo, local-first work. It optimizes specifically for two workflows:
building new plugins, and improving existing ones -- with determinism
coming from the scripts and checks themselves, not from an agent's memory
of the process.

**Ownership boundary:** each plugin is a fully independent repo, responsible
for its own code, build, and lint config once scaffolded (FlatBOMGenerator
already owns its own `pyproject.toml`/ruff and `package.json`/biome/vitest --
it needs none of the toolkit's help to build or lint itself). The toolkit's
job is the handful of things that genuinely can't live in a single plugin's
repo: the shared InvenTree dev/test environment (the devcontainer), deploy
orchestration to real servers (shared `config/servers.json`), and
scaffolding. Scaffolding is two steps, not one: run official `plugin-creator`
for the base plugin structure, then apply the toolkit's own test-scaffold
template on top -- unit / integration / Playwright layers, fixtures, and
`TEST-PLAN.md`. This second step exists because `plugin-creator`'s own
generated scaffold has no `tests/` folder at all -- without it, every new
plugin would reinvent its test layout from scratch the way FlatBOMGenerator
did by hand. `plugin-creator` itself is an upstream submodule and is never
forked or edited in place -- the toolkit's template layers on top of its
output after the fact. Solo, local-first dev doesn't need GitHub Actions to
run these tests, so `plugin-creator`'s CI/DevOps wizard question defaults to
**None** -- no `.github/workflows/` generated at all -- and CI stays a
parking-lot stretch goal, not part of the core loop.

---

## The Feature Lab

### Immediate Gaps
*(MVP fixes -- the core loop doesn't work without these)*

- Replace the current PowerShell-based `inventree-dev/` setup (broken,
  stale absolute paths from a folder rename) with InvenTree's official
  devcontainer.
- Local frontend dev server (`plugin_dev` config + `npm run dev`) running
  against the devcontainer instance, with hot reload.
- Playwright test scaffolding for plugin frontends, using InvenTree's
  `invoke dev.setup-test -i` for a known, reset dataset.
- One deterministic test command chaining preflight check -> unit ->
  integration -> Playwright, with clear, specific failure messages (not
  silent false passes).

### Strategic Expansions
*(Next evolution once the core loop is solid)*

- `new-inventree-plugin` skill: documents the scaffold process -- agent runs
  plugin-creator's CLI directly, answers its prompts from the plugin's plan
  docs (DevOps wizard question: **None**), then copies in the toolkit's
  test-scaffold template (unit / integration / Playwright layers, fixtures,
  `TEST-PLAN.md`) so the plugin has working local tests from day one.
- `improve-inventree-plugin` skill: documents the change -> deterministic-
  test loop for existing plugins.
- Remote deployment to selectable servers: keep `Deploy-Plugin.ps1` driven by
  `config/servers.json` for staging and production; the devcontainer is for
  local dev/test only, not a deploy target.
- Confirm plugin-creator submodule is current with the toolkit's
  documented default answers (DevOps wizard: None).

### Future Vision / Parking Lot

- GitHub Actions CI running the deterministic test command on every push
  (stretch goal -- not required for solo local-first work).
- Wayfinder-style GitHub issue tracking for backlog items, if a tracker
  gets set up for this repo (parked mid-session; not evaluated this
  iteration).
- Any additional official InvenTree plugin-dev tooling not yet surfaced --
  revisit if InvenTree's docs add new tools.

---

## Iterative Milestones

| Milestone | Status | Defining Capability |
|---|---|---|
| **v2.0 -- Working Local Dev Loop** | current | Devcontainer running, local frontend dev server live, Playwright scaffolded, one deterministic test command works end-to-end for FlatBOMGenerator (the pilot plugin). |
| **v2.1 -- Agent-Driven Plugin Workflows** | next | Both skills exist and work: an agent can scaffold a new plugin unattended, and can verify a change to an existing plugin with the deterministic test command, no manual staging clicks. |
| **v2.2 -- Documented & Polished Factory** | future | README/SETUP rewritten to match reality, session-onboarding doc exists, `.github/` audited for token bloat, optional CI wired up. |

---

## Actionable Backlog

| # | Task | Milestone | Type | Status | Pass/fail condition |
|---|------|-----------|------|--------|---------------------|
| 1 | Adopt InvenTree's official devcontainer as the toolkit's dev environment, replacing `Setup-InvenTreeDev.ps1` / `Link-PluginToDev.ps1` | v2.0 | build | done | Devcontainer boots; InvenTree backend runs inside it (`invoke dev.server`); FlatBOMGenerator is linked and active inside the container. |
| 2 | Configure local frontend dev server for FlatBOMGenerator inside the devcontainer | v2.0 | build | done | Editing `Panel.tsx` hot-reloads in the browser against the devcontainer's InvenTree instance, no build/deploy step needed. |
| 3 | Add Playwright test scaffolding to FlatBOMGenerator's frontend, using `invoke dev.setup-test -i` for known data | v2.0 | build | in-progress | A first Playwright test opens the plugin's panel on a part page, asserts visible content, and passes headless. |
| 4 | Build one deterministic test command chaining preflight + unit + integration + Playwright | v2.0 | build | in-progress | Running the command on a known-good state returns a single pass/fail verdict; a broken devcontainer/dataset/link produces a specific, clear failure -- never a false pass. |
| 5 | Write `new-inventree-plugin` skill | v2.1 | build | done | Following the skill's steps, an agent scaffolds a plugin via plugin-creator's CLI (DevOps wizard: None), answering all prompts from a supplied plan doc, then applies the toolkit's test-scaffold template so the new plugin has working unit/integration/Playwright tests -- with no human interaction. |
| 6 | Write `improve-inventree-plugin` skill | v2.1 | build | done | Following the skill's steps, an agent runs the deterministic test command (task #4) before considering any change complete. |
| 7 | Verify plugin-creator submodule is current | v2.1 | cleanup | open | Submodule pinned to a version matching documented CLI behavior; DevOps wizard question is answered **None** every time (decided -- solo local-first dev doesn't need generated GitHub Actions/GitLab CI). |
| 8 | Rewrite `README.md` / `SETUP.md` for the devcontainer-based process | v2.2 | cleanup | done | A fresh user following README + SETUP alone reaches a working devcontainer with a linked plugin, no missing steps. |
| 9 | Write a session-onboarding doc/instruction stating the exact plugin-dev process | v2.2 | cleanup | done | A brand-new chat session, given only the workspace, can state the two entry-point skills and the deterministic test command without the user re-explaining it. |
| 10 | (Stretch) Add GitHub Actions CI running the deterministic test command | v2.2 | build | open | A PR triggers the test command in CI and reports pass/fail on the PR. |
| 11 | Audit `.github/instructions/` and `.github/prompts/` for token bloat: replace mechanically-checkable rules (formatting, type errors, PowerShell style) with a linter/type-checker/pre-commit hook wired into the deterministic test command; prune or merge anything stale or duplicated by the new skills | v2.2 | cleanup | partially done / closed | The `.github` submodule was removed; no `.github/instructions/` or `.github/prompts/` remain to audit. |

---

## Architectural Impact

The v2.0 architecture is now reflected in `docs/architecture.md`:

- `inventree-dev/` (PowerShell-managed clone) replaced by a `.devcontainer/`-based environment.
- Playwright tests are located in each plugin's `frontend/e2e/`.
- `test-all.sh` is the per-plugin deterministic test command (run inside the devcontainer).
- `Setup-InvenTreeDev.ps1` and `Link-PluginToDev.ps1` are removed.
- `Build-Plugin.ps1` / `Deploy-Plugin.ps1` are the remote-only deployment path, not the local dev loop.

---

## Next Action

Continue closing the v2.0 core loop: finish tasks #3 and #4, then verify
the remote deployment path with `Deploy-Plugin.ps1`.

---

## Call to Action

**The single most critical gap:** the current dev environment's hardcoded
absolute paths point at a folder that no longer exists (the project was
moved from `C:\PythonProjects\...` to `C:\SoftwareProjects\...`), which is
very likely why integration tests "usually don't run correctly" today.

**The risk of leaving it unaddressed:** every session that runs
integration tests is getting silently unreliable results -- false
confidence at best, wasted debugging time at worst -- and it blocks every
other piece of this roadmap (local frontend loop, Playwright, the
deterministic test command) that depends on a working dev environment
underneath it.
