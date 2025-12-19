---
description: 'InvenTree plugin core patterns - plugin class, mixins, settings, scheduled tasks'
applyTo: ['**/core.py', '**/__init__.py']
---

# Backend Core Plugin Patterns

**Source**: Plugin creator templates (core.py)  
**References**: [PROJECT-CONTEXT.md](../../copilot/PROJECT-CONTEXT.md) for comprehensive mixin documentation

## Plugin Class Structure

```python
from plugin import InvenTreePlugin
from plugin.mixins import SettingsMixin, UrlsMixin, UserInterfaceMixin

class MyPlugin(SettingsMixin, UrlsMixin, UserInterfaceMixin, InvenTreePlugin):
    """Plugin description."""
    
    # Required metadata
    TITLE = "Human-Readable Plugin Title"
    NAME = "PluginClassName"
    SLUG = "plugin-slug"  # Used in URLs: /plugin/plugin-slug/
    DESCRIPTION = "Brief description"
    VERSION = "1.0.0"  # From __init__.py
    
    # Optional metadata
    AUTHOR = "Author Name"
    WEBSITE = "https://github.com/..."
    LICENSE = "MIT"
    
    # Version constraints (optional, test carefully)
    # MIN_VERSION = '0.18.0'  # Minimum InvenTree version
    # MAX_VERSION = '2.0.0'   # Maximum InvenTree version
```

**Mixin Order Best Practice**: Most specific → Most general → InvenTreePlugin last

## Settings Pattern (SettingsMixin)

```python
SETTINGS = {
    'API_KEY': {
        'name': 'API Key',
        'description': 'External service API key',
        'validator': str,
        'default': '',
        'protected': True,  # Hide value in UI
    },
    'MAX_RETRIES': {
        'name': 'Maximum Retries',
        'description': 'Number of retry attempts',
        'validator': int,
        'default': 3,
        'validator': lambda x: x >= 0,  # Custom validation
    },
    'ENABLE_FEATURE': {
        'name': 'Enable Feature',
        'description': 'Toggle feature on/off',
        'validator': bool,
        'default': False,
    },
}

# Access settings in code
def my_method(self):
    api_key = self.get_setting('API_KEY')
    max_retries = self.get_setting('MAX_RETRIES', 3)  # With default fallback
```

**When to Use Fallbacks**:
- ✅ **Use default**: Optional UI preference, graceful degradation
- ❌ **Fail loudly**: Required config, incorrect value breaks functionality

## Scheduled Tasks Pattern (ScheduleMixin)

```python
SCHEDULED_TASKS = {
    'sync_inventory': {
        'schedule': 'H',  # Hourly
        'func': 'sync_inventory_task',
    },
    'cleanup_data': {
        'schedule': 'D',  # Daily
        'func': 'cleanup_task',
    },
}

def sync_inventory_task(self):
    """Background task - must be idempotent."""
    try:
        # Business logic
        self.logger.info("Sync completed successfully")
    except Exception as e:
        # Log error but don't crash InvenTree
        self.logger.error(f"Sync failed: {e}")
        # Don't use bare except or generic fallbacks
```

**Background Task Principles**:
1. **Idempotent**: Safe to run multiple times
2. **Fail-safe**: Log errors, don't crash InvenTree
3. **Specific errors**: Catch specific exceptions, not `except:`
4. **Timeout aware**: Long operations should yield/batch

## Event Handling Pattern (EventMixin)

```python
def wants_process_event(self, event: str) -> bool:
    """Return True if plugin should process this event."""
    # Be specific - only process events you need
    return event in [
        'part_part.created',
        'build_build.completed',
    ]

def process_event(self, event: str, *args, **kwargs) -> None:
    """Process event - keep logic fast."""
    try:
        if event == 'part_part.created':
            part_id = kwargs.get('id')
            if not part_id:
                # FAIL LOUDLY - missing critical data
                raise ValueError(f"Event {event} missing 'id' parameter")
            
            self.handle_new_part(part_id)
    except Exception as e:
        # Log but don't crash event system
        self.logger.error(f"Event processing failed: {e}")
```

**Event Pattern Best Practices**:
- Filter early in `wants_process_event()` - avoid processing overhead
- Fail fast if required data missing - don't use `kwargs.get('id', None)` silently
- Log all errors - event processing is async, failures are silent otherwise

## URL Registration Pattern (UrlsMixin)

```python
from django.urls import path

def setup_urls(self):
    """Register custom API endpoints."""
    from .views import MyAPIView, AnotherView
    
    return [
        path('my-endpoint/<int:pk>/', MyAPIView.as_view(), name='my-endpoint'),
        path('another/', AnotherView.as_view(), name='another'),
    ]

# URLs will be: /api/plugin/{slug}/my-endpoint/{pk}/
```

**Critical**: Import views inside `setup_urls()`, not at module level (circular import prevention)

## Fail-Fast Decision Tree

**Question**: Should I use a default/fallback value?

1. **Is this field optional by design?** (UI preference, feature toggle)
   - ✅ Yes → Use sensible default
   - ❌ No → Continue to #2

2. **Does missing/wrong value cause incorrect behavior?** (calculation, data integrity)
   - ✅ Yes → Fail loudly with ValueError/KeyError
   - ❌ No → Use default with warning log

3. **Can user easily fix the error?** (missing config, invalid input)
   - ✅ Yes → Fail with clear error message
   - ❌ No → Use default with error log, alert admin

**Examples**:

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
    self.logger.error(f"Validation failed: {e}")
    raise  # Re-raise for caller to handle
except DatabaseError as e:
    self.logger.error(f"Database error: {e}")
    raise  # Don't hide infrastructure problems
```

## Industry Best Practices

**Logging**:
- Use `self.logger` (configured by InvenTree)
- Log levels: ERROR (problems), WARNING (potential issues), INFO (significant events), DEBUG (diagnostic)
- Include context: IDs, values, operation name

**Performance**:
- Don't query database in loops (use `select_related()`, `prefetch_related()`)
- Cache expensive operations
- Background tasks for long operations

**Security**:
- Never log sensitive data (API keys, passwords)
- Validate all user input
- Use Django's built-in security features

**Documentation**:
- Docstrings on all public methods
- Explain WHY, not just WHAT
- Include examples for complex logic

---

**When in doubt about defensive code**: Ask user how to proceed. Sometimes failing loudly reveals design issues.
