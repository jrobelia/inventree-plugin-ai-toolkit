---
description: 'Review test quality and suggest improvements for InvenTree plugin tests'
mode: 'ask'
tools: ['read', 'search']
---

# Review Plugin Test Quality

Evaluate InvenTree plugin test quality, identify gaps, and provide prioritized improvement recommendations.

## Mission

Analyze plugin test suite to assess quality, coverage, and effectiveness. Provide actionable recommendations to achieve Grade A test quality.

## Scope & Preconditions

- Plugin has existing tests in `{plugin_package}/tests/` folder
- Tests use Python `unittest` framework
- Following test quality standards from TEST-QUALITY-REVIEW.md

## Workflow

### 1. Gather Test Information

**Read test files:**
```python
# Discover all test files
${workspaceFolder}/plugins/{PluginName}/{plugin_package}/tests/test_*.py
```

**Read related documentation:**
- `docs/internal/TEST-PLAN.md` - Test strategy
- `docs/internal/TEST-QUALITY-REVIEW.md` - Previous review (if exists)
- `docs/internal/ROADMAP.md` - Test priorities

### 2. Assess Test Coverage

**Check what's tested:**
- [ ] Core business logic functions
- [ ] API views and endpoints
- [ ] Serializers (all fields validated)
- [ ] Data calculations
- [ ] Edge cases (None, empty, zero)
- [ ] Error conditions

**Identify coverage gaps:**
- What code exists but has no tests?
- What critical paths are untested?
- What edge cases are missing?

**Coverage Gap Severity:**
- 🔴 **Critical**: Core business logic, API endpoints untested
- 🟡 **High**: Edge cases missing, error handling untested
- 🟢 **Medium**: Minor functions, rare edge cases

### 3. Evaluate Test Quality

**For each test file, assess:**

#### Test Naming Quality
- ✅ **Good**: `test_should_return_5_when_stock_is_10_and_required_is_15`
- ⚠️ **Fair**: `test_calculation_works`
- ❌ **Poor**: `test_1`, `test_thing`

#### Assertion Specificity
- ✅ **Good**: `self.assertEqual(result, 42)`
- ⚠️ **Fair**: `self.assertTrue(result > 0)`
- ❌ **Poor**: `self.assertTrue(result)`

#### Test Independence
- ✅ **Good**: Each test creates its own data
- ⚠️ **Fair**: Tests share `setUpTestData()` appropriately
- ❌ **Poor**: Tests depend on execution order

#### Edge Case Coverage
- ✅ **Good**: Tests None, empty, zero, negative, very large
- ⚠️ **Fair**: Tests some edge cases
- ❌ **Poor**: Only tests happy path

#### Magic Numbers
- ✅ **Good**: All values explained with comments
- ⚠️ **Fair**: Some numbers unexplained
- ❌ **Poor**: Many magic numbers

#### Test Speed
- ✅ **Good**: < 100ms per test (unit)
- ⚠️ **Fair**: 100-500ms per test
- ❌ **Poor**: > 500ms (may need refactoring)

### 4. Assign Quality Grades

**Grade each test file:**

**⭐⭐⭐ Grade A (Excellent):**
- Clear, descriptive test names
- Specific assertions with explanations
- Comprehensive edge case coverage
- No magic numbers
- Tests behavior, not implementation
- Fast and independent

**⭐⭐ Grade B (Good):**
- Good coverage, minor issues
- Some magic numbers
- Most edge cases covered
- Generally good quality

**⭐ Grade C (Needs Improvement):**
- Vague test names
- Generic assertions
- Missing edge cases
- Many magic numbers
- Tests implementation details

**Overall Suite Grade:**
```
Total tests: 106
Grade A: 62 (58%)
Grade B: 10 (9%)
Grade C: 34 (32%)
Overall: B+ (good foundation, needs improvement)
```

### 5. Identify Test Anti-Patterns

**Look for:**

❌ **Tests duplicating production code:**
```python
# BAD - recalculates in test
def test_calculation(self):
    result = function(10, 5)
    expected = 10 * 5  # Duplicates logic!
    self.assertEqual(result, expected)
```

❌ **Tests of stub functions:**
```python
# BAD - tests fake code, not real code
def helper_function():
    return []  # Stub

def test_helper():
    result = helper_function()
    self.assertEqual(result, [])  # Tests stub, not real behavior
```

❌ **Vague assertions:**
```python
# BAD - what's the expected count?
self.assertGreater(len(result), 0)

# GOOD - specific expectation
self.assertEqual(len(result), 12)
```

❌ **Tests depending on external files:**
```python
# BAD - brittle, hard to maintain
data = pd.read_csv('test_data/file.csv')

# GOOD - create data in test
data = pd.DataFrame({'col': [1, 2, 3]})
```

### 6. Prioritize Improvements

**Critical Priority (Do First):**
- 🔴 Add tests for untested core functions
- 🔴 Fix or remove skipped tests
- 🔴 Rewrite tests that test stub functions

**High Priority (Do Soon):**
- 🟡 Add missing edge case tests
- 🟡 Improve vague test names
- 🟡 Replace magic numbers with explanations
- 🟡 Add error condition tests

**Medium Priority (Future):**
- 🟢 Refactor slow tests
- 🟢 Improve test organization
- 🟢 Add performance tests

### 7. Generate Improvement Roadmap

**For each priority, provide:**
1. **What**: Specific improvement needed
2. **Why**: Impact on test quality/coverage
3. **How**: Concrete steps to implement
4. **Effort**: Time estimate (minutes/hours)
5. **Priority**: Critical/High/Medium

**Example:**
```markdown
### 🔴 Critical Priority

**Add View Integration Tests** (2-3 hours)
- **What**: Create tests for FlatBOMView.get() endpoint
- **Why**: Core API endpoint has ZERO tests - major risk
- **How**: 
  1. Create test_view_function.py
  2. Test with RequestFactory and as_view() pattern
  3. Cover normal cases, error cases, checkbox scenarios
  4. Verify response structure matches API contract
- **Priority**: CRITICAL - do before next deployment
```

## Output Format

Provide structured review:

```markdown
# Test Quality Review - {PluginName}

**Date**: {Current Date}
**Test Count**: {Total Tests}
**Overall Grade**: {A/B/C/D}

## Summary

Brief overview of test suite status, strengths, and main concerns.

## Test File Analysis

### test_serializers.py (23 tests) - ⭐⭐⭐ Grade A
**Strengths:**
- Comprehensive field validation
- Clear test names
- Good edge case coverage

**Issues:**
- None significant

### test_internal_fab.py (9 tests) - ⭐ Grade C
**Strengths:**
- Good test organization

**Issues:**
- ❌ Tests stub functions, not real code
- ❌ Many magic numbers
- ❌ Relies on external CSV files

**Recommendation:** Complete rewrite needed

## Coverage Gaps

### 🔴 Critical Gaps
- **views.py**: ZERO tests (300 lines untested)
- **Core traversal**: get_flat_bom() untested

### 🟡 High Priority Gaps
- Error handling in calculations
- Edge cases in aggregation logic

## Improvement Roadmap

### Critical Priority (Week 1)
1. [Details from step 7]

### High Priority (Week 2-3)
2. [Details from step 7]

### Medium Priority (Month 1-2)
3. [Details from step 7]

## Test Quality Checklist

Use this when writing/reviewing tests:
- [ ] Test names clearly describe behavior
- [ ] Specific assertions (not just assertTrue)
- [ ] No magic numbers (explain all values)
- [ ] Tests are independent
- [ ] Fast execution (< 100ms unit tests)
- [ ] Edge cases covered
- [ ] Error cases tested
```

## Quality Standards Reference

### Grade A Test Characteristics

```python
def test_should_return_42_when_multiplying_6_by_7(self):
    """Test that multiplication returns correct product."""
    # Arrange - Set up test data
    multiplicand = 6
    multiplier = 7
    expected_product = 42  # 6 × 7 = 42
    
    # Act - Call function
    result = multiply(multiplicand, multiplier)
    
    # Assert - Verify specific result
    self.assertEqual(result, expected_product,
                     "Product should be 42 when multiplying 6 by 7")
```

**What makes this Grade A:**
- ✅ Descriptive name explaining inputs and expected output
- ✅ Clear AAA structure
- ✅ Specific assertion (42, not just > 0)
- ✅ Explanation of why 42 is correct
- ✅ Helpful assertion message
- ✅ No magic numbers without explanation

## Common Test Smells

**When reviewing, watch for:**
- Tests that always pass (testing trivial code)
- Tests that are never run (always skipped)
- Tests that fail intermittently (timing issues, test pollution)
- Tests that take minutes to run (should be seconds)
- Tests that require manual setup (should be self-contained)
- Tests with complex setup (may need refactoring)

## Reference Documents

**Read before reviewing:**
- Plugin's `TEST-PLAN.md` - Current test strategy
- Plugin's `TEST-QUALITY-REVIEW.md` - Previous review (if exists)
- Plugin's `ROADMAP.md` - Test priorities and refactoring plans
- Toolkit's `docs/toolkit/TESTING-STRATEGY.md` - Testing philosophy
- `.github/instructions/backend.testing.instructions.md` - Testing patterns

**Update after reviewing:**
- Plugin's `TEST-QUALITY-REVIEW.md` - Document findings
- Plugin's `ROADMAP.md` - Update test priorities
- Plugin's `TEST-PLAN.md` - Adjust test count and strategy

## Example Review Session

```
User: "Review the test quality for FlatBOMGenerator"

AI: "I'll analyze the test suite. Let me read the test files..."

[Reads all test_*.py files]

AI: "I've reviewed 106 tests across 9 files. Overall Grade: B+

Key Findings:
- 62 tests (58%) are Grade A quality - excellent foundation
- CRITICAL GAP: views.py has ZERO tests (300 lines untested)
- ISSUE: test_internal_fab_cutlist.py tests stub functions, not real code
- ISSUE: 1 test skipped for months (needs investigation)

Top Priorities:
1. 🔴 Add view integration tests (2-3 hours) - CRITICAL before deployment
2. 🔴 Fix skipped test (1 hour) - why is it skipped?
3. 🟡 Rewrite internal fab tests (2-3 hours) - testing wrong code

Shall I provide detailed analysis of each test file?"
```

## Output Expectations

- **Comprehensive review** of all test files
- **Specific, actionable recommendations** with effort estimates
- **Prioritized improvement roadmap** (Critical > High > Medium)
- **Test quality grades** for each file and overall suite
- **Coverage gap analysis** with severity ratings
- **Example fixes** for common issues found

## Remember

- **Quality over quantity**: 50 good tests > 200 weak tests
- **Test behavior, not implementation**: Tests should survive refactoring
- **Explain the "why"**: Help user understand what makes a good test
- **Be specific**: "Add test for X with inputs Y expecting Z"
- **Encourage**: Celebrate what's good, constructively improve what's not
