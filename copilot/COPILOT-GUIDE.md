# GitHub Copilot Guide for InvenTree Plugin Development

**AI Assistant Role:** You are a Python and InvenTree plugin development expert. You understand InvenTree's plugin architecture, mixins, hooks, and best practices. When helping the user, provide specific InvenTree-focused guidance and working code examples.

This guide helps GitHub Copilot assist you effectively when developing InvenTree plugins.

## 📋 Quick Start

### Creating a New Plugin with Copilot

**Recommended workflow for beginners:**

1. Open Copilot Chat in VS Code
2. Reference the guided creation template:
   ```
   @workspace I want to create a new InvenTree plugin. Follow the guided creation process in copilot/copilot-guided-creation.md
   ```
3. Copilot will:
   - Ask what your plugin should do
   - Recommend which mixins you need (with explanations)
   - Provide all answers in a formatted, copy/paste friendly list
   - Show you the command to run: `.\scripts\New-Plugin.ps1`
   - Help you understand InvenTree architecture
   
   **Note:** The plugin-creator is interactive only - Copilot provides answers you manually copy/paste at each prompt.

**Why use this approach:**
- ✅ Don't need to know InvenTree mixins upfront
- ✅ Intelligent recommendations based on your requirements
- ✅ Copilot explains WHY each feature is needed
- ✅ Natural language description → working plugin

See `copilot/copilot-guided-creation.md` for comprehensive prompts.

---

## 📋 Table of Contents
1. [Project Overview](#project-overview)
2. [Technology Stack](#technology-stack)
3. [File Structure](#file-structure)
4. [Common Patterns](#common-patterns)
5. [Copilot Prompts](#copilot-prompts)
6. [Troubleshooting](#troubleshooting)

---

## 🎯 Project Overview

**What is this?**
A development toolkit for creating and deploying InvenTree plugins. InvenTree is an open-source inventory management system, and plugins extend its functionality.

**Plugin Types:**
- **Backend plugins** (Python): Add business logic, API endpoints, scheduled tasks
- **Frontend plugins** (React/TypeScript): Add custom UI panels, dashboards, settings pages
- **Full-stack plugins**: Combine both backend and frontend

**Development Workflow:**
```
Create Plugin (with Copilot) → Edit Code → Build → Deploy to Staging → Test → Deploy to Production
```

---

## 🛠️ Technology Stack

### Backend (Python)
- **Framework**: Django (InvenTree is built on Django)
- **Language**: Python 3.9+
- **Key Libraries**:
  - `django-rest-framework` - API endpoints
  - `inventree` - Core InvenTree functionality

### Frontend (TypeScript/React)
- **Language**: TypeScript
- **Framework**: React 19+
- **UI Library**: Mantine 8+ (component library like Material-UI)
- **Build Tool**: Vite 6+
- **Translation**: Lingui (i18n support)

### Key Concepts
- **Mixins**: Plugins use mixins to add capabilities (like SettingsMixin, UrlsMixin, UserInterfaceMixin)
- **API Context**: Frontend components receive context from InvenTree with useful data and functions

---

## 📁 File Structure

### Toolkit Folders
- `plugins/` - Your active development plugins (built and deployed by scripts)
- `reference/` - Example plugins for learning (NOT built or deployed)
- `scripts/` - PowerShell automation tools
- `config/` - Server and toolkit configuration

### Plugin Root Structure
```
plugins/my-plugin/              # Active development plugin
├── my_custom_plugin/          # Python package (snake_case)
│   ├── __init__.py            # Version info
│   ├── core.py                # ⭐ Main plugin class - EDIT THIS
│   ├── models.py              # Database models (if using AppMixin)
│   ├── admin.py               # Django admin interface
│   ├── apps.py                # Django app config
│   ├── views.py               # API endpoints (if using UrlsMixin)
│   ├── serializers.py         # API serializers (if using UrlsMixin)
│   ├── migrations/            # Database migrations
│   └── static/                # ⚠️ AUTO-GENERATED - don't edit!
├── frontend/                  # Frontend code (if using UserInterfaceMixin)
│   ├── src/
│   │   ├── Panel.tsx          # ⭐ Custom panels - EDIT THIS
│   │   ├── Dashboard.tsx      # ⭐ Dashboard widgets - EDIT THIS
│   │   ├── Settings.tsx       # ⭐ Settings page - EDIT THIS
│   │   ├── locale.tsx         # Translation wrapper
│   │   └── locales/           # Translation files
│   ├── package.json           # Frontend dependencies
│   ├── vite.config.ts         # Build configuration
│   └── tsconfig.json          # TypeScript configuration
├── pyproject.toml             # Python package configuration
├── README.md                  # Plugin documentation
└── .github/workflows/         # CI/CD (GitHub Actions)
```

### What to Edit vs What's Auto-Generated

**✅ EDIT THESE:**
- `core.py` - Main plugin logic
- `views.py` - API endpoints
- `models.py` - Database schema
- `serializers.py` - API data formats
- `frontend/src/*.tsx` - UI components
- `pyproject.toml` - Dependencies
- `README.md` - Documentation

**⛔ DON'T EDIT:**
- `static/` folder - Generated from frontend build
- `migrations/` - Generated by Django
- `node_modules/` - npm packages
- `dist/` and `build/` - Build artifacts

---

## 🎨 Common Patterns

### Pattern 1: Add a Plugin Setting

**File:** `core.py`

```python
class MyPlugin(SettingsMixin, InvenTreePlugin):
    
    SETTINGS = {
        'API_KEY': {
            'name': 'API Key',
            'description': 'Your service API key',
            'default': '',
            'protected': True,  # Hide value in UI
        },
        'MAX_ITEMS': {
            'name': 'Maximum Items',
            'description': 'Maximum number of items to process',
            'default': 100,
            'validator': int,
        },
        'ENABLE_FEATURE': {
            'name': 'Enable Feature',
            'description': 'Enable the special feature',
            'default': False,
            'validator': bool,
        }
    }
    
    def get_setting(self, key):
        """Get a setting value"""
        return self.get_setting(key)
```

### Pattern 2: Add a Custom API Endpoint

**File:** `views.py`

```python
from rest_framework import permissions
from rest_framework.response import Response
from rest_framework.views import APIView

class CustomDataView(APIView):
    """Custom API endpoint"""
    
    permission_classes = [permissions.IsAuthenticated]
    
    def get(self, request):
        """Handle GET request"""
        data = {
            'message': 'Hello from plugin',
            'user': request.user.username,
        }
        return Response(data, status=200)
```

**File:** `core.py` (register the URL)

```python
class MyPlugin(UrlsMixin, InvenTreePlugin):
    
    def setup_urls(self):
        from django.urls import path
        from .views import CustomDataView
        
        return [
            path('custom-data/', CustomDataView.as_view(), name='custom-data'),
        ]
```

### Pattern 3: Add a Custom Panel to Part Page

**File:** `frontend/src/Panel.tsx`

```typescript
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

**File:** `core.py` (register the panel)

```python
class MyPlugin(UserInterfaceMixin, InvenTreePlugin):
    
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

### Pattern 4: Fetch Data from Plugin API in Frontend

**File:** `frontend/src/Panel.tsx`

```typescript
import { useQuery } from '@tanstack/react-query';
import type { InvenTreePluginContext } from '@inventreedb/ui';

function MyPanel({ context }: { context: InvenTreePluginContext }) {
  
  // Fetch data from your plugin API
  const apiQuery = useQuery(
    {
      queryKey: ['myPluginData', context.id],
      queryFn: async () => {
        const url = '/plugin/my-plugin-slug/custom-data/';
        const response = await context.api.get(url);
        return response.data;
      }
    },
    context.queryClient
  );
  
  if (apiQuery.isLoading) return <Text>Loading...</Text>;
  if (apiQuery.error) return <Text>Error loading data</Text>;
  
  return (
    <div>
      <Text>{apiQuery.data.message}</Text>
    </div>
  );
}
```

### Pattern 5: Access Plugin Settings in Frontend

**File:** `core.py`

```python
def get_ui_panels(self, request, context: dict, **kwargs):
    panels.append({
        'key': 'my-panel',
        'title': 'My Panel',
        'source': self.plugin_static_file('Panel.js:renderMyPanel'),
        'context': {
            'settings': self.get_settings_dict(),  # Pass settings to frontend
        }
    })
```

**File:** `frontend/src/Panel.tsx`

```typescript
function MyPanel({ context }: { context: InvenTreePluginContext }) {
  const settings = context.context?.settings;  // Access settings
  const apiKey = settings?.API_KEY;
  
  return <Text>Max Items: {settings?.MAX_ITEMS}</Text>;
}
```

---

## 💬 Copilot Prompts

### Creating New Features

**Prompt: Add a new plugin setting**
```
@workspace Add a new setting to my InvenTree plugin in core.py:
- Setting name: EMAIL_NOTIFICATIONS
- Type: boolean
- Default: true
- Description: "Enable email notifications for events"
Follow the pattern in the existing SETTINGS dictionary.
```

**Prompt: Create a custom API endpoint**
```
@workspace Create a new API endpoint in my InvenTree plugin that:
- Path: /plugin/my-plugin/calculate/
- Method: POST
- Accepts: part_id (integer)
- Returns: JSON with calculated_value (float)
- Requires authentication
Use Django REST Framework patterns from the existing views.py
```

**Prompt: Add a custom panel**
```
@workspace Create a new custom panel for InvenTree Part pages that:
- Shows a table of recent stock movements for that part
- Uses Mantine Table component
- Fetches data from InvenTree API endpoint: /api/stock/?part={id}
- Add it to frontend/src/Panel.tsx
```

### Debugging

**Prompt: Debug frontend build error**
```
I'm getting this error when building my InvenTree plugin frontend:
[PASTE ERROR]

My plugin uses:
- React 19
- Mantine 8
- Vite 6
- TypeScript

Help me fix it. Show me what file to edit and what changes to make.
```

**Prompt: Fix Python import error**
```
My InvenTree plugin is failing with this error:
[PASTE ERROR]

The plugin is located at: plugins/my-plugin/
It uses these mixins: SettingsMixin, UrlsMixin, UserInterfaceMixin

Help me diagnose and fix the import issue.
```

### Understanding Code

**Prompt: Explain context object**
```
@workspace Explain what properties are available in the InvenTreePluginContext
object that gets passed to frontend components in Panel.tsx.
List the most useful ones for accessing part data.
```

**Prompt: Understand mixins**
```
@workspace I see my plugin uses "UrlsMixin" in core.py.
Explain what this mixin does and show me an example of how to use it
to add a custom API endpoint.
```

---

## 🐛 Troubleshooting

### Problem: Frontend won't build

**Copilot Prompt:**
```
My InvenTree plugin frontend build is failing with:
[PASTE npm run build OUTPUT]

Plugin structure:
- Uses Mantine UI components
- Has Panel.tsx and Dashboard.tsx
- package.json lists these dependencies: [LIST KEY DEPENDENCIES]

What's wrong and how do I fix it?
```

### Problem: Plugin not showing in InvenTree

**Copilot Prompt:**
```
I deployed my plugin to InvenTree but it doesn't appear in the plugin list.

Plugin details:
- Name: MyCustomPlugin
- Location: plugins/my_custom_plugin/
- Has __init__.py with PLUGIN_VERSION
- Has core.py with plugin class

What could be wrong? Show me what to check.
```

### Problem: Panel not rendering

**Copilot Prompt:**
```
My custom panel is registered but doesn't show up on the Part page.

core.py get_ui_panels returns:
[PASTE YOUR CODE]

Panel.tsx exports:
[PASTE YOUR CODE]

What's missing?
```

---

## 🎓 Learning More

### Ask Copilot to Explain Concepts

**Example Prompts:**
- "Explain how InvenTree plugin mixins work"
- "What's the difference between a panel and a dashboard item in InvenTree plugins?"
- "How do I make my plugin API endpoint return custom data about a part?"
- "Show me how to use Mantine components in my InvenTree plugin frontend"

### Ask for Examples

**Example Prompts:**
- "Show me an example of a plugin that adds a scheduled task"
- "Give me an example of using the EventMixin to listen for part creation"
- "Create an example dashboard widget that shows statistics"

---

## 📚 Quick Reference

### InvenTree API Endpoints (Most Useful)
```
/api/part/              # Parts
/api/stock/             # Stock items  
/api/company/           # Companies (suppliers/customers)
/api/order/purchase/    # Purchase orders
/api/build/             # Build orders
/api/plugin/            # Your plugin APIs go here
```

### Mantine Components (Most Useful)
```typescript
import { 
  Alert,      // Colored notification boxes
  Button,     // Buttons
  Text,       // Text display
  Title,      // Headings
  Table,      // Data tables
  Stack,      // Vertical layout
  Group,      // Horizontal layout
  Card,       // Card container
  Badge,      // Small labels
  Loader,     // Loading spinner
} from '@mantine/core';
```

### Context Properties (Frontend)
```typescript
context.id              // Current model ID (e.g., part ID)
context.model           // Model type (e.g., 'part', 'stock')
context.instance        // Full object data
context.user            // Current user info
context.api             // API client for making requests
context.navigate()      // Navigate to another page
context.theme           // Theme colors
context.locale          // Current language
```

---

## 🚀 Quick Start Checklist

When starting a new feature, tell Copilot:

✅ "I'm working on an InvenTree plugin"
✅ "The plugin uses these mixins: [list them]"
✅ "I want to [describe what you want to do]"
✅ "Follow the patterns in this repository"

**Example Complete Prompt:**
```
@workspace I'm working on an InvenTree plugin that uses SettingsMixin and UrlsMixin.
I want to add a new API endpoint that accepts a part ID and returns custom calculated data.
The endpoint should be at /plugin/my-plugin/calculate/ and require authentication.
Follow the patterns in views.py and core.py in this workspace.
```

This gives Copilot all the context it needs to help you effectively!
