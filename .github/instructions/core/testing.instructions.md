---
applyTo: "**/test_*.py,**/tests/**/*.py,**/*.test.ts,**/*.test.tsx,**/*.spec.ts"
---

# Testing Patterns

Universal testing conventions. For framework-specific patterns (Django
`as_view()`, InvenTree fixtures), see domain instruction files.

---

## AAA Pattern (Arrange-Act-Assert)

Every test follows this structure:

```python
def test_should_return_shortfall_when_stock_insufficient(self):
    """Shortfall is positive when demand exceeds stock."""
    # Arrange -- set up inputs and expected output
    required = 15
    in_stock = 10
    expected = 5  # 15 - 10

    # Act -- call the function under test
    result = calculate_shortfall(required, in_stock)

    # Assert -- verify the result
    self.assertEqual(result, expected,
        "Shortfall should be 5 when needing 15 with stock of 10")
```

---

## Test Naming

Names describe **what should happen** in plain English:

```python
# GOOD: reads like a specification
test_should_return_zero_when_stock_exceeds_requirement
test_should_raise_error_when_quantity_is_negative
test_should_include_sub_assemblies_in_flat_bom

# BAD: vague, requires reading the test body
test_calculation
test_bom
test_error
```

Convention: `test_should_{expected}_when_{condition}` or
`test_should_{expected}_given_{input}`.

---

## Assertion Quality

```python
# GOOD: specific, with explanation
self.assertEqual(len(rows), 12,
    "Flat BOM should have 12 rows: 3 assemblies x 4 parts each")

# BAD: vague -- tells you nothing when it fails
self.assertTrue(len(rows) > 0)
self.assertGreater(result, 0)
```

- One primary assertion per test where practical.
- Every magic number gets a comment explaining where it comes from.
- Assertion messages describe the business meaning, not the code.

---

## What to Test

For every module, cover:

- **Happy paths** -- normal inputs produce correct outputs.
- **Edge cases** -- zero, empty, None, boundary values, single item, max items.
- **Failure cases** -- bad data, wrong types, missing fields.
  Confirm the right exception is raised with a clear message.
- **Integration points** -- verify modules connect correctly (inputs match
  expected shapes, outputs flow to the next stage).

---

## Test Independence

- Tests must be able to run in any order.
- No shared mutable state between tests.
- Each test creates its own data (no reliance on external files).
- No side effects that leak between tests.

---

## Quality Grades

Use this grading when reviewing existing tests:

**Grade A (target):** clear names, specific assertions, all edge cases,
self-contained data, explained magic numbers, fast execution.

**Grade B (acceptable):** good coverage, mostly specific assertions, some
magic numbers or missing edge cases.

**Grade C (needs rewrite):** vague names, generic assertions, many magic
numbers, tests implementation details, depends on external files.

---

## TDD Workflow

- **New features:** write the failing test FIRST (RED), implement minimum
  code to pass (GREEN), then clean up (REFACTOR).
- **Refactoring existing code:** understand behaviour first (code-first),
  write tests to lock it down, then refactor safely.
- Run the full suite after every change. A passing test that breaks later
  means a hidden dependency.

---

## Anti-Patterns to Avoid

- Duplicating production logic inside the test (recalculating expected values).
- Testing stubs or mocks instead of real behaviour.
- Assertions that pass for any input (`assertTrue(True)`).
- Shared test fixtures that create hidden coupling between tests.
