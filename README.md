# InvenTree Plugin Development Toolkit

**Audience:** Users and AI Agents | **Category:** Overview | **Purpose:** Toolkit introduction and feature summary | **Last Updated:** 2025-12-10

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
│   │   ├── WORKFLOWS.md                 # Step-by-step task guides
│   │   └── QUICK-REFERENCE.md           # Command cheat sheet
│   └── inventree/                       # InvenTree knowledge base
│       ├── CUSTOM-STATES.md             # Custom states guide
│       └── TESTING-FRAMEWORK.md         # Django testing patterns
├── plugins/                              # Your plugin projects go here
│   └── YourPlugin/                      # Each plugin in its own folder
├── scripts/                              # PowerShell automation scripts
│   ├── New-Plugin.ps1                   # Create a new plugin
│   ├── Build-Plugin.ps1                 # Build plugin (Python + Frontend)
│   ├── Deploy-Plugin.ps1                # Build & Deploy to server
│   ├── Test-Plugin.ps1                  # Run plugin unit tests
│   └── Dev-Frontend.ps1                 # Live frontend development
├── plugin-creator/                       # Git submodule (don't modify)
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

### 3. Build Your Plugin

```powershell
# Build everything (Python + Frontend if applicable)
.\scripts\Build-Plugin.ps1 -Plugin "your-plugin-name"
```

### 4. Deploy to Server

```powershell
# Deploy to staging server first
.\scripts\Deploy-Plugin.ps1 -Plugin "your-plugin-name" -Server staging

# After testing, deploy to production
.\scripts\Deploy-Plugin.ps1 -Plugin "your-plugin-name" -Server production
```

## 🛠️ Common Workflows

### Working on Frontend UI
If your plugin has custom panels or UI elements:

```powershell
# Start live development server
.\scripts\Dev-Frontend.ps1 -Plugin "your-plugin-name"
```

This lets you see changes instantly in your browser without rebuilding!

### Making Changes to Existing Plugin

1. Edit your code in VS Code
2. Build: `.\scripts\Build-Plugin.ps1 -Plugin "your-plugin-name"`
3. Deploy: `.\scripts\Deploy-Plugin.ps1 -Plugin "your-plugin-name" -Server staging`
4. Test on staging server
5. Deploy to production when ready

## 📖 Documentation

### AI Agent Guidance
- **copilot/AGENT-BEHAVIOR.md** - How agents should communicate with you and generate code
- **copilot/PROJECT-CONTEXT.md** - Project architecture, folder structure, and patterns
- **copilot/plugin-creation-prompts.md** - Ready-to-use prompts for creating plugins
- **.github/copilot-instructions.md** - Auto-discovered entry point for GitHub Copilot

### Toolkit Documentation
- **docs/toolkit/WORKFLOWS.md** - Step-by-step guides for common tasks
- **docs/toolkit/QUICK-REFERENCE.md** - Command cheat sheet

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
