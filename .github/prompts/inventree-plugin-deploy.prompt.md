---
description: 'Guide user through deploying an InvenTree plugin with Deploy-Plugin.ps1'
---

# Deploy InvenTree Plugin

Guide the user through safe plugin deployment to a server.

## Pre-Deployment Checklist

- [ ] All changes committed to git
- [ ] Tests passing locally
- [ ] Plugin built successfully
- [ ] Target confirmed (staging vs production)
- [ ] Server configured in `config/servers.json`

## Deployment

```powershell
# Build and deploy (recommended)
.\scripts\Deploy-Plugin.ps1 -Plugin "PluginName" -Server staging

# Deploy existing build only
.\scripts\Deploy-Plugin.ps1 -Plugin "PluginName" -Server staging -SkipBuild
```

## Post-Deployment Verification

1. Log into InvenTree on target server.
2. Navigate to Admin -> Plugins.
3. Verify plugin appears, is Active, and version matches.
4. Test plugin functionality end-to-end.
5. Check browser console (F12) for JavaScript errors.

## Common Issues

| Problem | Fix |
|---|---|
| Server config not found | Check `config/servers.json` |
| SSH connection failed | Test: `ssh user@server hostname` |
| Plugin not showing | Verify entry point in `pyproject.toml` |
| Old version still showing | Hard refresh (Ctrl+Shift+R), check `pip show` on server |
| InvenTree won't restart | SSH in, check `systemctl status inventree` and logs |

## Risk Levels
- Staging: safe, low risk.
- Production: requires careful review.
- Breaking changes: requires maintenance window.