---
description: 'Guide user through building an InvenTree plugin with Build-Plugin.ps1'
mode: 'ask'
tools: ['read', 'run']
---

# Build InvenTree Plugin

Help the user build an InvenTree plugin using the `Build-Plugin.ps1` script.

## Mission

Guide the user through the plugin build process, explaining parameters, verifying prerequisites, and troubleshooting common issues.

## Scope & Preconditions

- User is in the toolkit root directory or needs guidance to navigate there
- Plugin exists in `plugins/` folder
- Frontend code (if present) needs compilation to `static/` folder
- Python package needs building to `.whl` file

## Workflow

### 1. Gather Information

Ask if not already known:
- Which plugin to build? (required)
- Clean build? (optional, default: false - reuses existing venv)
- Plugin location if not in standard `plugins/` folder

### 2. Verify Prerequisites

Check:
- [ ] PowerShell session active
- [ ] In toolkit root directory
- [ ] Plugin folder exists at `plugins/{PluginName}/`
- [ ] Plugin has `pyproject.toml` and `setup.cfg`
- [ ] If frontend exists, `package.json` present

### 3. Build Command Construction

**Basic Build:**
```powershell
.\scripts\Build-Plugin.ps1 -Plugin "PluginName"
```

**Clean Build (recreate venv):**
```powershell
.\scripts\Build-Plugin.ps1 -Plugin "PluginName" -Clean
```

**Custom Plugin Path:**
```powershell
.\scripts\Build-Plugin.ps1 -PluginPath "C:\path\to\plugin"
```

### 4. Execute Build

**What the script does:**
1. Creates/activates Python virtual environment in plugin folder
2. Installs Python build dependencies
3. **If frontend exists**: Runs `npm install` and `npm run build`
4. Compiles frontend to `{plugin_package}/static/Panel.js`
5. Builds Python wheel in `dist/` folder
6. Reports build results

**Expected Duration:** 30 seconds - 2 minutes (longer on first build or with clean)

### 5. Verify Build Success

**Check for:**
- ✅ Green "[OK]" messages
- ✅ `.whl` file created in `dist/` folder
- ✅ `static/Panel.js` exists (if frontend present)
- ✅ No red "[ERROR]" messages

**Build Output Location:**
- Python wheel: `plugins/{PluginName}/dist/{plugin-name}-{version}-py3-none-any.whl`
- Frontend assets: `plugins/{PluginName}/{plugin_package}/static/`

## Common Issues & Solutions

### Issue: "Plugin folder not found"
**Cause:** Wrong plugin name or not in toolkit root  
**Solution:**
```powershell
# List available plugins
Get-ChildItem plugins -Directory

# Navigate to toolkit root
cd "C:\PythonProjects\Inventree Plugin Creator\inventree-plugin-ai-toolkit"
```

### Issue: "npm not found"
**Cause:** Node.js not installed or not in PATH  
**Solution:**
- Install Node.js from https://nodejs.org/
- Restart PowerShell after installation

### Issue: "Frontend build failed"
**Cause:** TypeScript errors or missing dependencies  
**Solution:**
```powershell
# Navigate to frontend folder
cd plugins/{PluginName}/frontend

# Check for TypeScript errors
npm run tsc

# Reinstall dependencies
Remove-Item node_modules -Recurse -Force
npm install
```

### Issue: "Virtual environment activation failed"
**Cause:** Python not installed or execution policy restrictive  
**Solution:**
```powershell
# Check Python installation
python --version

# Set execution policy (if admin)
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

### Issue: "Build succeeds but changes not reflected"
**Cause:** Need to rebuild and reinstall in InvenTree  
**Solution:**
```powershell
# Clean build to force recompilation
.\scripts\Build-Plugin.ps1 -Plugin "PluginName" -Clean

# Then deploy to test environment
.\scripts\Deploy-Plugin.ps1 -Plugin "PluginName" -Server staging
```

## Output Expectations

**Success Output:**
```
[INFO] Building plugin: PluginName
[INFO] Creating virtual environment...
[INFO] Installing build dependencies...
[INFO] Building frontend...
[OK] Frontend built successfully
[INFO] Building Python package...
[OK] Plugin built successfully
[INFO] Output: plugins\PluginName\dist\inventree-plugin-name-0.1.0-py3-none-any.whl
```

**Next Steps After Build:**
- Deploy to staging: `.\scripts\Deploy-Plugin.ps1 -Plugin "PluginName" -Server staging`
- Run tests: `.\scripts\Test-Plugin.ps1 -Plugin "PluginName"`
- Check build artifacts in `dist/` and `static/` folders

## Quality Checklist

- [ ] Plugin name verified and correct
- [ ] Build command includes all required parameters
- [ ] Prerequisites verified before executing
- [ ] Build output checked for errors
- [ ] Build artifacts confirmed to exist
- [ ] User understands next steps

## Additional Context

### When to Use Clean Build

Use `-Clean` flag when:
- Switching Python versions
- Dependencies changed significantly
- Weird caching issues occurring
- Virtual environment corrupted

**Trade-off:** Clean build takes longer (reinstalls all dependencies) but ensures fresh environment.

### Build vs Deploy

- **Build**: Creates `.whl` file locally (safe, no server changes)
- **Deploy**: Copies `.whl` to server and restarts InvenTree (requires server access)

Always build first, then deploy.

## Reference

- **Script Location**: `scripts/Build-Plugin.ps1`
- **Documentation**: See `docs/toolkit/WORKFLOWS.md` → "Building a Plugin"
- **Quick Reference**: See `QUICK-REFERENCE.md`
