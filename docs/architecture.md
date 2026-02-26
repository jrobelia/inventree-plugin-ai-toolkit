# Toolkit Architecture

**Purpose:** Module map for the InvenTree Plugin Development Toolkit  
**Last Updated:** February 26, 2026

---

## Folder Structure

```
inventree-plugin-ai-toolkit/
+-- .github/                    AI agent system (instructions, prompts, agents)
+-- config/                     Server connection settings
+-- docs/                       Living documents, references, and planning
+-- inventree-dev/              Local InvenTree dev environment (for integration tests)
+-- plugin-creator/             Git submodule -- InvenTree's official scaffolding tool
+-- plugins/                    Your plugin projects (each is its own git repo)
+-- scripts/                    PowerShell automation scripts
+-- QUICK-REFERENCE.md          Copy-paste command cheat sheet
+-- README.md                   User-facing introduction
+-- SETUP.md                    First-time installation guide
```

---

## The `.github/` System

This is the AI agent library. GitHub Copilot auto-discovers
`.github/copilot-instructions.md` and loads the rest on demand.

### How the pieces fit together

```
copilot-instructions.md          Entry point -- workspace ground rules
        |
        v
instructions/                    Always-on coding rules (loaded by file pattern)
  core/                            Language and practice rules
    agent-behavior                   How to communicate with the user
    design-principles                SOLID, DRY, KISS, YAGNI
    python                           PEP 8, type hints, fail-fast
    powershell                       PS 5.1 conventions
    typescript                       Strict mode, React hooks
    testing                          AAA pattern, naming, TDD workflow
  domain/                          InvenTree-specific patterns
    django-api                       DRF serializers, APIView
    django-testing                   URL 404 gotcha, as_view() pattern
    inventree-plugin                 Plugin class, mixins, settings
    inventree-packaging              pyproject.toml, entry points
    inventree-custom-states          Custom states (database-driven, not plugins)
    react-inventree                  InvenTree context, Mantine, Vite
    yaml-fixtures                    MPTT fields, BomItem fixtures
        |
        v
prompts/                         On-demand workflows (invoked explicitly)
  01-intake                        Stage 1: capture the problem
  02-plan                          Stage 2: break into steps
  03-architect                     Stage 3: design file structure
  04-build                         Stage 4: implement with TDD
  05-debrief                       Stage 5: post-build reflection
  06-git                           Git conventions (branch, commit)
  inventree-plugin-build           Build workflow
  inventree-plugin-deploy          Deploy workflow
  inventree-plugin-test            Test workflow
  inventree-review                 InvenTree-specific code review
  debug-solidworks                 SolidWorks macro debugging
        |
        v
agents/                          Persistent personas (manage multi-step work)
  orchestrator                     Full pipeline: understand -> build -> verify
  debug                            4-phase systematic debugging
  test                             RED phase: write failing tests
  code-review                      Quality and spec check
```

### When each piece loads

| Type | Loaded when | Example |
|---|---|---|
| Instructions | Automatically, when editing matching files | `python.instructions.md` loads for `*.py` |
| Prompts | Explicitly, via `/run [prompt-name]` | `/run inventree-plugin-deploy` |
| Agents | Explicitly, via `@agent [name]` or subagent call | `@agent orchestrator` |

---

## Scripts

All scripts assume you run them from the toolkit root.

| Script | Purpose |
|---|---|
| `New-Plugin.ps1` | Scaffold a new plugin using plugin-creator |
| `Build-Plugin.ps1` | Build Python package + frontend bundle |
| `Deploy-Plugin.ps1` | Build + copy to server (calls Build automatically) |
| `Test-Plugin.ps1` | Run unit or integration tests |
| `Test-Frontend.ps1` | Run vitest + TypeScript checks |
| `Setup-InvenTreeDev.ps1` | One-time: set up local InvenTree dev environment |
| `Link-PluginToDev.ps1` | One-time: symlink a plugin into the dev environment |

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
+-- docs/                       Plugin planning and reference docs
```

---

## Data Flow: Build and Deploy

```
1. Edit code in plugins/YourPlugin/
2. Run Build-Plugin.ps1
     -> npm run build (frontend -> static/Panel.js)
     -> python -m build (package -> dist/*.whl)
3. Run Deploy-Plugin.ps1 -Server staging
     -> Calls Build-Plugin.ps1 automatically
     -> Copies .whl to server via SSH/UNC path
     -> Server restarts InvenTree to load new version
4. Test on staging server
5. Deploy to production when verified
```
