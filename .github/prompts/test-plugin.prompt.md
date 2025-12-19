---
description: 'Guide user through running InvenTree plugin tests with Test-Plugin.ps1'
mode: 'ask'
tools: ['read', 'run']
---

# Test InvenTree Plugin

Help the user run tests for an InvenTree plugin using the `Test-Plugin.ps1` script.

## Mission

Guide the user through running unit and integration tests, explaining test types, interpreting results, and troubleshooting test failures.

## Scope & Preconditions

- Plugin has tests in `{plugin_package}/tests/` folder
- Unit tests run standalone (fast, no database)
- Integration tests require InvenTree dev environment setup
- User understands test-first workflow importance

## Test Types

### Unit Tests (Recommended for Development)

**Characteristics:**
- ✅ Fast (seconds)
- ✅ No database required
- ✅ Test pure functions and business logic
- ✅ Run locally in plugin venv
- ✅ Easy to debug

**When to use:** Testing serializers, calculations, categorization logic, data transformations

### Integration Tests (Required Before Deployment)

**Characteristics:**
- ⏱️ Slower (minutes)
- 🗄️ Requires InvenTree dev environment
- 🔗 Tests plugin integration with InvenTree
- 🌐 Tests API endpoints with real Django request/response
- 🏗️ One-time setup required

**When to use:** Testing views, database operations, InvenTree model interactions

## Workflow

### 1. Determine Test Type Needed

**Ask user:**
- Testing what? (serializers, views, business logic, etc.)
- Need quick feedback or full integration testing?
- Is InvenTree dev environment set up?

**Decision Matrix:**
| Testing | Test Type | Command |
|---------|-----------|---------|
| Serializers, calculations, categorization | Unit | `Test-Plugin.ps1 -Plugin "Name" -Unit` |
| API views, database operations | Integration | `Test-Plugin.ps1 -Plugin "Name" -Integration` |
| Everything before deployment | Both | `Test-Plugin.ps1 -Plugin "Name" -All` |

### 2. Unit Tests (Quick Start)

**Run all unit tests:**
```powershell
.\scripts\Test-Plugin.ps1 -Plugin "PluginName" -Unit
```

**Run specific test file:**
```powershell
.\scripts\Test-Plugin.ps1 -Plugin "PluginName" -Unit -TestPath "plugin_package.tests.test_serializers"
```

**With verbose output:**
```powershell
.\scripts\Test-Plugin.ps1 -Plugin "PluginName" -Unit -Verbose
```

**What happens:**
1. Activates plugin's virtual environment
2. Sets test environment variables
3. Runs Python unittest discover on `tests/` folder
4. Reports pass/fail results

**Expected Duration:** 5-30 seconds

### 3. Integration Tests (One-Time Setup)

**First time only - setup InvenTree dev environment:**
```powershell
# Step 1: Set up InvenTree development environment
.\scripts\Setup-InvenTreeDev.ps1

# Step 2: Link plugin to InvenTree dev
.\scripts\Link-PluginToDev.ps1 -Plugin "PluginName"

# Step 3: Activate plugin in InvenTree admin panel
# (Run InvenTree dev server, log in, enable plugin)
```

**Run integration tests:**
```powershell
.\scripts\Test-Plugin.ps1 -Plugin "PluginName" -Integration
```

**What happens:**
1. Checks InvenTree dev environment exists
2. Checks plugin is linked (Junction or pip install)
3. Activates InvenTree's virtual environment
4. Runs tests using InvenTree's `invoke dev.test` command
5. Reports results

**Expected Duration:** 30 seconds - 5 minutes (depending on test count)

### 4. Run All Tests

**For pre-deployment verification:**
```powershell
.\scripts\Test-Plugin.ps1 -Plugin "PluginName" -All
```

Runs unit tests first, then integration tests (if environment available).

### 5. Interpret Results

**Success Output:**
```
[INFO] Running unit tests for PluginName
Ran 23 tests in 2.5s
OK
[OK] All tests passed
```

**Failure Output:**
```
[INFO] Running unit tests for PluginName
FAIL: test_serializer_validates_required_fields
----------------------------------------------------------------------
AssertionError: Expected validation error for missing field
Ran 23 tests in 2.5s
FAILED (failures=1)
[ERROR] Tests failed
```

**Understanding Test Output:**
- `OK` = All tests passed
- `FAILED (failures=X)` = X tests failed (check assertions)
- `ERROR (errors=X)` = X tests crashed (check exceptions)
- `SKIPPED (skipped=X)` = X tests intentionally skipped

## Common Issues & Solutions

### Issue: "No tests found"
**Cause:** Tests folder empty or naming doesn't match pattern  
**Solution:**
```powershell
# Check tests exist
Get-ChildItem plugins/{PluginName}/{plugin_package}/tests

# Tests must be named test_*.py
# Test classes must inherit from unittest.TestCase
```

### Issue: "ModuleNotFoundError"
**Cause:** Missing dependencies or import paths wrong  
**Solution:**
```powershell
# Check venv has dependencies
& plugins/{PluginName}/.venv/Scripts/Activate.ps1
pip list

# Install missing dependencies
pip install missing-package
```

### Issue: "Integration tests: InvenTree dev not found"
**Cause:** InvenTree dev environment not set up  
**Solution:**
```powershell
# Run one-time setup
.\scripts\Setup-InvenTreeDev.ps1

# Then link plugin
.\scripts\Link-PluginToDev.ps1 -Plugin "PluginName"
```

### Issue: "Integration tests: Plugin not activated"
**Cause:** Plugin not enabled in InvenTree admin  
**Solution:**
1. Start InvenTree dev server: `cd inventree-dev\InvenTree; invoke dev.server`
2. Browse to http://localhost:8000/admin
3. Navigate to Plugins
4. Find plugin and set Active=True
5. Save

### Issue: "Test passes locally but fails in integration"
**Cause:** Integration test uses real database/InvenTree models  
**Solution:**
- Check if test assumes specific data exists
- Verify test creates required objects in `setUpTestData()`
- Check InvenTree version compatibility

### Issue: "One test skipped"
**Cause:** Test decorated with `@unittest.skip()` or conditional skip  
**Solution:**
```python
# Find skipped test
@unittest.skip("Reason for skipping")
def test_something(self):
    pass

# Investigate reason - is feature incomplete? Test broken?
```

## Test-First Workflow

### When Adding New Feature

1. **Write failing test first**
```powershell
# Run tests - new test should fail
.\scripts\Test-Plugin.ps1 -Plugin "Name" -Unit
```

2. **Implement feature**
```python
# Write minimal code to make test pass
```

3. **Run tests again**
```powershell
# Tests should now pass
.\scripts\Test-Plugin.ps1 -Plugin "Name" -Unit
```

4. **Refactor with confidence**
```python
# Improve code, tests ensure no regressions
```

### When Refactoring Existing Code

1. **Check tests exist**
```powershell
# If tests missing, write them first (code-first methodology)
```

2. **Run tests before refactoring**
```powershell
.\scripts\Test-Plugin.ps1 -Plugin "Name" -Unit
# All should pass
```

3. **Refactor code**
```python
# Make changes
```

4. **Run tests after refactoring**
```powershell
.\scripts\Test-Plugin.ps1 -Plugin "Name" -Unit
# Should still pass
```

## Output Expectations

### Successful Unit Test Run
```
[INFO] Running unit tests for FlatBOMGenerator
[INFO] Test path: flat_bom_generator.tests
.......................
----------------------------------------------------------------------
Ran 23 tests in 2.834s

OK
[OK] All tests passed (23 tests)
```

### Successful Integration Test Run
```
[INFO] Running integration tests for FlatBOMGenerator
[INFO] Using InvenTree dev environment
[INFO] Running: invoke dev.test -r FlatBOMGenerator.tests.integration
...............
----------------------------------------------------------------------
Ran 15 tests in 45.234s

OK
[OK] All integration tests passed (15 tests)
```

### Failed Test Run
```
[INFO] Running unit tests for FlatBOMGenerator
.....F.......
======================================================================
FAIL: test_shortfall_calculation (flat_bom_generator.tests.test_shortfall.ShortfallTests)
----------------------------------------------------------------------
Traceback (most recent call last):
  File "...", line 45, in test_shortfall_calculation
    self.assertEqual(shortfall, 5)
AssertionError: 10 != 5

----------------------------------------------------------------------
Ran 13 tests in 3.156s

FAILED (failures=1)
[ERROR] Tests failed (1 failure)
```

## Quality Checklist

- [ ] Test type appropriate for what's being tested
- [ ] Integration test prerequisites met (if needed)
- [ ] Test output reviewed and understood
- [ ] Failed tests investigated and fixed
- [ ] Skipped tests investigated (should they run?)
- [ ] Test results documented if needed

## Test Quality Standards

### Good Test Characteristics

- ✅ **Specific assertions**: `assertEqual(result, 42)` not `assertTrue(result > 0)`
- ✅ **Clear test names**: `test_should_return_5_when_stock_is_50_and_qty_is_10`
- ✅ **Tests actual behavior**: Not implementation details
- ✅ **Self-contained**: No external dependencies or files
- ✅ **Fast**: Unit tests run in milliseconds

### Test Anti-Patterns

- ❌ Tests that duplicate production code logic
- ❌ Tests with magic numbers (unexplained values)
- ❌ Tests that rely on external CSV files
- ❌ Tests with vague assertions
- ❌ Tests that are always skipped

### Test Coverage Goals

- **Unit Tests**: Test all public functions and edge cases
- **Integration Tests**: Test all API endpoints and views
- **Critical Paths**: 100% coverage of core business logic
- **Quality Over Quantity**: 50 good tests > 200 weak tests

## Reference

- **Script Location**: `scripts/Test-Plugin.ps1`
- **Test Strategy**: See `docs/toolkit/TESTING-STRATEGY.md`
- **Plugin Test Plan**: See plugin's `docs/internal/TEST-PLAN.md`
- **Test Quality Review**: See plugin's `docs/internal/TEST-QUALITY-REVIEW.md`
- **InvenTree Dev Setup**: See `docs/toolkit/INVENTREE-DEV-SETUP.md`
- **Integration Testing**: See `docs/toolkit/INTEGRATION-TESTING-SUMMARY.md`
