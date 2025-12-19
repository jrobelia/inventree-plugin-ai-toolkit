---
description: 'Python packaging configuration - setup.py, pyproject.toml, MANIFEST.in, versioning'
applyTo: ['**/setup.py', '**/setup.cfg', '**/pyproject.toml', '**/MANIFEST.in']
---

# Python Packaging Configuration

**Source**: Plugin creator templates (pyproject.toml, setup.cfg, MANIFEST.in)  
**Standards**: PEP 517, PEP 518, PEP 621

## Modern Packaging (pyproject.toml)

```toml
# pyproject.toml - Single source of configuration

[build-system]
requires = ["setuptools>=61.0", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "inventree-my-plugin"  # PyPI package name (lowercase, hyphens)
description = "Brief plugin description"
dynamic = ["version"]  # Read from __init__.py
authors = [
    { name = "Your Name", email = "you@example.com" }
]
readme = "README.md"
license = { text = "MIT" }
keywords = ["inventree", "plugin", "manufacturing"]
requires-python = ">=3.9"

# Plugin dependencies
dependencies = [
    # Core dependencies only - don't duplicate InvenTree's
    "requests>=2.28.0",  # Example external API library
]

# Optional development dependencies
[project.optional-dependencies]
dev = [
    "pytest>=7.0",
    "black>=22.0",
    "ruff>=0.1.0",
]

classifiers = [
    "Development Status :: 4 - Beta",
    "Programming Language :: Python :: 3",
    "Programming Language :: Python :: 3.9",
    "Programming Language :: Python :: 3.10",
    "Programming Language :: Python :: 3.11",
    "Programming Language :: Python :: 3.12",
    "Operating System :: OS Independent",
    "Framework :: InvenTree",
    "License :: OSI Approved :: MIT License",
]

[project.urls]
Homepage = "https://github.com/yourusername/inventree-my-plugin"
Documentation = "https://github.com/yourusername/inventree-my-plugin#readme"
Issues = "https://github.com/yourusername/inventree-my-plugin/issues"
Source = "https://github.com/yourusername/inventree-my-plugin"

# Plugin entry point (CRITICAL)
[project.entry-points."inventree_plugins"]
MyPlugin = "my_plugin.core:MyPlugin"
# Format: PluginClassName = "package.module:ClassName"

[tool.setuptools.packages.find]
where = [""]  # Look for packages in repo root
include = ["my_plugin*"]  # Only include plugin package
exclude = ["tests*", "docs*"]  # Exclude test and doc files

# Dynamic version from __init__.py
[tool.setuptools.dynamic]
version = { attr = "my_plugin.PLUGIN_VERSION" }

# Code quality tools
[tool.ruff]
line-length = 120
target-version = "py39"
exclude = [
    ".git",
    "__pycache__",
    "build",
    "dist",
    "venv",
    "frontend/node_modules",
]

[tool.ruff.lint]
select = [
    "E",   # pycodestyle errors
    "W",   # pycodestyle warnings
    "F",   # pyflakes
    "I",   # isort
    "N",   # pep8-naming
    "UP",  # pyupgrade
]
ignore = [
    "E501",  # line too long (handled by formatter)
]

[tool.pytest.ini_options]
testpaths = ["tests"]
python_files = ["test_*.py"]
python_classes = ["Test*"]
python_functions = ["test_*"]
```

## Version Management

**__init__.py** (Single source of truth):
```python
"""My Plugin for InvenTree."""

# Version is read by setuptools and plugin system
__version__ = "1.0.0"
PLUGIN_VERSION = __version__  # Alias for InvenTree

# Semantic Versioning: MAJOR.MINOR.PATCH
# - MAJOR: Breaking changes (incompatible API changes)
# - MINOR: New features (backward compatible)
# - PATCH: Bug fixes (backward compatible)
```

**Version Constraints**:
```python
# core.py - Specify supported InvenTree versions
class MyPlugin(InvenTreePlugin):
    VERSION = PLUGIN_VERSION  # From __init__.py
    
    # Optional: Constrain InvenTree version
    MIN_VERSION = '0.18.0'  # Minimum InvenTree version
    MAX_VERSION = '2.0.0'   # Maximum InvenTree version
```

## MANIFEST.in (Include Non-Python Files)

```manifest
# Include documentation
include README.md
include LICENSE
include CHANGELOG.md

# Include plugin metadata
include pyproject.toml
include setup.cfg

# Include compiled frontend
recursive-include my_plugin/static *.js *.css *.map

# Exclude development files
exclude vite.config.ts
exclude tsconfig.json
recursive-exclude frontend *
recursive-exclude tests *
recursive-exclude docs *
prune .github
prune __pycache__
global-exclude *.pyc
global-exclude *.pyo
global-exclude .DS_Store
```

## Building Distributions

```bash
# Install build tools
pip install build twine

# Build distributions
python -m build
# Creates:
#   dist/inventree-my-plugin-1.0.0.tar.gz  (source)
#   dist/inventree_my_plugin-1.0.0-py3-none-any.whl  (wheel)

# Check distributions
twine check dist/*

# Test install locally
pip install dist/inventree_my_plugin-1.0.0-py3-none-any.whl
```

## Publishing to PyPI

```bash
# Test PyPI (recommended first)
twine upload --repository testpypi dist/*

# Production PyPI
twine upload dist/*

# Or use toolkit script
.\scripts\Deploy-Plugin.ps1 -Plugin "MyPlugin" -Server production
```

## Dependency Best Practices

**What to include**:
```toml
dependencies = [
    # ✅ GOOD: Libraries your plugin needs
    "requests>=2.28.0",      # External API calls
    "pillow>=9.0.0",         # Image processing
    "python-dateutil>=2.8",  # Date parsing
]
```

**What NOT to include**:
```toml
dependencies = [
    # ❌ BAD: Already in InvenTree
    "django>=4.0",           # InvenTree provides Django
    "djangorestframework",   # InvenTree provides DRF
    "inventree",             # Plugin runs inside InvenTree
    
    # ❌ BAD: Development tools (use optional-dependencies)
    "pytest",
    "black",
]
```

**Version Pinning Strategy**:
```toml
# ✅ GOOD: Minimum version with compatibility
"requests>=2.28.0,<3.0"  # Allow updates, block breaking changes

# ⚠️ CAUTION: Exact pinning (only if absolutely necessary)
"library==1.2.3"  # Blocks all updates

# ❌ BAD: No version constraint
"requests"  # Could break with major updates
```

## Entry Point (CRITICAL)

**The entry point tells InvenTree where to find your plugin**:

```toml
[project.entry-points."inventree_plugins"]
MyPlugin = "my_plugin.core:MyPlugin"
#  ^          ^            ^       ^
#  |          |            |       Class name
#  |          |            Module path
#  |          Package name
#  Entry point name (can differ from class)
```

**Common mistakes**:
```toml
# ❌ WRONG: Module path has .py extension
MyPlugin = "my_plugin.core.py:MyPlugin"

# ❌ WRONG: Package name typo
MyPlugin = "myplugin.core:MyPlugin"  # Package is my_plugin, not myplugin

# ❌ WRONG: Class name typo
MyPlugin = "my_plugin.core:MyPluginClass"  # Class is MyPlugin

# ✅ CORRECT
MyPlugin = "my_plugin.core:MyPlugin"
```

**Testing entry point**:
```bash
# After installing plugin
python -c "from my_plugin.core import MyPlugin; print(MyPlugin.NAME)"
# Should print plugin name

# Check entry points
pip show -f inventree-my-plugin | grep inventree_plugins
```

## Package Structure

```
my-plugin/
├── pyproject.toml          # Main config (PEP 621)
├── setup.cfg               # Optional legacy config
├── MANIFEST.in             # Non-Python files to include
├── README.md               # PyPI description
├── LICENSE                 # License text
├── CHANGELOG.md            # Version history
│
├── my_plugin/              # Main package
│   ├── __init__.py         # Version: __version__ = "1.0.0"
│   ├── core.py             # Plugin class
│   ├── views.py            # API endpoints
│   ├── serializers.py      # DRF serializers
│   └── static/             # Compiled frontend
│       └── Panel.js
│
├── frontend/               # Frontend source (not packaged)
│   ├── src/
│   ├── package.json
│   └── vite.config.ts
│
├── tests/                  # Tests (not packaged)
│   └── test_*.py
│
└── dist/                   # Built distributions
    ├── *.tar.gz
    └── *.whl
```

## Versioning Strategy

**Semantic Versioning** (MAJOR.MINOR.PATCH):

```python
# Breaking changes (API changes, removed features)
"1.0.0" → "2.0.0"

# New features (backward compatible)
"1.0.0" → "1.1.0"

# Bug fixes (backward compatible)
"1.0.0" → "1.0.1"

# Pre-release versions
"1.0.0-alpha.1"  # Alpha release
"1.0.0-beta.2"   # Beta release
"1.0.0-rc.1"     # Release candidate
```

**InvenTree Version Constraints**:
```python
class MyPlugin(InvenTreePlugin):
    VERSION = "1.0.0"
    
    # Strategy 1: No constraints (recommended for simple plugins)
    # Works with any InvenTree version
    
    # Strategy 2: Minimum version only
    MIN_VERSION = "0.18.0"  # Uses features from 0.18+
    
    # Strategy 3: Version range (use carefully)
    MIN_VERSION = "0.18.0"
    MAX_VERSION = "2.0.0"   # Tested up to 2.0
```

## Industry Best Practices

**Package Naming**:
- PyPI: lowercase, hyphens (`inventree-my-plugin`)
- Python: lowercase, underscores (`my_plugin`)
- Class: PascalCase (`MyPlugin`)

**Metadata**:
- Clear description (< 200 chars)
- Appropriate classifiers (Python versions, license, status)
- Links to homepage, docs, issues
- README with install instructions

**Dependencies**:
- Minimum versions with compatibility range
- Don't duplicate InvenTree dependencies
- Pin breaking changes (`<3.0`)
- Document why each dependency needed

**Versioning**:
- Follow semantic versioning
- Update CHANGELOG.md
- Git tag releases
- Test before publishing

**Distribution**:
- Build both source (.tar.gz) and wheel (.whl)
- Test install from distributions
- Publish to TestPyPI first
- Include all necessary files in MANIFEST.in

---

**Entry point issues?** Check package/module/class names match exactly. Test with `python -c "from pkg.mod import Class"`.
