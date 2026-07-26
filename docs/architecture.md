# Toolkit Architecture

**Purpose:** Module map for the InvenTree Plugin Development Toolkit  
**Last Updated:** July 23, 2026

---

## Folder Structure

```
inventree-plugin-ai-toolkit/
+-- .devcontainer/              Official InvenTree devcontainer configuration
+-- .agents/                     AI agent workflows and skills
+-- config/                     Server connection settings
+-- docs/                       Living documents, references, and planning
+-- reference/                  Reference submodules
+--   plugin-creator/           Git submodule -- InvenTree's official scaffolding tool
+--   inventree-source/         Git submodule -- InvenTree source code
+-- plugin-templates/           Test-scaffold templates for new plugins
+-- plugins/                    Your plugin projects (each is its own git repo)
+-- scripts/                    PowerShell helpers for remote build/deploy and scaffolding
+-- QUICK-REFERENCE.md          Copy-paste command cheat sheet
+-- README.md                   User-facing introduction
+-- SETUP.md                    First-time installation guide
```

---

## The `.agents/` System

AI-assisted workflows live in `.agents/skills/`. Devin's entry point for this repo is the root `AGENTS.md`.

- `.agents/skills/new-inventree-plugin/` — scaffold a new plugin via `plugin-creator`
- `.agents/skills/improve-inventree-plugin/` — verify a change with the deterministic test command
- `.agents/skills/setup-matt-pocock-skills/` — configure issue tracker, triage labels, and domain docs
- `.agents/agent/test-agent.md` — legacy Cascade agent configuration (kept for reference)

---

## Scripts

All scripts assume you run them from the toolkit root.

| Script | Purpose |
|---|---|
| `test-all.sh` (per plugin) | Deterministic chain: preflight check → unit → integration → Playwright (run inside the devcontainer) |
| `New-Plugin.ps1` | Host-only helper that wraps `plugin-creator` (legacy, prefer `plugin_creator/main.py` in the devcontainer) |
| `Build-Plugin.ps1` | Host-only helper to build the `.whl` + frontend bundle before remote deployment |
| `Deploy-Plugin.ps1` | Deploy a built `.whl` to a selectable remote server from `config/servers.json` via SSH/SCP |
| `Test-Plugin.ps1` | **Superseded** — legacy unit/integration test runner |
| `Test-Frontend.ps1` | **Superseded** — legacy frontend test runner |
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
   Run `./test-all.sh` in the plugin directory
     -> preflight check (devcontainer, dataset, plugin link)
     -> `python -m pytest tests/unit`
     -> `python -m pytest tests/integration`
     -> `npm run test:e2e` (Playwright against the devcontainer frontend)
3. Build for remote deployment:
   - Inside the devcontainer: `python -m build` (and `npm run build` for frontend)
   - On a Windows host: `scripts/Build-Plugin.ps1 -Plugin YourPlugin`
4. Deploy to a selectable remote server:
   - `scripts/Deploy-Plugin.ps1 -Plugin YourPlugin -Server staging`
   - Uses `config/servers.json` to choose `staging` or `production`
5. Test on the remote staging server
6. Deploy to production when verified
```
