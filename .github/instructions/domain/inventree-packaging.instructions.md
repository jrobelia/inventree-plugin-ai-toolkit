---
applyTo: "**/pyproject.toml,**/setup.py,**/setup.cfg,**/MANIFEST.in"
---

# Python Packaging for InvenTree Plugins

Patterns for configuring Python packages, versioning, and distribution.

---

## pyproject.toml (Single Source of Configuration)

```toml
[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "inventree-my-plugin"
description = "Brief description"
dynamic = ["version"]
authors = [{ name = "Author", email = "author@example.com" }]
readme = "README.md"
license = { text = "MIT" }
requires-python = ">=3.9"

dependencies = [
    # Only YOUR dependencies -- don't duplicate InvenTree's
    "requests>=2.28.0",
]

[project.optional-dependencies]
dev = ["pytest>=7.0", "ruff>=0.1.0"]

# CRITICAL: Entry point (plugin won't load if wrong)
[project.entry-points."inventree_plugins"]
MyPlugin = "my_plugin.core:MyPlugin"

[tool.setuptools.packages.find]
where = [""]
include = ["my_plugin*"]
exclude = ["tests*", "docs*", "frontend*"]

[tool.setuptools.dynamic]
version = { attr = "my_plugin.PLUGIN_VERSION" }
```

---

## Entry Point Format (Most Common Error)

```toml
# Format: PluginClassName = "package.module:ClassName"
MyPlugin = "my_plugin.core:MyPlugin"
```

- Left side: arbitrary label (convention: use the class name).
- Right side: dotted import path, colon, then class name.
- Wrong format = plugin silently fails to load.

---

## Version Management

```python
# __init__.py -- single source of truth
__version__ = "1.0.0"
PLUGIN_VERSION = __version__

# Semantic Versioning:
# MAJOR -- breaking changes (incompatible API)
# MINOR -- new features (backward compatible)
# PATCH -- bug fixes (backward compatible)
```

---

## MANIFEST.in (Include Non-Python Files)

```manifest
include README.md LICENSE
recursive-include my_plugin/static *.js *.css *.map
recursive-exclude frontend *
recursive-exclude tests *
prune .github
global-exclude *.pyc *.pyo .DS_Store
```

---

## Dependency Rules

**Include:** libraries YOUR plugin needs that InvenTree does not provide.
**Exclude:** anything InvenTree already ships (Django, DRF, etc.).
**Pin loosely:** `requests>=2.28.0` not `requests==2.31.0`.

---

## Building and Publishing

```bash
# Build
python -m build
# Creates dist/inventree-my-plugin-1.0.0-py3-none-any.whl

# Check
twine check dist/*

# Publish (test PyPI first)
twine upload --repository testpypi dist/*
twine upload dist/*
```
