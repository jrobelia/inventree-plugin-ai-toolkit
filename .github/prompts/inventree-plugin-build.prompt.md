---
description: 'Guide user through building an InvenTree plugin with Build-Plugin.ps1'
---

# Build InvenTree Plugin

Guide the user through building a plugin using `Build-Plugin.ps1`.

## Workflow

1. **Gather info:** Which plugin? Clean build?
2. **Verify prerequisites:**
   - In toolkit root directory
   - Plugin exists at `plugins/{PluginName}/`
   - Has `pyproject.toml`
   - Has `package.json` (if frontend)
3. **Build:**
   ```powershell
   .\scripts\Build-Plugin.ps1 -Plugin "PluginName"
   # Or clean build:
   .\scripts\Build-Plugin.ps1 -Plugin "PluginName" -Clean
   ```
4. **Verify:**
   - `.whl` file in `dist/`
   - `static/Panel.js` exists (if frontend)
   - No `[ERROR]` messages

## Common Issues

| Problem | Fix |
|---|---|
| Plugin folder not found | Check name: `Get-ChildItem plugins -Directory` |
| npm not found | Install Node.js, restart PowerShell |
| Frontend build failed | `cd frontend; npm run tsc` to find TS errors |
| Changes not reflected | Use `-Clean` flag, then redeploy |

## Next Steps
- Deploy: `.\scripts\Deploy-Plugin.ps1 -Plugin "PluginName" -Server staging`
- Test: `.\scripts\Test-Plugin.ps1 -Plugin "PluginName"`