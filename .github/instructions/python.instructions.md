---
description: 'Python coding conventions and general guidelines for InvenTree plugins'
applyTo: '**/*.py'
---

# Python Coding Conventions

**Note**: For specialized patterns, see:
- [backend.core.instructions.md](backend.core.instructions.md) - Plugin class, mixins, settings
- [backend.api.instructions.md](backend.api.instructions.md) - Django, DRF, serializers, views
- [backend.testing.instructions.md](backend.testing.instructions.md) - Testing patterns

## Python Instructions

- Write clear and concise comments for each function.
- Ensure functions have descriptive names and include type hints.
- Provide docstrings following PEP 257 conventions.
- Use the `typing` module for type annotations (e.g., `List[str]`, `Dict[str, int]`).
- Break down complex functions into smaller, more manageable functions.

## Fail-Fast Philosophy (CRITICAL)

**Principle**: Fail loudly with clear errors rather than silently with wrong data.

### Decision Tree: Should I use `.get()` with a default?

1. **Is this field optional by design?** (UI preference, feature toggle)
   - ✅ Yes → Use sensible default
   - ❌ No → Continue to #2

2. **Does missing/wrong value cause incorrect behavior?** (calculation, data integrity)
   - ✅ Yes → Fail loudly with ValueError/KeyError
   - ❌ No → Use default with warning log

3. **Can user easily fix the error?** (missing config, invalid input)
   - ✅ Yes → Fail with clear error message
   - ❌ No → Use default with error log, alert admin

### Examples

```python
# ❌ BAD: Silent bug - wrong quantity calculated
quantity = data.get('quantity', 0)  # 0 is wrong if field required!

# ✅ GOOD: Fail fast with clear error
if 'quantity' not in data:
    raise ValueError("Quantity field required for BOM calculation")
quantity = data['quantity']

# ✅ ALSO GOOD: Optional UI setting
page_size = request.GET.get('page_size', 50)  # Reasonable default

# ❌ BAD: Swallows all errors
try:
    result = complex_operation()
except:
    result = None  # What went wrong? How do we debug?

# ✅ GOOD: Specific error handling
try:
    result = complex_operation()
except ValidationError as e:
    logger.error(f"Validation failed: {e}")
    raise  # Re-raise for caller to handle
```

**Lesson Learned**: FlatBOMGenerator had 2 incorrect fallbacks that hid bugs for months. Found during code-first test review (Dec 2025).

## General Instructions

- Always prioritize readability and clarity.
- For algorithm-related code, include explanations of the approach used.
- Write code with good maintainability practices, including comments on **why** certain design decisions were made.
- Handle edge cases with specific exceptions, not generic `except:` blocks.
- For libraries or external dependencies, mention their usage and purpose in comments.
- Use consistent naming conventions and follow language-specific best practices.
- Write concise, efficient, and idiomatic code that is also easily understandable.

## Code Style and Formatting

- Follow the **PEP 8** style guide for Python.
- Maintain proper indentation (use 4 spaces for each level of indentation).
- Ensure lines do not exceed 79 characters.
- Place function and class docstrings immediately after the `def` or `class` keyword.
- Use blank lines to separate functions, classes, and code blocks where appropriate.

## Edge Cases and Testing

- Always include test cases for critical paths of the application.
- Account for common edge cases like empty inputs, invalid data types, and large datasets.
- Include comments for edge cases and the expected behavior in those cases.
- Write unit tests for functions and document them with docstrings explaining the test cases.

## Example of Proper Documentation

```python
def calculate_area(radius: float) -> float:
    """
    Calculate the area of a circle given the radius.
    
    Parameters:
    radius (float): The radius of the circle.
    
    Returns:
    float: The area of the circle, calculated as π * radius^2.
    """
    import math
    return math.pi * radius ** 2
```
