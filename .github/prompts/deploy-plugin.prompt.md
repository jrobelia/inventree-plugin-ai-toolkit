---
description: 'Guide user through deploying an InvenTree plugin with Deploy-Plugin.ps1'
mode: 'ask'
tools: ['read', 'run']
---

# Deploy InvenTree Plugin

Help the user deploy an InvenTree plugin to a server using the `Deploy-Plugin.ps1` script.

## Mission

Guide the user through safe plugin deployment, including building, server configuration verification, deployment execution, and post-deployment validation.

## Scope & Preconditions

- User has server access configured in `config/servers.json`
- Plugin has been built successfully (`.whl` file exists)
- User understands deployment will restart InvenTree (brief downtime)
- User has SSH/file access to target server

## Workflow

### 1. Pre-Deployment Checklist

**CRITICAL**: Always verify before deploying:

- [ ] All changes committed to git
- [ ] Tests passing locally
- [ ] Plugin built successfully
- [ ] Deployment target confirmed (staging vs production)
- [ ] Server configuration verified in `config/servers.json`
- [ ] Documentation updated if needed

**Deployment Risk Assessment:**
- 🟢 **Staging**: Safe, low risk
- 🟡 **Production**: Requires careful review
- 🔴 **Breaking Changes**: Requires maintenance window

### 2. Gather Information

Ask if not already known:
- Which plugin to deploy? (required)
- Which server? (required: "staging" or "production")
- Build first, or deploy existing build?

### 3. Verify Server Configuration

**Check `config/servers.json`:**
```powershell
# View server config
Get-Content config/servers.json | ConvertFrom-Json
```

**Required fields per server:**
- `name`: Server identifier (e.g., "staging")
- `host`: Server hostname or IP
- `user`: SSH username
- `pluginPath`: InvenTree plugin install path
- `pythonPath`: Path to InvenTree's Python executable
- `restartCommand`: Command to restart InvenTree

**Example:**
```json
{
  "servers": [
    {
      "name": "staging",
      "host": "staging.example.com",
      "user": "inventree",
      "pluginPath": "/home/inventree/plugins",
      "pythonPath": "/home/inventree/venv/bin/python",
      "restartCommand": "sudo systemctl restart inventree"
    }
  ]
}
```

### 4. Build + Deploy Command

**Build and deploy in one command (recommended):**
```powershell
.\scripts\Deploy-Plugin.ps1 -Plugin "PluginName" -Server staging
```

**Deploy existing build only:**
```powershell
.\scripts\Deploy-Plugin.ps1 -Plugin "PluginName" -Server staging -SkipBuild
```

**Deploy to production (requires confirmation):**
```powershell
.\scripts\Deploy-Plugin.ps1 -Plugin "PluginName" -Server production
```

### 5. Deployment Process

**What the script does:**
1. Builds plugin (unless `-SkipBuild` specified)
2. Verifies `.whl` file exists
3. Copies `.whl` to server via SCP
4. Activates InvenTree virtual environment on server
5. Uninstalls old plugin version
6. Installs new plugin version with pip
7. Restarts InvenTree service
8. Verifies deployment success

**Expected Duration:** 1-3 minutes (includes InvenTree restart)

### 6. Post-Deployment Verification

**Immediate Checks:**
- [ ] Script completed without errors
- [ ] InvenTree service restarted successfully
- [ ] Server logs show no errors

**Manual Verification (in browser):**
1. Log into InvenTree on target server
2. Navigate to Admin → Plugins
3. Verify plugin appears in list and is Active
4. Check plugin version number matches deployed version
5. Test plugin functionality (generate BOM, check panel, etc.)
6. Check browser console (F12) for JavaScript errors

**InvenTree Log Check:**
```bash
# SSH into server
ssh user@server

# Check InvenTree logs
tail -f /path/to/inventree/logs/inventree.log
# Look for plugin loading messages and errors
```

## Common Issues & Solutions

### Issue: "Server configuration not found"
**Cause:** Server name not in `config/servers.json`  
**Solution:**
```powershell
# List configured servers
Get-Content config/servers.json | ConvertFrom-Json | Select-Object -ExpandProperty servers | Select-Object name

# Add server if missing - edit config/servers.json
```

### Issue: "SSH connection failed"
**Cause:** Network issue, wrong credentials, or SSH key not configured  
**Solution:**
```powershell
# Test SSH connection manually
ssh user@server hostname

# If key auth needed, add to SSH config or use ssh-copy-id
```

### Issue: "Plugin not showing in InvenTree admin"
**Cause:** Plugin not activated, entry point wrong, or InvenTree didn't reload  
**Solution:**
1. Check plugin appears in plugin list (may be disabled)
2. Verify entry point in `pyproject.toml`: `Plugin = "package.module:ClassName"`
3. Manually restart InvenTree service
4. Check InvenTree logs for plugin loading errors

### Issue: "Old plugin version still showing"
**Cause:** Browser cache or InvenTree cache  
**Solution:**
```powershell
# Hard refresh browser (Ctrl+Shift+R)
# Or clear browser cache

# On server, verify installed version
ssh user@server "/path/to/python -m pip show inventree-plugin-name"
```

### Issue: "InvenTree won't restart"
**Cause:** Syntax error in plugin, dependency conflict, or service issue  
**Solution:**
```bash
# SSH into server
ssh user@server

# Check service status
sudo systemctl status inventree

# Check logs for errors
tail -50 /path/to/inventree/logs/inventree.log

# Try manual restart
sudo systemctl restart inventree
```

### Issue: "Frontend changes not appearing"
**Cause:** Static files not collected or browser cache  
**Solution:**
```bash
# On server, collect static files
cd /path/to/inventree
source venv/bin/activate
python manage.py collectstatic --noinput

# Restart InvenTree
sudo systemctl restart inventree
```

## Output Expectations

**Success Output:**
```
[INFO] Building plugin: PluginName
[OK] Plugin built successfully
[INFO] Deploying to server: staging
[INFO] Copying plugin to server...
[OK] Plugin copied successfully
[INFO] Installing plugin on server...
[OK] Plugin installed successfully
[INFO] Restarting InvenTree...
[OK] InvenTree restarted
[OK] Deployment completed successfully
```

**Next Steps After Deployment:**
1. Verify plugin in InvenTree admin panel
2. Test plugin functionality manually
3. Check for errors in browser console and server logs
4. If staging successful, consider production deployment
5. Document deployment in git tag or changelog

## Deployment Best Practices

### Always Deploy to Staging First

```powershell
# Deploy to staging
.\scripts\Deploy-Plugin.ps1 -Plugin "PluginName" -Server staging

# Test thoroughly in staging
# If successful, then deploy to production
.\scripts\Deploy-Plugin.ps1 -Plugin "PluginName" -Server production
```

### Tag Deployments in Git

```powershell
# After successful deployment
git tag -a v0.9.3 -m "Deployed to production: Added feature X"
git push origin v0.9.3
```

### Keep Deployment Log

Document in plugin's `docs/internal/DEPLOYMENT-WORKFLOW.md`:
- Date deployed
- Version number
- Environment (staging/production)
- What changed
- Any issues encountered

### Rollback Plan

If deployment fails:
```bash
# SSH to server
ssh user@server

# Install previous version
pip install /path/to/old-version.whl --force-reinstall

# Restart InvenTree
sudo systemctl restart inventree
```

## Quality Checklist

- [ ] Pre-deployment checklist completed
- [ ] Server configuration verified
- [ ] Deploy command includes correct plugin and server
- [ ] Post-deployment verification performed
- [ ] Plugin functionality tested manually
- [ ] No errors in logs or browser console
- [ ] Deployment documented

## Production Deployment Safety

**Before deploying to production:**
- ✅ Tested in staging
- ✅ All tests passing
- ✅ Documentation updated
- ✅ Changelog entry added
- ✅ Rollback plan ready
- ✅ User notification if downtime expected

**During production deployment:**
- 🚨 InvenTree will restart (brief downtime)
- 🚨 Active user sessions may be interrupted
- 🚨 Consider maintenance window for major changes

## Reference

- **Script Location**: `scripts/Deploy-Plugin.ps1`
- **Server Config**: `config/servers.json`
- **Documentation**: See `docs/toolkit/WORKFLOWS.md` → "Deploying a Plugin"
- **Deployment Workflow**: See plugin's `docs/internal/DEPLOYMENT-WORKFLOW.md`
