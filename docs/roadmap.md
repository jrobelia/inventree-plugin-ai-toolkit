# Toolkit Roadmap

**Last updated:** July 23, 2026 (status review -- v2.0 core loop not yet fully verified)
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
| **v2.0 -- Working Local Dev Loop** | current | Devcontainer and frontend dev server are configured, Playwright scaffolding exists, and `test-all.sh` is in place, but the deterministic test command is not yet preflight-aware and the Playwright test does not yet exercise the plugin panel end-to-end. |
| **v2.1 -- Agent-Driven Plugin Workflows** | next | Both skills exist and work: an agent can scaffold a new plugin unattended, and can verify a change to an existing plugin with the deterministic test command, no manual staging clicks. |
| **v2.2 -- Documented & Polished Factory** | future | README/SETUP rewritten to match reality, session-onboarding doc exists, `.github/` audited for token bloat, optional CI wired up. |

---

## Actionable Backlog

| # | Task | Milestone | Type | Status | Pass/fail condition |
|---|------|-----------|------|--------|---------------------|
| 1 | Adopt InvenTree's official devcontainer as the toolkit's dev environment, replacing `Setup-InvenTreeDev.ps1` / `Link-PluginToDev.ps1` | v2.0 | build | done | `.devcontainer/` replaces the PowerShell setup. It boots a custom Debian/Python image and uses `reference/inventree-source/contrib/container/init.sh`; it does not directly reuse the InvenTree source's own `.devcontainer/` image. FlatBOMGenerator is linked via the `/workspace/plugins` volume mount. |
| 2 | Configure local frontend dev server for FlatBOMGenerator inside the devcontainer | v2.0 | build | done | `frontend/vite.dev.config.ts` binds port `5174`; `devcontainer.json` forwards `5174`; `postCreateCommand.sh` installs `frontend` dependencies. Hot reload is configured but not yet verified end-to-end against the devcontainer backend. |
| 3 | Add Playwright test scaffolding to FlatBOMGenerator's frontend, using `invoke dev.setup-test -i` for known data | v2.0 | build | in-progress | `frontend/e2e/` and `playwright.config.cjs` exist, but the example test only logs in and navigates to `/part/` -- it does not open the plugin panel or assert plugin-specific content. `postCreateCommand.sh` also does not run `invoke dev.setup-test -i` to load a known dataset. |
| 4 | Build one deterministic test command chaining preflight + unit + integration + Playwright | v2.0 | build | in-progress | `test-all.sh` exists in `plugin-templates/` and FlatBOMGenerator, but it has no preflight check for devcontainer health, dataset state, or plugin link. Failures will be generic tool errors, not the specific, clear messages required. |
| 5 | Write `new-inventree-plugin` skill | v2.1 | build | in-progress | Skill exists, but it still instructs the agent to guide a human through interactive prompts. It does not document the DevOps wizard default of **None**, nor the step of copying the toolkit's `plugin-templates/` test scaffold (`tests/`, `frontend/e2e/`, `TEST-PLAN.md`) onto the plugin after `plugin-creator` runs. |
| 6 | Write `improve-inventree-plugin` skill | v2.1 | build | in-progress | Skill exists and references `./test-all.sh`, but it hardcodes `flat_bom_generator` in the preflight example and does not tie every change to the deterministic test command from task #4. |
| 7 | Verify plugin-creator submodule is current | v2.1 | cleanup | open | Submodule is pinned at `1.20.0`. However, `plugin_creator/template/cookiecutter.json` defaults `ci_support` to `github`, and the interactive `get_devops_mode()` prompt defaults to **GitHub Actions**. The documented "answer **None** every time" is not yet enforced. |
| 8 | Rewrite `README.md` / `SETUP.md` for the devcontainer-based process | v2.2 | cleanup | done | README and SETUP are rewritten around the devcontainer workflow. Some stale cross-references remain (e.g., `docs/reference/PLUGIN-DEVELOPMENT-WORKFLOW.md` still points to `docs/skills/`). |
| 9 | Write a session-onboarding doc/instruction stating the exact plugin-dev process | v2.2 | cleanup | done | `docs/reference/SESSION-ONBOARDING.md` exists and lists the entry points, but it tells users to run E2E tests from the host while `test-all.sh` runs them from inside the devcontainer -- a workflow tension to resolve. |
| 10 | (Stretch) Add GitHub Actions CI running the deterministic test command | v2.2 | build | open | A PR triggers the test command in CI and reports pass/fail on the PR. |
| 11 | Audit `.github/instructions/` and `.github/prompts/` for token bloat: replace mechanically-checkable rules (formatting, type errors, PowerShell style) with a linter/type-checker/pre-commit hook wired into the deterministic test command; prune or merge anything stale or duplicated by the new skills | v2.2 | cleanup | partially done | Toolkit root `.github/` is gone, but stale docs (`docs/reference/PLUGIN-DEVELOPMENT-WORKFLOW.md`, `plugins/README.md`) still reference `C:\PythonProjects\...`, `inventree-dev/`, and the legacy PowerShell scripts. Legacy scripts `scripts/Test-Plugin.ps1` and `scripts/Test-Frontend.ps1` still contain broken `inventree-dev` paths. |

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

Close the v2.0 core loop before moving to v2.1:

1. Finish task #4: add a real preflight step to `test-all.sh` that checks the devcontainer is running, the plugin is linked, and the dataset is loaded (`invoke dev.setup-test -i`) before invoking ruff/pytest/Playwright, and emits specific failure messages.
2. Finish task #3: replace the generic login Playwright test with one that opens the FlatBOMGenerator panel on a part page and asserts plugin-specific content, then wire `invoke dev.setup-test -i` into the devcontainer setup.
3. Clean up task #11: archive or update `docs/reference/PLUGIN-DEVELOPMENT-WORKFLOW.md` and `plugins/README.md` so they no longer reference `C:\PythonProjects\...`, `inventree-dev/`, or the legacy PowerShell scripts.
4. Only after #3 and #4 are verified end-to-end, move to v2.1 skills (#5, #6) and the plugin-creator `None` default (#7).

---

## Call to Action

**The single most critical gap:** the deterministic test command (`test-all.sh`) has no preflight checks. A missing devcontainer, missing dataset, or unlinked plugin will produce confusing tool-level failures instead of a clear "environment is not ready" message, which still makes integration/Playwright results unreliable and wastes debugging time.

**The risk of leaving it unaddressed:** every session that runs the test chain is one silent false-pass or misleading failure away from drift, and v2.1's agent-driven skills cannot be trusted until the underlying v2.0 loop is truly deterministic.
