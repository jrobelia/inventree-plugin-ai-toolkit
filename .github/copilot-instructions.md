# GitHub Copilot Instructions

**Audience:** AI Agents (GitHub Copilot) | **Category:** Quick Reference | **Purpose:** Auto-discovered entry point for GitHub Copilot agents | **Last Updated:** 2025-12-10

**This file is automatically read by GitHub Copilot to provide context about this project.**

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
- See `copilot/AGENT-BEHAVIOR.md` for detailed communication guidelines

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
- **Run tests**: `.\scripts\Test-Plugin.ps1 -Plugin "PluginName"`
- See `docs/toolkit/QUICK-REFERENCE.md` for command reference

### When User Requests
- **"Create a plugin"**: Use prompts from `copilot/plugin-creation-prompts.md`
- **"How do I..."**: Check `docs/toolkit/WORKFLOWS.md` first
- **"What's the command for..."**: Reference `docs/toolkit/QUICK-REFERENCE.md`
- **Need InvenTree patterns**: See `copilot/PROJECT-CONTEXT.md` → InvenTree Patterns section

---

## File Organization

### AI Guidance (copilot/ folder)
All files in `copilot/` are **agent-facing documentation**:
- `AGENT-BEHAVIOR.md` - Communication style, tone, code generation rules
- `PROJECT-CONTEXT.md` - Architecture, tech stack, folder structure, patterns
- `plugin-creation-prompts.md` - Ready-to-use prompts for plugin creation

### Developer Documentation (docs/ folder)
- `WORKFLOWS.md` - Step-by-step task guides
- `QUICK-REFERENCE.md` - Command cheat sheet
- `copilot-prompts.md` - Ready-to-use Copilot prompts
- `CUSTOM-STATES-GUIDE.md` - InvenTree custom states
- `TESTING-FRAMEWORK-RESEARCH.md` - Django testing notes

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
- `docs/toolkit/QUICK-REFERENCE.md` - If commands change

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
- Architecture & patterns: `copilot/PROJECT-CONTEXT.md`
- Plugin creation: `copilot/plugin-creation-prompts.md`

**For Tasks:**
- How-to guides: `docs/toolkit/WORKFLOWS.md`
- Command reference: `docs/toolkit/QUICK-REFERENCE.md`
- Testing info: `docs/inventree/TESTING-FRAMEWORK.md`

**For Context:**
- Toolkit overview: `README.md`
- Initial setup: `SETUP.md`

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

**Last Updated**: December 10, 2025
**Toolkit Version**: 1.0
