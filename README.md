# InvenTree Plugin Development Toolkit

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![InvenTree](https://img.shields.io/badge/InvenTree-1.3.0+-blue.svg)](https://inventree.org)
[![Devcontainer](https://img.shields.io/badge/Devcontainer-Ready-green.svg)](https://code.visualstudio.com/docs/devcontainers/containers)
[![AI Assisted](https://img.shields.io/badge/AI%20Assisted-Optional-purple.svg)](https://github.com/features/copilot)

**Audience:** Users and AI Agents | **Category:** Overview | **Purpose:** Toolkit introduction and feature summary | **Last Updated:** 2026-08-04

---

A development toolkit for creating and deploying InvenTree plugins using an official InvenTree devcontainer for a consistent, reproducible development environment. Includes `.agents/skills/` AI-assisted development workflows.

## Official InvenTree Documentation

**Before using this toolkit, familiarize yourself with official InvenTree plugin documentation:**

- **[InvenTree Plugin Development Guide](https://docs.inventree.org/en/latest/plugins/)** - Official comprehensive guide
- **[Plugin API Reference](https://docs.inventree.org/en/latest/api/api/)** - InvenTree API documentation
- **[Frontend Development](https://docs.inventree.org/en/latest/plugins/frontend/)** - Running plugin UI locally

**What this toolkit does:**
- Provides a devcontainer-based development environment with InvenTree pre-configured
- Simplifies plugin creation with templates, leveraging InvenTree's plugin-creator tool
- Configures local frontend development with hot reload for plugins
- Provides AI-assisted development workflows via `.agents/skills/`
- Includes testing infrastructure

**What this toolkit does NOT do:**
- Replace understanding InvenTree plugin architecture
- Automatically test your plugin logic
- Guarantee bug-free code
- Handle production deployment (you must configure your own servers)

## Quick Start

**First time setup?** See [SETUP.md](SETUP.md) for detailed installation instructions including:
- Devcontainer setup with VS Code
- Git submodule initialization
- Server configuration
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
├── .devcontainer/              # Devcontainer configuration
│   ├── devcontainer.json       # VS Code devcontainer settings
│   ├── Dockerfile             # Container image definition
│   ├── docker-compose.yml     # Service orchestration
│   ├── docker-compose.frontend-volumes.yml  # Generated node_modules overlay
│   ├── frontend-node-modules-mounts.txt     # Generated mount-point list
│   ├── generate-frontend-volumes.py         # Generator for the overlay files
│   └── postCreateCommand.sh   # Container setup script
├── .agents/                     # AI agent skills
│   └── skills/                  # AI-assisted development workflows
├── config/
│   ├── servers.json                      # Your server configurations (gitignored)
│   ├── servers.json.example              # Template
│   └── plugin-dev-config.yaml            # Plugin development configuration
├── docs/
│   ├── architecture.md                  # Toolkit module map (living doc)
│   ├── decisions.md                     # Append-only decision log
│   ├── roadmap.md                       # Toolkit feature wish list
│   └── reference/                       # How things work today
│       ├── DOCUMENTATION-STANDARDS.md   # File naming conventions
│       ├── PLUGIN-DEVELOPMENT-WORKFLOW.md # Full dev lifecycle
│       └── SESSION-ONBOARDING.md        # Day-to-day development workflow
├── plugins/                              # Your plugin projects go here
│   └── YourPlugin/                      # Each plugin in its own folder
├── reference/                            # Reference submodules
│   └── inventree-source/                # InvenTree source code (submodule)
│   └── plugin-creator/                  # Plugin scaffolding tool (submodule)
├── SETUP.md                              # Initial setup instructions
└── README.md                             # ← You are here
```

---

## Prerequisites

- **Docker Desktop** installed and running
- **VS Code** with the **Dev Containers** extension
- **Git** installed
- **(Optional)** SSH access to your InvenTree server for deployment

---

## 2. Create Your First Plugin

**Option 1: With GitHub Copilot Assistance**

1. Open GitHub Copilot Chat in VS Code (inside the devcontainer)
2. Use the orchestrator agent:
   ```
   @agent orchestrator I want to create a new InvenTree plugin that [describe what it does]
   ```
3. Copilot can help:
   - Suggest appropriate mixins for your use case
   - Generate initial plugin structure
   - Provide implementation examples

**Option 2: Direct Command**

```bash
# Run plugin-creator directly (you'll answer questions interactively)
cd /workspace/reference/plugin-creator
python plugin_creator/main.py
```

**Benefits of using Copilot:**
- Works with natural language descriptions
- Can suggest mixins based on your requirements
- Provides explanations and code examples
- Helps with architecture decisions

**Note:** Copilot is a tool to assist development, not a replacement for understanding InvenTree plugin architecture. Always review and test generated code.

### 2a. Set Up Code Quality Tools (Recommended)

Every plugin is scaffolded with Biome (TypeScript linter) and pre-commit hooks (automatic code formatting). To activate:

```bash
cd /workspace/plugins/YourPlugin

# Create virtual environment
python -m venv .venv
source .venv/bin/activate

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

### 3. Test Your Plugin

```bash
# Run fast unit tests (no setup required)
cd /workspace/plugins/YourPlugin
python -m pytest tests/unit

# Run integration tests (requires InvenTree dev environment)
python -m pytest tests/integration

# Run all tests (including E2E with Playwright if configured)
./test-all.sh
```

**Integration Testing:**
The devcontainer provides a full InvenTree development environment with database, so integration tests work out of the box.

**E2E Testing:**
For plugins with frontend code, Playwright can be used for end-to-end UI testing:
```bash
cd frontend
npm install
npx playwright install
npm run test:e2e
```

See [docs/reference/SESSION-ONBOARDING.md](docs/reference/SESSION-ONBOARDING.md) for the day-to-day workflow.

### 4. Deploy to Server

**⚠️ CRITICAL: Always deploy to staging first!**

Deployment requires manual configuration of your servers in `config/servers.json`. The toolkit does not include automated deployment scripts - you must handle deployment according to your infrastructure.

**Manual deployment steps:**
1. Build your plugin: `cd /workspace/plugins/YourPlugin && python -m build`
2. Copy the `.whl` file to your InvenTree server
3. Install via pip: `pip install your-plugin.whl`
4. Restart InvenTree
5. Test thoroughly on staging

**Best Practice Workflow:**
1. Test locally with unit tests
2. Deploy to staging server
3. Manually test all plugin functionality on staging
4. Review InvenTree logs for warnings/errors
5. Only deploy to production after staging verification

## Common Workflows

### Making Changes to Existing Plugin

1. Edit your code in VS Code (inside the devcontainer)
2. Run tests: `cd /workspace/plugins/YourPlugin && python -m pytest`
3. Build the plugin: `python -m build`
4. Deploy manually to staging server
5. Test on staging server
6. Deploy to production when ready

### Frontend Development with Hot Reload

For plugins with frontend code:

1. Start InvenTree server: `cd /workspace/reference/inventree-source && invoke dev.server -a 0.0.0.0:8001`
2. Start plugin dev server: `cd /workspace/plugins/YourPlugin/frontend && npm run dev`
3. Edit frontend code - changes automatically reload
4. Access plugin UI at http://localhost:8001

## Documentation

### AI-Assisted Development
- **AGENTS.md** - Devin rules for the toolkit
- **.agents/skills/** - AI-assisted development workflows
  - **new-inventree-plugin** - Create a new InvenTree plugin
  - **improve-inventree-plugin** - Verify changes to an existing plugin

### Living Documents
- **docs/architecture.md** - Toolkit module map
- **docs/decisions.md** - Append-only decision log
- **docs/roadmap.md** - Toolkit feature wish list

### Reference Guides
- **SETUP.md** - Initial setup instructions (devcontainer-based)
- **docs/reference/SESSION-ONBOARDING.md** - Step-by-step development session process
- **.agents/skills/** - AI-assisted development workflows
  - **new-inventree-plugin/skill.md** - Creating new plugins from scratch
  - **improve-inventree-plugin/skill.md** - Change verification loop for existing plugins
- **docs/reference/DOCUMENTATION-STANDARDS.md** - Documentation naming conventions
- **docs/reference/PLUGIN-DEVELOPMENT-WORKFLOW.md** - Complete plugin development lifecycle

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
- Check **docs/reference/SESSION-ONBOARDING.md** for the day-to-day workflow
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
- The devcontainer provides a complete InvenTree development environment
- **Frontend development**: The devcontainer includes hot reload for plugin frontend development
- **Deployment**: Manual deployment to your servers is required - configure in `config/servers.json`

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
