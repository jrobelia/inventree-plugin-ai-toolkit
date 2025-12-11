# Project Context - InvenTree Plugin Toolkit

**Audience:** AI Agents | **Category:** Technical Architecture | **Purpose:** Project architecture, folder structure, tech stack, and InvenTree patterns | **Last Updated:** 2025-12-10

---

**For communication guidelines and user preferences**, see `AGENT-BEHAVIOR.md`.

---

## Project Overview

**What is this?**
A lightweight development toolkit for creating and deploying InvenTree plugins. InvenTree is an open-source inventory management system, and plugins extend its functionality.

### Critical Distinction: Toolkit vs Plugins

**The Toolkit** (this repository):
- The **development environment** for building InvenTree plugins
- PowerShell scripts (Build, Deploy, Test, New-Plugin)
- Documentation infrastructure (copilot/, docs/)
- Configuration files (servers.json, workspace settings)
- **Toolkit documentation** covers how to use the development tools

**Plugins** (in plugins/ folder):
- The **InvenTree plugins** being developed USING this toolkit
- Each plugin is a separate project with its own README.md
- Each plugin has its own git repository (optional)
- **Plugin documentation** covers what the plugin does and how to use it

**Example:**
- Modifying `Build-Plugin.ps1` = Toolkit change → Update toolkit docs (copilot/PROJECT-CONTEXT.md)
- Adding a feature to FlatBOMGenerator = Plugin change → Update plugin docs (plugins/FlatBOMGenerator/README.md)

**Key Design Philosophy:**
- ✅ Simple PowerShell scripts (not complex CI/CD)
- ✅ Copy-to-server deployment (mirrors user's current workflow)
- ✅ Separate from plugin-creator (won't conflict with updates)
- ✅ Copilot-friendly documentation
- ✅ Easy to abandon and resume (part-time development)

**Plugin Types:**
- **Backend plugins** (Python): Add business logic, API endpoints, scheduled tasks
- **Frontend plugins** (React/TypeScript): Add custom UI panels, dashboards, settings pages
- **Full-stack plugins**: Combine both backend and frontend

**Development Workflow:**
```
Create Plugin → Edit Code → Build → Deploy to Staging → Test → Deploy to Production
```

---

## Architecture & Folder Structure

### Toolkit Root Structure

```
C:\PythonProjects\Inventree Plugin Creator\
├── plugin-creator\                     # Original repo (git submodule, gets updates)
└── inventree-plugin-ai-toolkit\        # This toolkit (user's workspace)
    ├── .vscode\                        # VS Code workspace settings
    │   └── settings.json               # Workspace configuration
    ├── config\                         # Server configurations
    │   ├── servers.json                # Server paths and credentials (gitignored)
    │   └── servers.json.example        # Template for servers.json
    ├── copilot\                        # AI agent guidance (all files agent-facing)
    │   ├── AGENT-BEHAVIOR.md           # Agent communication style and rules
    │   ├── PROJECT-CONTEXT.md          # This file - architecture and tech info
    │   └── plugin-creation-prompts.md  # Plugin creation workflow templates
    ├── docs\                           # Developer documentation
    │   ├── WORKFLOWS.md                # Step-by-step task guides
    │   ├── QUICK-REFERENCE.md          # Command cheat sheet
    │   ├── copilot-prompts.md          # Ready-to-use prompts
    │   ├── CUSTOM-STATES-GUIDE.md      # InvenTree custom states
    │   └── TESTING-FRAMEWORK-RESEARCH.md # Django testing framework notes
    ├── plugins\                        # User's plugin projects (active development)
    │   ├── README.md                   # About plugins folder
    │   └── FlatBOMGenerator\           # Example plugin (active development)
    ├── reference\                      # Example plugins (for learning, NOT deployed)
    │   ├── README.md                   # About reference folder
    │   ├── flat_bom_plugin_reference\  # Reference implementations
    │   └── inventree-source\           # InvenTree source code (for reference)
    ├── scripts\                        # PowerShell automation
    │   ├── New-Plugin.ps1              # Create new plugin from template
    │   ├── Build-Plugin.ps1            # Build Python + frontend
    │   ├── Deploy-Plugin.ps1           # Deploy to server via SSH/SCP
    │   └── Test-Plugin.ps1             # Run plugin tests
    ├── inventree-plugin-ai-toolkit.code-workspace  # VS Code workspace file
    ├── README.md                       # Toolkit overview and quick start
    └── SETUP.md                        # Initial setup instructions
```

### Plugin Structure (Inside `plugins/` folder)

```
plugins/my-plugin/                  # Active development plugin
├── my_custom_plugin/              # Python package (snake_case)
│   ├── __init__.py                # Version info and metadata
│   ├── core.py                    # ⭐ Main plugin class - EDIT THIS
│   ├── models.py                  # Database models (if using AppMixin)
│   ├── admin.py                   # Django admin interface
│   ├── apps.py                    # Django app config
│   ├── views.py                   # API endpoints (if using UrlsMixin)
│   ├── serializers.py             # API serializers (if using UrlsMixin)
│   ├── migrations/                # Database migrations (auto-generated)
│   ├── tests/                     # Unit tests
│   │   ├── __init__.py
│   │   └── test_*.py              # Test files
│   └── static/                    # ⚠️ AUTO-GENERATED - don't edit!
├── frontend/                      # Frontend code (if using UserInterfaceMixin)
│   ├── src/
│   │   ├── Panel.tsx              # ⭐ Custom panels - EDIT THIS
│   │   ├── Dashboard.tsx          # ⭐ Dashboard widgets - EDIT THIS
│   │   ├── Settings.tsx           # ⭐ Settings page - EDIT THIS
│   │   ├── locale.tsx             # Translation wrapper
│   │   ├── vite-env.d.ts          # TypeScript definitions
│   │   └── locales/               # Translation files
│   ├── package.json               # Frontend dependencies
│   ├── vite.config.ts             # Vite build configuration
│   ├── vite.dev.config.ts         # Vite dev server config
│   ├── tsconfig.json              # TypeScript configuration
│   ├── tsconfig.app.json          # TypeScript app config
│   ├── tsconfig.node.json         # TypeScript node config
│   ├── index.html                 # HTML entry point
│   └── README.md                  # Frontend docs
├── .github/                       # CI/CD (optional)
│   └── workflows/
│       └── ci.yaml                # GitHub Actions workflow
├── .gitignore                     # Git ignore patterns
├── biome.json                     # Biome linter/formatter config
├── LICENSE                        # Plugin license
├── MANIFEST.in                    # Python package manifest
├── pyproject.toml                 # Python package configuration
├── setup.cfg                      # Python setup configuration
└── README.md                      # Plugin documentation
```

### What to Edit vs What's Auto-Generated

**✅ EDIT THESE:**
- `core.py` - Main plugin logic, mixins, settings
- `views.py` - API endpoints
- `models.py` - Database schema
- `serializers.py` - API data formats
- `frontend/src/*.tsx` - UI components
- `pyproject.toml` - Python dependencies
- `frontend/package.json` - Frontend dependencies
- `README.md` - Documentation
- `tests/test_*.py` - Unit tests

**⛔ DON'T EDIT (Auto-generated):**
- `static/` folder - Generated from frontend build by Vite
- `migrations/` - Generated by Django
- `node_modules/` - npm packages
- `dist/` and `build/` - Build artifacts
- `__pycache__/` - Python bytecode cache
- `.egg-info/` - Python package metadata

---

## Technology Stack

### Backend (Python)
- **Framework**: Django 4.x+ (InvenTree is built on Django)
- **Language**: Python 3.9+
- **Key Libraries**:
  - `django-rest-framework` - REST API endpoints
  - `inventree` - Core InvenTree functionality and models

**Key Concepts:**
- **Mixins**: Plugins use mixins to add capabilities
- **Django ORM**: Database access through models
- **DRF Serializers**: Convert Python objects to JSON
- **DRF ViewSets/APIView**: Handle HTTP requests

### Frontend (TypeScript/React)
- **Language**: TypeScript 5.x+
- **Framework**: React 19+
- **UI Library**: Mantine 8+ (component library similar to Material-UI)
- **Build Tool**: Vite 6+ (fast ES module bundler)
- **Translation**: Lingui 5+ (i18n/internationalization)
- **State Management**: React Query (TanStack Query)
- **Routing**: InvenTree provides navigation context

**Key Concepts:**
- **InvenTreePluginContext**: Context object passed to all components with API client, user info, model data
- **Mantine Components**: Pre-built UI components (Button, Table, Modal, etc.)
- **React Query**: Data fetching and caching
- **Lingui i18n**: Translation system using `<Trans>` component

### Development Tools
- **Package Manager (Python)**: pip with virtual environments
- **Package Manager (JS)**: npm or yarn
- **Linter (Python)**: ruff (fast Python linter)
- **Linter/Formatter (JS/TS)**: Biome (fast alternative to ESLint/Prettier)
- **Build Tool**: Vite for frontend bundling
- **Test Runner**: Python unittest or Django TestCase

### Deployment
- **Method**: Manual copy to server plugin directories
- **Protocols**: SSH/SCP for file transfer
- **Servers**: Staging and production (configured in `config/servers.json`)
- **No Docker/Kubernetes**: Intentionally simple
- **No CI/CD**: Manual deployment only

---

## InvenTree Plugin System

### Available Mixins

Mixins add specific capabilities to your plugin class:

| Mixin | Purpose | Common Methods |
|-------|---------|----------------|
| `SettingsMixin` | Configuration settings UI | `get_setting()`, `set_setting()` |
| `UrlsMixin` | Custom API endpoints | `setup_urls()` |
| `UserInterfaceMixin` | Custom frontend UI | `get_ui_panels()`, `get_ui_features()` |
| `EventMixin` | React to InvenTree events | `process_event()` |
| `ScheduleMixin` | Background scheduled tasks | `get_scheduled_tasks()` |
| `AppMixin` | Django app with models | `setup_models()` |
| `ValidationMixin` | Custom validation rules | `validate_*()` methods |
| `ReportMixin` | Custom report templates | `add_report_templates()` |
| `LabelMixin` | Custom label templates | `add_label_templates()` |
| `CurrencyExchangeMixin` | Currency conversion | `update_exchange_rates()` |
| `LocateMixin` | Custom locate functionality | `locate_stock_item()` |
| `NavigationMixin` | Add navigation menu items | `navigation()` |

### Plugin Class Structure

```python
from plugin import InvenTreePlugin
from plugin.mixins import SettingsMixin, UrlsMixin, UserInterfaceMixin

class MyCustomPlugin(SettingsMixin, UrlsMixin, UserInterfaceMixin, InvenTreePlugin):
    """My custom InvenTree plugin."""
    
    # Plugin metadata
    TITLE = "My Custom Plugin"
    SLUG = "my-custom-plugin"
    AUTHOR = "Your Name"
    DESCRIPTION = "Brief description"
    VERSION = "1.0.0"
    
    # Settings (if using SettingsMixin)
    SETTINGS = {
        'SETTING_NAME': {
            'name': 'Display Name',
            'description': 'What this setting does',
            'default': 'default_value',
            'validator': str,  # or int, bool, etc.
        }
    }
    
    # API endpoints (if using UrlsMixin)
    def setup_urls(self):
        from django.urls import path
        from .views import MyView
        return [
            path('custom/', MyView.as_view(), name='custom-endpoint'),
        ]
    
    # UI panels (if using UserInterfaceMixin)
    def get_ui_panels(self, request, context: dict, **kwargs):
        panels = []
        if context.get('target_model') == 'part':
            panels.append({
                'key': 'my-panel',
                'title': 'My Custom Panel',
                'icon': 'ti:info-circle',  # Tabler icon name
                'source': self.plugin_static_file('Panel.js:renderMyPanel'),
            })
        return panels
```

### InvenTree Models (Most Common)

These Django models are available for querying:

```python
from part.models import Part, PartCategory, BomItem
from stock.models import StockItem, StockLocation
from company.models import Company, SupplierPart
from order.models import PurchaseOrder, SalesOrder
from build.models import Build

# Example: Get all active parts
active_parts = Part.objects.filter(active=True)

# Example: Get stock for a part
stock = StockItem.objects.filter(part=my_part)
```

---

## Common InvenTree Patterns

### Pattern 1: Add Plugin Settings

```python
# In core.py
SETTINGS = {
    'API_KEY': {
        'name': 'API Key',
        'description': 'External service API key',
        'default': '',
        'protected': True,  # Hide value in UI
    },
    'MAX_ITEMS': {
        'name': 'Maximum Items',
        'description': 'Max items to process',
        'default': 100,
        'validator': int,
    },
    'ENABLE_FEATURE': {
        'name': 'Enable Feature',
        'description': 'Turn on special feature',
        'default': False,
        'validator': bool,
    }
}

# Access settings in plugin methods
def my_method(self):
    api_key = self.get_setting('API_KEY')
    max_items = int(self.get_setting('MAX_ITEMS'))
```

### Pattern 2: Custom API Endpoint

```python
# In views.py
from rest_framework import permissions, status
from rest_framework.response import Response
from rest_framework.views import APIView

class CustomDataView(APIView):
    """Custom API endpoint."""
    
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request):
        """Handle GET request."""
        data = {
            'message': 'Hello from plugin',
            'user': request.user.username,
        }
        return Response(data, status=status.HTTP_200_OK)
    
    def post(self, request):
        """Handle POST request."""
        input_data = request.data.get('value')
        result = self.process_data(input_data)
        return Response({'result': result}, status=status.HTTP_200_OK)

# In core.py
def setup_urls(self):
    from django.urls import path
    from .views import CustomDataView
    
    return [
        path('data/', CustomDataView.as_view(), name='custom-data'),
    ]
```

### Pattern 3: Custom Panel

```python
# In core.py
def get_ui_panels(self, request, context: dict, **kwargs):
    panels = []
    
    # Only show on Part pages
    if context.get('target_model') == 'part':
        panels.append({
            'key': 'my-custom-panel',
            'title': 'My Custom Data',
            'description': 'Shows custom part data',
            'icon': 'ti:info-circle',
            'source': self.plugin_static_file('Panel.js:renderMyPanel'),
        })
    
    return panels
```

```typescript
// In frontend/src/Panel.tsx
import { Alert, Text, Button } from '@mantine/core';
import type { InvenTreePluginContext } from '@inventreedb/ui';

function MyCustomPanel({ context }: { context: InvenTreePluginContext }) {
  const partId = context.id;  // Current part ID
  
  return (
    <Alert title="My Custom Panel" color="blue">
      <Text>Part ID: {partId}</Text>
      <Button onClick={() => alert('Clicked!')}>
        Click Me
      </Button>
    </Alert>
  );
}

export function renderMyPanel(context: InvenTreePluginContext) {
  return <MyCustomPanel context={context} />;
}
```

### Pattern 4: Fetch Data from Plugin API

```typescript
// In frontend/src/Panel.tsx
import { useQuery } from '@tanstack/react-query';
import { Text, Loader } from '@mantine/core';
import type { InvenTreePluginContext } from '@inventreedb/ui';

function MyPanel({ context }: { context: InvenTreePluginContext }) {
  
  // Fetch data from your plugin API
  const dataQuery = useQuery(
    {
      queryKey: ['myPluginData', context.id],
      queryFn: async () => {
        const url = '/plugin/my-plugin-slug/data/';
        const response = await context.api.get(url);
        return response.data;
      }
    },
    context.queryClient
  );
  
  if (dataQuery.isLoading) return <Loader />;
  if (dataQuery.error) return <Text c="red">Error loading data</Text>;
  
  return <Text>{dataQuery.data.message}</Text>;
}
```

### Pattern 5: React to InvenTree Events

```python
# In core.py
from plugin.mixins import EventMixin

class MyPlugin(EventMixin, InvenTreePlugin):
    
    def process_event(self, event, *args, **kwargs):
        """Handle InvenTree events."""
        
        if event == 'part.created':
            # Handle new part creation
            part = kwargs.get('instance')
            self.handle_new_part(part)
        
        elif event == 'stock.locationchanged':
            # Handle stock location change
            stock_item = kwargs.get('instance')
            self.update_tracking(stock_item)
```

---

## Frontend Context Object

The `InvenTreePluginContext` object passed to all frontend components contains:

```typescript
interface InvenTreePluginContext {
  // Current model data
  id: number;                    // Current model ID (e.g., part ID)
  model: string;                 // Model type ('part', 'stock', etc.)
  instance: any;                 // Full object data from API
  
  // User and permissions
  user: UserState;               // Current user info
  
  // API client
  api: AxiosInstance;            // Axios client for API calls
  
  // Navigation
  navigate: (url: string) => void;  // Navigate to another page
  
  // UI state
  theme: MantineTheme;           // Mantine theme with colors
  locale: string;                // Current language code
  
  // React Query
  queryClient: QueryClient;      // For data fetching/caching
  
  // Plugin-specific context
  context?: any;                 // Custom data from core.py
}
```

**Most useful properties:**
- `context.id` - Current record ID
- `context.api` - Make API calls
- `context.user` - Check permissions
- `context.navigate()` - Change page
- `context.queryClient` - React Query client

---

## PowerShell Scripts

### Available Scripts

| Script | Purpose | Usage |
|--------|---------|-------|
| `New-Plugin.ps1` | Create new plugin | `.\scripts\New-Plugin.ps1` |
| `Build-Plugin.ps1` | Build Python + frontend | `.\scripts\Build-Plugin.ps1 -Plugin "MyPlugin"` |
| `Deploy-Plugin.ps1` | Deploy to server | `.\scripts\Deploy-Plugin.ps1 -Plugin "MyPlugin" -Server "staging"` |
| `Test-Plugin.ps1` | Run tests | `.\scripts\Test-Plugin.ps1 -Plugin "MyPlugin"` |

### Script Behavior

**Build-Plugin.ps1:**
1. Builds Python package (wheel)
2. Builds frontend (if exists) with Vite
3. Copies frontend bundle to `static/` folder

**Deploy-Plugin.ps1:**
1. Builds plugin (calls Build-Plugin.ps1)
2. Copies built plugin to server via SCP
3. SSHs to server and restarts InvenTree

**Test-Plugin.ps1:**
1. Sets InvenTree test environment variables
2. Discovers test files in plugin's `tests/` directory
3. Runs tests using `invoke dev.test` (preferred) or Python unittest (fallback)

---

## Testing Framework

InvenTree plugins use **Django TestCase**, not standard Python unittest.

### Test Structure

```python
from InvenTree.unit_test import InvenTreeTestCase

class MyFeatureTests(InvenTreeTestCase):
    """Tests for my feature."""
    
    @classmethod
    def setUpTestData(cls):
        """Setup test data once for all test methods."""
        super().setUpTestData()
        # Create test objects here
        from part.models import Part
        cls.test_part = Part.objects.create(name='TestPart', active=True)
    
    def test_something(self):
        """Test that something works."""
        result = self.my_function(self.test_part)
        self.assertEqual(result, expected)
```

### Running Tests

**Preferred (with InvenTree dev environment):**
```powershell
.\scripts\Test-Plugin.ps1 -Plugin "MyPlugin"
```

**Manual:**
```bash
# Set environment variables first
$env:INVENTREE_PLUGINS_ENABLED = "True"
$env:INVENTREE_PLUGIN_TESTING = "True"
$env:INVENTREE_PLUGIN_TESTING_SETUP = "True"

# Run with invoke
invoke dev.test -r my_plugin.tests.test_feature

# Or with Python unittest (pure Python tests only)
python -m unittest discover -s tests -p "test_*.py"
```

See `docs/TESTING-FRAMEWORK-RESEARCH.md` for comprehensive testing documentation.

---

## Documentation Update Routine

**IMPORTANT**: This section covers **TOOLKIT documentation only**. Plugin-specific documentation (README.md in each plugin folder) is separate.

### Toolkit vs Plugin Documentation

**Toolkit Documentation** (Update when modifying the toolkit itself):
- `copilot/PROJECT-CONTEXT.md` - Architecture, folder structure, tech stack
- `copilot/AGENT-BEHAVIOR.md` - Communication guidelines
- `copilot/plugin-creation-prompts.md` - Creation workflow prompts
- `.github/copilot-instructions.md` - Quick reference for agents
- `docs/WORKFLOWS.md` - How-to guides for using toolkit
- `docs/QUICK-REFERENCE.md` - Command reference
- `README.md` (toolkit root) - Toolkit overview

**Plugin Documentation** (Update when developing plugins):
- `plugins/[PluginName]/README.md` - Plugin features and usage
- `plugins/[PluginName]/COPILOT-GUIDE.md` - Plugin-specific dev guide (if exists)
- Plugin code comments and docstrings

### 1. Files That Need Updating (Toolkit Changes)

**After Toolkit Code Changes:**
- [ ] Script documentation in `.ps1` files - Update help text if parameters change
- [ ] `docs/QUICK-REFERENCE.md` - If command usage changes
- [ ] Code comments - Inline documentation in scripts

**After Toolkit Architecture Changes:**
- [ ] `copilot/PROJECT-CONTEXT.md` - This file (if folder structure changes)
- [ ] `docs/WORKFLOWS.md` - If workflows change
- [ ] `.github/copilot-instructions.md` - If quick reference needs updating
- [ ] Toolkit `README.md` - If setup process changes

### 2. Documentation Sync Checklist

When updating plugin documentation:

**README.md Updates:**
- [ ] Feature list reflects current capabilities
- [ ] Usage instructions match current UI
- [ ] API endpoint documentation is current
- [ ] Examples and code snippets work

**Code Documentation:**
- [ ] Docstrings updated for modified functions/classes
- [ ] Type hints accurate
- [ ] Comments explain "why" not just "what"

**Test Documentation:**
- [ ] New features have test cases
- [ ] Test names clearly describe what they test
- [ ] Edge cases documented

### 3. Proactive Review Trigger

Suggest documentation review after:
- 5+ feature additions without doc review
- Major refactoring or restructuring
- Before production deployment
- Quarterly (for mature plugins)

### 4. Version Tracking in Docs

Add "Last Verified" dates to major sections:

```markdown
## API Endpoints

**Last Verified:** 2025-12-10 (v1.2.0)

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/data/` | GET | Returns custom data |
```

---

## Useful References

### InvenTree API Endpoints (Most Common)

```
/api/part/              # Parts and BOMs
/api/stock/             # Stock items and locations
/api/company/           # Companies (suppliers/customers)
/api/order/purchase/    # Purchase orders
/api/order/sales/       # Sales orders
/api/build/             # Build orders
/api/plugin/            # Plugin management
/api/user/              # User management
```

### Mantine Components (Most Useful)

```typescript
import { 
  Alert,      // Colored notification boxes
  Button,     // Buttons with variants
  Text,       // Styled text display
  Title,      // Headings (h1-h6)
  Table,      // Data tables
  Stack,      // Vertical layout (flexbox column)
  Group,      // Horizontal layout (flexbox row)
  Card,       // Card container with shadow
  Badge,      // Small colored labels
  Loader,     // Loading spinner
  Modal,      // Dialog/popup
  TextInput,  // Text input field
  Select,     // Dropdown select
  Checkbox,   // Checkbox input
  Switch,     // Toggle switch
} from '@mantine/core';
```

### Tabler Icons (For UI)

```python
# In core.py panel definitions
'icon': 'ti:info-circle'    # Info icon
'icon': 'ti:list'           # List icon
'icon': 'ti:chart-bar'      # Bar chart
'icon': 'ti:settings'       # Settings gear
'icon': 'ti:package'        # Package/box
'icon': 'ti:tools'          # Tools/wrench
```

Browse icons at: https://tabler.io/icons

---

## Documentation Update System

### Automated Git Hook

A post-commit hook automatically reminds developers to update documentation when toolkit changes are committed. This ensures documentation stays synchronized with code changes.

**How It Works:**
1. After each commit, `.git/hooks/post-commit` runs
2. PowerShell script `.git/hooks/post-commit.ps1` analyzes changed files
3. If toolkit files changed (scripts/, config/, docs/, copilot/), displays reminder with:
   - Commit hash and message (for context and copy-paste to AI agents)
   - Specific files that changed in each area
   - Relevant documentation files that may need updates
4. Hook ONLY triggers for toolkit changes, NOT plugin development

**What Triggers Reminders:**
- `scripts/` changes → Update WORKFLOWS.md, QUICK-REFERENCE.md, PROJECT-CONTEXT.md
- `config/` changes → Update PROJECT-CONTEXT.md, SETUP.md
- `copilot/` changes → Update **Last Updated** date, copilot-instructions.md
- `docs/` changes → Update **Last Updated** date
- Root .md files → Update **Last Updated** date

**What Doesn't Trigger:**
- Changes in `plugins/` folder (plugin development)
- Changes in `reference/` folder (example code)
- Build outputs, node_modules, etc.

**Purpose Headers:**
Every .md file has a purpose header showing:
- **Audience** - Who reads this (Users/AI Agents/Both)
- **Category** - Type of documentation
- **Purpose** - What this file is for
- **Last Updated** - When last modified (YYYY-MM-DD format)

Example:
```markdown
**Audience:** AI Agents | **Category:** Technical Architecture | **Purpose:** Project architecture and patterns | **Last Updated:** 2025-12-10
```

**Best Practice:**
When the git hook shows a reminder, review the listed files and update:
1. Purpose header **Last Updated** dates
2. Command examples if syntax changed
3. Workflow steps if process changed
4. File paths if structure changed

---

## Official Documentation Links

- **InvenTree Docs**: https://docs.inventree.org/
- **InvenTree Plugin Development**: https://docs.inventree.org/en/latest/plugins/
- **InvenTree Plugin Testing**: https://docs.inventree.org/en/latest/plugins/test/
- **Django Documentation**: https://docs.djangoproject.com/
- **Django REST Framework**: https://www.django-rest-framework.org/
- **React Documentation**: https://react.dev/
- **Mantine UI**: https://mantine.dev/
- **Vite Documentation**: https://vitejs.dev/

---

---

**Last Updated**: December 10, 2025  
**Toolkit Version**: 1.0
**InvenTree Compatibility**: 0.16.x+
