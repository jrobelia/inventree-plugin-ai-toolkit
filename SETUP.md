# InvenTree Plugin Toolkit - Setup Guide

**Audience:** Users | **Category:** Installation Guide | **Purpose:** Initial setup and configuration instructions | **Last Updated:** 2025-12-10

---

This toolkit helps you create, develop, and deploy InvenTree plugins efficiently.

---

## 📋 Prerequisites

- **Python 3.8+** installed
- **Node.js 18+** and npm (for frontend development)
- **PowerShell 5.1+** (Windows) or PowerShell Core (cross-platform)
- **Git** installed
- **(Optional)** SSH access to your InvenTree server

---

## 🚀 Initial Setup

### 1. Clone the Repository

```powershell
git clone <your-repo-url> inventree-plugin-ai-toolkit
cd inventree-plugin-ai-toolkit
```

### 2. Initialize plugin-creator Submodule

The toolkit uses [plugin-creator](https://github.com/inventree/plugin-creator) as a submodule to ensure you always have the latest version.

```powershell
# Initialize and update the submodule
git submodule init
git submodule update
```

This will clone plugin-creator into the correct location automatically.

**Alternative:** If you cloned without `--recurse-submodules`, run:
```powershell
git submodule update --init --recursive
```

### 3. Install plugin-creator Dependencies

```powershell
cd plugin-creator
pip install -e .
cd ..
```

### 4. Configure Your Servers

Copy the example configuration:
```powershell
Copy-Item config\servers.json.example config\servers.json
```

Edit `config\servers.json` with your server details:
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

---

## 🔄 Updating plugin-creator

To get the latest version of plugin-creator:

```powershell
# Update submodule to latest commit
git submodule update --remote plugin-creator

# Or update all submodules
git submodule update --remote

# Commit the update
git add plugin-creator
git commit -m "Update plugin-creator to latest version"
```

---

## 📦 Plugin-creator Location

The toolkit expects plugin-creator at: `plugin-creator/` (inside the toolkit directory)

This is configured in `config\servers.json`:
```json
{
  "paths": {
    "plugin_creator": "plugin-creator"
  }
}
```

**Why as a submodule?**
- Always get the latest official version
- Easy updates via `git submodule update --remote`
- Consistent across all team members
- Separated from your custom code

---

## 🎯 Directory Structure

After setup, you should have:

```
inventree-plugin-ai-toolkit/
├── config/
│   ├── servers.json          # Your server configs (gitignored)
│   └── servers.json.example  # Template
├── copilot/                  # AI assistant resources
├── docs/                     # Documentation
├── plugins/                  # Your plugin projects
├── scripts/                  # PowerShell automation
└── plugin-creator/           # Git submodule (don't modify)
```

---

## 🔐 Security Notes

1. **Never commit `servers.json`** - It contains API keys and credentials
   - Already in `.gitignore`
   
2. **SSH Keys:** Use key-based authentication, not passwords
   ```powershell
   # Generate SSH key if needed
   ssh-keygen -t ed25519 -C "inventree-deployment"
   
   # Copy to server
   ssh-copy-id -i ~/.ssh/id_ed25519 user@your-server
   ```

3. **API Keys:** Generate in InvenTree → Admin → Users → Your User → API Tokens

---

## ✅ Verify Setup

Test that everything works:

```powershell
# Check plugin-creator is accessible
python plugin-creator\plugin_creator\main.py --version

# Create a test plugin
.\scripts\New-Plugin.ps1
# Follow prompts to create "TestPlugin"

# Build it
.\scripts\Deploy-Plugin.ps1 -Plugin "TestPlugin" -Server staging
```

If this works, your setup is complete! 🎉

---

## 🆘 Troubleshooting

### "plugin-creator not found"

```powershell
# Initialize submodule
git submodule init
git submodule update
```

### "Permission denied (SSH)"

```powershell
# Test SSH connection
ssh -i ~/.ssh/your-key user@server

# Check key permissions (should be 600)
chmod 600 ~/.ssh/your-key  # Linux/Mac
icacls ~/.ssh/your-key /inheritance:r /grant:r "${env:USERNAME}:R"  # Windows
```

### "Module not found" errors

```powershell
# Reinstall plugin-creator
cd plugin-creator
pip install -e . --force-reinstall
cd ..
```

---

## 📚 Next Steps

Once setup is complete:
1. Read [WORKFLOWS.md](docs/toolkit/WORKFLOWS.md) for development workflows
2. Check [QUICK-REFERENCE.md](docs/toolkit/QUICK-REFERENCE.md) for quick commands
3. Use [copilot/copilot-guided-creation.md](copilot/copilot-guided-creation.md) with GitHub Copilot

Happy plugin development! 🚀
 
