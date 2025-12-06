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

From the toolkit root, run:

```powershell
.\scripts\New-Plugin.ps1
```

The new plugin will automatically be created in this directory.

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
