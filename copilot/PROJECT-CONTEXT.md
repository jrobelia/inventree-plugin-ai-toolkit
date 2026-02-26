# Project Context - InvenTree Plugin Toolkit

**Audience:** AI Agents | **Category:** Comprehensive Developer Context | **Purpose:** Project architecture, tech stack, testing infrastructure, development workflows, debugging patterns, and InvenTree integration guide | **Last Updated:** 2025-12-16

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

### Server Configuration

**Server credentials stored in:** `config/servers.json`

**Contents:**
- SSH connection details (host, user, port)
- SSH key path (if configured)
- InvenTree installation path
- Server aliases (staging, production, etc.)

**SSH Key Usage:**
- Deploy-Plugin.ps1 automatically uses SSH key from servers.json
- No need to manually specify key or enter passwords
- Key path is typically: `C:\Users\<user>\.ssh\id_ed25519` or `id_rsa`

**Example servers.json:**
```json
{
  "staging": {
    "host": "staging.example.com",
    "user": "root",
    "ssh_key": "C:\\Users\\User\\.ssh\\id_ed25519",
    "inventree_path": "/root/inventree/inventree"
  }
}
```

**When SSHing to servers:**
- Use credentials from servers.json
- No passphrase prompts if key is configured correctly
- Scripts handle authentication automatically

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
├── .pre-commit-config.yaml        # Pre-commit hooks (Ruff + Biome)
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
- **React Query**: Data fetching and caching (use `useQuery` hook)
- **Lingui i18n**: Translation system using `` t`text` `` macro
- **See `.github/instructions/frontend.react.instructions.md`** for complete patterns

### Development Tools
- **Package Manager (Python)**: pip with virtual environments
- **Package Manager (JS)**: npm or yarn
- **Linter (Python)**: ruff (fast Python linter)
- **Linter/Formatter (JS/TS)**: Biome (fast alternative to ESLint/Prettier)
- **Build Tool**: Vite for frontend bundling
- **Test Runner**: Python unittest or Django TestCase
- **Pre-commit Hooks**: Automated code quality checks (scaffolded but requires setup)

### Code Quality Workflow

**Every plugin is scaffolded with:**
- `biome.json` - Biome configuration for TypeScript/React linting
- `.pre-commit-config.yaml` - Pre-commit hook configuration for Ruff and Biome

**To activate (one-time per plugin):**
```powershell
cd plugins/YourPlugin
python -m venv .venv
.\.venv\Scripts\Activate.ps1
pip install pre-commit
pre-commit install
pre-commit run --all-files  # Initial formatting
```

**After activation:**
- Every `git commit` automatically runs Ruff (Python) and Biome (TypeScript)
- Code is auto-formatted to PEP 8 and modern TypeScript standards
- Commits are blocked if unfixable issues are found
- No manual formatting needed

**Manual checks (optional):**
```powershell
# Frontend only
cd frontend
npm run lint        # Check for issues
npm run lint:fix    # Auto-fix issues

# All code
pre-commit run --all-files
```

**Why this matters:**
- Consistent code style across all plugins
- Catches errors before deployment
- Reduces code review friction
- Enforces best practices automatically

### Testing Infrastructure

**Two-Tier Testing Approach:**

**Unit Tests** (Fast, No Database):
- Location: `plugins/PluginName/plugin_name/tests/unit/`
- Speed: ~0.2 seconds
- Setup: None (just Python)
- Use For: Pure functions, business logic, serializer validation
- Runner: `python -m unittest`

**Integration Tests** (Real InvenTree Models):
- Location: `plugins/PluginName/plugin_name/tests/integration/`
- Speed: ~2-5 seconds
- Setup: InvenTree dev environment (one-time, 1-2 hours)
- Use For: API endpoints, BOM traversal, database queries
- Runner: `invoke dev.test` (InvenTree test framework)

**Setup Commands:**
```powershell
# One-time setup (1-2 hours)
.\scripts\Setup-InvenTreeDev.ps1
.\scripts\Link-PluginToDev.ps1 -Plugin "PluginName"

# Run tests
.\scripts\Test-Plugin.ps1 -Plugin "PluginName" -Unit         # Fast
.\scripts\Test-Plugin.ps1 -Plugin "PluginName" -Integration  # Real models
.\scripts\Test-Plugin.ps1 -Plugin "PluginName" -All          # Both
```

**Test-First Workflow:**
1. Check if tests exist for code you're refactoring
2. Evaluate test quality (coverage, thoroughness, accuracy)
3. Improve/create tests BEFORE refactoring
4. Refactor code
5. Verify tests still pass

**Why**: Phase 2 serializer refactoring found 2 bugs immediately through test-first approach.

**Documentation:**
- **Testing Strategy**: `docs/toolkit/TESTING-STRATEGY.md` - When to use unit vs integration tests
- **Setup Guide**: `docs/toolkit/INVENTREE-DEV-SETUP.md` - Complete InvenTree dev setup
- **Quick Summary**: `docs/toolkit/INTEGRATION-TESTING-SUMMARY.md` - Executive overview

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
import { Center, Loader, Alert } from '@mantine/core';
import type { InvenTreePluginContext } from '@inventreedb/ui';

function MyPanel({ context }: { context: InvenTreePluginContext }) {
  
  // Fetch data from your plugin API using React Query
  const { data, isLoading, error } = useQuery({
    queryKey: ['myPluginData', context.id],
    queryFn: async () => {
      const url = '/plugin/my-plugin-slug/data/';
      const response = await context.api.get(url);
      return response.data;
    },
    enabled: !!context.id  // Only fetch when ID exists
  });
  
  if (isLoading) return <Center h={200}><Loader /></Center>;
  if (error) return <Alert color="red">Error loading data</Alert>;
  
  return <div>{data.message}</div>;
}
```

**See `.github/instructions/frontend.react.instructions.md` for complete React Query patterns.**
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
1. Auto-builds plugin (calls Build-Plugin.ps1 first)
2. Copies built plugin to server via SCP
3. SSHs to server and restarts InvenTree

*Note: Use Build-Plugin.ps1 only when you want to build without deploying.*

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

### 3. Documentation Organization Principles

**Single Source of Truth**:
Each document should have ONE focused purpose. Avoid duplicating information across files.

**Good Organization:**
- **TEST-PLAN.md** → Testing execution, strategy, workflow, CI/CD guidance
- **TEST-QUALITY-REVIEW.md** → Test quality analysis, gaps, improvement roadmap
- **REFAC-PLAN.md** → What to refactor, how to refactor, current status, next steps

**When Documents Get Too Large (>500 lines):**
1. Identify duplicate content across multiple files
2. Link to other docs instead of duplicating information
3. Trim historical progress logs (git has full details)
4. Keep focus on "what's next" rather than historical narrative
5. Use git commit messages for comprehensive session summaries

**Examples of Good Cross-Referencing:**
```markdown
## Testing Strategy
See [TEST-PLAN.md](../tests/TEST-PLAN.md) for complete testing workflow and strategy.

## Known Issues
See [TEST-QUALITY-REVIEW.md](TEST-QUALITY-REVIEW.md) for detailed test quality analysis and improvement priorities.
```

**Progress Log Guidelines:**
- Keep progress logs brief (3-5 lines per session)
- Reference git commits for full details
- Focus on key insights learned, not step-by-step narrative
- Example good format:
  ```markdown
  **2025-12-15**: Phase 2 serializers (commit abc1234)
  - Implemented FlatBOMItemSerializer (24 fields)
  - Found 2 bugs through testing
  - Production validated with 117 BOM items
  ```

### 4. Proactive Review Trigger

Suggest documentation review after:
- 5+ feature additions without doc review
- Major refactoring or restructuring
- Before production deployment
- Quarterly (for mature plugins)
- **Document exceeds 500 lines** - Consider reorganizing

### 5. Version Tracking in Docs

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

## Debugging & Deployment Commands

### Server Configuration

**Server keys and SSH settings** are configured in `config/servers.json`. See `config/servers.json.example` for template.

### Deployment Commands

**Deploy plugin to staging:**
```powershell
cd 'C:\PythonProjects\Inventree Plugin Creator\inventree-plugin-ai-toolkit'
.\scripts\Deploy-Plugin.ps1 -Plugin "FlatBOMGenerator" -Server staging
```

### Server Log Viewing (SSH)

**View last 500 lines of InvenTree server logs:**
```powershell
ssh -i "C:\Users\<you>\.ssh\id_rsa_inventree" user@staging.example.com "cd /path/to/inventree && docker-compose logs --tail=500 inventree-server"
```

**Filter logs for specific keywords (e.g., part IPN, debug tags):**
```powershell
ssh -i "C:\Users\<you>\.ssh\id_rsa_inventree" user@staging.example.com "cd /path/to/inventree && docker-compose logs --tail=1000 inventree-server" | Select-String -Pattern 'PART-001|plugin_name|function_name'
```

**Run Django management command inside container:**
```powershell
ssh -i "C:\Users\<you>\.ssh\id_rsa_inventree" user@staging.example.com 'cd /path/to/inventree && docker-compose exec -T inventree-server python manage.py shell -c "from your_plugin.module import function; result=function(123); import pprint; pprint.pprint(result)"'
```

### Local Testing Commands

**Activate plugin virtual environment:**
```powershell
& ".\plugins\FlatBOMGenerator\.venv\Scripts\Activate.ps1"
```

**Run single test file:**
```powershell
python -m unittest plugins/FlatBOMGenerator/flat_bom_generator/tests/test_internal_fab_cut_rollup.py -v
```

**Run all plugin tests (discovery):**
```powershell
python -m unittest discover plugins/FlatBOMGenerator -v
```

### Important Notes

- **SSH keys and server paths**: Use exact values from `config/servers.json` for your environment
- **Complex remote commands**: Wrap outer command in single quotes, escape inner quotes, or use remote scripts
- **Testing workflow**: Run tests locally in plugin venv before deploying to staging

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
