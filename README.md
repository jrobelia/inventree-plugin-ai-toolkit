# InvenTree Plugin Development Toolkit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![InvenTree](https://img.shields.io/badge/InvenTree-1.1.6+-blue.svg)](https://inventree.org)
[![AI Assisted](https://img.shields.io/badge/AI%20Assisted-Optional-purple.svg)](https://github.com/features/copilot)

**Audience:** Users and AI Agents | **Category:** Overview | **Purpose:** Toolkit introduction and feature summary | **Last Updated:** 2025-12-19

---

A lightweight development toolkit for creating and deploying InvenTree plugins. Includes PowerShell automation scripts and GitHub Copilot instructions to help guide development.

## Official InvenTree Documentation

**Before using this toolkit, familiarize yourself with official InvenTree plugin documentation:**

- **[InvenTree Plugin Development Guide](https://docs.inventree.org/en/latest/plugins/)** - Official comprehensive guide
- **[Plugin API Reference](https://docs.inventree.org/en/latest/api/api/)** - InvenTree API documentation
- **[Frontend Development](https://docs.inventree.org/en/latest/plugins/frontend/)** - Running plugin UI locally

**What this toolkit does:**
- Simplifies plugin creation with templates, leveraging Inventree's plugin-creator tool
- Automates building and deployment to servers
- Provides AI assistance for development
- Includes testing infrastructure

**What this toolkit does NOT do:**
- **Local frontend development server** - InvenTree recommends running frontend code locally against a development InvenTree instance. See [InvenTree's Frontend Plugin Guide](https://docs.inventree.org/en/latest/plugins/frontend/) for local development setup.
- Replace understanding InvenTree plugin architecture
- Automatically test your plugin logic
- Guarantee bug-free code

## Quick Start

**First time setup?** See [SETUP.md](SETUP.md) for detailed installation instructions including:
- Git submodule initialization for plugin-creator
- Server configuration
- SSH setup
- Verification steps

**Already set up?** Jump to [Create Your First Plugin](#2-create-your-first-plugin)

---

## Important Disclaimer

**This toolkit is provided as-is for development assistance.**

- **Not a magic solution** - You are responsible for understanding and testing your plugin code
- **Always test on staging first** - Never deploy directly to production without verification
- **Review AI-generated code** - GitHub Copilot suggestions should be reviewed for correctness and security
- **Backup your data** - Test plugins can affect your InvenTree database
- **Use at your own risk** - No warranties or guarantees provided
- **You own the responsibility** - For bugs, data loss, or system issues from your plugins

**Best practices:**
1. Set up a staging/test InvenTree server separate from production
2. Test thoroughly before deploying to production
3. Keep backups of your InvenTree database
4. Review all code changes, especially from AI assistance
5. Start simple - test basic functionality before adding complexity

See [SETUP.md](SETUP.md) for recommended staging server configuration.

---

## Folder Structure

```
inventree-plugin-ai-toolkit/
├── .github/
│   ├── agents/                          # Copilot agent personas
│   │   ├── orchestrator.agent.md        # Full pipeline management
│   │   ├── debug.agent.md              # Systematic debugging
│   │   ├── test.agent.md               # RED phase test writing
│   │   └── code-review.agent.md        # Quality and spec check
│   ├── instructions/                    # Always-on coding rules
│   │   ├── core/                        # Language and practice rules
│   │   │   ├── agent-behavior           # Communication style
│   │   │   ├── design-principles        # SOLID, DRY, KISS, YAGNI
│   │   │   ├── python                   # PEP 8, type hints
│   │   │   ├── powershell               # PS 5.1 conventions
│   │   │   ├── typescript               # Strict mode, React
│   │   │   └── testing                  # AAA, naming, TDD
│   │   └── domain/                      # InvenTree-specific patterns
│   │       ├── django-api               # DRF serializers, views
│   │       ├── django-testing           # URL 404 gotcha, as_view()
│   │       ├── inventree-plugin         # Plugin class, mixins
│   │       ├── inventree-packaging      # pyproject.toml, entry points
│   │       ├── inventree-custom-states  # Custom states (Admin UI)
│   │       ├── react-inventree          # Context, Mantine, Vite
│   │       └── yaml-fixtures            # MPTT fields, BomItem
│   ├── prompts/                         # On-demand workflows
│   │   ├── 01-intake through 06-git     # Pipeline stages
│   │   ├── inventree-plugin-*           # Build, deploy, test
│   │   ├── inventree-review             # Code review
│   │   └── debug-solidworks             # SolidWorks debugging
│   └── copilot-instructions.md          # Auto-discovered entry point
├── config/
│   └── servers.json                      # Your server configurations (gitignored)
├── docs/
│   ├── architecture.md                  # Toolkit module map (living doc)
│   ├── decisions.md                     # Append-only decision log
│   ├── roadmap.md                       # Toolkit feature wish list
│   ├── reference/                       # How things work today
│   │   ├── FRESH-USER-WORKFLOW.md       # Zero to working tests
│   │   ├── INVENTREE-DEV-SETUP.md       # Dev environment setup
│   │   ├── DOCUMENTATION-STANDARDS.md   # File naming conventions
│   │   └── PLUGIN-DEVELOPMENT-WORKFLOW.md # Full dev lifecycle
│   ├── planning/                        # What we want to do next
│   │   └── TEST-SCRIPT-IMPROVEMENTS.md  # Test script backlog
│   └── archive/                         # Superseded docs (gitignored)
├── plugins/                              # Your plugin projects go here
│   └── YourPlugin/                      # Each plugin in its own folder
├── scripts/                              # PowerShell automation scripts
│   ├── New-Plugin.ps1                   # Create a new plugin
│   ├── Build-Plugin.ps1                 # Build plugin (Python + Frontend)
│   ├── Deploy-Plugin.ps1                # Build & Deploy to server
│   ├── Test-Plugin.ps1                  # Run plugin tests
│   ├── Test-Frontend.ps1                # Run frontend tests
│   ├── Setup-InvenTreeDev.ps1           # Set up InvenTree dev environment
│   └── Link-PluginToDev.ps1            # Link plugin to dev environment
├── plugin-creator/                       # Git submodule (don't modify)
├── QUICK-REFERENCE.md                    # Command cheat sheet
├── SETUP.md                              # Initial setup instructions
└── README.md                             # ← You are here
```

---

## Prerequisites

- **Python 3.8+**
- **Node.js 18+** and npm
- **PowerShell 5.1+** 
- **Git** with submodule support
- **(Optional)** SSH access to InvenTree server

---

## 2. Create Your First Plugin

**Option 1: With GitHub Copilot Assistance**

1. Open GitHub Copilot Chat in VS Code
2. Use the orchestrator agent:
   ```
   @agent orchestrator I want to create a new InvenTree plugin that [describe what it does]
   ```
3. Copilot can help:
   - Suggest appropriate mixins for your use case
   - Generate initial plugin structure
   - Provide implementation examples

**Option 2: Direct Command**

```powershell
# Run plugin-creator directly (you'll answer questions interactively)
.\scripts\New-Plugin.ps1
```

**Benefits of using Copilot:**
- Works with natural language descriptions
- Can suggest mixins based on your requirements
- Provides explanations and code examples
- Helps with architecture decisions

**Note:** Copilot is a tool to assist development, not a replacement for understanding InvenTree plugin architecture. Always review and test generated code.

### 2a. Set Up Code Quality Tools (Recommended)

Every plugin is scaffolded with Biome (TypeScript linter) and pre-commit hooks (automatic code formatting). To activate:

```powershell
cd plugins\YourPlugin

# Create virtual environment
python -m venv .venv
.\.venv\Scripts\Activate.ps1

# Install and activate pre-commit
pip install pre-commit
pre-commit install
pre-commit run --all-files  # Initial formatting
```

**What this does:**
- **Ruff** formats Python code (PEP 8 style)
- **Biome** formats TypeScript/React code
- Runs automatically on every `git commit`
- Catches common errors before deployment

See `docs/reference/PLUGIN-DEVELOPMENT-WORKFLOW.md` for details.

### 3. Build Your Plugin (Optional)

```powershell
# Build everything (Python + Frontend if applicable)
# Note: Deploy-Plugin.ps1 automatically builds, so this is optional
.\scripts\Build-Plugin.ps1 -Plugin "your-plugin-name"
```

### 4. Test Your Plugin (Optional but Recommended)

```powershell
# Run fast unit tests (no setup required)
.\scripts\Test-Plugin.ps1 -Plugin "your-plugin-name" -Unit

# Run integration tests (requires InvenTree dev setup - see below)
.\scripts\Test-Plugin.ps1 -Plugin "your-plugin-name" -Integration
```

**Integration Testing** (one-time setup):
```powershell
# Set up InvenTree development environment (1-2 hours, one-time)
.\scripts\Setup-InvenTreeDev.ps1

# Link your plugin to InvenTree dev environment
.\scripts\Link-PluginToDev.ps1 -Plugin "your-plugin-name"

# Now you can run integration tests with real InvenTree models
.\scripts\Test-Plugin.ps1 -Plugin "your-plugin-name" -Integration
```

See [docs/reference/FRESH-USER-WORKFLOW.md](docs/reference/FRESH-USER-WORKFLOW.md) for complete guide.

### 5. Deploy to Server

**⚠️ CRITICAL: Always deploy to staging first!**

```powershell
# Deploy to staging server (automatically builds first)
.\scripts\Deploy-Plugin.ps1 -Plugin "your-plugin-name" -Server staging

# Test thoroughly on staging server:
# - Verify plugin loads correctly
# - Test all features manually
# - Check for errors in InvenTree logs
# - Confirm database changes are safe

# After thorough testing, deploy to production
.\scripts\Deploy-Plugin.ps1 -Plugin "your-plugin-name" -Server production
```

**Note:** `Deploy-Plugin.ps1` automatically runs `Build-Plugin.ps1` before deploying, so you don't need to build separately unless you want to test the build without deploying.

**Best Practice Workflow:**
1. Test locally with unit tests
2. Deploy to staging server
3. Manually test all plugin functionality on staging
4. Review InvenTree logs for warnings/errors
5. Only deploy to production after staging verification

## Common Workflows

### Making Changes to Existing Plugin

1. Edit your code in VS Code
2. Deploy: `.\scripts\Deploy-Plugin.ps1 -Plugin "your-plugin-name" -Server staging`
3. Test on staging server
4. Deploy to production when ready

**Optional:** Run `.\scripts\Build-Plugin.ps1` first if you want to verify the build succeeds before deploying.

## Documentation

### GitHub Copilot Integration
- **.github/copilot-instructions.md** - Auto-discovered entry point for GitHub Copilot
- **.github/agents/** - Orchestrator, debug, test, and code-review agents
- **.github/instructions/core/** - Language and practice rules (Python, TypeScript, testing)
- **.github/instructions/domain/** - InvenTree-specific patterns (plugins, Django, fixtures)
- **.github/prompts/** - On-demand workflows (build, deploy, test, review)

### Living Documents
- **docs/architecture.md** - Toolkit module map
- **docs/decisions.md** - Append-only decision log
- **docs/roadmap.md** - Toolkit feature wish list

### Reference Guides
- **QUICK-REFERENCE.md** - Command cheat sheet
- **SETUP.md** - Initial setup instructions
- **docs/reference/FRESH-USER-WORKFLOW.md** - First-time user walkthrough
- **docs/reference/INVENTREE-DEV-SETUP.md** - InvenTree dev environment setup
- **docs/reference/DOCUMENTATION-STANDARDS.md** - Documentation naming conventions
- **docs/reference/PLUGIN-DEVELOPMENT-WORKFLOW.md** - Complete plugin development lifecycle

### Using GitHub Copilot (Optional)

This toolkit includes specialized Copilot agents and instruction files for AI assistance.

**Use the Orchestrator agent for feature work:**
```
@agent orchestrator [describe what you want to build]
```

**Use the Debug agent for problems:**
```
@agent debug [describe the issue]
```

**Or ask Copilot directly:**

```
How do I add a custom panel to the Part page?
Show me how to create a plugin setting
Help me debug this error: [paste error]
```

**Tip:** GitHub Copilot is helpful but not required. All documentation is readable by humans and can guide manual development.

## Plugin Deployment Methods

InvenTree supports two ways to deploy plugins:

### Method 1: Simple Single-File Plugin
For basic plugins without dependencies or frontend code:
- Drop a single `.py` file into the InvenTree plugins directory
- InvenTree discovers and loads it automatically
- ✅ Quick and simple for development
- ⚠️ No version management or dependency tracking

### Method 2: Packaged Plugin (Recommended)
For professional plugins with proper structure:
- Build as a Python package (`.whl` file)
- Install via pip on the InvenTree server
- ✅ Version control, dependency management
- ✅ Can include frontend code
- ✅ Professional distribution
- This toolkit supports this method with build scripts

**When to use which:**
- **Single file:** Quick prototypes, simple backend-only plugins
- **Packaged:** Production plugins, plugins with frontend, shared plugins

## Getting Help

### Documentation and AI Assistance

**If using GitHub Copilot:**
- Use `@agent orchestrator` for feature work
- Use `@agent debug` for problems
- Try asking questions like: "How do I add a custom panel to the Part page?"

**Manual development:**
- See **docs/reference/** for setup guides and workflows
- Check **QUICK-REFERENCE.md** for command cheat sheet
- Review [InvenTree Plugin Documentation](https://docs.inventree.org/en/latest/plugins/)

**Note:** The Copilot instructions are designed to help AI assistants provide better suggestions, but all information is available in human-readable documentation.

## Configuration

### Server Configuration (config/servers.json)

```json
{
  "servers": {
    "staging": {
      "plugin_dir": "\\\\staging-server\\inventree\\plugins",
      "url": "https://staging.inventree.company.com"
    },
    "production": {
      "plugin_dir": "\\\\prod-server\\inventree\\plugins",
      "url": "https://inventree.company.com"
    }
  }
}
```

**For local servers:** Use regular paths like `C:\\InvenTree\\plugins`
**For network servers:** Use UNC paths like `\\\\server\\share\\inventree\\plugins`

## Notes

- This toolkit works **alongside** the plugin-creator, not inside it
- Your plugins are created in `plugins/` folder
- Each plugin can have its own git repository
- The scripts handle building both Python and frontend code
- Always test on staging before production!
- **Frontend development**: For local frontend development, see [InvenTree's Frontend Plugin Guide](https://docs.inventree.org/en/latest/plugins/frontend/)

## Essential Resources

### Official InvenTree Documentation (Read These First!)
- **[InvenTree Plugin Development Guide](https://docs.inventree.org/en/latest/plugins/)** - Start here for plugin concepts
- **[Frontend Plugin Development](https://docs.inventree.org/en/latest/plugins/frontend/)** - Local frontend development setup
- **[InvenTree API Documentation](https://docs.inventree.org/en/latest/api/api/)** - API reference
- **[Plugin Mixins Reference](https://docs.inventree.org/en/latest/plugins/mixins/)** - Available plugin capabilities

### Related Tools
- [Plugin Creator Repository](https://github.com/inventree/plugin-creator) - Template generator (used by this toolkit)

---

## Future Work

### Toolkit Enhancements

**Workflow Checklists for AI Agents**
- Create structured checklists to guide AI agent behavior during development
- Prevent common mistakes (stacking unverified changes, skipping deployment testing)
- Examples:
  - "Before Starting Work" checklist (check git log, git status, deployment status)
  - "Phase-Based Refactoring" workflow (implement → test → deploy → verify before next phase)
  - "Testing Philosophy" guide (unit vs integration vs manual testing)
- See `plugins/FlatBOMGenerator/docs/internal/DEPLOYMENT-WORKFLOW.md` for working prototype
- Goal: Make AI agents more reliable and educational in their approach

**Automated Deployment Verification**
- Script to run basic smoke tests after deployment
- Check server health, plugin loaded, basic API calls work
- Reduce manual verification burden

**Plugin Template Improvements**
- Add optional integration testing setup to plugin scaffolding
- Include deployment workflow checklist template
- Pre-configure Biome and pre-commit hooks by default

**CI/CD Templates**
- GitHub Actions workflow templates for plugin testing
- Automated build and deployment pipelines
- For when manual testing becomes a bottleneck

### Documentation Enhancements

**Agent Behavior Guidelines**
- Expand collaborative development principles
- More examples of "explain before implementing" patterns
- Test-first workflow detailed guides

**InvenTree Knowledge Base**
- More Django REST Framework serializer patterns
- Frontend integration patterns (React + InvenTree API)
- Performance optimization guides

### Ideas/Suggestions Welcome

Have ideas for improving the toolkit? Open an issue or discussion in your plugin repository!
