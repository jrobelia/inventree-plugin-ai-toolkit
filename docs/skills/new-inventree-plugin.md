# New InvenTree Plugin Skill

**Purpose:** Agent-driven scaffolding for new InvenTree plugins

---

## Overview

This skill guides an AI agent through the process of creating a new InvenTree plugin from scratch using the plugin-creator tool.

---

## Prerequisites

- Devcontainer is open and running
- Plugin-creator submodule is initialized
- User has a clear description of the plugin functionality

---

## Workflow

### 1. Understand Requirements

Ask the user to describe:
- Plugin purpose and functionality
- Required mixins (e.g., EventMixin, NavigationMixin)
- Frontend requirements (React UI, panels, buttons)
- API endpoints needed
- Database models (if any)

### 2. Run Plugin-Creator

```bash
cd /workspace/plugin-creator
python plugin_creator/main.py
```

Guide the user through the interactive prompts:
- Plugin name (kebab-case)
- Human-readable name
- Description
- Author information
- License (default: MIT)
- Mixins selection
- Frontend inclusion (yes/no)

### 3. Configure Plugin Development

After plugin creation:
```bash
cd /workspace/plugins/your-plugin-name
```

**Backend setup:**
- Review generated `core.py` structure
- Add required mixins to plugin class
- Configure plugin settings in `__init__.py`

**Frontend setup (if included):**
- Review generated React components
- Configure Vite for development
- Test hot reload: `cd frontend && npm run dev`

### 4. Set Up Code Quality

```bash
# Python
python -m venv .venv
source .venv/bin/activate
pip install pre-commit
pre-commit install

# Frontend
cd frontend
npm install
```

### 5. Initial Test

```bash
# Unit tests
python -m pytest tests/unit

# Frontend lint
npm run lint
```

### 6. Document Plugin

Update `README.md` with:
- Plugin purpose
- Features
- Installation instructions
- Usage examples
- Configuration options

---

## Common Patterns

### Adding a Custom Panel

1. Create panel component in `frontend/src/`
2. Register in plugin's `setup.py` or core
3. Add navigation entry if using NavigationMixin

### Adding an API Endpoint

1. Create endpoint in `api.py` or `views.py`
2. Add URL routing in `api/urls.py`
3. Create serializer if needed
4. Write unit test

### Adding Database Models

1. Create model in `models.py`
2. Create migration
3. Register with InvenTree admin if needed

---

## Verification Checklist

- [ ] Plugin-creator ran successfully
- [ ] Plugin directory created in `/workspace/plugins/`
- [ ] Plugin class configured with required mixins
- [ ] Frontend hot reload working (if applicable)
- [ ] Code quality tools installed (pre-commit, biome)
- [ ] Unit tests pass
- [ ] README.md updated
- [ ] Plugin loads in InvenTree (test in devcontainer)

---

## Troubleshooting

**Plugin not appearing in InvenTree:**
- Check plugin is in correct directory
- Verify plugin is enabled in InvenTree settings
- Check InvenTree logs for errors

**Frontend not loading:**
- Verify plugin dev server is running
- Check CORS configuration
- Check browser console for errors

**Tests failing:**
- Ensure virtual environment is activated
- Check dependencies are installed
- Verify test fixtures are correct
