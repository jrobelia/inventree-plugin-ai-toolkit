---
applyTo: "**/*.yaml,**/*.yml"
---

# InvenTree YAML Fixtures

Patterns for Django test fixtures used with InvenTree models.
For general testing patterns, see `testing.instructions.md`.

---

## Quick Validation

```powershell
python -c "import yaml; yaml.safe_load(open('path/to/fixture.yaml')); print('[OK] YAML valid')"
```

---

## MPTT Fields (CRITICAL)

InvenTree uses Modified Preorder Tree Traversal for Part and PartCategory.
Missing these fields causes: `NOT NULL constraint failed: part_part.level`.

**Part:**
```yaml
- model: part.part
  pk: 9001
  fields:
    name: 'Part Name'
    category: 9001
    assembly: true
    active: true
    purchaseable: true
    tree_id: 9001       # Required MPTT
    level: 0            # Required MPTT (0 = root)
    lft: 1              # Required MPTT
    rght: 2             # Required MPTT
```

**PartCategory:**
```yaml
- model: part.partcategory
  pk: 9001
  fields:
    name: 'Category Name'
    parent: null
    tree_id: 901
    level: 0
    lft: 1
    rght: 2
```

---

## BomItem Fixtures

BomItem entries bypass `Part.check_add_to_bom()` validation when loaded
via `loaddata` -- this is the only way to create complex BOM structures
in tests without triggering circular reference protection.

```yaml
- model: part.bomitem
  pk: 8001
  fields:
    part: 9001          # Parent assembly PK
    sub_part: 9002      # Child component PK
    quantity: 2.0       # Must be float
    validated: true     # Required for BOM validation
    reference: 'U1, U2' # Optional
    note: ''            # Optional
```

---

## Loading Fixtures in Plugin Tests

Plugins are not in `INSTALLED_APPS`, so use programmatic loading:

```python
import os
from django.core.management import call_command

fixture_path = os.path.join(
    os.path.dirname(os.path.dirname(__file__)),  # tests/integration/ -> tests/
    'fixtures',
    'my_fixture.yaml'
)
call_command('loaddata', fixture_path, verbosity=0)
```

---

## PK Conventions

Use ranges to avoid clashing with InvenTree's own test data:

| Range | Model |
|---|---|
| 8000-8999 | BomItem |
| 9000-9199 | Part |
| 9200-9299 | PartCategory |

---

## Indentation Rules

Django fixtures require **exactly 4 spaces** for field values under `fields:`.
Six spaces silently breaks field parsing.

```yaml
# GOOD (4 spaces)
  fields:
    name: 'Part Name'

# BAD (6 spaces -- Django ignores fields)
  fields:
      name: 'Part Name'
```

---

## Debugging Checklist

1. YAML syntax valid? (run validation command above)
2. All Part/PartCategory entries have MPTT fields?
3. All BomItem entries have `validated: true`?
4. `part` and `sub_part` PKs exist in the same fixture?
5. Fixture path correct? (use `print(fixture_path)` to check)