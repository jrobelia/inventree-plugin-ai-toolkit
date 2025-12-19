---
description: 'Testing patterns for InvenTree plugins - unit tests, integration tests, quality standards'
applyTo: ['**/test_*.py', '**/tests/**/*.py']
---

# Testing Patterns for InvenTree Plugins

**References**: 
- [TEST-PLAN.md](../../plugins/FlatBOMGenerator/flat_bom_generator/tests/TEST-PLAN.md) - Complete testing strategy
- [TEST-QUALITY-REVIEW.md](../../plugins/FlatBOMGenerator/docs/TEST-QUALITY-REVIEW.md) - Quality standards
- [TEST-WRITING-METHODOLOGY.md](../../plugins/FlatBOMGenerator/docs/TEST-WRITING-METHODOLOGY.md) - Code-first approach
- [TESTING-STRATEGY.md](../../docs/toolkit/TESTING-STRATEGY.md) - Unit vs integration philosophy

## Test Structure (AAA Pattern)

```python
import unittest
from InvenTree.unit_test import InvenTreeTestCase

class TestMyFeature(unittest.TestCase):  # Unit test
    """Test my_function with various inputs."""
    
    def test_should_return_sum_when_given_two_numbers(self):
        """Test name describes expected behavior."""
        # Arrange - Setup
        value1 = 10
        value2 = 5
        
        # Act - Execute
        result = my_function(value1, value2)
        
        # Assert - Verify
        self.assertEqual(result, 15)
        self.assertIsInstance(result, int)
```

**Test Naming Convention**: `test_should_{expected}_when_{condition}_given_{input}`

## Unit vs Integration Tests

**Unit Tests** (Fast, no database):
```python
import unittest

class TestCategorization(unittest.TestCase):
    """Test pure functions without database."""
    
    def test_should_identify_fab_part_when_name_starts_with_fab(self):
        """Test categorization logic."""
        from my_plugin.categorization import categorize_part
        
        result = categorize_part(
            part_name='FAB-001',
            is_assembly=False,
            has_supplier=False
        )
        
        self.assertEqual(result, 'Fab Part')
```

**Integration Tests** (Requires InvenTree dev environment):
```python
from InvenTree.unit_test import InvenTreeTestCase
from part.models import Part, PartCategory

class TestWithRealModels(InvenTreeTestCase):
    """Test with actual InvenTree database models."""
    
    @classmethod
    def setUpTestData(cls):
        """Create test data once for all tests in this class."""
        super().setUpTestData()
        
        # Create test category
        cls.category = PartCategory.objects.create(
            name='TestCategory',
            description='For testing'
        )
        
        # Create test part
        cls.part = Part.objects.create(
            name='TestPart',
            description='Test part',
            category=cls.category,
            active=True,
            purchaseable=True
        )
    
    def test_should_process_real_part(self):
        """Test with real Part object."""
        from my_plugin.processor import process_part
        
        result = process_part(self.part.pk)
        
        self.assertIsNotNone(result)
        self.assertIn('name', result)
```

## Testing Plugin Views (CRITICAL)

**⚠️ Plugin URLs DO NOT work in Django test client**

```python
from rest_framework.test import APIRequestFactory, force_authenticate
from django.contrib.auth import get_user_model

class TestAPIView(InvenTreeTestCase):
    """Test API views using DRF patterns."""
    
    @classmethod
    def setUpTestData(cls):
        super().setUpTestData()
        
        # Create test user
        User = get_user_model()
        cls.user = User.objects.create_user(
            username='testuser',
            password='testpass'
        )
        
        # Create test data
        cls.part = Part.objects.create(name='Test', active=True)
    
    def test_should_return_200_when_valid_part_id(self):
        """Test view with valid input."""
        from my_plugin.views import MyAPIView
        
        # Create request factory
        factory = APIRequestFactory()
        
        # Get view as callable
        view = MyAPIView.as_view()
        
        # Create GET request (URL doesn't matter)
        request = factory.get('/fake-url/')
        
        # Authenticate request
        force_authenticate(request, user=self.user)
        
        # Call view as function
        response = view(request, pk=self.part.pk)
        
        # Assert
        self.assertEqual(response.status_code, 200)
        self.assertIn('name', response.data)
        self.assertEqual(response.data['name'], 'Test')
```

**Reference**: See [TESTING-STRATEGY.md](../../docs/toolkit/TESTING-STRATEGY.md) for 6-hour research breakthrough

## Test Quality Standards

**High Quality (⭐⭐⭐)**:
- Tests actual behavior, not implementation details
- Clear assertions (not just `assertGreater(x, 0)`)
- No magic numbers (explain expected values)
- Self-contained (no external file dependencies)
- Tests edge cases and error conditions
- Descriptive test names

**Medium Quality (⭐⭐)**:
- Good coverage but has some issues
- Some magic numbers
- Duplicates production logic
- Tests are passing but could be clearer

**Low Quality (⭐)**:
- Tests stub functions, not real code
- Unclear assertions
- External dependencies (CSV files)
- Magic numbers everywhere
- Tests implementation, not behavior

## Code-First Test Writing (For Refactoring)

**When**: Refactoring legacy code with poor/no tests

**Process**:
1. **Read Implementation** - Understand what code actually does
2. **Find Working Test** - Locate test that passes
3. **Trace Step-by-Step** - Walk through with concrete example
4. **Question Suspicious Code** - Identify dead code, wrong fallbacks
5. **Write Tests Matching Behavior** - Test what code DOES
6. **Learn from Failures** - Behavior changes reveal misunderstandings

```python
# Example: Found incorrect fallback in code
def process_item(item):
    # ❌ This fallback was WRONG - found via code-first testing
    quantity = item.get('quantity', 1)  # Should fail if missing!
    return quantity * 10

# ✅ Fixed after code-first analysis
def process_item(item):
    if 'quantity' not in item:
        raise ValueError("Quantity required")
    return item['quantity'] * 10

# Test validates the fix
def test_should_raise_error_when_quantity_missing(self):
    """Quantity field is required for calculations."""
    with self.assertRaises(ValueError) as context:
        process_item({'name': 'Part'})
    
    self.assertIn('Quantity required', str(context.exception))
```

**Reference**: [TEST-WRITING-METHODOLOGY.md](../../plugins/FlatBOMGenerator/docs/TEST-WRITING-METHODOLOGY.md)

## Test-First Workflow (For New Features)

**When**: Building new features

**Process**:
1. Write failing test (Red)
2. Write minimum code to pass (Green)
3. Refactor for quality (Refactor)
4. Repeat

```python
# 1. RED - Write failing test
def test_should_calculate_total_cost_when_multiple_items(self):
    """Calculate total cost across multiple BOM items."""
    items = [
        {'quantity': 10, 'unit_cost': 5.0},
        {'quantity': 5, 'unit_cost': 10.0},
    ]
    
    result = calculate_total_cost(items)
    
    self.assertEqual(result, 100.0)  # (10*5) + (5*10) = 100

# 2. GREEN - Implement minimum code
def calculate_total_cost(items):
    return sum(item['quantity'] * item['unit_cost'] for item in items)

# 3. REFACTOR - Improve quality
def calculate_total_cost(items):
    """Calculate total cost for BOM items.
    
    Args:
        items: List of dicts with 'quantity' and 'unit_cost'
    
    Returns:
        Decimal: Total cost
    
    Raises:
        ValueError: If required fields missing
    """
    total = Decimal(0)
    for item in items:
        if 'quantity' not in item or 'unit_cost' not in item:
            raise ValueError("Items must have quantity and unit_cost")
        total += Decimal(item['quantity']) * Decimal(item['unit_cost'])
    return total
```

## Edge Cases & Error Conditions

**Always test**:
```python
class TestEdgeCases(unittest.TestCase):
    """Test edge cases and error conditions."""
    
    def test_should_handle_none_input(self):
        """Function should validate input."""
        with self.assertRaises(ValueError):
            my_function(None)
    
    def test_should_handle_empty_string(self):
        """Empty string is invalid input."""
        with self.assertRaises(ValueError):
            my_function('')
    
    def test_should_handle_negative_quantity(self):
        """Negative quantities are invalid."""
        with self.assertRaises(ValueError):
            calculate_cost(quantity=-5, price=10)
    
    def test_should_handle_zero_quantity(self):
        """Zero is valid (different from None)."""
        result = calculate_cost(quantity=0, price=10)
        self.assertEqual(result, 0)
    
    def test_should_handle_very_large_numbers(self):
        """Test numeric overflow."""
        result = calculate_cost(quantity=1000000, price=1000000)
        self.assertEqual(result, 1000000000000)
```

## Fail-Fast Test Philosophy

**Question**: Should test use `.get()` with default?

1. **Is the field optional by design?** (UI preference, optional filter)
   - ✅ Yes → Use default in test
   - ❌ No → Test should expect KeyError/ValueError

2. **Does missing field indicate a bug?** (Required calculation input)
   - ✅ Yes → Test should verify error is raised
   - ❌ No → Continue to #3

3. **Am I testing production code or test setup?**
   - Production code → Follow production fail-fast rules
   - Test setup → Can use defaults for convenience

**Examples**:

```python
# ❌ BAD: Hides bugs in test
def test_calculation(self):
    data = {'name': 'Part'}  # Missing quantity!
    quantity = data.get('quantity', 1)  # Test passes with wrong default
    result = quantity * 10
    self.assertEqual(result, 10)  # Wrong expectation

# ✅ GOOD: Test verifies error
def test_should_raise_error_when_quantity_missing(self):
    data = {'name': 'Part'}
    with self.assertRaises(KeyError):
        quantity = data['quantity']  # Should fail loudly

# ✅ ALSO GOOD: Test optional field behavior
def test_should_use_default_page_size_when_not_specified(self):
    """Page size is optional UI preference."""
    request = {}
    page_size = request.get('page_size', 50)  # Sensible default
    self.assertEqual(page_size, 50)
```

## Mocking External Dependencies

```python
from unittest.mock import patch, MagicMock

class TestWithMocks(unittest.TestCase):
    """Test with mocked dependencies."""
    
    @patch('my_plugin.views.Part.objects')
    def test_should_handle_api_call(self, mock_part_objects):
        """Mock database queries."""
        # Setup mock
        mock_part = MagicMock()
        mock_part.name = 'TestPart'
        mock_part.pk = 123
        mock_part_objects.get.return_value = mock_part
        
        # Test
        result = my_function(123)
        
        # Verify mock was called
        mock_part_objects.get.assert_called_once_with(pk=123)
        self.assertEqual(result['name'], 'TestPart')
```

## Running Tests

```powershell
# Unit tests (fast, no InvenTree required)
cd plugins/MyPlugin
python -m unittest discover -s my_plugin/tests/unit -v

# Integration tests (requires InvenTree dev environment)
# See INTEGRATION-TESTING-SETUP-SUMMARY.md for setup
cd inventree-dev/InvenTree
invoke dev.test -r MyPlugin.tests.integration -v

# Or use toolkit script
cd toolkit-root
.\scripts\Test-Plugin.ps1 -Plugin "MyPlugin" -Unit
.\scripts\Test-Plugin.ps1 -Plugin "MyPlugin" -Integration
```

## Industry Best Practices

**Test Isolation**:
- No test interdependencies
- Clean state per test
- Use `setUpTestData()` for shared fixtures
- Teardown in `tearDown()` if needed

**Test Coverage**:
- Focus on critical paths (business logic, API contracts)
- Don't chase 100% coverage (vanity metric)
- Test edge cases and error conditions
- Test what users care about

**Test Maintenance**:
- Keep tests simple and readable
- Update tests when requirements change
- Delete obsolete tests
- Don't test framework code (Django, DRF)

**Test Performance**:
- Unit tests should be fast (< 1 second each)
- Integration tests can be slower (database access)
- Mock expensive operations (external APIs)
- Parallelize test execution when possible

---

**When test defensive code looks wrong**: Question if production code is correct. Tests reveal design issues.
