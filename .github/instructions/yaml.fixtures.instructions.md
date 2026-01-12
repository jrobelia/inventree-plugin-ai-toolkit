---
description: 'YAML fixture validation and InvenTree-specific requirements for Django fixtures'
applyTo: '**/*.yaml,**/*.yml'
---

# YAML Fixtures for InvenTree Testing

## Quick Validation

Always validate YAML syntax before running tests:

```powershell
python -c "import yaml; yaml.safe_load(open('path/to/fixture.yaml')); print('[OK] YAML valid')"
```

**Common YAML errors:**
- Inconsistent indentation (use 4 spaces for Part/BomItem fields, 2 spaces for model declarations)
- Missing colons after field names
- Unquoted strings with special characters
- Tabs instead of spaces (YAML doesn't allow tabs)

---

## InvenTree Fixture Requirements

### MPPT Fields (Modified Preorder Tree Traversal)

**PartCategory models MUST include:**
```yaml
- model: part.partcategory
  pk: 9001
  fields:
    name: 'Category Name'
    tree_id: 901        # Unique tree identifier
    level: 0            # Depth in tree (0 = root)
    lft: 1              # Left boundary
    rght: 2             # Right boundary
```

**Part models MUST include:**
```yaml
- model: part.part
  pk: 9001
  fields:
    name: 'Part Name'
    category: 9001
    tree_id: 9001       # Unique tree identifier (can use PK)
    level: 0            # Depth in tree (0 = root)
    lft: 1              # Left boundary
    rght: 2             # Right boundary
    assembly: true      # or false
    active: true
    purchaseable: true  # or false
```

**BomItem models MUST include:**
```yaml
- model: part.bomitem
  pk: 8001
  fields:
    part: 9001          # Parent part PK
    sub_part: 9002      # Child part PK
    quantity: 2.0       # Must be float
    validated: true     # REQUIRED for BOM validation
    reference: 'U1, U2' # Optional
    note: ''            # Optional
```

### Common Mistakes

**❌ Missing MPPT fields:**
```yaml
# WRONG - will fail with "NOT NULL constraint failed: part_part.level"
- model: part.part
  pk: 9001
  fields:
    name: 'Part Name'
    category: 9001
    assembly: true
```

**✅ Correct:**
```yaml
- model: part.part
  pk: 9001
  fields:
    name: 'Part Name'
    category: 9001
    assembly: true
    tree_id: 9001
    level: 0
    lft: 1
    rght: 2
```

**❌ Wrong indentation (6 spaces breaks Django):**
```yaml
- model: part.part
  pk: 9001
  fields:
      name: 'Part Name'  # 6 spaces - WRONG
```

**✅ Correct (4 spaces for fields):**
```yaml
- model: part.part
  pk: 9001
  fields:
    name: 'Part Name'    # 4 spaces
    category: 9001
```

---

## Fixture Organization

### PK Conventions

Use PK ranges to avoid conflicts:
- **8000-8999**: BomItem models
- **9000-9999**: Part models for complex BOM tests
- **9200-9299**: PartCategory models for test scenarios

### File Structure

```yaml
# Comment describing scenario
- model: part.partcategory
  pk: 9001
  fields:
    name: 'Test Category'
    tree_id: 901
    level: 0
    lft: 1
    rght: 2

# Parts
- model: part.part
  pk: 9001
  fields:
    name: 'Assembly'
    category: 9001
    assembly: true
    tree_id: 9001
    level: 0
    lft: 1
    rght: 2

- model: part.part
  pk: 9002
  fields:
    name: 'Component'
    category: 9001
    assembly: false
    tree_id: 9002
    level: 0
    lft: 1
    rght: 2

# BOM Items
- model: part.bomitem
  pk: 8001
  fields:
    part: 9001        # Assembly
    sub_part: 9002    # Component
    quantity: 1.0
    validated: true
```

---

## Loading Fixtures in Plugin Tests

**Plugins require programmatic loading** (not in INSTALLED_APPS):

```python
import os
from django.core.management import call_command

# Calculate absolute path (4 levels up from test file)
fixture_path = os.path.join(
    os.path.dirname(os.path.dirname(__file__)),  # Up 2 levels from test file
    'fixtures',
    'my_fixture.yaml'
)

# Load fixture
call_command('loaddata', fixture_path, verbosity=0)
```

**Path calculation pattern:**
```
tests/integration/test_file.py  (current file)
    → os.path.dirname(__file__)     = tests/integration/
    → os.path.dirname(...)          = tests/
    → join with 'fixtures/file.yaml'
```

---

## Debugging Workflow

1. **Validate YAML syntax first:**
   ```powershell
   python -c "import yaml; yaml.safe_load(open('fixture.yaml'))"
   ```

2. **If Django error "NOT NULL constraint failed: part_part.level":**
   - Add MPPT fields (`tree_id`, `level`, `lft`, `rght`) to ALL Part models
   - Use this script to batch-add:
   ```python
   import yaml
   with open('fixture.yaml', 'r') as f:
       data = yaml.safe_load(f)
   
   for item in data:
       if item.get('model') == 'part.part':
           fields = item['fields']
           if 'tree_id' not in fields:
               pk = item['pk']
               fields['tree_id'] = pk
               fields['level'] = 0
               fields['lft'] = 1
               fields['rght'] = 2
   
   with open('fixture.yaml', 'w') as f:
       yaml.dump(data, f, sort_keys=False, default_flow_style=False)
   ```

3. **If BOM validation error:**
   - Ensure all BomItem entries have `validated: true`
   - Check that `part` and `sub_part` PKs exist in fixture

4. **If fixture not loading:**
   - Verify path calculation (use `print(fixture_path)` to debug)
   - Check file exists with absolute path
   - Ensure YAML is valid (step 1)

---

## InvenTree Model Field Reference

### Part Model (Essential Fields)

```yaml
name: 'Part Name'          # Required
IPN: 'PART-001'            # Internal Part Number (optional)
description: 'Description' # Optional
category: 9001             # FK to PartCategory
assembly: true             # Is this an assembly?
active: true               # Is part active?
purchaseable: true         # Can be purchased?
tree_id: 9001              # MPPT field (required)
level: 0                   # MPPT field (required)
lft: 1                     # MPPT field (required)
rght: 2                    # MPPT field (required)
```

### BomItem Model (Essential Fields)

```yaml
part: 9001                 # Parent assembly PK
sub_part: 9002             # Child component PK
quantity: 1.0              # Must be float
validated: true            # Required for BOM validation
reference: 'U1, U2'        # Optional reference designators
note: 'Note text'          # Optional notes
optional: false            # Is this item optional?
inherited: false           # Inherited from template?
```

### PartCategory Model (Essential Fields)

```yaml
name: 'Category Name'      # Required
description: 'Description' # Optional
parent: null               # FK to parent category (null for root)
tree_id: 901               # MPPT field (required)
level: 0                   # MPPT field (required, 0 for root)
lft: 1                     # MPPT field (required)
rght: 2                    # MPPT field (required)
```

---

## See Also

- `backend.testing.instructions.md` - Comprehensive fixture patterns and loading
- `docs/toolkit/TESTING-STRATEGY.md` - Fixture debugging workflow and best practices
- Django Fixtures: https://docs.djangoproject.com/en/stable/howto/initial-data/
- MPTT Documentation: https://django-mptt.readthedocs.io/
