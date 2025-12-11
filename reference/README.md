# Reference Plugins

This folder contains example/reference plugins for AI agents and developers to learn from.

## Purpose

- **Examples** - Working plugins that demonstrate patterns and best practices
- **Reference** - Code to study when implementing similar features
- **Learning** - Complete implementations to understand how things work

## Important Notes

⚠️ **Plugins in this folder are NOT built or deployed** by the toolkit scripts.

The build and deploy scripts (`Build-Plugin.ps1`, `Deploy-Plugin.ps1`) only operate on plugins in the `plugins/` folder.

## How to Use

1. **Study the code** - Open plugins here to see how features are implemented
2. **Copy patterns** - Use as templates for your own plugins
3. **Ask AI** - Point Copilot to these examples when asking questions

## Adding Reference Material

### Reference Plugins

Simply copy or move complete plugin folders into this directory:

```
reference/
├── my-example-plugin/
│   ├── my_example_plugin/
│   ├── frontend/
│   └── pyproject.toml
└── another-reference/
    └── ...
```

### InvenTree Source Code

Clone the InvenTree source code for reference when developing plugins:

```powershell
cd reference
git clone https://github.com/inventree/InvenTree.git inventree-source
```

**Why include InvenTree source?**
- See how built-in features are implemented
- Reference Django models and API endpoints
- Understand InvenTree's architecture and patterns
- Study frontend components and UI patterns
- Check plugin base classes and mixins

**Recommended folders to study:**
- `InvenTree/plugin/` - Plugin framework base classes
- `InvenTree/part/` - Part model and related code
- `InvenTree/order/` - Order management implementation
- `InvenTree/stock/` - Stock tracking system
- `src/frontend/` - React frontend source code

### Other Reference Software

You can also add other useful reference material:

```
reference/
├── inventree-source/         # InvenTree core codebase
├── example-plugins/          # Third-party plugin examples
├── django-patterns/          # Django code patterns
└── react-components/         # React component examples
```

## For AI Agents

When users ask about plugin features or patterns, check this folder for working examples and reference code:

**Example Plugins** - Demonstrate:
- Custom panels
- Dashboard widgets
- API endpoints
- Settings configuration
- Database models
- Scheduled tasks
- And more...

**InvenTree Source** - Reference for:
- Plugin base classes and mixins
- InvenTree models (Part, Stock, Order, etc.)
- API endpoint patterns
- Frontend component architecture
- Django patterns and best practices

**How to reference:**
```
#file:reference/inventree-source/InvenTree/plugin/base/ui/mixins.py
Show me how UserInterfaceMixin works
```
