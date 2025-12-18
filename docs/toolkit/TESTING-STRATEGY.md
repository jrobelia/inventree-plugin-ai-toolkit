# Testing Strategy - InvenTree Plugin Toolkit

**Purpose**: Define when and how to use unit tests vs integration tests for InvenTree plugins

**Audience**: Plugin developers  
**Last Updated**: December 17, 2025

**Related Documentation**:
- **[INVENTREE-DEV-SETUP.md](INVENTREE-DEV-SETUP.md)** - How to set up InvenTree dev environment (step-by-step)
- **[INTEGRATION-TESTING-SUMMARY.md](INTEGRATION-TESTING-SUMMARY.md)** - Quick overview and what we built

---

## Overview

This toolkit supports **two types of tests**:

1. **Unit Tests**: Fast, pure Python, no database
2. **Integration Tests**: Real InvenTree models, with database

**Philosophy**: Use the right tool for the job. Fast unit tests for TDD, integration tests for validation.

### ⚠️ Critical Understanding: Plugin URL Testing Not Supported

**InvenTree does NOT support plugin URL integration testing via HTTP requests.** Django's test client cannot resolve dynamic plugin URLs during tests. This is a framework limitation, not a bug.

**What This Means:**
- ❌ **Cannot test**: `self.client.get('/api/plugin/your-plugin/endpoint/')` → Returns 404
- ✅ **Can test**: Direct function calls with real models → Works perfectly

**Correct Integration Testing Approach:**
```python
# ❌ DON'T: Try to test plugin URLs via HTTP
response = self.client.get('/api/plugin/flat-bom-generator/flat-bom/123/')  # 404!

# ✅ DO: Call functions directly with real Part objects
from flat_bom_generator.bom_traversal import get_flat_bom
result, imp_count, warnings, max_depth = get_flat_bom(part.pk)  # Works!

# ✅ ALSO WORKS: Call DRF APIView as callable (for testing view layer)
from rest_framework.test import APIRequestFactory, force_authenticate
factory = APIRequestFactory()
view = MyAPIView.as_view()  # Get callable
request = factory.get('/fake-url/')
force_authenticate(request, user=test_user)  # Bypass auth
response = view(request, part_id=123)  # Calls dispatch() which wraps request
```

**Key Principle**: Integration tests validate "does it work with real InvenTree models?" not "does the HTTP layer work?" (that's manual testing).

See [INTEGRATION-TESTING-SUMMARY.md](INTEGRATION-TESTING-SUMMARY.md) for detailed investigation notes.

---

## Test Types Comparison

| Aspect | Unit Tests | Integration Tests |
|--------|-----------|------------------|
| **Speed** | Very fast (~0.2s) | Slower (~2-5s) |
| **Setup** | None (just Python) | InvenTree dev environment |
| **Database** | No database | Temporary test database |
| **Models** | Mock or no models | Real Part, BOM, Stock models |
| **When** | During development | Before deployment |
| **Purpose** | Fast feedback, TDD | Validate real behavior |
| **Location** | `tests/unit/` | `tests/integration/` |
| **Runner** | `python -m unittest` | `invoke dev.test` |

---

## When to Use Each Type

### Use Unit Tests For:

✅ **Pure Functions**
```python
# categorization.py
def categorize_part(part_name, is_assembly, is_top_level, has_default_supplier):
    """Pure function - no database, perfect for unit testing."""
    if is_top_level:
        return "TLA"
    # ... logic
```

**Test with**: Mock inputs, assert outputs
```python
# tests/unit/test_categorization.py
def test_categorize_part_tla(self):
    result = categorize_part("Assembly", True, True, False)
    self.assertEqual(result, "TLA")
```

✅ **Business Logic**
- Calculation functions (shortfall, pricing)
- Parsing logic (extracting units from strings)
- Data transformation (format conversion)
- Validation rules

✅ **Serializer Field Validation**
```python
# tests/unit/test_serializers.py
def test_bom_item_serializer_required_fields(self):
    """Test serializer validates required fields."""
    data = {"part_id": 123}  # Missing required fields
    serializer = FlatBOMItemSerializer(data=data)
    self.assertFalse(serializer.is_valid())
```

✅ **Edge Cases and Error Handling**
- Null/None values
- Empty strings
- Invalid inputs
- Type mismatches

**Benefits:**
- Instant feedback (< 1 second)
- Run continuously during development
- No setup complexity
- Easy to debug

---

### Use Integration Tests For:

✅ **Functions with Real Database Models**
```python
# tests/integration/test_bom_traversal_integration.py
class BOMTraversalIntegrationTests(InvenTreeTestCase):
    """Test BOM functions with real InvenTree models."""
    
    def test_get_flat_bom_accepts_real_part_id(self):
        """get_flat_bom should work with real Part objects."""
        from flat_bom_generator.bom_traversal import get_flat_bom
        
        # Create real parts
        assembly = Part.objects.create(name='TLA', assembly=True, active=True)
        
        # Call function directly (NOT via HTTP)
        result, imp_count, warnings, max_depth = get_flat_bom(assembly.pk)
        
        # Validate return types
        self.assertIsInstance(result, list)
        self.assertIsInstance(imp_count, int)
```

**Important**: Integration tests call **functions directly**, not HTTP endpoints. Plugin URLs don't resolve in tests.

✅ **Part/Stock Property Access**
```python
def test_part_stock_properties_work(self):
    """Validate Part stock properties return numeric values."""
    part = Part.objects.create(name='Test', active=True, purchaseable=True)
    
    # These should work without errors
    stock = part.total_stock
    available = part.available_stock
    allocated = part.allocation_count()
    
    self.assertIsInstance(float(stock), float)
```

✅ **Serializer Validation with Real Data**
```python
def test_serializers_validate_real_part_data(self):
    """Serializers should handle data from real Part objects."""
    part = Part.objects.create(name='Test', IPN='TST-001', active=True)
    
    data = {
        'part_id': part.pk,
        'ipn': part.IPN,
        'part_name': part.name,
        # ... other fields
    }
    
    serializer = FlatBOMItemSerializer(data=data)
    self.assertTrue(serializer.is_valid())
```

✅ **BOM Quantity Calculations**
```python
def test_bom_quantity_aggregation(self):
    """Verify quantity calculations through real BOM structure."""
    # NOTE: Keep BOM structures simple to avoid InvenTree validation issues
    assembly = Part.objects.create(name='ASM', assembly=True, active=True)
    component = Part.objects.create(name='CMP', assembly=False, active=True)
    
    BomItem.objects.create(part=assembly, sub_part=component, quantity=5)
    
    result, _, _, _ = get_flat_bom(assembly.pk)
    # Validate quantities are correct
```

**Key Principle**: Integration tests should be **simple validation that functions work with real models**, not complex end-to-end scenarios. Complex scenarios belong in unit tests with controlled inputs.

---

### Testing DRF APIView Subclasses (View Layer)

**Problem**: APIView.get() expects DRF Request object (has `.query_params`), but APIRequestFactory creates plain WSGIRequest.

**Solution**: Use `as_view()` pattern to trigger full DRF lifecycle (dispatch → initialize_request → get).

✅ **Complete Pattern**:
```python
# tests/integration/test_views_integration.py
from rest_framework.test import APIRequestFactory, force_authenticate
from django.contrib.auth import get_user_model
from InvenTree.unit_test import InvenTreeTestCase

class ViewIntegrationTests(InvenTreeTestCase):
    """Test DRF APIView with real InvenTree models."""
    
    @classmethod
    def setUpTestData(cls):
        """Create test data once."""
        super().setUpTestData()
        
        # Create test user for authentication
        User = get_user_model()
        cls.user, _ = User.objects.get_or_create(
            username='plugin_testuser',
            defaults={'email': 'test@example.com', 'password': 'test123'}
        )
        
        # Create test parts
        cls.assembly = Part.objects.create(
            name='Test Assembly',
            IPN='TST-001',
            assembly=True,
            active=True
        )
    
    def setUp(self):
        """Set up test environment."""
        super().setUp()
        self.factory = APIRequestFactory()
        self.view = MyPluginView.as_view()  # Returns callable
    
    def test_view_returns_200_with_valid_data(self):
        """View should return 200 OK with valid part ID."""
        # Create DRF-compatible request
        request = self.factory.get('/fake-url/')  # URL doesn't matter
        
        # Bypass authentication (tests don't need real auth)
        force_authenticate(request, user=self.user)
        
        # Call view as callable (triggers dispatch)
        response = self.view(request, part_id=self.assembly.pk)
        
        # Validate response
        self.assertEqual(response.status_code, 200)
        self.assertIn('part_id', response.data)
```

**Why This Works**:
1. `MyPluginView.as_view()` returns a **callable** (not instance)
2. Calling `self.view(request, **kwargs)` triggers `dispatch()` method
3. `dispatch()` calls `initialize_request()` which wraps WSGIRequest → DRF Request
4. Wrapped request has `.query_params`, `.user`, and other DRF attributes
5. `force_authenticate()` bypasses permission checks (test doesn't need real auth)

**Common Mistakes**:
```python
# ❌ DON'T: Call view.get() directly (bypasses dispatch)
view = MyPluginView()
response = view.get(request, part_id=123)  # AttributeError: no query_params

# ❌ DON'T: Use RequestFactory (not DRF-aware)
factory = RequestFactory()  # Django factory, not DRF

# ✅ DO: Use as_view() and call as callable
view = MyPluginView.as_view()
response = view(request, part_id=123)  # Works!
```

**Reference**: See `plugins/FlatBOMGenerator/flat_bom_generator/tests/test_view_function.py` for complete working example (14 view tests).

---

**Benefits:**
- Test real behavior
- Catch integration bugs
- Validate functions accept real InvenTree objects
- Confidence before deployment

**Limitations:**
- Cannot test plugin HTTP endpoints (use manual testing)
- Slower than unit tests
- Require InvenTree dev environment

---

## Test Organization

### Directory Structure

```
flat_bom_generator/tests/
├── __init__.py
├── unit/                          # Fast unit tests
│   ├── __init__.py
│   ├── test_categorization.py    # Pure functions
│   ├── test_serializers.py       # Field validation
│   ├── test_shortfall_calculation.py
│   └── test_parsing.py
└── integration/                   # InvenTree integration tests
    ├── __init__.py
    ├── test_views_integration.py  # API endpoints
    ├── test_bom_traversal_integration.py  # BOM with real models
    └── test_stock_integration.py
```

**Key Points:**
- `unit/` and `integration/` are separate folders
- Each has its own `__init__.py`
- Unit tests run independently (no InvenTree)
- Integration tests require InvenTree dev environment

---

## Development Workflow

### 1. TDD with Unit Tests (Fast Iteration)

```bash
# Start with failing test
# tests/unit/test_categorization.py

# Run unit tests (instant feedback)
python -m unittest flat_bom_generator.tests.unit.test_categorization -v

# Implement feature
# categorization.py

# Re-run tests until passing
python -m unittest flat_bom_generator.tests.unit.test_categorization -v

# Commit when tests pass
git commit -m "feat: Add IMP categorization logic"
```

**Benefit**: Tight feedback loop, fast iterations

---

### 2. Integration Testing Before Deployment

```powershell
# All unit tests pass, ready for integration check
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Integration

# If pass → deploy to staging
.\scripts\Deploy-Plugin.ps1 -Plugin "FlatBOMGenerator" -Server staging

# Manual UI smoke test (5 min)
# See TEST-PLAN.md manual checklist

# If staging pass → deploy to production
```

**Benefit**: Catch integration bugs before production

---

### 3. Full Test Suite Before Release

```powershell
# Run all tests (unit + integration)
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -All

# If all pass → tag release
git tag -a v0.10.0 -m "Release 0.10.0"
git push --tags

# Deploy to production
.\scripts\Deploy-Plugin.ps1 -Plugin "FlatBOMGenerator" -Server production
```

**Benefit**: Maximum confidence for production releases

---

## Writing Good Tests

### Unit Test Example (Good)

```python
"""Unit tests for categorization logic.

Pure function tests - no database required.
"""

class CategorizationTests(unittest.TestCase):
    """Test categorize_part() function."""
    
    def test_top_level_assembly_is_tla(self):
        """Top-level assemblies should be categorized as TLA."""
        result = categorize_part(
            part_name="Main Assembly",
            is_assembly=True,
            is_top_level=True,
            has_default_supplier=False
        )
        self.assertEqual(result, "TLA")
    
    def test_non_assembly_with_supplier_is_coml(self):
        """Non-assemblies with suppliers are commercial parts."""
        result = categorize_part(
            part_name="Resistor",
            is_assembly=False,
            is_top_level=False,
            has_default_supplier=True
        )
        self.assertEqual(result, "Coml Part")
    
    def test_edge_case_none_part_name(self):
        """Function should handle None part name."""
        result = categorize_part(
            part_name=None,
            is_assembly=False,
            is_top_level=False,
            has_default_supplier=False
        )
        self.assertEqual(result, "Other")
```

**Good practices:**
- Clear test names (what's being tested)
- Explicit inputs (no magic values)
- One assertion per test
- Tests edge cases (None, empty, invalid)

---

### Integration Test Example (Good)

```python
"""Integration tests for BOM traversal with real InvenTree models.

These tests call functions directly (NOT via HTTP) with real database models.
Plugin URL testing is not supported by InvenTree.

Requires InvenTree development environment setup.
"""

from InvenTree.unit_test import InvenTreeTestCase
from part.models import Part, PartCategory
from flat_bom_generator.bom_traversal import get_flat_bom
from flat_bom_generator.serializers import FlatBOMItemSerializer


class BOMTraversalIntegrationTests(InvenTreeTestCase):
    """Integration tests calling functions directly with real models."""
    
    def test_get_flat_bom_accepts_real_part_id(self):
        """get_flat_bom should work with real Part ID and return tuple."""
        # Create real part (simple, no complex BOM needed)
        cat = PartCategory.objects.create(name='Test Category')
        part = Part.objects.create(
            name='Test Part',
            IPN='TST-001',
            category=cat,
            active=True,
            assembly=True
        )
        
        # Call function directly (returns tuple)
        result, imp_count, warnings, max_depth = get_flat_bom(part.pk)
        
        # Validate return types
        self.assertIsInstance(result, list)
        self.assertIsInstance(imp_count, int)
        self.assertIsInstance(warnings, list)
        self.assertIsInstance(max_depth, int)
    
    def test_part_stock_properties_work(self):
        """Part stock properties should return numeric values."""
        cat = PartCategory.objects.create(name='Test')
        part = Part.objects.create(
            name='Test Part',
            IPN='TST-002',
            category=cat,
            active=True,
            purchaseable=True
        )
        
        # These should all work without errors
        stock = part.total_stock
        available = part.available_stock
        allocated = part.allocation_count()
        
        self.assertIsInstance(float(stock), float)
        self.assertIsInstance(float(available), float)
        self.assertIsInstance(float(allocated), float)
    
    def test_serializer_validates_real_part_data(self):
        """Serializers should validate data from real Part objects."""
        cat = PartCategory.objects.create(name='Test')
        part = Part.objects.create(
            name='Test Part',
            IPN='TST-003',
            category=cat,
            active=True,
            purchaseable=True
        )
        
        # Build item data like views.py does
        item_data = {
            'part_id': part.pk,
            'ipn': part.IPN,
            'part_name': part.name,
            'full_name': part.name,
            'description': part.description or '',
            'total_qty': 5.0,
            'unit': part.units or '',
            'part_type': 'Other',
            'is_assembly': part.assembly,
            'purchaseable': part.purchaseable,
            'in_stock': 0.0,
            'allocated': 0.0,
            'available': 0.0,
            'on_order': 0.0,
            'link': f'/part/{part.pk}/',
        }
        
        serializer = FlatBOMItemSerializer(data=item_data)
        self.assertTrue(serializer.is_valid(), f"Errors: {serializer.errors}")
```

**Good practices:**
- Call functions directly, not via HTTP (plugin URLs don't work in tests)
- Keep test data simple (avoid complex BOM structures)
- Test return types and basic behavior, not complex logic (that's for unit tests)
- Validate functions accept real InvenTree objects without errors
- Focus on "does it work with real models?" not "is the logic perfect?"

---

## Running Tests

### Quick Reference

```powershell
# Unit tests only (fast, 0.2s)
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Unit

# Integration tests only (slower, 2-5s)
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -Integration

# All tests (unit + integration)
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -All

# Specific test file
.\scripts\Test-Plugin.ps1 -Plugin "FlatBOMGenerator" -TestPath "flat_bom_generator.tests.unit.test_categorization"
```

### Manual Execution

```powershell
# Unit tests (from plugin directory)
cd plugins\FlatBOMGenerator
python -m unittest discover -s flat_bom_generator/tests/unit -v

# Integration tests (from InvenTree dev directory)
cd inventree-dev\InvenTree
& .venv\Scripts\Activate.ps1
invoke dev.test -r FlatBOMGenerator.tests.integration -v
```

---

## Best Practices Summary

### DO:

✅ Write unit tests for pure functions and business logic  
✅ Write integration tests for functions with real InvenTree models  
✅ Call functions directly in integration tests (not via HTTP)  
✅ Keep integration test data simple (avoid complex BOM structures)  
✅ Run unit tests during development (fast feedback)  
✅ Run integration tests before deployment (catch bugs)  
✅ Organize tests into `unit/` and `integration/` folders  
✅ Use descriptive test names  
✅ Test edge cases and error conditions in unit tests  
✅ Test "works with real models" in integration tests  
✅ Keep tests isolated (no dependencies between tests)

### DON'T:

❌ Try to test plugin URLs via HTTP (Django test client returns 404)  
❌ Use integration tests for pure functions (overkill, slow)  
❌ Use unit tests for database-dependent code (won't work)  
❌ Skip integration tests thinking unit tests are enough  
❌ Create complex BOM structures in integration tests (InvenTree validation issues)  
❌ Write tests that depend on each other  
❌ Use magic numbers without explanation  
❌ Duplicate production code in tests  
❌ Test implementation details instead of behavior

---

## CI/CD Considerations

**Current State**: Manual testing (works well for part-time development)

**When to Add CI**:
- Deploying weekly or more frequently
- Multiple developers contributing
- Test suite is comprehensive (150+ tests)
- Manual execution becomes friction point

**Recommended Approach**:
1. **Phase 1**: Pre-commit hook (5 min setup) - Run unit tests before commit
2. **Phase 2**: GitHub Actions (30 min setup) - Run all tests on PR
3. **Phase 3**: Automated deployment - Deploy to staging on merge to main

See [docs/toolkit/INVENTREE-DEV-SETUP.md](INVENTREE-DEV-SETUP.md) → CI/CD section

---

## Troubleshooting

### "Plugin URL returns 404 in tests"

**Problem**: Trying to test plugin API endpoints via `self.client.get('/api/plugin/...')`

**Why**: InvenTree's Django test client cannot resolve dynamic plugin URLs. This is a framework limitation.

**Solution**: Call functions directly instead of testing via HTTP
```python
# ❌ DON'T: Test via HTTP (returns 404)
response = self.client.get('/api/plugin/flat-bom-generator/flat-bom/123/')

# ✅ DO: Call function directly
from flat_bom_generator.bom_traversal import get_flat_bom
result, imp_count, warnings, max_depth = get_flat_bom(123)
```

**Alternative**: Test API endpoints manually via staging server (not automated tests)

---

### "ModuleNotFoundError: No module named 'InvenTree'"

**Problem**: Trying to run integration tests without InvenTree dev environment

**Solution**:
```powershell
# Set up InvenTree dev environment (one-time)
.\scripts\Setup-InvenTreeDev.ps1

# Link your plugin
.\scripts\Link-PluginToDev.ps1 -Plugin "FlatBOMGenerator"

# Run from InvenTree directory
cd inventree-dev\InvenTree
& .venv\Scripts\Activate.ps1
invoke dev.test -r FlatBOMGenerator.tests.integration
```

---

### "Tests pass locally but fail on staging"

**Problem**: Unit tests mock behavior that doesn't match real InvenTree

**Solution**: Add integration tests to catch mismatch
```python
# tests/integration/test_views_integration.py
def test_api_matches_serializer_contract(self):
    """Integration test to ensure API matches expected structure."""
    # This would have caught serializer bugs immediately
```

---

### "Integration tests are too slow"

**Problem**: Creating too much test data or running too many queries

**Solution**:
- Use `setUpTestData()` instead of `setUp()` (data created once)
- Minimize test data (3 parts, not 100)
- Use `select_related()` and `prefetch_related()`
- Run integration tests only before deployment, not during development

---

## Summary

**Testing Philosophy**: Fast unit tests for TDD, integration tests for validation

**Test Organization**:
- `tests/unit/` - Pure Python, no database, instant feedback
- `tests/integration/` - Real InvenTree models, validate actual behavior

**Development Workflow**:
1. Write failing unit test
2. Implement feature
3. Unit tests pass
4. Run integration tests before deployment
5. Deploy to staging if all tests pass

**Key Benefit**: Right tool for the job - speed when you need it, confidence when it matters.

---

## References

- **InvenTree Testing Docs**: https://docs.inventree.org/en/stable/plugins/test/
- **Setup Guide**: [INVENTREE-DEV-SETUP.md](INVENTREE-DEV-SETUP.md)
- **Test Plan**: [plugins/FlatBOMGenerator/flat_bom_generator/tests/TEST-PLAN.md](../../plugins/FlatBOMGenerator/flat_bom_generator/tests/TEST-PLAN.md)
- **Test Quality Review**: [plugins/FlatBOMGenerator/docs/internal/TEST-QUALITY-REVIEW.md](../../plugins/FlatBOMGenerator/docs/internal/TEST-QUALITY-REVIEW.md)

---

**Last Updated**: December 16, 2025  
**Toolkit Version**: 1.1
