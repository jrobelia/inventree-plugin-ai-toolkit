# Fresh User Workflow - Integration Testing Setup

**Purpose:** Guide a fresh user from zero to working integration tests  
**Last Updated:** December 17, 2025  
**Time Required:** 1-2 hours (one-time setup)

---

## Prerequisites

Before starting, ensure you have:
- ✅ Git installed ([git-scm.com](https://git-scm.com/))
- ✅ Python 3.9+ installed ([python.org](https://www.python.org/))
- ✅ Windows OS (PowerShell scripts)
- ✅ SQLite3 (usually comes with Python)
- ✅ 5-10 GB disk space (InvenTree + dependencies)

---

## Step 1: Clone Toolkit

```powershell
# Clone the toolkit repository
cd "C:\PythonProjects"
git clone <your-toolkit-repo-url> inventree-plugin-ai-toolkit
cd inventree-plugin-ai-toolkit
```

**What this does:**
- Downloads toolkit with scripts and plugin structure
- Creates workspace for plugin development

**Time:** 1-2 minutes

---

## Step 2: Set Up InvenTree Dev Environment (One-Time)

```powershell
# From toolkit root
.\scripts\Setup-InvenTreeDev.ps1
```

**What this does:**
1. Clones InvenTree stable branch to `inventree-dev/InvenTree/`
2. Creates Python virtual environment (`.venv`)
3. Installs InvenTree dependencies (~200 packages)
4. Runs database migrations (creates SQLite database)
5. Creates test superuser (username: admin, password: inventree)
6. Creates marker file: `inventree-dev/setup-complete.txt`

**Time:** 30-60 minutes (downloads + compilation)

**Troubleshooting:**
- If script fails, use `-Force` to restart from scratch
- Check `inventree-dev/InvenTree/.venv` exists after completion
- Check `inventree-dev/setup-complete.txt` exists

**Output:**
```
[OK] InvenTree dev environment setup complete!
[OK] Database: C:\...\inventree-dev\data\inventree_test.sqlite3
[OK] Admin user: admin / inventree
[INFO] Next step: .\scripts\Link-PluginToDev.ps1 -Plugin "YourPlugin"
```

---

## Step 3: Link Plugin to Dev Environment

```powershell
# From toolkit root
.\scripts\Link-PluginToDev.ps1 -Plugin "FlatBOMGenerator"
```

**What this does:**
1. Creates directory junction: `inventree-dev/InvenTree/src/backend/plugins/FlatBOMGenerator` → `plugins/FlatBOMGenerator`
2. Activates InvenTree virtual environment
3. **Installs plugin via pip**: `pip install -e ./plugins/FlatBOMGenerator`
4. **Activates plugin**: Sets Active=True in database
5. Verifies plugin appears in InvenTree plugin list

**Why pip install?**
- InvenTree loads plugins via entry points (defined in `pyproject.toml`)
- Junction provides file access, but entry points require package installation
- See [INTEGRATION-TESTING-SUMMARY.md](INTEGRATION-TESTING-SUMMARY.md) for 6-hour investigation details

**Time:** 1-2 minutes

**Troubleshooting:**
- If `setup-complete.txt` doesn't exist, run Setup-InvenTreeDev.ps1 first
- If link fails, use `-Force` to recreate
- Check junction: `Get-Item inventree-dev\InvenTree\src\backend\plugins\FlatBOMGenerator`
- Check installation: `cd inventree-dev\InvenTree; .venv\Scripts\pip list | findstr inventree-flat-bom`

**Output:**
```
[OK] Junction created: inventree-dev/InvenTree/src/backend/plugins/FlatBOMGenerator
[OK] Plugin installed via pip
[OK] Plugin activated in database (Active=True)
[OK] Plugin 'inventree-flat-bom-generator' is registered
```

---

## Step 4: Run Integration Tests

```powershell
# From toolkit root
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Integration
```

**What this does:**
1. Activates InvenTree virtual environment
2. Sets plugin testing environment variables
3. Runs `invoke dev.test -r FlatBOMGenerator.tests.integration`
4. Displays test results with colored output

**Time:** 10-30 seconds (depends on test count)

**Expected Output:**
```
[INFO] Running integration tests...
[INFO] Test module: FlatBOMGenerator.flat_bom_generator.tests.integration
----------------------------------------------------------------------
test_view_returns_200_with_valid_part ... ok
test_view_returns_404_with_invalid_part ... ok
test_response_structure_matches_api ... ok
... (11 more tests) ...
----------------------------------------------------------------------
Ran 14 tests in 2.345s

OK
[OK] All integration tests passed!
```

---

## Step 5: Run Unit Tests (Optional)

```powershell
# From toolkit root
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Unit
```

**What this does:**
- Runs fast unit tests (no InvenTree required)
- Uses Python unittest directly
- Tests pure functions in isolation

**Time:** 1-5 seconds

**Why optional?**
- Unit tests don't require InvenTree dev environment
- Can run anytime without setup
- Faster feedback during development

---

## Verification Checklist

After completing all steps, verify:

```powershell
# 1. InvenTree dev environment exists
Test-Path inventree-dev\setup-complete.txt  # Should be True

# 2. Virtual environment exists
Test-Path inventree-dev\InvenTree\.venv  # Should be True

# 3. Plugin is linked (Junction)
Get-Item inventree-dev\InvenTree\src\backend\plugins\FlatBOMGenerator  # Should show Junction

# 4. Plugin is installed (pip)
cd inventree-dev\InvenTree
.venv\Scripts\pip list | findstr inventree-flat-bom  # Should show package

# 5. Integration tests pass
cd ..\..  # Back to toolkit root
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Integration  # All pass
```

**All checks should pass.**

---

## Common Issues & Solutions

### Issue: "InvenTree dev environment not set up"

**Solution:**
```powershell
.\scripts\Setup-InvenTreeDev.ps1
```

### Issue: "Plugin directory not found"

**Solution:**
- Check spelling: `-Plugin "FlatBOMGenerator"` (case-sensitive)
- Check plugin exists: `ls plugins\`

### Issue: Tests fail with "Plugin not found" or "Module not found"

**Root Cause:** Plugin installed via Junction but not pip  
**Solution:**
```powershell
# Re-run Link script (now includes pip install)
.\scripts\Link-PluginToDev.ps1 -Plugin "FlatBOMGenerator" -Force
```

### Issue: AttributeError: 'WSGIRequest' object has no attribute 'query_params'

**Root Cause:** Old DRF APIView testing pattern (pre-December 17, 2025)  
**Solution:**
- Pattern fixed in test_view_function.py
- Update to latest code: `git pull`
- See TESTING-STRATEGY.md → "Testing DRF APIView Subclasses"

### Issue: IntegrityError: UNIQUE constraint failed: auth_user.username

**Root Cause:** Using `--keepdb` with create_user()  
**Solution:**
- Pattern fixed with `get_or_create()` in test_view_function.py
- Update to latest code: `git pull`

---

## What You've Accomplished

After completing this workflow, you have:

✅ **InvenTree Dev Environment** - Full development instance with test database  
✅ **Plugin Linked** - Both Junction (file access) AND pip installed (entry points)  
✅ **Plugin Activated** - Active=True in database, appears in admin panel  
✅ **Integration Tests Working** - Can test with real InvenTree models  
✅ **Unit Tests Working** - Fast tests without database  
✅ **Automated Scripts** - One command to run any test type

---

## Next Steps

**For Development:**
1. Make code changes in `plugins/FlatBOMGenerator/`
2. Run unit tests: `.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Unit`
3. Run integration tests: `.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Integration`
4. Build plugin: `.\scripts\Build-Plugin.ps1 -Plugin "FlatBOMGenerator"`
5. Deploy: `.\scripts\Deploy-Plugin.ps1 -Plugin "FlatBOMGenerator" -Server staging`

**For Learning:**
- Read [TESTING-STRATEGY.md](TESTING-STRATEGY.md) - Unit vs integration philosophy
- Read [INVENTREE-DEV-SETUP.md](INVENTREE-DEV-SETUP.md) - Detailed setup documentation
- Read [INTEGRATION-TESTING-SUMMARY.md](INTEGRATION-TESTING-SUMMARY.md) - What we learned (6-hour investigation)
- See `plugins/FlatBOMGenerator/flat_bom_generator/tests/` for test examples

---

## Time Summary

| Step | Time | Frequency |
|------|------|-----------|
| Setup InvenTree Dev | 30-60 min | One-time |
| Link Plugin | 1-2 min | Per plugin |
| Run Integration Tests | 10-30 sec | Every change |
| Run Unit Tests | 1-5 sec | Very frequent |

**Total First-Time Setup:** ~1 hour  
**Per-Plugin Setup:** ~2 minutes  
**Daily Development:** < 1 minute per test run

---

## Documentation References

**Toolkit Documentation** (docs/toolkit/):
- **TESTING-STRATEGY.md** - Unit vs integration, DRF APIView testing pattern
- **INVENTREE-DEV-SETUP.md** - Detailed setup guide with troubleshooting
- **INTEGRATION-TESTING-SUMMARY.md** - 6-hour investigation notes
- **INTEGRATION-TESTING-SETUP-SUMMARY.md** - Current status, known issues

**Plugin Documentation** (plugins/FlatBOMGenerator/):
- **flat_bom_generator/tests/TEST-PLAN.md** - Test execution guide
- **flat_bom_generator/tests/test_view_function.py** - DRF APIView testing example
- **docs/internal/ROADMAP.md** - Test-first workflow
- **docs/internal/TEST-QUALITY-REVIEW.md** - Test quality analysis

---

_Last Updated: December 18, 2025_  
_Reflects: DRF APIView testing pattern, pip install requirement, Junction + pip dual setup, renamed ROADMAP.md_
