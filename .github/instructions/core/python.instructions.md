---
applyTo: "**/*.py"
---

# Python Coding Conventions

General Python patterns applied to all `.py` files in the workspace.

---

## Style

- Follow **PEP 8**. 4-space indentation. Max 79 characters per line.
- Use `typing` module for annotations: `List[str]`, `Dict[str, int]`,
  `Optional[float]`, etc.
- Docstrings follow **PEP 257**: immediately after `def` or `class`,
  triple double-quotes, imperative mood.
- Name things clearly enough that a comment is rarely necessary.
- Comments explain **why**, not **what**.

---

## Fail-Fast Philosophy (CRITICAL)

Fail loudly with clear errors rather than silently with wrong data.

### Decision Tree: Should I use `.get()` with a default?

1. **Is this field optional by design?** (UI preference, feature toggle)
   - Yes -> use a sensible default.
   - No -> continue to #2.

2. **Does a missing/wrong value cause incorrect behaviour?** (calculation,
   data integrity)
   - Yes -> **fail loudly** with `ValueError` / `KeyError`.
   - No -> use default with a warning log.

3. **Can the user easily fix the error?** (missing config, invalid input)
   - Yes -> fail with a clear error message.
   - No -> use default with error log, alert admin.

### Examples

```python
# BAD: silent bug -- wrong quantity calculated
quantity = data.get('quantity', 0)  # 0 is wrong if field required!

# GOOD: fail fast with clear error
if 'quantity' not in data:
    raise ValueError("Quantity field required for BOM calculation")
quantity = data['quantity']

# GOOD: optional UI setting -- default is fine
page_size = request.GET.get('page_size', 50)

# BAD: swallows all errors
try:
    result = complex_operation()
except:
    result = None  # What went wrong? How to debug?

# GOOD: specific error handling
try:
    result = complex_operation()
except ValidationError as e:
    logger.error(f"Validation failed: {e}")
    raise
```

---

## General Rules

- For algorithm-heavy code, include a brief explanation of the approach.
- When using external libraries, note their purpose in a comment.
