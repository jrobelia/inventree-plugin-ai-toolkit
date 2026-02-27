---
applyTo: "**/core.py,**/plugin.py,plugins/**/__init__.py"
---

# InvenTree Plugin Patterns

Patterns specific to the InvenTree plugin system. Apply when editing
plugin core files, __init__.py, or any file defining plugin classes.

---

## Plugin Class Structure

```python
from plugin import InvenTreePlugin
from plugin.mixins import SettingsMixin, UrlsMixin, UserInterfaceMixin

class MyPlugin(SettingsMixin, UrlsMixin, UserInterfaceMixin, InvenTreePlugin):
    """Plugin description."""

    # Required metadata
    TITLE = "Human-Readable Title"
    NAME = "PluginClassName"
    SLUG = "plugin-slug"          # Used in URLs: /plugin/plugin-slug/
    DESCRIPTION = "Brief description"
    VERSION = "1.0.0"

    # Optional
    AUTHOR = "Author Name"
    LICENSE = "MIT"
    # MIN_VERSION = '0.18.0'     # Minimum InvenTree version
    # MAX_VERSION = '2.0.0'      # Maximum InvenTree version
```

**Mixin order:** Most specific -> Most general -> `InvenTreePlugin` last.

---

## Available Mixins

| Mixin | Purpose |
|---|---|
| `SettingsMixin` | Plugin settings (UI-configurable) |
| `UrlsMixin` | Custom API endpoints |
| `UserInterfaceMixin` | Frontend panels and dashboards |
| `EventMixin` | React to InvenTree events |
| `ScheduleMixin` | Background recurring tasks |

Only include mixins the plugin actually uses.

---

## Settings Pattern (SettingsMixin)

```python
SETTINGS = {
    'API_KEY': {
        'name': 'API Key',
        'description': 'External service API key',
        'validator': str,
        'default': '',
        'protected': True,       # Hide value in UI
    },
    'ENABLE_FEATURE': {
        'name': 'Enable Feature',
        'description': 'Toggle feature on/off',
        'validator': bool,
        'default': False,
    },
}

# Access in code:
api_key = self.get_setting('API_KEY')
# Write: self.set_setting('API_KEY', 'new-value')
```

Valid validators: `bool`, `int`, `str`, or `choice` (add `'choices': [('val','Label'), ...]`).
Settings are stored in the database. Admin UI is auto-generated from this dict.

**Fail-fast rule:** Use defaults for optional UI preferences only. If a
missing setting breaks functionality, raise a clear error instead.

---

## URL Registration (UrlsMixin)

Plugin URLs are auto-prefixed: `/api/plugin/{plugin-slug}/your-path/`.
Trailing slash required on all patterns.

```python
from django.urls import path

def setup_urls(self):
    from .views import MyAPIView        # Import INSIDE method (avoid circular imports)
    return [
        path('endpoint/<int:pk>/', MyAPIView.as_view(), name='my-endpoint'),
    ]
# URLs become: /api/plugin/{slug}/endpoint/{pk}/
```

Reference in templates/nav: `plugin:{plugin-slug}:{url-name}`

---

## Event Handling (EventMixin)

Events fire **asynchronously** via django-q background worker -- not inline.
If the worker isn't running, events silently don't fire.

`process_event` always receives these kwargs:
- `event`: string like `part_part.created`, `build_build.completed`
- `id`: primary key of the affected object
- `model`: model class name string (e.g. `'Part'`)
- `sender`: the model class itself

```python
def wants_process_event(self, event: str) -> bool:
    return event in ['part_part.created', 'build_build.completed']

def process_event(self, event: str, *args, **kwargs) -> None:
    try:
        part_id = kwargs.get('id')
        if not part_id:
            raise ValueError(f"Event {event} missing 'id' parameter")
        self.handle_new_part(part_id)
    except Exception as e:
        self.logger.error(f"Event processing failed: {e}")
```

Fire custom events: `trigger_event('my_plugin.thing_happened', id=obj.pk)`

**Rules:** Filter early in `wants_process_event()`. Fail fast on missing
required data. Log errors -- event processing is async and silent.

---

## Scheduled Tasks (ScheduleMixin)

Schedule codes: `'I'` (interval), `'D'` (daily), `'W'` (weekly),
`'M'` (monthly). Runs via django-q -- if worker is stopped, tasks silently skip.

```python
SCHEDULED_TASKS = {
    'sync_inventory': {
        'func': 'sync_inventory_task',
        'schedule': 'I',            # Interval
        'minutes': 30,              # Every 30 minutes
    },
}

def sync_inventory_task(self):
    """Must be idempotent -- safe to run multiple times."""
    try:
        # Business logic
        self.logger.info("Sync completed")
    except Exception as e:
        self.logger.error(f"Sync failed: {e}")
```

**Testing gotcha:** scheduled tasks won't execute in the test environment.
Mock the task method directly instead of triggering the scheduler.

---

## Entry Point (CRITICAL)

In `pyproject.toml`, the entry point must be exact:

```toml
[project.entry-points."inventree_plugins"]
MyPlugin = "my_plugin.core:MyPlugin"
```

Format: `PluginClassName = "package.module:ClassName"`.
A wrong entry point means the plugin silently fails to load.

---

## Critical Gotchas

1. **Plugin URLs in tests** -> use `as_view()` pattern, not HTTP client.
2. **External dependencies** -> externalize React/Mantine, don't bundle.
3. **Entry point format** -> exact match required.
4. **Import inside `setup_urls()`** -> prevents circular imports.
5. **N+1 queries** -> always use `select_related()` / `prefetch_related()`.
