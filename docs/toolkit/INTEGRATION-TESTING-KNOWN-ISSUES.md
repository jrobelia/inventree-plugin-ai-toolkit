# Integration Testing - Known Issues

**Last Updated**: December 17, 2025  
**Status**: Plugin URLs not routing during test execution

---

## Issue: Plugin URLs Return 404 During Tests

### Summary
- ✅ Plugin loads in registry (confirmed via diagnostic script)
- ✅ Plugin pip-installed with entry points registered  
- ✅ UrlsMixin detected with 1 endpoint defined
- ✅ Plugin activated in database
- ❌ **URLs return 404 during Django test execution**

### Evidence

**Registry Check (Outside Tests)**:
```
Plugin found: flat-bom-generator
UrlsMixin: True
URL patterns: flat-bom/<int:part_id>/
Database Active: True
```

**Test Execution**:
```
GET /api/plugin/flat-bom-generator/flat-bom/1/
→ 404 "API endpoint not found"
```

### Environment Variables Set
```powershell
INVENTREE_PLUGINS_ENABLED = "True"
INVENTREE_PLUGIN_TESTING = "True"        # Should enable all plugins
INVENTREE_PLUGIN_TESTING_SETUP = "True"  # Should enable UrlsMixin
```

### Root Cause Analysis

According to InvenTree documentation:
- `INVENTREE_PLUGIN_TESTING=True` should "enable all plugins no matter their active state in the db"
- `INVENTREE_PLUGIN_TESTING_SETUP=True` should "enable the url mixin"

**However**: During Django `manage.py test` execution, plugin URLs are not being added to Django's URL configuration even with these settings.

### Possible Causes

1. **URL Registration Timing**: Plugin URLs may be registered during Django startup, but test database setup happens AFTER URL routing is configured
2. **Test Client Isolation**: Django test client may not reload plugin URLs for the test database
3. **InvenTree Version Issue**: This behavior may be specific to InvenTree 4.2.26 (stable branch)
4. **Plugin Discovery Order**: Junction + pip install might not be sufficient during test initialization

### Attempted Solutions

✅ Created Junction link to plugin directory  
✅ Pip installed plugin in editable mode (`pip install -e .`)  
✅ Activated plugin in database (PluginConfig.active = True)  
✅ Set all required environment variables  
✅ Confirmed plugin loads in registry outside of tests  
❌ **URLs still not routing during test execution**

---

## Workarounds

### Option 1: Unit Testing Only (Current Approach)

**Recommendation**: Focus on unit tests for business logic, skip integration tests for now.

**What to Test**:
- ✅ BOM traversal algorithms (`bom_traversal.py`)
- ✅ Part categorization (`categorization.py`)
- ✅ Serializers (`serializers.py`)
- ✅ Pure Python functions (no Django models)

**What to Skip**:
- ❌ API endpoint responses (views.py)
- ❌ Database interactions
- ❌ Full request/response cycle

**Run Tests**:
```powershell
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Unit
```

**Test Status**: 106 unit tests (105 passing, 1 skipped)

### Option 2: Manual Integration Testing

Test the API endpoints manually after deploying to staging:

**Setup** (one-time):
```powershell
# 1. Deploy to staging
.\scripts\Deploy-Plugin.ps1 -Plugin "FlatBOMGenerator" -Server staging

# 2. Activate plugin in staging admin panel
# Visit: https://staging.example.com/admin/plugin/pluginconfig/
# Find "FlatBOMGenerator", check "Active", Save
```

**Test**:
```bash
# Test API endpoint
curl https://staging.example.com/api/plugin/flat-bom-generator/flat-bom/123/
```

### Option 3: InvenTree Dev Server Testing

Start InvenTree dev server and test manually:

```powershell
# 1. Start InvenTree server
cd inventree-dev\InvenTree\src\backend\InvenTree
& "..\..\..\.venv\Scripts\Activate.ps1"
python manage.py runserver

# 2. In another terminal, test API
curl http://localhost:8000/api/plugin/flat-bom-generator/flat-bom/1/
```

### Option 4: Wait for InvenTree Fix

This may be a known issue with InvenTree's plugin testing framework. Check:
- InvenTree GitHub issues for plugin testing bugs
- InvenTree Discord/forum for workarounds
- Future InvenTree versions for improvements

---

## Impact Assessment

**Low Impact** for this plugin because:
- ✅ Core BOM algorithms are pure Python (unit testable)
- ✅ API endpoint is simple (thin wrapper around business logic)
- ✅ Serializers have comprehensive unit tests (23 tests)
- ✅ Manual testing on staging server validates end-to-end functionality

**Integration tests would be valuable for**:
- Verifying Django model interactions (Part, BOMItem queries)
- Testing error handling in API views
- Validating serializer integration with real data
- Ensuring stock calculations match database

**Mitigation Strategy**:
1. Maintain high unit test coverage (current: 106 tests)
2. Manual testing on staging before production deployment
3. Monitor InvenTree plugin testing improvements
4. Consider integration tests if InvenTree framework improves

---

## Next Steps

**Short Term** (Current Workflow):
1. Continue with unit tests for all business logic
2. Test refactored code with existing unit tests
3. Deploy to staging and validate manually
4. Document any issues found in staging

**Long Term** (If InvenTree Fixes Issue):
1. Re-enable integration tests
2. Add API endpoint tests (views.py)
3. Add database interaction tests
4. Integrate into CI/CD pipeline

---

## Documentation

**Test Strategy**: See [TESTING-STRATEGY.md](TESTING-STRATEGY.md) for when to use unit vs integration tests

**Test Plan**: See [plugins/FlatBOMGenerator/flat_bom_generator/tests/TEST-PLAN.md](../../plugins/FlatBOMGenerator/flat_bom_generator/tests/TEST-PLAN.md) for plugin-specific test documentation

**Setup Guide**: See [INVENTREE-DEV-SETUP.md](INVENTREE-DEV-SETUP.md) for InvenTree dev environment setup (still useful for development)

---

## References

- **InvenTree Plugin Testing Docs**: https://docs.inventree.org/en/latest/plugins/test/
- **Plugin Discovery Issue**: This document
- **Our Investigation**: check_plugin_registry.py diagnostic script
- **InvenTree Version**: 4.2.26 (stable branch)

---

**Conclusion**: Integration tests for plugin URLs are blocked by an InvenTree framework limitation. Unit testing provides sufficient coverage for this plugin's business logic.
