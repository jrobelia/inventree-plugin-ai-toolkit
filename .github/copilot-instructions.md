# GitHub Copilot Instructions

**Audience:** AI Agents (GitHub Copilot) | **Category:** Quick Reference | **Purpose:** Auto-discovered entry point for GitHub Copilot agents | **Last Updated:** 2025-12-19

**This file is automatically read by GitHub Copilot to provide context about this project.**

---

## GitHub Copilot Agent

**For comprehensive InvenTree plugin development assistance**, invoke the specialized agent:

```
@workspace /agent inventree-plugin
```

**Agent Features**:
- Expert guidance on plugin architecture and patterns
- Code review for InvenTree compatibility and best practices
- Fail-fast philosophy enforcement (avoid defensive bugs)
- Testing strategies (unit + integration, code-first + test-first)
- Critical gotcha detection (plugin URLs, externalized deps, entry points)

**Documentation**: See [.github/agents/README.md](.github/agents/README.md)

---

## Quick Start for AI Agents

When working in this workspace, **always review these files first**:

1. **`copilot/AGENT-BEHAVIOR.md`** - How to communicate with the user and generate code
2. **`copilot/PROJECT-CONTEXT.md`** - Project architecture, folder structure, and technical patterns
3. **`copilot/plugin-creation-prompts.md`** - Ready-to-use prompts for plugin creation

---

## Project Type

This is an **InvenTree Plugin Development Toolkit** - a lightweight workspace for creating and deploying InvenTree plugins.

---

## Key Guidelines

### Communication Style
- **User is a mechanical engineer** with intermediate Python skills and beginner frontend experience
- Use **plain English** - explain software concepts simply
- Provide **complete examples** with step-by-step instructions
- **No emoji in code** (use ASCII prefixes like `[INFO]`, `[OK]`, `[ERROR]`)
- **MANDATORY todo lists** for multi-step work (3+ steps, 5+ files, 30+ minutes)
- **Commit after EVERY verified checkpoint** (tests pass, build succeeds, manual test confirms)
- **Test incrementally** - Never stack unverified changes
- See `copilot/AGENT-BEHAVIOR.md` for detailed communication guidelines
- See `copilot/DEVELOPMENT-WORKFLOW.md` for universal development workflow

### Architecture
- **Toolkit root**: PowerShell scripts for building/deploying plugins
- **Active development**: `plugins/` folder
- **Reference examples**: `reference/` folder (NOT deployed)
- **Backend**: Python/Django with InvenTree plugin mixins
- **Frontend**: React 19 + TypeScript + Mantine 8 + Vite 6
- See `copilot/PROJECT-CONTEXT.md` for complete architecture

### Common Tasks
- **Create plugin**: `.\scripts\New-Plugin.ps1` (interactive)
- **Build plugin**: `.\scripts\Build-Plugin.ps1 -Plugin "PluginName"`
- **Deploy plugin**: `.\scripts\Deploy-Plugin.ps1 -Plugin "PluginName" -Server "staging"`
- **Run unit tests**: `.\scripts\Test-Plugin.ps1 -Plugin "PluginName" -Unit` (fast)
- **Run integration tests**: `.\scripts\Test-Plugin.ps1 -Plugin "PluginName" -Integration` (requires setup)
- **Set up integration testing**: `.\scripts\Setup-InvenTreeDev.ps1` (one-time)
- See `QUICK-REFERENCE.md` for command reference

### Workflow Discipline (MANDATORY)
**Agents MUST follow incremental verification workflow:**

1. **Before starting** - Create TODO list if 3+ steps
2. **During work** - Change 1-3 files, test, deploy, verify, commit
3. **Between phases** - STOP and ask user to verify before proceeding
4. **Phase complete** - Only when deployed, tested in browser, and committed

**Commit immediately after:**
- All tests pass (unit + integration)
- Build succeeds (`npm run tsc`, `Build-Plugin.ps1`)
- Manual browser test confirms feature works
- Phase completion (after deployment verification)

**Never commit:**
- Failing tests, compilation errors, broken functionality

See `copilot/DEVELOPMENT-WORKFLOW.md` for complete workflow guide.

### When User Requests
- **"Create a plugin"**: Use prompts from `copilot/plugin-creation-prompts.md`
- **"Build/deploy plugin"**: Run `/run build-plugin` or `/run deploy-plugin` for guided workflow
- **"Write tests"**: Run `/run create-plugin-test` for Grade A quality tests
- **"Review my code"**: Use `@workspace /agent plugin-reviewer` for structured review
- **"Check test quality"**: Run `/run review-test-quality` or use `@workspace /agent test-quality`
- **"How do I..."**: Check `docs/toolkit/WORKFLOWS.md` first
- **"What's the command for..."**: Reference `QUICK-REFERENCE.md`
- **"Need plugin development guide"**: See `docs/toolkit/PLUGIN-DEVELOPMENT-WORKFLOW.md`
- **"Documentation standards"**: See `docs/toolkit/DOCUMENTATION-STANDARDS.md`
- **Need InvenTree patterns**: See `copilot/PROJECT-CONTEXT.md` → InvenTree Patterns section

---

## File Organization

### AI Guidance (copilot/ folder)
All files in `copilot/` are **agent-facing documentation**:
- `AGENT-BEHAVIOR.md` - Communication style, tone, code generation rules
- `DEVELOPMENT-WORKFLOW.md` - Universal workflow: TODO lists, commits, testing, phase completion
- `PROJECT-CONTEXT.md` - Architecture, tech stack, folder structure, patterns
- `plugin-creation-prompts.md` - Ready-to-use prompts for plugin creation

### Instruction Files (.github/instructions/ folder)
**Comprehensive patterns for code generation** (10 files, ~2950 lines):
- `python.instructions.md` - General Python + fail-fast philosophy
- `powershell.instructions.md` - PowerShell cmdlets, parameters, pipeline, error handling
- `backend.core.instructions.md` - Plugin class, mixins, settings
- `backend.api.instructions.md` - Django/DRF, serializers, views, QuerySet optimization
- `backend.testing.instructions.md` - Unit/integration, code-first methodology, test quality
- `frontend.react.instructions.md` - React, TypeScript, InvenTree context, Mantine UI
- `frontend.build.instructions.md` - Vite, externalized dependencies, TypeScript config
- `packaging.instructions.md` - pyproject.toml, versioning, entry points, PyPI
- `taming-copilot.instructions.md` - Control Copilot behavior, prevent overly broad changes
- `update-docs-on-code-change.instructions.md` - Auto-sync documentation when code changes

**Key Feature**: Fail-fast decision trees to avoid defensive fallbacks that hide bugs

**Documentation**: See `.github/instructions/README.md` for complete guide

### Prompts (.github/prompts/ folder)
**Guided workflows for common tasks** (5 prompts):
- `build-plugin.prompt.md` - Guide for Build-Plugin.ps1 usage
- `deploy-plugin.prompt.md` - Guide for Deploy-Plugin.ps1 with safety checks
- `test-plugin.prompt.md` - Guide for Test-Plugin.ps1 (unit/integration)
- `create-plugin-test.prompt.md` - Generate Grade A quality unit tests
- `review-test-quality.prompt.md` - Assess test suite quality with grading system

**Usage**: Type `/run [prompt-name]` in Copilot Chat (e.g., `/run build-plugin`)

**Documentation**: See `.github/prompts/README.md` for usage examples

### Agents (.github/agents/ folder)
**Specialized expertise for complex tasks** (3 agents):
- `inventree-plugin` - Expert assistant for InvenTree plugin development
- `plugin-reviewer.agent.md` - Code review specialist with structured checklist
- `test-quality.agent.md` - Test quality assessment with grading system

**Usage**: Type `@workspace /agent [agent-name]` in Copilot Chat

**Documentation**: See `.github/agents/README.md` for agent descriptions

### Developer Documentation (docs/ folder)
- `toolkit/WORKFLOWS.md` - Step-by-step task guides
- `toolkit/PLUGIN-DEVELOPMENT-WORKFLOW.md` - Complete plugin development process
- `toolkit/DOCUMENTATION-STANDARDS.md` - Documentation naming conventions
- `toolkit/TESTING-STRATEGY.md` - Testing guidelines
- `toolkit/INVENTREE-DEV-SETUP.md` - Integration testing setup
- `inventree/CUSTOM-STATES.md` - InvenTree custom states
- `inventree/TESTING-FRAMEWORK.md` - Django testing patterns

### Root Documentation
- `QUICK-REFERENCE.md` - Command cheat sheet
- `README.md` - Toolkit overview
- `SETUP.md` - Initial setup

### Active Development (plugins/ folder)
- User's plugins under development
- Scripts operate on plugins in this folder
- Example: `plugins/FlatBOMGenerator/`

### Reference Material (reference/ folder)
- Example plugins for learning
- InvenTree source code for reference
- **NOT** built or deployed by scripts

---

## Technology Context

### Backend
- Django 4.x+ (InvenTree framework)
- Python 3.9+
- Django REST Framework for APIs
- InvenTree plugin mixins for capabilities

### Frontend
- React 19 with TypeScript
- Mantine 8 UI library
- Vite 6 build tool
- Lingui i18n for translations

### Development Environment
- Windows OS (PowerShell)
- VS Code with GitHub Copilot
- Python virtual environment
- Manual copy-to-server deployment
- InvenTree dev environment (optional, for integration testing)

---

## Important Patterns

### Plugin Structure
```
plugins/my-plugin/
├── my_plugin/           # Python package (snake_case)
│   ├── core.py          # Main plugin class
│   ├── views.py         # API endpoints
│   └── static/          # AUTO-GENERATED (don't edit)
├── frontend/            # React TypeScript
│   └── src/
│       ├── Panel.tsx    # UI panels
│       └── Dashboard.tsx
└── pyproject.toml       # Configuration
```

### Mixins Usage
- `SettingsMixin` - Plugin settings
- `UrlsMixin` - Custom API endpoints
- `UserInterfaceMixin` - Frontend UI
- `EventMixin` - React to events
- `ScheduleMixin` - Background tasks

See `copilot/PROJECT-CONTEXT.md` for complete mixin reference.

---

## Code Generation Rules

**CRITICAL**: Avoid emoji and special Unicode in generated code.

❌ Don't: `print("✅ Success!")`  
✅ Do: `print("[OK] Success!")`

**Why**: Emoji cause PowerShell parsing errors and Python encoding issues on Windows.

**Acceptable**: Emoji in Markdown docs, React UI text (user-facing only)
**Testing**: When refactoring or adding features:
- Check if tests exist first (test-first workflow)
- Write unit tests for pure functions (fast, no database)
- Write integration tests for API endpoints (requires InvenTree dev setup)
- See `docs/toolkit/TESTING-STRATEGY.md` for guidelines
---

## Documentation Updates

When making code changes, update documentation:

**Always Update:**
- Plugin `README.md` - Feature list, usage instructions
- Code docstrings and comments
- Tests for new features

**Update if Changed:**
- `copilot/PROJECT-CONTEXT.md` - If architecture/folder structure changes
- `docs/toolkit/WORKFLOWS.md` - If workflows change
- `QUICK-REFERENCE.md` - If commands change

See `copilot/PROJECT-CONTEXT.md` → Documentation Update Routine for checklist.

---

## Workflow Tips

### Creating Features
1. Ask user what they want to accomplish
2. Recommend InvenTree mixins/approach
3. Show complete code with file paths
4. Provide test command

### Debugging
1. Ask for specific error message
2. Explain what the error means
3. Provide step-by-step fix
4. Explain why it fixes the issue

### Building
- Frontend: Automatically built by `Build-Plugin.ps1`
- Output: Goes to `static/` folder (auto-generated)
- Never edit `static/` folder directly

---

## Quick Reference Links

**For Agents:**
- Communication style: `copilot/AGENT-BEHAVIOR.md`
- Architecture, patterns & debugging: `copilot/PROJECT-CONTEXT.md`
- Plugin creation: `copilot/plugin-creation-prompts.md`
- Specialized agents: `.github/agents/README.md`

**For Workflows (Prompts):**
- Build plugin: `/run build-plugin` or `.github/prompts/build-plugin.prompt.md`
- Deploy plugin: `/run deploy-plugin` or `.github/prompts/deploy-plugin.prompt.md`
- Test plugin: `/run test-plugin` or `.github/prompts/test-plugin.prompt.md`
- Create tests: `/run create-plugin-test` or `.github/prompts/create-plugin-test.prompt.md`
- Review tests: `/run review-test-quality` or `.github/prompts/review-test-quality.prompt.md`

**For Tasks:**
- How-to guides: `docs/toolkit/WORKFLOWS.md`
- Command reference: `QUICK-REFERENCE.md`
- Plugin development workflow: `docs/toolkit/PLUGIN-DEVELOPMENT-WORKFLOW.md`
- Documentation standards: `docs/toolkit/DOCUMENTATION-STANDARDS.md`
- Testing strategy: `docs/toolkit/TESTING-STRATEGY.md`
- Integration testing setup: `docs/toolkit/INVENTREE-DEV-SETUP.md`
- Integration testing summary: `docs/toolkit/INTEGRATION-TESTING-SUMMARY.md`
- Django testing patterns: `docs/inventree/TESTING-FRAMEWORK.md`

**For Context:**
- Toolkit overview: `README.md`
- Initial setup: `SETUP.md`
- Copilot improvements: `.github/COPILOT-IMPROVEMENTS.md`

---

## Remember

This user:
- Works part-time on plugins (needs easy resume)
- Prefers simple solutions over complex automation
- Comfortable with Python, learning frontend
- Deploys manually (no CI/CD complexity)
- Values clear explanations over assumed knowledge

**Your goal**: Make InvenTree plugin development accessible and achievable for a mechanical engineer learning software development patterns.

---

**Last Updated**: January 9, 2026
**Toolkit Version**: 1.0
