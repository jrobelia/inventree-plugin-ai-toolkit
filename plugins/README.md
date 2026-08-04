# Plugins Directory

This folder contains your InvenTree plugin projects.

## Structure

Each plugin you create will be placed here as its own folder:

```
plugins/
├── my-first-plugin/
│   ├── my_first_plugin/      # Python package
│   ├── frontend/             # Frontend code (if applicable)
│   ├── pyproject.toml        # Configuration
│   └── README.md
│
├── another-plugin/
│   └── ...
│
└── third-plugin/
    └── ...
```

## Creating a New Plugin

From a terminal inside the devcontainer, run the plugin-creator CLI:

```bash
cd /workspace/plugins
create-inventree-plugin
```

If `create-inventree-plugin` is not installed, install it first:

```bash
pip install -e /workspace/reference/plugin-creator
```

After `plugin-creator` finishes, copy the toolkit's test scaffold from `plugin-templates/` into the new plugin so unit, integration, and Playwright tests are wired from day one.

## Git Repositories

Each plugin can be its own git repository. After creating a plugin:

```powershell
cd plugins/my-plugin-name
git remote add origin https://github.com/your-org/my-plugin.git
git push -u origin main
```

## Notes

- **Don't** put the entire `plugins/` folder in git
- **Do** put each individual plugin in its own git repo
- The `.gitignore` in the toolkit root handles this correctly
- If you add a plugin to the VS Code workspace (`*.code-workspace`), make sure the `path` matches the actual plugin directory name on disk (e.g. `plugins/inventree-flat-bom-generator`, not `plugins/FlatBOMGenerator`)
