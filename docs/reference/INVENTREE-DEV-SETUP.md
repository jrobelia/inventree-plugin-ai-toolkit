# InvenTree Development Environment Setup

**Purpose**: Set up InvenTree development environment for real integration testing of plugins

**Audience**: Plugin developers needing integration tests with real InvenTree models  
**Time**: 1-2 hours (one-time setup)  
**Benefit**: Reusable testing infrastructure for all plugins in toolkit

**Related Documentation**:
- **[TESTING-STRATEGY.md](TESTING-STRATEGY.md)** - When to use unit vs integration tests (read this first!)
- **[INTEGRATION-TESTING-SUMMARY.md](INTEGRATION-TESTING-SUMMARY.md)** - Executive summary and quick start

---

## Overview

### What You Get

✅ **Real Integration Tests**: Test plugins with actual Part, BOM, Stock models  
✅ **Temporary Test Database**: Safe testing, no risk to production data  
✅ **Official Pattern**: InvenTree's recommended approach, won't break with updates  
✅ **Shared Infrastructure**: One setup works for all plugins in toolkit  
✅ **Automated Testing**: Run via `invoke dev.test` command

### When to Use This

**Use InvenTree Dev Environment For:**
- API endpoint integration tests (views.py)
- BOM traversal with real BOM structures
- Database query validation
- Serializer testing with real models
- Complex plugin features requiring InvenTree context

**Keep Fast Unit Tests For:**
- Pure functions (categorization, parsing, calculations)
- Serializer field validation
- Business logic without database
- Quick feedback during development

**Testing Strategy**: Hybrid approach - fast unit tests for TDD, integration tests before deployment

---

## Architecture

### Directory Structure

```
inventree-plugin-ai-toolkit/
├── inventree-dev/                # NEW: InvenTree development environment
│   ├── InvenTree/                # Cloned InvenTree repository
│   │   ├── InvenTree/            # InvenTree source code
│   │   ├── src/                  # Plugin symlinks go here
│   │   │   └── backend/
│   │   │       └── plugins/
│   │   │           └── FlatBOMGenerator → (symlink to plugins/FlatBOMGenerator)
│   │   ├── manage.py
│   │   └── pyproject.toml
│   ├── data/                     # SQLite test database, media files
│   ├── .env                      # InvenTree configuration
│   └── setup-complete.txt        # Setup status marker
├── plugins/
│   └── FlatBOMGenerator/
│       └── flat_bom_generator/
│           └── tests/
│               ├── unit/          # Fast unit tests (existing tests)
│               └── integration/   # InvenTree integration tests (NEW)
├── scripts/
│   ├── Setup-InvenTreeDev.ps1    # NEW: Automated setup script
│   ├── Test-Plugin.ps1           # Updated: Support integration tests
│   └── Link-PluginToDev.ps1      # NEW: Symlink plugin to InvenTree
└── docs/
    └── toolkit/
        └── INVENTREE-DEV-SETUP.md  # This file
```

### How It Works

1. **InvenTree Development Mode**: Clone InvenTree repo with full source code
2. **Plugin Symlinks**: Symlink your plugin into InvenTree's plugins directory
3. **Test Execution**: InvenTree creates temporary database, runs tests, cleans up
4. **Shared Environment**: All plugins use same InvenTree dev setup

---

## Setup Process

### Prerequisites

**Required Software:**
- Git (for cloning InvenTree)
- Python 3.9+ (preferably 3.12)
- PostgreSQL OR MySQL OR SQLite (SQLite easiest for testing)
- Node.js + npm (for frontend, optional for testing)

**Check Prerequisites:**
```powershell
# Verify installations
git --version
python --version
sqlite3 --version  # Or mysql --version / psql --version
```

### Step 1: Automated Setup (Recommended)

We'll create an automated script to handle setup:

```powershell
# From toolkit root
.\scripts\Setup-InvenTreeDev.ps1

# Script will:
# 1. Create inventree-dev/ directory
# 2. Clone InvenTree stable branch
# 3. Create Python virtual environment
# 4. Install InvenTree dependencies
# 5. Create .env configuration
# 6. Run initial database migrations
# 7. Create test superuser
# 8. Mark setup complete
```

**What the script does:**
- Clones InvenTree from `https://github.com/inventree/inventree.git`
- Uses `stable` branch (matches your production InvenTree version)
- Creates isolated Python virtual environment
- Installs all InvenTree dependencies
- Configures for development + testing
- Creates marker file when complete

### Step 2: Manual Setup (Alternative)

If automated script fails or you prefer manual:

```powershell
# 1. Create directory and clone InvenTree
cd "C:\PythonProjects\Inventree Plugin Creator\inventree-plugin-ai-toolkit"
mkdir inventree-dev
cd inventree-dev
git clone --branch stable https://github.com/inventree/inventree.git InvenTree

# 2. Create virtual environment
cd InvenTree
python -m venv .venv
& .venv\Scripts\Activate.ps1

# 3. Install dependencies
pip install --upgrade pip
pip install -e .
pip install -r requirements-dev.txt

# 4. Create .env file
@"
# InvenTree Configuration for Testing
INVENTREE_DEBUG=True
INVENTREE_LOG_LEVEL=WARNING
INVENTREE_DB_ENGINE=sqlite3
INVENTREE_DB_NAME=../data/inventree_test.sqlite3
INVENTREE_MEDIA_ROOT=../data/media
INVENTREE_STATIC_ROOT=../data/static
INVENTREE_BACKUP_DIR=../data/backup
INVENTREE_PLUGINS_ENABLED=True
INVENTREE_PLUGIN_TESTING=True
INVENTREE_PLUGIN_TESTING_SETUP=True
"@ | Out-File -Encoding utf8 .env

# 5. Run initial setup
python manage.py migrate
python manage.py collectstatic --noinput
python manage.py createsuperuser --username admin --email admin@example.com

# 6. Mark setup complete
"Setup completed on $(Get-Date)" | Out-File -Encoding utf8 ../setup-complete.txt
```

### Step 3: Verify Installation

```powershell
# Activate InvenTree environment
cd "C:\PythonProjects\Inventree Plugin Creator\inventree-plugin-ai-toolkit\inventree-dev\InvenTree"
& .venv\Scripts\Activate.ps1

# Check InvenTree version
python manage.py version

# Run InvenTree's own tests (optional, ~5 min)
invoke dev.test

# Should see: "OK" or "Ran XXX tests"
```

---

## Plugin Integration

### Linking Your Plugin

Each plugin needs to be symlinked into InvenTree for testing:

```powershell
# Link FlatBOMGenerator plugin
.\scripts\Link-PluginToDev.ps1 -Plugin "FlatBOMGenerator"

# Creates symlink:
# inventree-dev/InvenTree/src/backend/plugins/FlatBOMGenerator
# → plugins/FlatBOMGenerator
```

**Why Symlinks?**
- InvenTree sees your plugin as if installed
- Changes in `plugins/FlatBOMGenerator` immediately visible
- No need to reinstall plugin after each change
- Same pattern for all plugins

### Test Organization

Organize tests into unit vs integration:

```
flat_bom_generator/tests/
├── __init__.py
├── unit/                          # Fast tests, no InvenTree
│   ├── __init__.py
│   ├── test_categorization.py
│   ├── test_serializers.py
│   └── test_shortfall_calculation.py
└── integration/                   # InvenTree integration tests
    ├── __init__.py
    ├── test_views_integration.py  # API endpoint tests
    └── test_bom_traversal_integration.py
```

**Benefits:**
- Run fast unit tests during development (`python -m unittest discover -s flat_bom_generator/tests/unit`)
- Run integration tests before deployment (`invoke dev.test -r FlatBOMGenerator.tests.integration`)
- Clear separation of concerns

---

## Writing Integration Tests

### Basic Pattern

```python
"""Integration tests for FlatBOMGenerator views.

These tests use InvenTree's test framework with real database models.
Requires InvenTree development environment setup.
"""

from InvenTree.unit_test import InvenTreeTestCase
from part.models import Part, PartCategory, BomItem
from plugin.registry import registry


class FlatBOMViewIntegrationTests(InvenTreeTestCase):
    """Integration tests for FlatBOMView API endpoint."""
    
    @classmethod
    def setUpTestData(cls):
        """Create test data once for all tests."""
        super().setUpTestData()
        
        # Create category
        cls.test_cat = PartCategory.objects.create(name='Electronics')
        
        # Create parts
        cls.assembly = Part.objects.create(
            name='Main Assembly',
            IPN='ASM-001',
            category=cls.test_cat,
            active=True,
            is_template=False,
            assembly=True
        )
        
        cls.component = Part.objects.create(
            name='Resistor, 10k',
            IPN='FAB-100',
            category=cls.test_cat,
            active=True,
            purchaseable=True
        )
        
        # Create BOM relationship
        BomItem.objects.create(
            part=cls.assembly,
            sub_part=cls.component,
            quantity=2
        )
    
    def test_flat_bom_api_returns_correct_structure(self):
        """Test that flat BOM API returns expected JSON structure."""
        # Get plugin instance
        plugin = registry.get_plugin('flatbomgenerator')
        
        # Call the view (or test via API client)
        from flat_bom_generator.views import FlatBOMView
        
        # Mock request with part_id
        # ... test actual API behavior
        
        # Assertions
        self.assertIsNotNone(plugin)
        # ... more assertions
```

### Advanced Examples

**Test BOM Traversal with Real BOM:**
```python
def test_nested_bom_traversal(self):
    """Test BOM traversal with 3-level nested assembly."""
    # Create 3-level BOM: TLA → IMP → FAB
    tla = Part.objects.create(name='TLA', assembly=True)
    imp = Part.objects.create(name='IMP', assembly=True)
    fab = Part.objects.create(name='FAB', purchaseable=True)
    
    BomItem.objects.create(part=tla, sub_part=imp, quantity=2)
    BomItem.objects.create(part=imp, sub_part=fab, quantity=5)
    
    # Test traversal
    from flat_bom_generator.bom_traversal import get_flat_bom
    result = get_flat_bom(tla.pk)
    
    # Should have 1 leaf part (FAB) with quantity 10 (2 × 5)
    self.assertEqual(len(result), 1)
    self.assertEqual(result[0]['part_id'], fab.pk)
    self.assertEqual(result[0]['total_qty'], 10.0)
```

**Test with Stock Levels:**
```python
def test_shortfall_calculation_with_stock(self):
    """Test shortfall calculation with actual stock items."""
    from stock.models import StockItem
    
    # Create part with stock
    part = Part.objects.create(name='Component', purchaseable=True)
    StockItem.objects.create(part=part, quantity=50)
    StockItem.objects.create(part=part, quantity=25)
    
    # Total stock should be 75
    self.assertEqual(part.total_stock, 75)
    
    # Test shortfall calculation
    # ... call your plugin function
```

---

## Running Tests

### Quick Reference

```powershell
# Unit tests only (fast, 0.2s)
cd plugins\FlatBOMGenerator
python -m unittest discover -s flat_bom_generator/tests/unit -v

# Integration tests (slower, 2-5s)
cd inventree-dev\InvenTree
& .venv\Scripts\Activate.ps1
invoke dev.test -r FlatBOMGenerator.tests.integration -v

# All tests (unit + integration)
invoke dev.test -r FlatBOMGenerator.tests -v

# Specific test class
invoke dev.test -r FlatBOMGenerator.tests.integration.test_views_integration.FlatBOMViewIntegrationTests
```

### Test-Plugin.ps1 Updates

The toolkit's `Test-Plugin.ps1` script will be updated to support both:

```powershell
# Run fast unit tests (default)
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator"

# Run integration tests (requires InvenTree dev setup)
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Integration

# Run all tests
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -All
```

---

## Workflow Examples

### Development Workflow

**1. TDD with Fast Unit Tests:**
```powershell
# Write failing test
# flat_bom_generator/tests/unit/test_categorization.py

# Run unit tests (fast feedback)
python -m unittest flat_bom_generator.tests.unit.test_categorization -v

# Implement feature
# flat_bom_generator/categorization.py

# Re-run tests until passing
python -m unittest flat_bom_generator.tests.unit.test_categorization -v
```

**2. Integration Testing Before Deployment:**
```powershell
# All unit tests pass, ready for integration check
cd inventree-dev\InvenTree
& .venv\Scripts\Activate.ps1

# Run integration tests
invoke dev.test -r FlatBOMGenerator.tests.integration -v

# If pass → deploy to staging
cd ..\..
.\scripts\Deploy-Plugin.ps1 -Plugin "FlatBOMGenerator" -Server staging
```

**3. Full Test Suite Before Release:**
```powershell
# Run everything
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -All

# If all pass → tag release and deploy to production
```

### CI/CD Integration (Future)

When ready for CI/CD, GitHub Actions can:
1. Clone InvenTree
2. Symlink plugin
3. Run integration tests
4. Auto-deploy if passing

---

## Troubleshooting

### Common Issues

**Issue**: "InvenTree.unit_test module not found"
```powershell
# Solution: Activate InvenTree virtual environment
cd inventree-dev\InvenTree
& .venv\Scripts\Activate.ps1
```

**Issue**: "Plugin not found in registry"
```powershell
# Solution: Symlink not created or broken
.\scripts\Link-PluginToDev.ps1 -Plugin "FlatBOMGenerator"

# Verify symlink exists
Test-Path "inventree-dev\InvenTree\src\backend\plugins\FlatBOMGenerator"
```

**Issue**: "Database migration errors"
```powershell
# Solution: Reset test database
cd inventree-dev\InvenTree
rm ../data/inventree_test.sqlite3
python manage.py migrate
```

**Issue**: "Tests can't import plugin modules"
```powershell
# Solution: Ensure plugin is in Python path
# Check inventree-dev/InvenTree/src/backend/plugins/ has symlink

# Or run from InvenTree directory with invoke
cd inventree-dev\InvenTree
invoke dev.test -r FlatBOMGenerator.tests.integration
```

---

## Maintenance

### Updating InvenTree Version

When new InvenTree stable version releases:

```powershell
cd inventree-dev\InvenTree
git fetch origin
git checkout stable
git pull

# Update dependencies
& .venv\Scripts\Activate.ps1
pip install -e . --upgrade
pip install -r requirements-dev.txt --upgrade

# Run migrations
python manage.py migrate

# Verify setup still works
invoke dev.test -r FlatBOMGenerator.tests.integration
```

### Cleaning Up

```powershell
# Remove test database and media
cd inventree-dev
rm -Recurse data\*

# Re-run migrations
cd InvenTree
python manage.py migrate
```

### Removing Dev Environment

```powershell
# If you need to start over
cd "C:\PythonProjects\Inventree Plugin Creator\inventree-plugin-ai-toolkit"
rm -Recurse -Force inventree-dev

# Re-run setup
.\scripts\Setup-InvenTreeDev.ps1
```

---

## Performance Tips

**Keep Integration Tests Fast:**
- Minimize database queries (use `select_related()`, `prefetch_related()`)
- Create minimal test data (don't create 100 parts if 3 will do)
- Use `setUpTestData()` for data shared across tests
- Run unit tests during development, integration tests before commits

**Optimize Test Execution:**
```powershell
# Parallel test execution (if many test files)
invoke dev.test -r FlatBOMGenerator.tests.integration --parallel

# Failfast (stop on first failure)
invoke dev.test -r FlatBOMGenerator.tests.integration --failfast
```

---

## References

- **InvenTree Testing Docs**: https://docs.inventree.org/en/stable/plugins/test/
- **InvenTree Development Setup**: https://docs.inventree.org/en/stable/start/bare_dev/
- **Django Testing**: https://docs.djangoproject.com/en/stable/topics/testing/
- **Invoke Commands**: `invoke --list` (in InvenTree directory)

---

## Summary

**What We Built:**
- Shared InvenTree development environment for all plugins
- Automated setup script for reproducible installation
- Clear testing strategy (unit tests for TDD, integration tests for validation)
- Documentation and tooling for long-term maintainability

**Benefits:**
- Real integration tests with actual InvenTree models
- Reusable infrastructure across all plugins
- Official InvenTree pattern (future-proof)
- 1-2 hour setup pays off across multiple plugins

**Next Steps:**
1. Run `.\scripts\Setup-InvenTreeDev.ps1` (one-time)
2. Link your plugin: `.\scripts\Link-PluginToDev.ps1 -Plugin "FlatBOMGenerator"`
3. Organize tests into `unit/` and `integration/` folders
4. Write integration tests for views.py API endpoint
5. Update deployment workflow to run integration tests

---

**Last Updated**: December 16, 2025  
**Toolkit Version**: 1.1  
**InvenTree Compatibility**: Stable branch (1.1.x)
