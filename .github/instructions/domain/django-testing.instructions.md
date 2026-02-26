---
applyTo: "**/test_*.py,**/tests/**/*.py"
---

# Django Testing Patterns

Framework-specific testing patterns for Django and InvenTree projects.
For general testing principles (AAA, naming, grades), see
`testing.instructions.md`.

---

## CRITICAL: Plugin URLs Do NOT Work in Django Test Client

Plugin-registered URLs return 404 in Django's test client. This is a known
InvenTree behaviour that cost ~6 hours to discover.

**BAD -- will always return 404:**
```python
response = self.client.get('/api/plugin/my-plugin/endpoint/')
```

**GOOD -- use `as_view()` with `APIRequestFactory`:**
```python
from rest_framework.test import APIRequestFactory, force_authenticate
from my_plugin.views import MyAPIView

factory = APIRequestFactory()
view = MyAPIView.as_view()

request = factory.get('/fake-url/')  # URL does not matter
force_authenticate(request, user=self.user)
response = view(request, pk=123)

self.assertEqual(response.status_code, 200)
```

This pattern bypasses URL routing entirely and calls the view directly.

---

## InvenTree Test Base Classes

- `InvenTreeTestCase` (unit/integration) and `InvenTreeAPITestCase` (API tests)
- These handle: user creation, role assignment, authentication, fixture loading
- `InvenTreeAPITestCase` provides `self.get()`, `self.post()`, `self.patch()`,
  `self.delete()` helpers with auth pre-configured
- Use raw `unittest.TestCase` only for pure logic with zero Django dependencies

---

## Unit vs Integration Tests

**Unit tests** (fast, no database):
```python
import unittest

class TestCalculation(unittest.TestCase):
    def test_should_return_shortfall_when_stock_low(self):
        from my_plugin.logic import calculate_shortfall
        result = calculate_shortfall(required=15, in_stock=10)
        self.assertEqual(result, 5)
```

**Integration tests** (require InvenTree dev environment):
```python
from InvenTree.unit_test import InvenTreeTestCase
from part.models import Part

class TestPartAPI(InvenTreeTestCase):
    @classmethod
    def setUpTestData(cls):
        cls.part = Part.objects.create(
            name='Test Part', description='Test', active=True,
            tree_id=9001, level=0, lft=1, rght=2
        )

    def test_should_return_part_data(self):
        view = MyAPIView.as_view()
        request = self.factory.get('/fake/')
        force_authenticate(request, user=self.user)
        response = view(request, pk=self.part.pk)
        self.assertEqual(response.status_code, 200)
```

**Decision:** Use unit tests for pure logic. Use integration tests only
when you need the database, Django ORM, or InvenTree models.

---

## YAML Fixture Requirements

When creating test fixtures for InvenTree models, MPTT fields are required:

```yaml
- model: part.part
  pk: 9001
  fields:
    name: 'Test Part'
    category: 9001
    assembly: true
    active: true
    tree_id: 9001      # Required MPTT field
    level: 0            # Required MPTT field
    lft: 1              # Required MPTT field
    rght: 2             # Required MPTT field
```

Missing MPTT fields cause: `NOT NULL constraint failed: part_part.level`.

---

## Mocking External Dependencies

```python
from unittest.mock import patch, Mock

def test_should_handle_api_timeout(self):
    """Verify graceful handling when external API times out."""
    with patch('requests.get') as mock_get:
        mock_get.side_effect = TimeoutError()
        with self.assertRaises(TimeoutError):
            fetch_data()
```

---

## Test Organization

```
plugin_package/
  tests/
    __init__.py
    test_logic.py           # Unit tests for pure functions
    test_serializers.py     # Unit tests for serializer validation
    test_views.py           # Integration tests using as_view()
    fixtures/
      test_data.yaml        # YAML fixtures for integration tests
```
