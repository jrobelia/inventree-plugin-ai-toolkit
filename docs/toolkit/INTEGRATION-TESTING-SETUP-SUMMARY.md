# Integration Testing Setup - Summary & Status

**Date**: December 17, 2025  
**Status**: ✅ Test Discovery Working, ⚠️ Plugin URL Registration Issue

---

## What We Accomplished

### ✅ Successfully Completed

1. **InvenTree Dev Environment Setup**
   - InvenTree v4.2.26 installed in `inventree-dev/InvenTree`
   - Virtual environment configured with all dependencies
   - WeasyPrint/Pango configured for PDF generation (Windows)
   - Test database created

2. **Plugin Linking**
   - FlatBOMGenerator linked via Windows Junction (no admin privileges needed)
   - Link verified: `inventree-dev\InvenTree\src\backend\plugins\FlatBOMGenerator`

3. **Test Discovery Fixed**
   - **Root Cause**: Plugin directory needed `__init__.py` to be proper Python package (not namespace package)
   - **Solution**: Created `FlatBOMGenerator/__init__.py`
   - Tests now discoverable via path: `FlatBOMGenerator.flat_bom_generator.tests.integration`

4. **Test Execution Working**
   - Test-Plugin.ps1 script successfully runs integration tests
   - 14 tests discovered and executed
   - Django test framework properly initialized

5. **Script Improvements**
   - Test-Plugin.ps1 loads .env file for InvenTree configuration
   - Adds plugins directory to PYTHONPATH automatically
   - Sets required plugin testing environment variables
   - Activates InvenTree virtual environment correctly
   - Uses `python manage.py test` directly (Windows-compatible, no PTY issues)

### ⚠️ Known Issue - Plugin URL Registration

**Current State**: Tests run but fail with 404 errors

**Error**: `{"detail": "API endpoint not found", "url": "http://testserver/api/plugin/flat-bom-generator/flat-bom/1/"}`

**Root Cause**: Plugin URLs aren't being registered during test execution despite correct environment variables:
- `INVENTREE_PLUGINS_ENABLED=True`
- `INVENTREE_PLUGIN_TESTING=True`
- `INVENTREE_PLUGIN_TESTING_SETUP=True`

**Test Results**: 13 failures (all 404), 1 pass (404 test that expects nonexistent part)

**What This Means**: Test framework is working correctly, but plugin registration mechanism needs investigation.

---

## Key Files Created/Modified

### Created Files

1. **`FlatBOMGenerator/__init__.py`**
   ```python
   # FlatBOMGenerator Plugin
   # This file makes the plugin directory a proper Python package for test discovery
   ```
   **Why**: Converts namespace package to regular package for Django test discovery

2. **`plugins/__init__.py`** (in `src/backend/plugins`)
   ```python
   # InvenTree plugins directory
   # This file makes the plugins directory a Python package for testing
   ```
   **Why**: Allows `from plugins import FlatBOMGenerator` syntax

3. **Integration test file**: `flat_bom_generator/tests/integration/test_views_integration.py`
   - 14 comprehensive integration tests
   - Tests API endpoints, serializers, BOM traversal
   - Username changed to `flatbom_testuser` (avoids InvenTree fixture conflicts)

### Modified Files

1. **`Test-Plugin.ps1`** (scripts/)
   - Loads .env file before integration tests
   - Sets plugin testing environment variables after venv activation
   - Adds plugins directory to PYTHONPATH
   - Uses full module path: `FlatBOMGenerator.flat_bom_generator.tests.integration`

2. **`Link-PluginToDev.ps1`** (scripts/)
   - Accepts both SymbolicLink and Junction link types
   - Auto-fallbacks to Junction without admin privileges

3. **`Setup-InvenTreeDev.ps1`** (scripts/)
   - Automates Pango installation via MSYS2
   - Configures WEASYPRINT_DLL_DIRECTORIES in .env

---

## How to Run Integration Tests

### Prerequisites (One-Time Setup)

```powershell
# 1. Set up InvenTree dev environment
.\scripts\Setup-InvenTreeDev.ps1

# 2. Link plugin to InvenTree
.\scripts\Link-PluginToDev.ps1 -Plugin "FlatBOMGenerator"
```

### Running Tests

```powershell
# Run all integration tests (from toolkit root)
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Integration

# Run specific test module
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -TestPath "FlatBOMGenerator.flat_bom_generator.tests.integration.test_views_integration"

# Run unit tests (fast, no InvenTree required)
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Unit

# Run all tests
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -All
```

### Manual Execution (For Debugging)

```powershell
# Navigate to InvenTree backend
cd inventree-dev\InvenTree\src\backend\InvenTree

# Activate virtual environment
& "..\..\..\.venv\Scripts\Activate.ps1"

# Set environment variables
$env:INVENTREE_PLUGINS_ENABLED = "True"
$env:INVENTREE_PLUGIN_TESTING = "True"
$env:INVENTREE_PLUGIN_TESTING_SETUP = "True"
$env:PYTHONPATH = "C:\...\inventree-dev\InvenTree\src\backend\plugins"

# Run tests
python manage.py test FlatBOMGenerator.flat_bom_generator.tests.integration
```

---

## Test Path Format

**Correct**: `FlatBOMGenerator.flat_bom_generator.tests.integration`

**Breakdown**:
- `FlatBOMGenerator` - Plugin directory name (needs `__init__.py`)
- `flat_bom_generator` - Python package (snake_case)
- `tests` - Test directory
- `integration` - Integration test subdirectory

**NOT**: `plugins.FlatBOMGenerator...` (Django can't find this path)

---

## Environment Variables Required

These must be set for plugin integration tests:

| Variable | Value | Purpose |
|----------|-------|---------|
| `INVENTREE_PLUGINS_ENABLED` | `True` | Enable plugin system |
| `INVENTREE_PLUGIN_TESTING` | `True` | Enable all plugins regardless of database state |
| `INVENTREE_PLUGIN_TESTING_SETUP` | `True` | Enable URL mixin during testing |
| `PYTHONPATH` | `<path-to-plugins-dir>` | Allow Django to discover plugin modules |

**Where They're Set**: Test-Plugin.ps1 sets these after venv activation

---

## Critical Patterns Discovered

### 1. Plugin Must Be Regular Package, Not Namespace Package

**Problem**: Django test discovery failed with `ModuleNotFoundError: No module named 'FlatBOMGenerator.tests'`

**Cause**: Plugin directory had no `__init__.py`, making it a namespace package

**Solution**: Create `FlatBOMGenerator/__init__.py` (even if empty)

**Test**: `python -c "import FlatBOMGenerator; print(FlatBOMGenerator)"` should show module path, not "namespace"

### 2. Environment Variables Must Be Set AFTER Venv Activation

**Problem**: Environment variables set before venv activation weren't available to Django

**Solution**: Set variables after running `. $activateScript` in PowerShell

### 3. Username Conflicts with InvenTree Test Fixtures

**Problem**: `IntegrityError: UNIQUE constraint failed: auth_user.username` with 'testuser'

**Solution**: Use unique username like 'flatbom_testuser'

---

## Next Steps (Plugin URL Registration)

**Goal**: Get plugin URLs registered so API endpoint tests pass

**Possible Causes**:
1. Plugin not being detected by InvenTree plugin registry during testing
2. UrlsMixin not being initialized despite `INVENTREE_PLUGIN_TESTING_SETUP=True`
3. Plugin needs to be in `plugins.txt` or plugin configuration file
4. Test client not reloading URL patterns after plugin registration

**Investigation Needed**:
- Check InvenTree plugin registry logs during test execution
- Verify plugin is in `registry.plugins` dict during test
- Check if URL patterns are being generated by UrlsMixin
- Review InvenTree's own plugin integration tests as reference

**Temporary Workaround**:
- Tests can be marked as `@unittest.expectedFailure` for URL-dependent tests
- Focus on testing business logic (BOM traversal, serializers) without API layer

---

## Windows-Specific Considerations

### Junction vs SymbolicLink
- Junction works without admin privileges
- Link-PluginToDev.ps1 auto-fallbacks to Junction
- Verify with: `Get-Item <path> | Select-Object LinkType, Target`

### WeasyPrint/Pango
- Requires MSYS2 for GTK3 libraries
- `WEASYPRINT_DLL_DIRECTORIES` must point to MinGW64 bin folder
- Setup-InvenTreeDev.ps1 automates this

### PowerShell Environment
- Use dot-sourcing (`. script.ps1`) to persist env vars
- Avoid `& script.ps1` for activation scripts

---

## Lessons Learned

1. **Test-First Workflow Works**: Creating integration tests before InvenTree dev setup helped validate the entire toolchain

2. **Windows Development Viable**: With proper setup (MSYS2, Junction links), Windows is fully supported for InvenTree plugin development

3. **Django Test Discovery Requires Proper Packages**: Namespace packages cause test discovery failures

4. **Environment Variable Timing Matters**: Variables must be set in the correct shell context (after venv activation)

5. **InvenTree Plugin Testing Is Complex**: Plugin registration during testing requires specific configuration not fully documented

---

## Documentation References

**InvenTree Plugin Testing**: https://docs.inventree.org/en/latest/plugins/test/

**Created Documentation**:
- [INVENTREE-DEV-SETUP.md](INVENTREE-DEV-SETUP.md) - Full InvenTree dev environment setup guide
- [TESTING-STRATEGY.md](TESTING-STRATEGY.md) - Unit vs integration testing philosophy
- [INTEGRATION-TESTING-SUMMARY.md](INTEGRATION-TESTING-SUMMARY.md) - This document

**Related Plugin Documentation**:
- [FlatBOMGenerator/docs/internal/TEST-PLAN.md](../../plugins/FlatBOMGenerator/flat_bom_generator/tests/TEST-PLAN.md)
- [FlatBOMGenerator/docs/internal/TEST-QUALITY-REVIEW.md](../../plugins/FlatBOMGenerator/docs/internal/TEST-QUALITY-REVIEW.md)

---

## Success Metrics

✅ **Achieved**:
- InvenTree dev environment fully functional
- Plugin linked and discoverable
- 14 integration tests discovered and executed
- Test framework properly configured
- Automated test script working

⚠️ **In Progress**:
- Plugin URL registration (404 errors)
- All 14 integration tests passing

---

**Last Updated**: December 17, 2025  
**Next Review**: After plugin URL registration issue resolved
