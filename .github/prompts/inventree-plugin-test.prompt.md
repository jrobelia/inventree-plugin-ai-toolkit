---
description: 'Guide user through running InvenTree plugin tests with Test-Plugin.ps1'
---

# Test InvenTree Plugin

Guide the user through running unit and integration tests for an InvenTree
plugin using `Test-Plugin.ps1`.

---

## Decision Matrix

| Testing | Type | Command |
|---|---|---|
| Serializers, calculations, logic | Unit | `Test-Plugin.ps1 -Plugin "Name" -Unit` |
| API views, database operations | Integration | `Test-Plugin.ps1 -Plugin "Name" -Integration` |
| Everything before deployment | Both | `Test-Plugin.ps1 -Plugin "Name" -All` |

---

## Unit Tests (fast, no database)

```powershell
# Run all unit tests
.\scripts\Test-Plugin.ps1 -Plugin "PluginName" -Unit

# Run specific test file
.\scripts\Test-Plugin.ps1 -Plugin "PluginName" -Unit -TestPath "plugin_package.tests.test_serializers"

# Verbose output
.\scripts\Test-Plugin.ps1 -Plugin "PluginName" -Unit -Verbose
```

Expected duration: 5-30 seconds.

---

## Integration Tests (requires InvenTree dev environment)

**First-time setup:**
```powershell
.\scripts\Setup-InvenTreeDev.ps1
.\scripts\Link-PluginToDev.ps1 -Plugin "PluginName"
# Then enable the plugin in InvenTree admin -> Plugins -> Active = True
```

**Run integration tests:**
```powershell
.\scripts\Test-Plugin.ps1 -Plugin "PluginName" -Integration
```

Expected duration: 30 seconds - 5 minutes.

---

## Interpreting Output

| Output | Meaning |
|---|---|
| `OK` | All tests passed |
| `FAILED (failures=X)` | X assertion failures -- check expected vs actual |
| `ERROR (errors=X)` | X tests crashed -- check exceptions |
| `SKIPPED (skipped=X)` | X tests intentionally skipped |

---

## Common Issues

| Problem | Fix |
|---|---|
| No tests found | Check `tests/` folder exists with `test_*.py` files |
| ModuleNotFoundError | Activate venv and `pip install` missing package |
| InvenTree dev not found | Run `.\scripts\Setup-InvenTreeDev.ps1` (one-time) |
| Plugin not activated | Enable in InvenTree admin -> Plugins -> Active = True |
| Passes locally, fails in integration | Check `setUpTestData()` creates all required objects |

---

## Next Steps

- Build: `/run inventree-plugin-build`
- Deploy: `/run inventree-plugin-deploy`
- Review: `/run inventree-review`