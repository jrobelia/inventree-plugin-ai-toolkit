# InvenTree Plugin Testing Framework - Research Summary

## Overview

This document summarizes findings from investigating InvenTree's Django-based testing framework for plugins.

**Date**: 2025-12-10  
**Context**: Creating lightweight testing strategy and automated test runner for FlatBOMGenerator plugin

---

## Key Findings

### 1. Test Framework: Django TestCase

InvenTree plugins use **Django's TestCase** framework, NOT Python's standard `unittest` or `pytest`.

**Base Classes** (from `InvenTree.unit_test`):
- `InvenTreeTestCase` - For basic unit tests
- `InvenTreeAPITestCase` - For API endpoint tests (extends Django REST Framework's `APITestCase`)

**Mixins Available**:
- `PluginRegistryMixin` - Ensures plugin registry is ready
- `UserMixin` - Creates test users with permissions
- `ExchangeRateMixin` - Sets up exchange rate data
- `TestQueryMixin` - Helpers for asserting query counts

### 2. Test Execution: `invoke dev.test`

InvenTree uses **invoke** task runner (not pytest, not manage.py test directly).

**Command Pattern**:
```bash
invoke dev.test -r module.path.TestClass
```

**Example**:
```bash
# Run specific test class
invoke dev.test -r flat_bom_generator.tests.test_shortfall_calculation.ShortfallCalculationTests

# Run all tests in module
invoke dev.test -r flat_bom_generator.tests.test_shortfall_calculation
```

**Important**: Module path omits `plugin_directory` prefix when plugin is installed outside InvenTree directory (e.g., in `.local/lib/`).

### 3. Environment Variables Required

Three environment variables must be set before running tests:

```powershell
$env:INVENTREE_PLUGINS_ENABLED = "True"
$env:INVENTREE_PLUGIN_TESTING = "True"
$env:INVENTREE_PLUGIN_TESTING_SETUP = "True"
```

| Variable | Purpose |
|----------|---------|
| `INVENTREE_PLUGINS_ENABLED` | Enables 3rd party plugin system |
| `INVENTREE_PLUGIN_TESTING` | Activates all plugins regardless of DB state |
| `INVENTREE_PLUGIN_TESTING_SETUP` | Enables URL mixin for test endpoints |

### 4. Test File Structure

**Standard Location**:
```
plugin_name/
  __init__.py
  core.py
  views.py
  tests/
    __init__.py
    test_feature1.py
    test_feature2.py
```

**Test File Naming**: Must start with `test_` prefix

**Test Class Pattern**:
```python
from InvenTree.unit_test import InvenTreeTestCase

class MyFeatureTests(InvenTreeTestCase):
    """Tests for MyFeature functionality."""
    
    @classmethod
    def setUpTestData(cls):
        """Setup test data once for all test methods."""
        super().setUpTestData()
        # Create test objects here
    
    def test_something(self):
        """Test that something works."""
        # Arrange, Act, Assert
        self.assertEqual(result, expected)
```

### 5. Test Database

Django creates a **temporary test database** automatically:
- Completely isolated from development/production databases
- Created before tests run, destroyed after
- All Django ORM models available (Part, BomItem, Stock, etc.)

**Creating Test Data**:
```python
from part.models import Part, PartCategory

# In test method or setUpTestData()
test_cat = PartCategory.objects.create(name='TestCategory')
test_part = Part.objects.create(
    name='TestPart',
    category=test_cat,
    active=True,
    purchaseable=True
)
```

### 6. Plugin-Creator Scaffolding

**Surprising Finding**: The `plugin-creator` tool **does NOT scaffold a tests directory** by default.

**What IS Scaffolded**:
- `pyproject.toml` - Includes `tests` in ruff exclude list
- `.gitlab-ci.yml` - Has lint/build stages but NO test stage
- Core plugin files (core.py, views.py, serializers.py)
- Frontend structure

**What Is NOT Scaffolded**:
- `tests/` directory
- Example test files
- Test configuration (pytest.ini, etc.)

**Implication**: InvenTree plugin testing is **optional** and left to plugin developers to implement as needed.

### 7. GitLab CI Pipeline

Standard plugin CI pipeline has 3 stages:

1. **Lint Stage** - `ruff check` for code quality
2. **Build Stage** - `python -m build` to create wheel
3. **Frontend Stage** - `npm run build` + `biome lint`

**No Test Stage** - CI does not run unit tests by default

### 8. Fallback: Python unittest

If `invoke` command is not available (e.g., running outside InvenTree dev environment), tests can fall back to standard Python unittest:

```bash
python -m unittest discover -s tests -p "test_*.py" -v
```

**Limitations**:
- No InvenTree database models available
- Can only test pure Python logic (no Django ORM)
- Must mock InvenTree imports

---

## Implementation Decisions

Based on these findings, we implemented:

### 1. Test-Plugin.ps1 Script

**Location**: `scripts/Test-Plugin.ps1`

**Features**:
- Automatically sets required environment variables
- Discovers test files in plugin's `tests/` directory
- Tries `invoke dev.test` first (preferred)
- Falls back to `python -m unittest` if invoke unavailable
- Colored output with pass/fail indicators

**Usage**:
```powershell
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator"
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Verbose
```

### 2. Simplified TEST-PLAN.md

**Location**: `plugins/FlatBOMGenerator/TEST-PLAN.md`

**Approach**:
- Lightweight: 10-15 minute manual smoke test checklist
- Minimal unit tests: Only critical logic (shortfall calculation)
- No CI/CD complexity: Manual test execution as needed
- Optional future tests: BOM traversal, categorization (only if bugs found)

**Philosophy**: Practical testing that respects user's preference for lightweight solutions over comprehensive automation.

### 3. Future Test Migration

**Current**: `test_shortfall_calculation.py` uses Python's `unittest.TestCase`  
**Future**: Should migrate to `InvenTreeTestCase` when needed

**Migration Example**:
```python
# Before (current)
import unittest

class ShortfallCalculationTests(unittest.TestCase):
    def calculate_shortfall(self, ...):
        # Pure Python logic
    
    def test_scenario_1(self):
        result = self.calculate_shortfall(...)
        self.assertEqual(result, expected)

# After (Django-based)
from InvenTree.unit_test import InvenTreeTestCase
from part.models import Part

class ShortfallCalculationTests(InvenTreeTestCase):
    @classmethod
    def setUpTestData(cls):
        super().setUpTestData()
        cls.test_part = Part.objects.create(...)
    
    def test_scenario_1_with_real_part(self):
        # Test with actual Django models
        result = calculate_shortfall(self.test_part, ...)
        self.assertEqual(result, expected)
```

---

## References

### Official Documentation
- **InvenTree Plugin Testing**: https://docs.inventree.org/en/latest/plugins/test/
- **Django TestCase**: https://docs.djangoproject.com/en/stable/topics/testing/tools/#testcase

### Example Test Files in InvenTree Source
- `plugin/test_plugin.py` - Plugin registry tests
- `plugin/test_api.py` - Plugin API endpoint tests
- `plugin/samples/integration/test_sample.py` - Sample integration plugin tests
- `plugin/samples/integration/test_validation_sample.py` - Sample validation tests
- `plugin/builtin/barcodes/test_inventree_barcode.py` - Built-in plugin tests

### Helper Classes
- `InvenTree/unit_test.py` - Base test classes and mixins
  - `InvenTreeTestCase` (line 364)
  - `InvenTreeAPITestCase` (line 475)
  - `PluginRegistryMixin` (line 360)

---

## Next Steps

1. ✅ **DONE**: Created `Test-Plugin.ps1` automated test runner
2. ✅ **DONE**: Simplified `TEST-PLAN.md` to lightweight approach
3. 📋 **OPTIONAL**: Migrate `test_shortfall_calculation.py` to `InvenTreeTestCase` when Django models needed
4. 📋 **OPTIONAL**: Add basic BOM traversal tests if production issues arise
5. 📋 **OPTIONAL**: Configure GitLab CI test stage (if full automation desired in future)

---

## Lessons Learned

1. **InvenTree is Django-based** - Plugins must use Django test framework for full functionality
2. **Testing is optional** - plugin-creator doesn't scaffold tests by default
3. **invoke is key** - `invoke dev.test` is the standard way to run InvenTree plugin tests
4. **Fallback is limited** - Python unittest fallback only works for pure logic tests
5. **Lightweight is valid** - Not all plugins need comprehensive test automation
6. **Manual testing is practical** - 10-15 minute smoke test checklist can be sufficient for stable plugins
