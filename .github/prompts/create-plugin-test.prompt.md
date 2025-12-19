---
description: 'Generate comprehensive unit tests for InvenTree plugin code'
mode: 'edit'
tools: ['edit', 'read', 'search']
---

# Generate Plugin Unit Tests

Generate high-quality unit tests for InvenTree plugin code following test-first methodology and quality standards.

## Mission

Create comprehensive, maintainable unit tests that validate plugin behavior, follow best practices, and achieve high test quality (Grade A).

## Scope & Preconditions

- Code to test exists and behavior is understood
- Following test-first workflow (write test before or after implementation)
- Tests use Python `unittest` framework
- Tests are placed in `{plugin_package}/tests/` folder
- Test files named `test_*.py`

## Input Requirements

**Required Information:**
- What code needs testing? (function, class, module)
- What behavior should be tested? (normal cases, edge cases, errors)
- What's the expected input/output?
- Are there dependencies? (Django models, external APIs)

**Context to Gather:**
```python
# Read the code to test
${file} # File containing code to test
${selection} # Specific function/class selected
```

## Workflow

### 1. Analyze Code to Test

**Understand before writing tests:**
- What does the code do? (read docstrings, trace logic)
- What are inputs and outputs?
- What are edge cases? (None, empty, zero, negative)
- What can fail? (validation, exceptions, missing data)
- Are there dependencies? (mocked or real)

**Read relevant documentation:**
- Plugin's `TEST-PLAN.md` for testing strategy
- `TEST-QUALITY-REVIEW.md` for quality standards
- `ARCHITECTURE.md` for code patterns

### 2. Design Test Cases

**Test Coverage Checklist:**
- [ ] **Happy path**: Normal inputs, expected behavior
- [ ] **Edge cases**: Boundary values, empty inputs
- [ ] **Error cases**: Invalid inputs, exceptions
- [ ] **Data validation**: Type checking, required fields
- [ ] **Calculations**: Verify math with known values

**Example Test Design:**
```
Function: calculate_shortfall(required, in_stock, on_order, include_on_order)

Tests needed:
1. test_no_shortfall_when_stock_sufficient
2. test_shortfall_when_stock_insufficient  
3. test_include_on_order_reduces_shortfall
4. test_exclude_on_order_ignores_incoming
5. test_zero_stock_returns_full_requirement
6. test_negative_values_raise_error (if applicable)
```

### 3. Write Test File Structure

**File Template:**
```python
"""
Unit tests for {module_name}.

Tests cover:
- Normal operation with valid inputs
- Edge cases (None, empty, zero values)
- Error conditions and exceptions
- [Specific behavior tested]
"""

import unittest
from {plugin_package}.{module} import {function_or_class}


class {FeatureName}Tests(unittest.TestCase):
    """Tests for {feature_name} functionality."""
    
    @classmethod
    def setUpTestData(cls):
        """Create test data once for all tests (if needed)."""
        # Set up data used by all tests
        pass
    
    def test_should_{expected}_when_{condition}_given_{input}(self):
        """Test that {feature} {expected behavior} when {condition}."""
        # Arrange
        input_data = ...
        expected_result = ...
        
        # Act
        result = function(input_data)
        
        # Assert
        self.assertEqual(result, expected_result)
```

### 4. Write Test Cases

**Follow AAA Pattern (Arrange-Act-Assert):**

```python
def test_shortfall_is_zero_when_stock_exceeds_requirement(self):
    """Test that shortfall is 0 when we have enough stock."""
    # Arrange - Set up test data
    required = 10
    in_stock = 50
    on_order = 0
    include_on_order = False
    
    # Act - Call function being tested
    result = calculate_shortfall(required, in_stock, on_order, include_on_order)
    
    # Assert - Verify expected behavior
    self.assertEqual(result, 0, "Shortfall should be 0 when stock exceeds requirement")
```

**Test Quality Standards:**
- ✅ **Descriptive names**: `test_should_return_5_when_stock_is_10_and_required_is_15`
- ✅ **Clear arrange/act/assert**: Separate setup, execution, verification
- ✅ **Specific assertions**: `assertEqual(x, 42)` not `assertTrue(x > 0)`
- ✅ **Explain expected values**: Why is 42 the right answer?
- ✅ **One concept per test**: Test one thing at a time
- ✅ **Fast**: No database, no network, no files

### 5. Handle Dependencies

**For Django/InvenTree models:**
```python
# Use InvenTreeTestCase for database access
from InvenTree.unit_test import InvenTreeTestCase
from part.models import Part

class MyTests(InvenTreeTestCase):
    """Tests requiring database access."""
    
    @classmethod
    def setUpTestData(cls):
        """Create test data once."""
        cls.test_part = Part.objects.create(
            name='Test Part',
            description='Test description',
            active=True
        )
```

**For external dependencies:**
```python
# Use unittest.mock for external calls
from unittest.mock import Mock, patch

def test_api_call_handles_timeout(self):
    """Test that API timeout is handled gracefully."""
    with patch('requests.get') as mock_get:
        mock_get.side_effect = TimeoutError()
        
        # Should handle timeout without crashing
        result = fetch_data()
        
        self.assertIsNone(result)
```

### 6. Test Edge Cases

**Always test:**
- Empty inputs: `""`, `[]`, `{}`
- None values: `None`
- Zero: `0`, `0.0`
- Negative values: `-1`, `-100`
- Very large values: `999999`
- Wrong types: `"5"` when expecting `int`

**Example:**
```python
def test_handles_none_gracefully(self):
    """Test that None input raises ValueError."""
    with self.assertRaises(ValueError):
        calculate_shortfall(None, 10, 0, False)

def test_handles_empty_string(self):
    """Test that empty string raises TypeError."""
    with self.assertRaises(TypeError):
        calculate_shortfall("", 10, 0, False)
```

### 7. Verify Test Quality

**Quality Checklist:**
- [ ] Test names clearly describe what's being tested
- [ ] No magic numbers (explain all values)
- [ ] Tests are independent (can run in any order)
- [ ] Tests are fast (< 100ms each)
- [ ] No external dependencies (files, network, database unless integration test)
- [ ] Tests validate actual behavior, not implementation
- [ ] All edge cases covered
- [ ] Error conditions tested

### 8. Run Tests

```powershell
# Run the new tests
.\scripts\Test-Plugin.ps1 -Plugin "PluginName" -Unit -TestPath "plugin_package.tests.test_new_feature"
```

**Expected:**
- All tests pass (green)
- No skipped tests (unless intentional with good reason)
- Fast execution (< 5 seconds for unit tests)

## Test Anti-Patterns to Avoid

❌ **Testing implementation instead of behavior:**
```python
# BAD - tests internal structure
def test_uses_list_comprehension(self):
    # Don't test HOW code works, test WHAT it does
```

❌ **Duplicating production code in tests:**
```python
# BAD - duplicates logic
def test_calculation(self):
    result = calculate(10, 5)
    expected = 10 - 5  # DON'T recalculate in test!
    self.assertEqual(result, expected)
```

❌ **Vague assertions:**
```python
# BAD - not specific enough
self.assertTrue(result > 0)

# GOOD - specific expectation
self.assertEqual(result, 42)
```

❌ **Magic numbers without explanation:**
```python
# BAD - why 42?
self.assertEqual(result, 42)

# GOOD - explain the value
# Expected: 2 assemblies × 5 parts each × 4.2 units = 42
self.assertEqual(result, 42)
```

## Output Expectations

**Test File Created:**
```python
# Location: {plugin_package}/tests/test_{feature}.py
# Contains: Test class with 5-15 test methods
# Coverage: Happy path, edge cases, error cases
# Quality: Grade A (follows all standards)
```

**Test Results:**
```
Ran 12 tests in 1.234s
OK
```

## Example: Complete Test File

```python
"""
Unit tests for shortfall calculation logic.

Tests cover:
- Basic shortfall calculation with various stock levels
- Include/exclude on-order behavior
- Include/exclude allocated stock behavior
- Edge cases (zero stock, zero requirements, etc.)
"""

import unittest
from flat_bom_generator.calculations import calculate_shortfall


class ShortfallCalculationTests(unittest.TestCase):
    """Tests for calculate_shortfall function."""
    
    def test_no_shortfall_when_stock_exceeds_requirement(self):
        """Test that shortfall is 0 when we have more stock than needed."""
        # Arrange - We need 10, have 50
        required = 10
        in_stock = 50
        
        # Act
        result = calculate_shortfall(required, in_stock, 0, False)
        
        # Assert - Shortfall should be 0
        self.assertEqual(result, 0)
    
    def test_shortfall_when_stock_insufficient(self):
        """Test that shortfall is calculated when stock is below requirement."""
        # Arrange - We need 100, have 30
        required = 100
        in_stock = 30
        
        # Act
        result = calculate_shortfall(required, in_stock, 0, False)
        
        # Assert - Shortfall should be 70 (100 - 30)
        self.assertEqual(result, 70)
    
    def test_on_order_reduces_shortfall_when_included(self):
        """Test that on-order quantity reduces shortfall when include_on_order=True."""
        # Arrange - Need 100, have 30, 50 on order
        required = 100
        in_stock = 30
        on_order = 50
        
        # Act
        result = calculate_shortfall(required, in_stock, on_order, include_on_order=True)
        
        # Assert - Shortfall should be 20 (100 - 30 - 50)
        self.assertEqual(result, 20)
    
    def test_on_order_ignored_when_excluded(self):
        """Test that on-order quantity is ignored when include_on_order=False."""
        # Arrange - Same as above but exclude on-order
        required = 100
        in_stock = 30
        on_order = 50
        
        # Act
        result = calculate_shortfall(required, in_stock, on_order, include_on_order=False)
        
        # Assert - Shortfall should be 70 (ignoring on-order)
        self.assertEqual(result, 70)
    
    def test_zero_stock_returns_full_requirement(self):
        """Test that zero stock results in shortfall equal to requirement."""
        # Arrange - Need 100, have nothing
        required = 100
        in_stock = 0
        
        # Act
        result = calculate_shortfall(required, in_stock, 0, False)
        
        # Assert - Shortfall should equal requirement
        self.assertEqual(result, 100)
    
    def test_zero_requirement_returns_zero_shortfall(self):
        """Test that zero requirement results in zero shortfall regardless of stock."""
        # Arrange - Need nothing
        required = 0
        in_stock = 50
        
        # Act
        result = calculate_shortfall(required, in_stock, 0, False)
        
        # Assert - Shortfall should be 0
        self.assertEqual(result, 0)


if __name__ == '__main__':
    unittest.main()
```

## Quality Standards Summary

**Grade A Test (Target):**
- ⭐⭐⭐ Clear, descriptive test names
- ⭐⭐⭐ Tests actual behavior, not implementation
- ⭐⭐⭐ Specific assertions with explanations
- ⭐⭐⭐ No magic numbers
- ⭐⭐⭐ Complete edge case coverage
- ⭐⭐⭐ Fast execution (< 100ms per test)
- ⭐⭐⭐ Independent tests (no order dependency)

**Grade B Test (Acceptable):**
- ⭐⭐ Good coverage but some magic numbers
- ⭐⭐ Some assertions could be more specific
- ⭐⭐ Missing a few edge cases

**Grade C Test (Needs Improvement):**
- ⭐ Vague test names
- ⭐ Tests implementation details
- ⭐ Many magic numbers
- ⭐ Missing edge cases

## Reference

- **Testing Strategy**: See `docs/toolkit/TESTING-STRATEGY.md`
- **Test Quality Standards**: See plugin's `docs/internal/TEST-QUALITY-REVIEW.md`
- **Python Testing**: See `.github/instructions/backend.testing.instructions.md`
- **InvenTree Testing**: See `docs/inventree/TESTING-FRAMEWORK.md`
