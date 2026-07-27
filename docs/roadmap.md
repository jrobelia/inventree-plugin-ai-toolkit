# Toolkit Roadmap

**Last updated:** July 27, 2026 (Call to Action and Next Action updated with PR #1 merge blocker: issue #3 / devserver fresh-install)
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
agent first reaches a clear plan (e.g., via the `/wayfinder` skill or an
equivalent planning mode) and then runs plugin-creator directly in the
terminal, answering its prompts from the plan docs -- no human sitting
through the wizard. Every code change is checked by one deterministic
command that chains a preflight environment check, unit tests, integration
tests against real InvenTree models, and Playwright tests against the
local frontend dev server (a known dataset loaded via InvenTree's own
`invoke dev.setup-test` is the goal once that command is reliable; until
then, tests rely on the dataset already present in the devcontainer).
Verifying a change never again means manually clicking through a remote
staging server.

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
template on top -- unit / integration / Playwright layers and fixtures.
This second step exists because `plugin-creator`'s own generated scaffold
has no `tests/` folder at all -- without it, every new plugin would reinvent
its test layout from scratch the way FlatBOMGenerator did by hand. `plugin-creator` itself is an upstream submodule and is never
forked or edited in place -- the toolkit's template layers on top of its
output after the fact. Solo, local-first dev doesn't need GitHub Actions to
run these tests, so the `new-inventree-plugin` skill explicitly selects
**None** for `plugin-creator`'s CI/DevOps wizard (overriding the upstream
default) and removes any generated `.github/workflows/` files. CI stays a
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
- Playwright test scaffolding for plugin frontends. (A known, reset
  dataset via `invoke dev.setup-test -i` is parked until the import is
  debugged.)
- One deterministic test command chaining preflight check -> unit ->
  integration -> Playwright, with clear, specific failure messages (not
  silent false passes).

### Strategic Expansions
*(Next evolution once the core loop is solid)*

- `new-inventree-plugin` skill: documents the scaffold process -- agent
  reaches a clear plan first (e.g., via `/wayfinder`), then runs
  plugin-creator's CLI and answers its prompts from the plan docs (DevOps
  wizard question: **None**), then applies the toolkit's test-scaffold
  template (`tests/`, `frontend/e2e/`) so the plugin has working local tests
  from day one.
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
- Auto-loading a known dataset on devcontainer creation. The demo dataset
  (`invoke dev.setup-test -i`) currently fails and wipes existing data, so it
  needs debugging. Longer term, consider a custom toolkit dataset tailored for
  plugin E2E tests instead of the generic InvenTree demo data.

---

## Iterative Milestones

| Milestone | Status | Defining Capability |
|---|---|---|
| **v2.0 -- Working Local Dev Loop** | current | Devcontainer and frontend dev server are configured, Playwright scaffolding exists, and `test-all.sh` is in place with preflight checks added, but the deterministic test command has not been verified end-to-end, the Playwright test is still generic, and auto-loading a known dataset is not yet reliable. |
| **v2.1 -- Agent-Driven Plugin Workflows** | next | Both skills exist and work: an agent can scaffold a new plugin unattended from a plan doc, and can verify a change to an existing plugin with the deterministic test command, no manual staging clicks. |
| **v2.2 -- Documented & Polished Factory** | future | README/SETUP rewritten to match reality, session-onboarding doc exists, `.github/` audited for token bloat, optional CI wired up as a stretch/parking-lot item if ever adopted. |

---

## Actionable Backlog

| # | Task | Milestone | Type | Status | Pass/fail condition |
|---|------|-----------|------|--------|---------------------|
| 1 | Adopt InvenTree's official devcontainer as the toolkit's dev environment, replacing `Setup-InvenTreeDev.ps1` / `Link-PluginToDev.ps1` | v2.0 | build | done | `.devcontainer/` replaces the PowerShell setup. It boots a custom Debian/Python image and uses `reference/inventree-source/contrib/container/init.sh`; it does not directly reuse the InvenTree source's own `.devcontainer/` image. FlatBOMGenerator is linked via the `/workspace/plugins` volume mount. |
| 2 | Configure local frontend dev server for FlatBOMGenerator inside the devcontainer | v2.0 | build | done | `frontend/vite.dev.config.ts` binds port `5174`; `devcontainer.json` forwards `5174`; `postCreateCommand.sh` installs `frontend` dependencies. Hot reload is configured but not yet verified end-to-end against the devcontainer backend. |
| 3 | Add Playwright test scaffolding to the plugin templates (known dataset parked) | v2.0 | build | partially done | `plugin-templates/frontend/e2e/example.spec.cjs` is now a generic login + parts-list test with a skipped plugin-panel template. `postCreateCommand.sh` does not run `invoke dev.setup-test -i` because the demo-data import fails and wipes existing data; auto-loading a known dataset is parked for debugging (see Future Vision). |
| 4 | Build one deterministic test command chaining preflight + unit + integration + Playwright | v2.0 | build | in-progress | `test-all.sh` in `plugin-templates/` and FlatBOMGenerator now preflights devcontainer environment (`INVENTREE_HOME`, `INVENTREE_PLUGIN_DIR`), plugin link (`$PWD` under `$INVENTREE_PLUGIN_DIR` and `$MODULE_NAME` directory exists), server health (`/api/system/health/`), and dataset presence (at least one Part). It emits specific failure messages. End-to-end verification against a running devcontainer is still pending. |
| 5 | Write `new-inventree-plugin` skill | v2.1 | build | in-progress | Skill documents the planning step (e.g., `/wayfinder`), runs `plugin-creator` with prompts answered from the plan docs, selects **None** for DevOps, and applies the toolkit's `plugin-templates/` test scaffold (`tests/`, `frontend/e2e/`) onto the generated plugin. |
| 6 | Write `improve-inventree-plugin` skill | v2.1 | build | in-progress | Skill centers every change on `./test-all.sh` and uses the actual plugin module name instead of hardcoding `flat_bom_generator`. |
| 7 | Align plugin-creator DevOps default with no-CI decision | v2.1 | cleanup | open | Submodule is pinned at `1.20.0`. `plugin_creator/template/cookiecutter.json` defaults `ci_support` to `github`, and `get_devops_mode()` defaults to **GitHub Actions**; the `new-inventree-plugin` skill must explicitly select **None** and remove any generated `.github/workflows/` files. |
| 8 | Rewrite `README.md` / `SETUP.md` for the devcontainer-based process | v2.2 | cleanup | done | README and SETUP are rewritten around the devcontainer workflow. Stale cross-references (e.g., `docs/reference/PLUGIN-DEVELOPMENT-WORKFLOW.md` pointing to `docs/skills/` and `plugins/README.md` referencing legacy PowerShell scripts) have been cleaned up. |
| 9 | Write a session-onboarding doc/instruction stating the exact plugin-dev process | v2.2 | cleanup | done | `docs/reference/SESSION-ONBOARDING.md` exists and lists the entry points, but it tells users to run E2E tests from the host while `test-all.sh` runs them from inside the devcontainer -- a workflow tension to resolve. |
| 10 | (Stretch) Add GitHub Actions CI running the deterministic test command | v2.2 | build | open | A PR triggers the test command in CI and reports pass/fail on the PR. |
| 11 | Audit `.github/instructions/` and `.github/prompts/` for token bloat: replace mechanically-checkable rules (formatting, type errors, PowerShell style) with linter/type-checker steps wired into the deterministic test command; prune or merge anything stale or duplicated by the new skills | v2.2 | cleanup | done | Toolkit root `.github/instructions/` and `.github/prompts/` token-bloat files are gone. `docs/reference/PLUGIN-DEVELOPMENT-WORKFLOW.md` and `plugins/README.md` no longer reference `C:\PythonProjects\...`, `inventree-dev/`, or the legacy PowerShell test scripts. `scripts/Test-Plugin.ps1` and `scripts/Test-Frontend.ps1` have been removed. |

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

1. **Resolve the devcontainer fresh-install blocker (GitHub issue #3).** The Dockerfile must not use InvenTree's production `init.sh` as its `ENTRYPOINT` (the container should start with `sleep infinity` and let `postCreateCommand.sh` handle one-time setup), `postCreateCommand.sh` must create the Python venv without `--upgrade-deps` and install `pip`/`setuptools`/`wheel`/`invoke` explicitly, and generated InvenTree data (`venv`, `config.yaml`, `static/`, `media/`, `backup/`) must be moved out of `reference/inventree-source/dev/` into a dedicated path or named volume. Verify with issue #3's acceptance test: on a clean container, `docker compose -f .devcontainer/docker-compose.yml up -d` and `docker compose exec toolkit bash .devcontainer/postCreateCommand.sh` complete, then `cd /workspace/reference/inventree-source && invoke dev.server -a 0.0.0.0:8001` responds `200` on `/api/system/health/`.
2. Verify task #4 end-to-end: with the devcontainer from step 1 actually running, run `./test-all.sh` from a plugin directory with the InvenTree server running and a populated dataset. The preflight checks are in place; confirm they emit clear failure messages when the environment is not ready and pass through to ruff/pytest/Playwright when it is.
3. Task #3 (Playwright / dataset): the generic E2E test template is in place. Auto-loading a known dataset via `invoke dev.setup-test -i` is parked; the demo-data import fails and wipes existing data, so it needs debugging before it can be wired into `postCreateCommand.sh`.
4. Only after the devcontainer blocker, task #4, and the Playwright dataset work are verified end-to-end, move to v2.1 skills (#5, #6) and the plugin-creator `None` default (#7).

---

## Call to Action

**The single merge blocker for PR #1 is GitHub issue #3 — the devcontainer fresh-install / `invoke dev.server` startup.** The devcontainer cannot finish on a fresh install because the Dockerfile still runs InvenTree's production `init.sh` as its `ENTRYPOINT`, `postCreateCommand.sh` creates the Python venv with `python3 -m venv --upgrade-deps` (which corrupts the venv), and generated InvenTree data is written into `reference/inventree-source/dev/`. Until those three problems are fixed, `cd /workspace/reference/inventree-source && invoke dev.server -a 0.0.0.0:8001` cannot reliably start and respond `200` on `/api/system/health/`. Do not merge PR #1 until issue #3 is closed and its server-readiness acceptance test passes.

**Why this blocks the whole roadmap:** v2.0 is "Working Local Dev Loop," and the loop cannot work if the devcontainer fails on first use. The preflighted `test-all.sh`, the Playwright E2E scaffolding, and the v2.1 agent-driven skills all depend on a repeatable `dev.server` startup. Resolving issue #3 is the prerequisite; everything else in the roadmap (including the current `in-progress` task #4 and the Playwright dataset work) is downstream verification.

**The risk of leaving it unaddressed:** merging PR #1 with a broken fresh-install path would ship a "reproducible devcontainer" that reproduces failure, not a working loop. Every roadmap milestone after v2.0 would be built on an environment that cannot start, and the deterministic test chain would continue to produce silent false-passes or confusing tool-level failures.
