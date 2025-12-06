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

## Adding Reference Plugins

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

## For AI Agents

When users ask about plugin features or patterns, check this folder for working examples that demonstrate:
- Custom panels
- Dashboard widgets
- API endpoints
- Settings configuration
- Database models
- Scheduled tasks
- And more...
