# InvenTree Plugin Toolkit - Setup Guide

**Audience:** Users | **Category:** Installation Guide | **Purpose:** Initial setup and configuration instructions | **Last Updated:** 2026-08-05

---

This toolkit helps you create, develop, and deploy InvenTree plugins efficiently using a devcontainer-based development environment.

---

## Prerequisites

- **Docker Desktop** installed and running
- **VS Code** with the **Dev Containers** extension (optional; you can also use plain `docker compose`)
- **Git** installed
- **(Optional)** SSH access to your InvenTree server for deployment

---

## Quick Start (Devcontainer Setup)

The toolkit uses an official InvenTree devcontainer for a consistent, reproducible development environment.

### 1. Clone the Repository

```bash
git clone <your-repo-url> inventree-plugin-ai-toolkit
cd inventree-plugin-ai-toolkit
```

### 2. Initialize Submodules

```bash
git submodule update --init --recursive
```

This initializes:
- `reference/inventree-source` - InvenTree source code for development
- `reference/plugin-creator` - Plugin scaffolding tool

### 3. Open in VS Code with Devcontainer

```bash
code .
```

In VS Code:
1. Press `Ctrl+Shift+P`
2. Run: `Dev Containers: Reopen in Container`
3. Wait for the container to build (first build takes 5-10 minutes)

The devcontainer automatically:
- Installs Python 3.11, Node.js, and required dependencies
- Sets up InvenTree development environment
- Configures PostgreSQL and Redis databases
- Installs plugin frontend dependencies
- Creates admin user for development

### Alternative: Start the devcontainer from the terminal

If you prefer not to use VS Code, the same `.devcontainer` configuration works with Docker Compose:

```bash
cd inventree-plugin-ai-toolkit
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml up -d

# First-time setup only
docker compose -f .devcontainer/docker-compose.yml -f .devcontainer/docker-compose.frontend-volumes.yml exec -u vscode toolkit bash -c "cd /workspace && bash .devcontainer/postCreateCommand.sh"
```

See `.devcontainer/README.md` for the full CLI workflow.

### 4. Access InvenTree

Once the container is built:
- InvenTree server: http://localhost:8001
- Default credentials: Use the admin user created during setup
- Plugin dev server: http://localhost:5174 (for frontend development)

### 5. Start Development Servers

**Start InvenTree server:**
```bash
cd /workspace/reference/inventree-source
invoke dev.server -a 0.0.0.0:8001
```

**Start plugin dev server (for frontend development):**
```bash
cd /workspace/plugins/inventree-flat-bom-generator/frontend
npm run dev
```

---

## Next Steps

For daily development workflow, testing, building, and deployment, see **[docs/reference/SESSION-ONBOARDING.md](docs/reference/SESSION-ONBOARDING.md)**.

For AI-assisted development workflows, see **[.agents/skills/](.agents/skills/)**.

---

## Manual Setup (Alternative)

If you prefer not to use the devcontainer, you can set up the environment manually. However, the devcontainer is strongly recommended for consistency.

### Manual Prerequisites

- **Python 3.8+** installed
- **Node.js 18+** and npm (for frontend development)
- **PostgreSQL** database server
- **Redis** server

### Manual Setup Steps

1. **Clone and initialize submodules** (same as above)
2. **Set up InvenTree development environment** - Follow [InvenTree's official dev setup guide](https://docs.inventree.org/en/latest/developer/)
3. **Install plugin-creator dependencies:**
   ```bash
   cd reference/plugin-creator
   pip install -e .
   cd ../..
   ```
4. **Configure your servers** (see below)

---

## Server Configuration

### Configure Deployment Servers

Copy the example configuration:
```bash
cp config/servers.json.example config/servers.json
```

Edit `config/servers.json` with your server details:
```json
{
  "servers": {
    "staging": {
      "plugin_dir": "/path/to/inventree/data/plugins",
      "url": "https://staging.example.com",
      "api_key": "your-api-key-here",
      "ssh": {
        "host": "staging.example.com",
        "user": "root",
        "port": 22,
        "password": "",
        "key_file": "~/.ssh/id_rsa"
      }
    }
  }
}
```

**For local servers:** Use regular paths like `C:\\InvenTree\\plugins`
**For network servers:** Use UNC paths like `\\\\server\\share\\inventree\\plugins`

---

## Directory Structure

After setup, you should have:

```
inventree-plugin-ai-toolkit/
├── .devcontainer/              # Devcontainer configuration
│   ├── devcontainer.json       # VS Code devcontainer settings
│   ├── Dockerfile             # Container image definition
│   ├── docker-compose.yml     # Service orchestration
│   └── postCreateCommand.sh   # Container setup script
├── config/
│   ├── servers.json          # Your server configs (gitignored)
│   ├── servers.json.example  # Template
│   └── plugin-dev-config.yaml # Plugin development configuration
├── docs/                      # Documentation
├── plugins/                    # Your plugin projects
│   └── inventree-flat-bom-generator/ # Example plugin
├── reference/                  # Reference submodules
│   ├── inventree-source/      # InvenTree source code (submodule)
│   └── plugin-creator/        # Plugin scaffolding tool (submodule)
└── scripts/                    # Legacy PowerShell scripts (deprecated)
```

---

## Security Notes

1. **Never commit `servers.json`** - It contains API keys and credentials
   - Already in `.gitignore`
   
2. **SSH Keys:** Use key-based authentication, not passwords
   ```bash
   # Generate SSH key if needed
   ssh-keygen -t ed25519 -C "inventree-deployment"
   
   # Copy to server
   ssh-copy-id -i ~/.ssh/id_ed25519 user@your-server
   ```

3. **API Keys:** Generate in InvenTree → Admin → Users → Your User → API Tokens

---

## Updating Submodules

To get the latest versions:

```bash
# Update InvenTree source
cd reference/inventree-source
git pull origin stable
cd ../..

# Update plugin-creator
git submodule update --remote reference/plugin-creator

# Commit the updates
git add reference/inventree-source reference/plugin-creator
git commit -m "Update submodules"
```

---

## Troubleshooting

### Devcontainer Issues

**"No space left on device"**
- Free up disk space in WSL/Docker Desktop
- Remove unused Docker images: `docker system prune -a`

**"Workspace does not exist"**
- Rebuild the container: `Dev Containers: Rebuild Container`

**"invoke command not found"**
- Ensure you're running commands inside the devcontainer terminal
- Look for `vscode ➜ /workspace` in the terminal prompt

### Manual Setup Issues

**"plugin-creator not found"**
```bash
git submodule init
git submodule update
```

**"Permission denied (SSH)"**
```bash
# Test SSH connection
ssh -i ~/.ssh/your-key user@server

# Check key permissions (should be 600)
chmod 600 ~/.ssh/your-key  # Linux/Mac
icacls ~/.ssh/your-key /inheritance:r /grant:r "${env:USERNAME}:R"  # Windows
```

---

## Next Steps

Once setup is complete:

1. **Learn the toolkit structure**
   - Read [docs/architecture.md](docs/architecture.md) for the module map
   - Check [docs/reference/SESSION-ONBOARDING.md](docs/reference/SESSION-ONBOARDING.md) for the day-to-day workflow
   - Browse [docs/reference/](docs/reference/) for setup guides and workflows

2. **Use AI-assisted development skills**
   - See `.devin/skills/new-inventree-plugin/` to scaffold a new plugin
   - See `.agents/skills/improve-inventree-plugin/` to verify changes to an existing plugin

Happy plugin development!
