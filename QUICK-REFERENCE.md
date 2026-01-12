# Quick Reference Card

**Audience:** Users and AI Agents | **Category:** Command Reference | **Purpose:** Quick lookup for toolkit commands and patterns | **Last Updated:** 2026-01-12

**Location:** Toolkit root (moved from `docs/toolkit/` for easy access)

---

Keep this handy while developing InvenTree plugins!

---

## 🚀 Copy-Paste Commands

**All commands assume you're starting from the toolkit root:**
```
c:\PythonProjects\Inventree Plugin Creator\inventree-plugin-ai-toolkit\
```

### Build, Commit, Deploy (Full Workflow) FlatBOMGenerator used as Plugin Example Name
```powershell
cd "c:\PythonProjects\Inventree Plugin Creator\inventree-plugin-ai-toolkit"
cd plugins\FlatBOMGenerator
git add -A
git commit -m "your commit message here"
git push origin main
cd ..\..
.\scripts\Deploy-Plugin.ps1 -Plugin "FlatBOMGenerator" -Server staging  # Auto-builds
```

### Build Only
```powershell
cd "c:\PythonProjects\Inventree Plugin Creator\inventree-plugin-ai-toolkit"
.\scripts\Build-Plugin.ps1 -Plugin "FlatBOMGenerator"
```

### Commit Plugin Changes Only
```powershell
cd "c:\PythonProjects\Inventree Plugin Creator\inventree-plugin-ai-toolkit\plugins\FlatBOMGenerator"
git add -A
git commit -m "your message"
git push origin main
```

### Deploy Only
```powershell
cd "c:\PythonProjects\Inventree Plugin Creator\inventree-plugin-ai-toolkit"
.\scripts\Deploy-Plugin.ps1 -Plugin "FlatBOMGenerator" -Server staging
```

### Deploy (Auto-builds)
```powershell
cd "c:\PythonProjects\Inventree Plugin Creator\inventree-plugin-ai-toolkit"
.\scripts\Deploy-Plugin.ps1 -Plugin "FlatBOMGenerator" -Server staging
```

**Why cd to toolkit root?** Scripts look for `plugins/` folder and `config/servers.json` as relative paths.

---

## 🛠️ Common Toolkit Commands

```powershell
# Create new plugin
.\scripts\New-Plugin.ps1

# Build plugin (optional - Deploy auto-builds)
.\scripts\Build-Plugin.ps1 -Plugin "plugin-name"

# Deploy to staging (automatically builds first)
.\scripts\Deploy-Plugin.ps1 -Plugin "plugin-name" -Server staging

# Deploy to production (automatically builds first)
.\scripts\Deploy-Plugin.ps1 -Plugin "plugin-name" -Server production
```

**Note:** Deploy-Plugin.ps1 automatically runs Build-Plugin.ps1 before copying files, so manual builds are optional.

---

## 🧪 Testing Commands

```powershell
# Run unit tests (fast, no InvenTree required)
.\scripts\Test-Plugin.ps1 -Plugin "plugin-name" -Unit

# Run integration tests (requires InvenTree dev setup)
.\scripts\Test-Plugin.ps1 -Plugin "plugin-name" -Integration

# Run all tests
.\scripts\Test-Plugin.ps1 -Plugin "plugin-name" -All

# Filter test output (useful for CI/CD or large test suites)
.\scripts\Test-Plugin.ps1 -Plugin "plugin-name" -Integration 2>&1 | Select-String -Pattern '(test_name|Ran|OK|FAILED)'

# Show only last 40 lines with context
.\scripts\Test-Plugin.ps1 -Plugin "plugin-name" -Integration 2>&1 | Select-String -Pattern '(Ran \d+|OK|FAILED)' -Context 0,1 | Select-Object -Last 40
```

---

## 📁 Important Files

| File | Purpose | Edit? |
|------|---------|-------|
| `core.py` | Main plugin logic | ✅ YES |
| `views.py` | API endpoints | ✅ YES |
| `models.py` | Database models | ✅ YES |
| `Panel.tsx` | UI panels | ✅ YES |
| `Dashboard.tsx` | Dashboard widgets | ✅ YES |
| `pyproject.toml` | Python dependencies | ✅ YES |
| `package.json` | Frontend dependencies | ✅ YES |
| `static/` | Compiled frontend | ❌ NO (auto-generated) |

---

## 🎨 Mantine Components (Most Used)

```typescript
import { 
  Alert,      // <Alert title="Title">Content</Alert>
  Button,     // <Button onClick={...}>Click</Button>
  Text,       // <Text size="lg">Text</Text>
  Title,      // <Title order={3}>Heading</Title>
  Table,      // <Table><Table.Tbody>...</Table.Tbody></Table>
  Stack,      // <Stack>Items stacked vertically</Stack>
  Group,      // <Group>Items in a row</Group>
  Card,       // <Card>Container with border</Card>
  Badge,      // <Badge>Label</Badge>
  Loader,     // <Loader /> (spinning loader)
} from '@mantine/core';
```

---

## 🔌 Plugin Mixins

Add to your plugin class to enable features:

```python
class MyPlugin(
    SettingsMixin,        # Plugin settings
    UrlsMixin,            # Custom API endpoints
    UserInterfaceMixin,   # UI panels/dashboards
    EventMixin,           # Listen to InvenTree events
    ScheduleMixin,        # Scheduled tasks
    AppMixin,             # Database models
    InvenTreePlugin
):
    ...
```

---

## 🌐 Context Properties (Frontend)

```typescript
context.id              // Current item ID (e.g., part ID)
context.model           // Model type ('part', 'stock', etc.)
context.instance        // Full object data
context.user.username() // Current user
context.api.get(url)    // Make API calls
context.navigate('/..') // Go to another page
context.theme           // Theme colors
context.locale          // Current language
```

---

## 🎯 Target Models (for Panels)

```python
# Show panel on different pages:
if context.get('target_model') == 'part':        # Part pages
if context.get('target_model') == 'stock':       # Stock pages
if context.get('target_model') == 'company':     # Company pages
if context.get('target_model') == 'purchaseorder': # PO pages

# Access the instance ID and query database:
part_id = context.get('target_id')
from part.models import Part
part = Part.objects.get(pk=part_id)
if part.assembly:  # Check properties
    # Show panel only for assemblies
```

---

## 📊 Icon Examples (Tabler Icons)

```python
'icon': 'ti:info-circle'      # Info icon
'icon': 'ti:chart-bar'        # Chart/stats icon
'icon': 'ti:settings'         # Settings icon
'icon': 'ti:tool'             # Tool icon
'icon': 'ti:package'          # Package icon
'icon': 'ti:check'            # Checkmark
'icon': 'ti:alert-triangle'   # Warning
'icon': 'ti:dashboard'        # Dashboard
```

Browse all icons: https://tabler-icons.io/

---

## ✨ Code Quality Tools

**Auto-formatted when scaffolding new plugins:**

```powershell
# One-time setup per plugin
cd plugins/YourPlugin
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install pre-commit
pre-commit install
pre-commit run --all-files  # Initial formatting

# Runs automatically on every commit
git commit  # Ruff + Biome auto-format code

# Manual checks (optional)
pre-commit run --all-files          # All code
cd frontend; npm run lint           # Frontend only
cd frontend; npm run lint:fix       # Frontend auto-fix
```

**Tools included:**
- **Ruff** - Python linter/formatter (PEP 8)
- **Biome** - TypeScript/React linter/formatter
- **Pre-commit** - Runs checks before each commit

---

## 🐛 Troubleshooting Checklist

**Plugin doesn't appear:**
- [ ] Deployed to correct folder?
- [ ] InvenTree restarted?
- [ ] Check server logs
- [ ] Verify `__init__.py` exists with `PLUGIN_VERSION`

**Panel doesn't show:**
- [ ] Frontend built? (Deploy-Plugin auto-builds if needed)
- [ ] `static/` folder exists with .js files?
- [ ] Panel registered in `get_ui_panels()`?
- [ ] Correct `target_model`?
- [ ] Check browser console for errors

**Build fails:**
- [ ] Run `npm install` in frontend/
- [ ] Delete `node_modules/` and reinstall
- [ ] Check for TypeScript syntax errors
- [ ] Read the error message!

---

## 💬 Quick Copilot Prompts

```
# Create a panel
@workspace Create a custom panel for Part pages in Panel.tsx with [DESCRIPTION]

# Add API endpoint  
@workspace Create an API endpoint in views.py that [DESCRIPTION]

# Debug error
I'm getting this error: [ERROR]. Help me fix it.

# Add setting
@workspace Add a plugin setting called [NAME] that [DESCRIPTION]
```

---

## 📞 Getting Help

1. **Read error messages** - they usually tell you what's wrong
2. **Check toolkit/WORKFLOWS.md** - step-by-step guides
3. **Check copilot/PROJECT-CONTEXT.md** - technical architecture and patterns
4. **Ask Copilot** - reference copilot/plugin-creation-prompts.md for guided creation
5. **InvenTree Docs** - https://docs.inventree.org/

---

## 🎓 Learning Path

1. ✅ Create your first simple plugin (no frontend)
2. ✅ Add plugin settings
3. ✅ Add a custom API endpoint
4. ✅ Create a plugin with a simple panel
5. ✅ Fetch data from your API in the frontend
6. ⬜ Add a dashboard widget
7. ⬜ Use database models
8. ⬜ Add scheduled tasks
9. ⬜ Handle events

---

## 💾 Configuration Locations

```
config/servers.json          # Server paths & credentials
.vscode/settings.json        # VS Code settings
plugins/your-plugin/         # Your plugin code
```

---

## 🔄 Typical Workflow

```
1. Create plugin    → .\scripts\New-Plugin.ps1
2. Edit code        → Use VS Code
3. Deploy to test   → .\scripts\Deploy-Plugin.ps1 -Server staging  # Auto-builds
4. Test it          → Check on staging server
5. Fix issues       → Repeat from step 2
6. Deploy to prod   → .\scripts\Deploy-Plugin.ps1 -Server production
```

**Note:** Deploy-Plugin.ps1 automatically runs Build-Plugin.ps1, so you don't need to build separately unless testing the build.

---

Print this page and keep it near your desk! 📌
