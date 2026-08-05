# Toolkit Architecture

**Purpose:** Module map for the InvenTree Plugin Development Toolkit  
**Last Updated:** 2026-08-05

---

## Folder Structure

```
inventree-plugin-ai-toolkit/
+-- .devcontainer/              Docker Compose + Dockerfile dev environment (see `.devcontainer/README.md` for CLI usage)
+-- .devin/                      Devin-specific skills
+-- .agents/                     Shared/legacy AI agent skills
+-- config/                     Server connection settings
+-- docs/                       Living documents and references
+-- reference/                  Reference submodules
+--   plugin-creator/           Git submodule -- InvenTree's official scaffolding tool
+--   inventree-source/         Git submodule -- InvenTree source code
+-- plugin-templates/           Test-scaffold templates for new plugins
+-- plugins/                    Your plugin projects (each is its own git repo)
+-- scripts/                    Host helpers and devcontainer test runner
+-- AGENTS.md                   Agent interaction rules and cross-plugin discipline
+-- CONTEXT-MAP.md              Shared domain vocabulary map
+-- CONTEXT.md                  Toolkit purpose and boundaries
+-- README.md                   User-facing introduction
+-- SETUP.md                    First-time installation guide
```

---

## The Agent Skill System

AI-assisted workflows live in `.devin/skills/` (Devin skills) and `.agents/skills/` (shared/legacy skills). Devin's entry point for this repo is the root `AGENTS.md`.

- `.devin/skills/build-inventree-plugin/` — build a plugin wheel and frontend bundle inside the devcontainer
- `.devin/skills/deploy-inventree-plugin/` — deploy a built wheel to staging or production
- `.devin/skills/test-inventree-plugin/` — run the deterministic test chain
- `.agents/skills/new-inventree-plugin/` — scaffold a new plugin via `plugin-creator`
- `.agents/skills/improve-inventree-plugin/` — verify a change with the deterministic test command
- `.agents/skills/setup-matt-pocock-skills/` — configure issue tracker, triage labels, and domain docs
- `.agents/agent/test-agent.md` — legacy Cascade agent configuration (kept for reference)

---

## Scripts

All scripts assume you run them from the toolkit root.

| Script | Purpose |
|---|---|
| `run-test-all.sh` (toolkit root) | Discovers or starts the InvenTree server, then runs the plugin's `test-all.sh` in the devcontainer |
| `test-all.sh` (per plugin) | Deterministic chain called by `run-test-all.sh`: preflight check → unit → integration → Playwright |
| `New-Plugin.ps1` | Host-only helper that wraps `plugin-creator` (legacy; prefer `create-inventree-plugin` or `python -m plugin_creator.cli` in the devcontainer) |
| `build-plugin.sh` | Devcontainer build script: bump version, run pre-commit, build frontend, and create the `.whl` package |
| `Deploy-Plugin.ps1` | Windows host script that calls `build-plugin.sh` if needed and deploys a built `.whl` to a server from `config/servers.json` via SSH/SCP |
| `Setup-InvenTreeDev.ps1` | **Removed** — replaced by `.devcontainer/` |
| `Link-PluginToDev.ps1` | **Removed** — replaced by `.devcontainer/` |

---

## Docs

```
docs/
+-- architecture.md             This file (module map)
+-- decisions.md                Append-only log of non-obvious choices
+-- roadmap.md                  Toolkit-level feature wish list
+-- reference/                  How things work today
+-- planning/                   What we want to do next
+-- archive/                    Superseded docs (gitignored, local only)
```

---

## Plugin Layout

Each plugin lives in `plugins/` and follows this structure:

```
plugins/YourPlugin/
+-- __init__.py                 Package init with PLUGIN_VERSION
+-- CONTEXT.md                  Plugin domain glossary
+-- ARCHITECTURE.md             Plugin-specific architecture doc
+-- README.md                   User-facing features and installation
+-- pyproject.toml              Python packaging and dependencies
+-- flat_bom_generator/         (or your_package_name/)
|     core.py                     Plugin class with mixins
|     views.py                    API endpoints
|     serializers.py              DRF serializers
|     tests/                      Unit and integration tests
+-- frontend/                   React/TypeScript UI
|     src/Panel.tsx               Main panel component
|     e2e/                        Playwright end-to-end tests
+-- docs/                       Plugin planning and reference docs
|     adr/                        Plugin-specific decisions
```

---

## Data Flow: Build and Deploy

```
1. Edit code in `plugins/YourPlugin/`
2. Verify locally in the devcontainer:
   Run `bash scripts/run-test-all.sh /workspace/plugins/YourPlugin`
     -> checks for a healthy InvenTree server and starts one if needed
     -> runs the plugin's `test-all.sh`:
        - preflight check (devcontainer, dataset, plugin link)
        - `python -m pytest tests/unit`
        - `python -m pytest tests/integration`
        - `npm run test:e2e` (Playwright against the devcontainer frontend)
3. Build for remote deployment inside the devcontainer:
   ```bash
   bash scripts/build-plugin.sh /workspace/plugins/YourPlugin
   ```
4. Deploy to a selectable remote server from the Windows host:
   ```powershell
   .\scripts\Deploy-Plugin.ps1 -Plugin "YourPlugin" -Server staging
   ```
   - Uses `config/servers.json` to choose `staging` or `production`
5. Test on the remote staging server
6. Deploy to production when verified
```
