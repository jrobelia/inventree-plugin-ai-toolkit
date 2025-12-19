---
description: 'Django REST Framework patterns - serializers, views, validation, responses'
applyTo: ['**/serializers.py', '**/views.py']
---

# Backend API Patterns (DRF)

**Source**: Plugin creator templates (serializers.py, views.py)  
**References**: [PROJECT-CONTEXT.md](../../copilot/PROJECT-CONTEXT.md), [TESTING-STRATEGY.md](../../docs/toolkit/TESTING-STRATEGY.md)

## Serializer Pattern

```python
from rest_framework import serializers

class MyDataSerializer(serializers.Serializer):
    """Define API response structure.
    
    Serializers validate data and define API contract.
    Use Serializer (not dict) for type safety and validation.
    """
    
    class Meta:
        """Optional: List fields for documentation."""
        fields = ['id', 'name', 'value', 'optional_field']
    
    # Required fields - fail if missing
    id = serializers.IntegerField(
        label="ID",
        help_text="Database primary key"
    )
    
    name = serializers.CharField(
        max_length=200,
        required=True,
        label="Name",
        help_text="Item name"
    )
    
    value = serializers.DecimalField(
        max_digits=10,
        decimal_places=2,
        required=True
    )
    
    # Optional fields - use required=False
    optional_field = serializers.CharField(
        max_length=100,
        required=False,  # Explicitly optional
        allow_null=True,  # Allow null in JSON
        allow_blank=True,  # Allow empty string
        default='',  # Default if missing
        help_text="This field is optional by design"
    )
    
    def validate_value(self, value):
        """Custom field validation."""
        if value < 0:
            raise serializers.ValidationError(
                "Value must be non-negative"
            )
        return value
    
    def validate(self, data):
        """Cross-field validation."""
        if data['name'].startswith('DEPRECATED') and data['value'] > 0:
            raise serializers.ValidationError(
                "Deprecated items cannot have positive value"
            )
        return data
```

**Serializer Best Practices**:
- Use `Serializer` for API responses (structured data contract)
- Use `ModelSerializer` only when directly mapping Django models
- Fail validation loudly - don't use `.get()` with defaults for required fields
- Document all fields with `label` and `help_text`

## APIView Pattern

```python
from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status, permissions

class MyAPIView(APIView):
    """Custom API endpoint.
    
    GET /api/plugin/my-plugin/my-endpoint/{pk}/
    """
    
    # Authentication/permissions
    permission_classes = [permissions.IsAuthenticated]
    
    # Serializer for response
    serializer_class = MyDataSerializer
    
    def get(self, request, pk):
        """Handle GET request.
        
        Args:
            request: DRF Request object
            pk: URL parameter (int)
        
        Returns:
            Response with serialized data or error
        """
        try:
            # Validate input
            if not pk or pk < 1:
                return Response(
                    {'error': 'Invalid ID parameter'},
                    status=status.HTTP_400_BAD_REQUEST
                )
            
            # Business logic
            from part.models import Part
            try:
                part = Part.objects.get(pk=pk)
            except Part.DoesNotExist:
                return Response(
                    {'error': f'Part {pk} not found'},
                    status=status.HTTP_404_NOT_FOUND
                )
            
            # Build response data
            data = {
                'id': part.pk,
                'name': part.name,
                'value': part.get_price(1),
            }
            
            # Serialize and validate
            serializer = self.serializer_class(data=data)
            if not serializer.is_valid():
                # Fail loudly - serializer validation errors indicate bugs
                return Response(
                    {'error': 'Serialization failed', 'details': serializer.errors},
                    status=status.HTTP_500_INTERNAL_SERVER_ERROR
                )
            
            return Response(
                serializer.data,
                status=status.HTTP_200_OK
            )
            
        except Exception as e:
            # Log unexpected errors
            import logging
            logger = logging.getLogger('inventree')
            logger.exception(f"API error in MyAPIView: {e}")
            
            return Response(
                {'error': 'Internal server error', 'message': str(e)},
                status=status.HTTP_500_INTERNAL_SERVER_ERROR
            )
    
    def post(self, request):
        """Handle POST request with request data validation."""
        # Validate incoming data
        serializer = self.serializer_class(data=request.data)
        
        if not serializer.is_valid():
            # Return validation errors to client
            return Response(
                serializer.errors,
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Use validated_data (guaranteed to match serializer schema)
        validated = serializer.validated_data
        name = validated['name']
        value = validated['value']
        
        # Business logic here...
        
        return Response(
            {'message': 'Created successfully'},
            status=status.HTTP_201_CREATED
        )
```

## HTTP Status Code Best Practices

**Use proper RESTful status codes**:

```python
# Success
status.HTTP_200_OK              # GET, PUT, PATCH successful
status.HTTP_201_CREATED         # POST successful, resource created
status.HTTP_204_NO_CONTENT      # DELETE successful

# Client errors
status.HTTP_400_BAD_REQUEST     # Invalid input, validation failed
status.HTTP_401_UNAUTHORIZED    # Authentication required
status.HTTP_403_FORBIDDEN       # Authenticated but not authorized
status.HTTP_404_NOT_FOUND       # Resource doesn't exist
status.HTTP_409_CONFLICT        # State conflict (e.g., duplicate)

# Server errors
status.HTTP_500_INTERNAL_SERVER_ERROR  # Unexpected server error
status.HTTP_503_SERVICE_UNAVAILABLE    # Temporary service issue
```

## Django QuerySet Optimization

**⚠️ Critical**: Prevent N+1 query problems

```python
# ❌ BAD: N+1 queries (1 for parts + 1 per part for category)
parts = Part.objects.all()
for part in parts:
    print(part.category.name)  # Database query EACH iteration!

# ✅ GOOD: Single query with JOIN
parts = Part.objects.select_related('category').all()
for part in parts:
    print(part.category.name)  # No additional queries

# ✅ GOOD: Many-to-many relationships
parts = Part.objects.prefetch_related('supplier_parts').all()
for part in parts:
    suppliers = part.supplier_parts.all()  # Cached, no query
```

**QuerySet optimization patterns**:
- `select_related()` - ForeignKey, OneToOne (SQL JOIN)
- `prefetch_related()` - ManyToMany, reverse ForeignKey (separate query + cache)
- `only()` - Load only specific fields
- `defer()` - Load all fields except specified

## Fail-Fast Decision Tree (API Edition)

**Question**: Should I use `.get()` with a default?

1. **Is this a required field in the API contract?**
   - ✅ Yes → Access directly, let KeyError happen
   - ❌ No → Continue to #2

2. **Does the missing field break business logic?**
   - ✅ Yes → Return 400 with clear error message
   - ❌ No → Use default with warning log

3. **Is this coming from user input or internal code?**
   - User input → Validate with serializer, return 400
   - Internal code → Let exception happen (indicates bug)

**Examples**:

```python
# ❌ BAD: Hides API contract violations
part_id = request.data.get('part_id', None)
if part_id:
    # Silently skips if missing - is that correct behavior?
    ...

# ✅ GOOD: Fail loudly for required field
if 'part_id' not in request.data:
    return Response(
        {'error': 'part_id field is required'},
        status=status.HTTP_400_BAD_REQUEST
    )
part_id = request.data['part_id']

# ✅ ALSO GOOD: Use serializer validation
class MyRequestSerializer(serializers.Serializer):
    part_id = serializers.IntegerField(required=True)

serializer = MyRequestSerializer(data=request.data)
if not serializer.is_valid():
    return Response(serializer.errors, status=400)

# ❌ BAD: Silent data corruption
quantity = item.get('quantity', 1)  # Wrong if 0 is valid!

# ✅ GOOD: Explicit validation
if 'quantity' not in item:
    raise ValueError(f"Item {item.get('name')} missing quantity")
quantity = item['quantity']
if quantity < 0:
    raise ValueError(f"Negative quantity not allowed: {quantity}")
```

## Serializer Validation Errors

**When serializer validation fails in production code**: This indicates a BUG, not user error.

```python
# Response data from internal logic
data = build_response_data(part)

serializer = MySerializer(data=data)
if not serializer.is_valid():
    # ❌ BAD: Silent failure
    return Response({'data': {}}, status=200)
    
    # ✅ GOOD: Fail loudly - this is a code bug
    logger.error(f"Serializer validation failed: {serializer.errors}")
    logger.error(f"Invalid data: {data}")
    return Response(
        {'error': 'Internal validation error', 'details': serializer.errors},
        status=status.HTTP_500_INTERNAL_SERVER_ERROR
    )

# Request data from user
serializer = MySerializer(data=request.data)
if not serializer.is_valid():
    # ✅ GOOD: User error, return 400
    return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
```

## Testing API Views (CRITICAL)

**⚠️ Plugin URLs DO NOT work in Django test client**

```python
# ❌ DOES NOT WORK - Plugin URLs return 404 in tests
response = self.client.get('/api/plugin/my-plugin/endpoint/123/')  # Always 404!

# ✅ SOLUTION: Call view directly with DRF patterns
from rest_framework.test import APIRequestFactory, force_authenticate
from .views import MyAPIView

def test_my_view(self):
    factory = APIRequestFactory()
    view = MyAPIView.as_view()  # Get callable
    
    request = factory.get('/fake-url/')  # URL doesn't matter
    force_authenticate(request, user=self.user)  # Bypass auth
    
    response = view(request, pk=123)  # Call as function
    
    self.assertEqual(response.status_code, 200)
    self.assertIn('id', response.data)
```

**Reference**: See [TESTING-STRATEGY.md](../../docs/toolkit/TESTING-STRATEGY.md) for complete testing patterns

## Industry Best Practices

**Security**:
- Validate all user input with serializers
- Use Django's CSRF protection (enabled by default)
- Never trust client data - always validate server-side
- Sanitize output to prevent XSS (DRF does this automatically)

**Performance**:
- Use `select_related()` / `prefetch_related()` to prevent N+1 queries
- Paginate large result sets (DRF pagination classes)
- Cache expensive operations (Django cache framework)
- Use database indexes for frequently queried fields

**Error Handling**:
- Return appropriate HTTP status codes
- Provide clear error messages for clients
- Log unexpected errors with full context
- Don't expose internal implementation details in errors

**API Design**:
- RESTful URLs: `/resource/`, `/resource/{id}/`
- Use proper HTTP methods: GET (read), POST (create), PUT/PATCH (update), DELETE (delete)
- Version APIs if changes break compatibility (not common for plugins)
- Document endpoints with serializer `help_text`

---

**When defensive code looks suspicious**: Ask user if this is correct behavior. Silent bugs are worse than loud errors.
