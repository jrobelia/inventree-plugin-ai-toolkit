---
applyTo: "**/views.py,**/serializers.py,**/urls.py"
---

# Django REST Framework Patterns

Patterns for DRF API development. Auto-loaded when editing views,
serializers, or URL configuration.

---

## Serializer Pattern

```python
from rest_framework import serializers

class MyDataSerializer(serializers.Serializer):
    """Define API response structure. Validates data and defines contract."""

    id = serializers.IntegerField(label="ID", help_text="Primary key")
    name = serializers.CharField(
        max_length=200, required=True,
        label="Name", help_text="Item name"
    )
    value = serializers.DecimalField(
        max_digits=10, decimal_places=2, required=True
    )
    # Optional fields -- use required=False explicitly
    notes = serializers.CharField(
        required=False, allow_blank=True, default='',
        help_text="Optional notes"
    )

    def validate_value(self, value):
        """Custom field validation."""
        if value < 0:
            raise serializers.ValidationError("Value must be non-negative")
        return value

    def validate(self, data):
        """Cross-field validation."""
        # Business rules that span multiple fields
        return data
```

**Best practices:**
- Use `Serializer` for API responses (explicit contract).
- Use `ModelSerializer` only when directly mapping Django models.
- Document all fields with `label` and `help_text`.
- Validate with `serializer.is_valid(raise_exception=True)`.

---

## APIView Pattern

```python
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions

class MyAPIView(APIView):
    """Handle GET /api/my-endpoint/{pk}/"""

    permission_classes = [permissions.IsAuthenticated]
    serializer_class = MyDataSerializer

    def get(self, request, pk):
        if not pk or pk < 1:
            return Response(
                {'error': 'Invalid ID parameter'},
                status=status.HTTP_400_BAD_REQUEST
            )

        try:
            obj = MyModel.objects.get(pk=pk)
        except MyModel.DoesNotExist:
            return Response(
                {'error': f'Item {pk} not found'},
                status=status.HTTP_404_NOT_FOUND
            )

        serializer = self.serializer_class(data={'id': obj.pk, 'name': obj.name})
        serializer.is_valid(raise_exception=True)
        return Response(serializer.data, status=status.HTTP_200_OK)
```

---

## HTTP Status Codes

```python
# Success
HTTP_200_OK              # GET, PUT, PATCH successful
HTTP_201_CREATED         # POST successful, resource created
HTTP_204_NO_CONTENT      # DELETE successful

# Client errors
HTTP_400_BAD_REQUEST     # Invalid input, validation failed
HTTP_401_UNAUTHORIZED    # Authentication required
HTTP_403_FORBIDDEN       # Authenticated but not authorised
HTTP_404_NOT_FOUND       # Resource does not exist
```

---

## QuerySet Optimization (CRITICAL)

Prevent N+1 query problems:

```python
# BAD: N+1 queries (1 for parts + 1 per part for category)
parts = Part.objects.all()
for part in parts:
    print(part.category.name)  # Query EACH iteration

# GOOD: single query with JOIN
parts = Part.objects.select_related('category').all()

# GOOD: many-to-many relationships
parts = Part.objects.prefetch_related('supplier_parts').all()
```

- `select_related()` -- ForeignKey, OneToOne (SQL JOIN).
- `prefetch_related()` -- ManyToMany, reverse ForeignKey (separate query + cache).
- `only()` -- load specific fields only.
- `defer()` -- load all fields except specified.

---

## Fail-Fast (API Edition)

1. **Required field in the API contract?** -> Access directly, let KeyError surface.
2. **Missing field breaks business logic?** -> Return 400 with clear message.
3. **From user input or internal code?**
   - User input -> validate with serializer, return 400.
   - Internal code -> let exception propagate (it is a bug).

---

## Security Checklist

- Validate permissions: `request.user.has_perm()`.
- Never trust client data -- always validate with serializers.
- Use Django ORM, never raw SQL.
- CSRF protection enabled by default -- do not disable.
