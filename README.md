# InvenTree Plugin Development Toolkit

**Audience:** Users and AI Agents | **Category:** Overview | **Purpose:** Toolkit introduction and feature summary | **Last Updated:** 2025-12-11

---

A simple, easy-to-use toolkit for creating and deploying InvenTree plugins with GitHub Copilot integration.

## 🚀 Quick Start

**First time setup?** See [SETUP.md](SETUP.md) for detailed installation instructions including:
- Git submodule initialization for plugin-creator
- Server configuration
- SSH setup
- Verification steps

**Already set up?** Jump to [Create Your First Plugin](#2-create-your-first-plugin)

---

## 📁 Folder Structure

```
inventree-plugin-ai-toolkit/
├── .github/
│   └── copilot-instructions.md          # Auto-discovered by GitHub Copilot
├── config/
│   └── servers.json                      # Your server configurations (gitignored)
├── copilot/                              # AI agent guidance
│   ├── AGENT-BEHAVIOR.md                # Communication style and code generation rules
│   ├── PROJECT-CONTEXT.md               # Architecture, tech stack, patterns
│   └── plugin-creation-prompts.md       # Ready-to-use creation workflows
├── docs/
│   ├── toolkit/                         # Toolkit usage guides
│   │   └── WORKFLOWS.md                 # Step-by-step task guides
│   └── inventree/                       # InvenTree knowledge base
│       ├── CUSTOM-STATES.md             # Custom states guide
│       └── TESTING-FRAMEWORK.md         # Django testing patterns
├── plugins/                              # Your plugin projects go here
│   └── YourPlugin/                      # Each plugin in its own folder
├── scripts/                              # PowerShell automation scripts
│   ├── New-Plugin.ps1                   # Create a new plugin
│   ├── Build-Plugin.ps1                 # Build plugin (Python + Frontend)
│   ├── Deploy-Plugin.ps1                # Build & Deploy to server
│   └── Test-Plugin.ps1                  # Run plugin unit tests
├── plugin-creator/                       # Git submodule (don't modify)
├── QUICK-REFERENCE.md                    # Command cheat sheet (moved to root for easy access)
└── README.md                             # ← You are here
```

---

## 🛠️ Prerequisites

- **Python 3.8+**
- **Node.js 18+** and npm
- **PowerShell 5.1+** 
- **Git** with submodule support
- **(Optional)** SSH access to InvenTree server

---

## 2. Create Your First Plugin

**Recommended: Use GitHub Copilot (Intelligent Guidance)**

1. Open GitHub Copilot Chat in VS Code
2. Reference the creation prompts:
   ```
   @workspace I want to create a new InvenTree plugin. Follow the guided creation process in copilot/plugin-creation-prompts.md
   ```
3. Copilot will:
   - Ask what your plugin should do
   - Recommend the right mixins based on your needs
   - Generate the plugin structure
   - Provide implementation guidance

**Alternative: Direct Command**

```powershell
# Run plugin-creator directly (you'll answer questions interactively)
.\scripts\New-Plugin.ps1
```

**Why use Copilot?**
- Understands natural language ("I need to send emails when orders ship")
- Recommends mixins intelligently, not just yes/no questions
- Explains WHY each feature is needed
- Provides code examples and architecture guidance

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

See `docs/toolkit/WORKFLOWS.md` for details.

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

See [docs/toolkit/INTEGRATION-TESTING-SUMMARY.md](docs/toolkit/INTEGRATION-TESTING-SUMMARY.md) for complete guide.

### 5. Deploy to Server

```powershell
# Deploy to staging server (automatically builds first)
.\scripts\Deploy-Plugin.ps1 -Plugin "your-plugin-name" -Server staging

# After testing, deploy to production
.\scripts\Deploy-Plugin.ps1 -Plugin "your-plugin-name" -Server production
```

**Note:** `Deploy-Plugin.ps1` automatically runs `Build-Plugin.ps1` before deploying, so you don't need to build separately unless you want to test the build without deploying.

## 🛠️ Common Workflows

### Making Changes to Existing Plugin

1. Edit your code in VS Code
2. Deploy: `.\scripts\Deploy-Plugin.ps1 -Plugin "your-plugin-name" -Server staging`
3. Test on staging server
4. Deploy to production when ready

**Optional:** Run `.\scripts\Build-Plugin.ps1` first if you want to verify the build succeeds before deploying.

## 📖 Documentation

### AI Agent Guidance
- **copilot/AGENT-BEHAVIOR.md** - How agents should communicate with you and generate code
- **copilot/PROJECT-CONTEXT.md** - Project architecture, folder structure, and patterns
- **copilot/plugin-creation-prompts.md** - Ready-to-use prompts for creating plugins
- **.github/copilot-instructions.md** - Auto-discovered entry point for GitHub Copilot

### Toolkit Documentation
- **QUICK-REFERENCE.md** - Command cheat sheet (at toolkit root for easy access)
- **docs/toolkit/WORKFLOWS.md** - Step-by-step guides for common tasks
- **docs/toolkit/INVENTREE-DEV-SETUP.md** - InvenTree development environment setup for integration testing
- **docs/toolkit/TESTING-STRATEGY.md** - When to use unit tests vs integration tests
- **docs/toolkit/INTEGRATION-TESTING-SUMMARY.md** - Complete integration testing guide

### InvenTree Knowledge Base
- **docs/inventree/CUSTOM-STATES.md** - Understanding InvenTree custom states
- **docs/inventree/TESTING-FRAMEWORK.md** - Django testing patterns for plugins

### Using GitHub Copilot

Copilot automatically discovers `.github/copilot-instructions.md` for context. You can also:

**Create a plugin:**
```
@workspace Create a new InvenTree plugin using copilot/plugin-creation-prompts.md
```

**Get help with development:**
```
How do I add a custom panel to the Part page?
Show me how to create a plugin setting
Help me debug this error: [paste error]
```

**Reference specific guides:**
```
#file:docs/toolkit/WORKFLOWS.md Show me how to deploy a plugin
```

## 📦 Plugin Deployment Methods

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

## 🆘 Getting Help

### Ask Copilot

Open Copilot Chat in VS Code and try:
- "How do I add a custom panel to the Part page?"
- "Show me how to create a plugin setting"
- "Help me debug this frontend error: [paste error]"

See **copilot/plugin-creation-prompts.md** for ready-to-use prompts and **docs/toolkit/WORKFLOWS.md** for step-by-step guides.

## ⚙️ Configuration

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

## 📝 Notes

- This toolkit works **alongside** the plugin-creator, not inside it
- Your plugins are created in `plugins/` folder
- Each plugin can have its own git repository
- The scripts handle building both Python and frontend code
- Always test on staging before production!

## 🔗 Useful Links

- [InvenTree Plugin Documentation](https://docs.inventree.org/en/latest/plugins/)
- [InvenTree API Documentation](https://docs.inventree.org/en/latest/api/api/)
- [Plugin Creator Repository](https://github.com/inventree/plugin-creator)

---

## 🚧 Future Work

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
