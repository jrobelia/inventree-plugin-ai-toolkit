# .github -- Agentic Coding Setup

Optimised GitHub Copilot configuration for AI-assisted development.
Two layers: **Core** (any project) + **Domain** (InvenTree-specific).

---

## How It Works

| File Type | When Loaded | Put Here |
|---|---|---|
| `copilot-instructions.md` | Every chat | Routing + project context only (~24 lines) |
| `instructions/**/*.md` | Auto by `applyTo` pattern | Coding standards, language patterns |
| `agents/*.md` | When user invokes | Pipeline roles (orchestrator, debug) |
| `prompts/*.md` | When user invokes | Reusable workflow steps |

**Subfolder support:** `instructions/` supports subfolders (documented by
GitHub). `agents/` and `prompts/` must stay flat.

---

## File Map (28 files)

### Always Loaded (Every Chat)

| File | Lines | Purpose |
|---|---|---|
| `copilot-instructions.md` | ~24 | Agent routing, user context, living docs pointers |

### Core Instructions (`instructions/core/`)

Auto-loaded by `applyTo` pattern. Project-agnostic -- works for any codebase.

| File | `applyTo` | Purpose |
|---|---|---|
| `design-principles` | `**` | SOLID, DRY, KISS, TDD methodology |
| `agent-behavior` | `**` | Taming copilot, surgical edits, communication |
| `python` | `**/*.py` | PEP 8, fail-fast philosophy |
| `typescript` | `**/*.ts,tsx` | Strict mode, React hooks, component patterns |
| `testing` | `**/test_*` | AAA pattern, naming, quality grades |
| `powershell` | `**/*.ps1` | Cmdlet patterns, error handling, encoding |

### Domain Instructions (`instructions/domain/`)

Auto-loaded by `applyTo` pattern. InvenTree-specific -- delete for other projects.

| File | `applyTo` | Purpose |
|---|---|---|
| `django-api` | `**/views.py, serializers.py, urls.py` | DRF serializers, APIView, QuerySet optimisation |
| `django-testing` | `**/test_*.py` | `as_view()` gotcha, YAML fixtures, MPTT fields |
| `inventree-plugin` | `**/core.py, plugin.py, __init__.py` | Mixins, settings, entry points, events |
| `react-inventree` | `frontend/src/**, vite.config.*` | InvenTree context, Vite build, externals |
| `inventree-packaging` | `**/pyproject.toml` | Entry points, versioning, MANIFEST.in |
| `yaml-fixtures` | `**/*.yaml, *.yml` | MPTT fields, BomItem bypass, fixture loading |

### Agents (Loaded When Invoked)

| Agent | Invokable By | Purpose |
|---|---|---|
| `orchestrator` | User | 10-stage pipeline: understand -> plan -> design -> branch -> tests -> build -> review -> verify -> commit -> debrief |
| `debug` | User | 4-phase: reproduce -> root cause -> fix minimally -> verify |
| `test` | Orchestrator only | TDD RED phase: write failing tests before implementation |
| `code-review` | Orchestrator only | 3-stage: spec compliance, code + test quality, verification |

### Prompts

**Pipeline** (numbered to show stage order):

| Prompt | Pipeline Stage | Ad-Hoc |
|---|---|---|
| `01-intake` | Stage 1 | `/run 01-intake` |
| `02-plan` | Stage 2 | `/run 02-plan` |
| `03-architect` | Stage 3 | `/run 03-architect` |
| `04-build` | Stage 6 | `/run 04-build` |
| `05-debrief` | Stage 10 | `/run 05-debrief` |
| `06-git` | Stages 4, 9 | `/run 06-git` |

**Domain** (InvenTree-specific, prefixed `inventree-`):

| Prompt | Usage |
|---|---|
| `inventree-plugin-build` | `/run inventree-plugin-build` -- guided Build-Plugin.ps1 |
| `inventree-plugin-test` | `/run inventree-plugin-test` -- unit + integration test runner |
| `inventree-plugin-deploy` | `/run inventree-plugin-deploy` -- safe deployment with checks |
| `inventree-review` | `/run inventree-review` -- domain review checklist |

**Debug** (app-specific debugging techniques):

| Prompt | Usage |
|---|---|
| `debug-solidworks` | `/run debug-solidworks` -- COM host logging for SolidWorks add-ins |

---

## Usage Quick Reference

### Build a feature (full pipeline)
```
@orchestrator
I want to add a BOM export button to the part detail page.
```

### Fix a bug (systematic debugging)
```
@debug
The plugin crashes when I click "Generate BOM" on a part with no sub-parts.
```

### Run domain checks
```
/run inventree-review
/run inventree-plugin-build
/run inventree-plugin-deploy
```

---

## Adapting for Other Projects

### To use the Core layer only (non-InvenTree project):

Delete the domain folder and domain files:
- `instructions/domain/` (entire folder)
- `prompts/inventree-plugin-build.prompt.md`
- `prompts/inventree-plugin-test.prompt.md`
- `prompts/inventree-plugin-deploy.prompt.md`
- `prompts/inventree-review.prompt.md`

The core pipeline (orchestrator, debug, test, code-review) and universal
instructions (`instructions/core/`) work for any project.

### To add domain knowledge for a different framework:

1. Create `instructions/domain/{framework}.instructions.md` with an
   appropriate `applyTo` pattern.
2. Optionally create domain prompts in `prompts/`.
3. The core pipeline automatically picks up domain instructions when
   relevant files are edited.

---

## Design Decisions

| Decision | Reason |
|---|---|
| `copilot-instructions.md` is ~24 lines | Loaded every chat -- minimal context cost |
| Instructions use `applyTo` patterns | Zero cost when editing unrelated files |
| Instructions split into `core/` and `domain/` | Clean separation; drop domain for other projects |
| Agents/prompts stay flat | Subfolders not supported for these directories |
| DRF in domain, not core | Framework-specific; a Flask project would get wrong guidance |
| No standalone InvenTree agent | Domain knowledge auto-loads via instructions; review checklist is a prompt |
| Pipeline prompts numbered 01-06 | Shows stage order at a glance; sorts naturally in file explorer |
| Domain prompts prefixed `inventree-` | Instantly distinguishes core from domain without subfolders |
| Three always-loaded files have zero overlap | copilot-instructions = routing; agent-behavior = HOW; design-principles = WHAT |
| Test generation in test agent | Agent already handles test creation; separate prompt was redundant |
| Test quality review in code-review agent | Code review already assesses quality; separate prompt was a subset |
| Orchestrator owns the pipeline | Single point of control prevents skipped steps |
| Test + code-review are subagent-only | Pipeline ensures proper sequencing |
