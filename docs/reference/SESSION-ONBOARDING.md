# Plugin Development Session Onboarding

**Audience:** Developers | **Category:** Workflow Guide | **Purpose:** Step-by-step plugin development process | **Last Updated:** 2026-07-22

---

This document provides the exact, reproducible process for InvenTree plugin development using the devcontainer. Follow these steps for each development session.

---

**Prerequisites:** Complete the initial setup in [SETUP.md](../../SETUP.md) before starting your first development session.

---

## Starting a Development Session

### Step 1: Open the Devcontainer

```bash
cd inventree-plugin-ai-toolkit
code .
```

In VS Code:
1. Press `Ctrl+Shift+P`
2. Run: `Dev Containers: Reopen in Container`

### Step 2: Start InvenTree Server

In the devcontainer terminal:
```bash
cd /workspace/reference/inventree-source
invoke dev.server
```

The InvenTree server will be available at http://localhost:8001 on your host machine.

### Step 3: Start Plugin Dev Server (Optional)

For frontend development with hot reload:
```bash
cd /workspace/plugins/your-plugin/frontend
npm run dev
```

---

## Plugin Development Workflow

### Creating a New Plugin

```bash
cd /workspace/plugin-creator
python plugin_creator/main.py
```

Follow the interactive prompts to create your plugin. The plugin will be created in `/workspace/plugins/`.

### Working on Existing Plugin

```bash
cd /workspace/plugins/your-plugin-name
```

**Backend development:**
- Edit Python files in the plugin directory
- Changes require InvenTree server restart
- Run tests: `python -m pytest tests/unit`

**Frontend development:**
- Edit TypeScript/React files in `frontend/` directory
- Changes automatically reload via Vite dev server
- Run linter: `npm run lint`

### Running Tests

**Unit tests (fast, no database):**
```bash
cd /workspace/plugins/your-plugin-name
python -m pytest tests/unit
```

**Integration tests (requires InvenTree dev environment):**
```bash
cd /workspace/plugins/your-plugin-name
python -m pytest tests/integration
```

**E2E tests with Playwright (for frontend):**

Playwright tests run **locally on your host machine** and access the InvenTree dev server in the devcontainer via forwarded ports.

```bash
# On host machine (not in devcontainer)
cd /workspace/plugins/your-plugin-name/frontend
npm install
npx playwright install

# Windows: No additional steps needed
# Linux: sudo npx playwright install-deps

npm run test:e2e
```

**Note:** E2E tests require the InvenTree server running in the devcontainer. Start it first:
```bash
# In devcontainer terminal
cd /workspace/reference/inventree-source
invoke dev.server
```

The devcontainer forwards the InvenTree server to http://localhost:8001 on your host machine.

**All tests (deterministic chain):**
```bash
cd /workspace/plugins/your-plugin-name
./test-all.sh
```

### Code Quality

**Format code:**
```bash
# Python
ruff check .
ruff format .

# TypeScript/React
npm run lint
npm run lint:fix
```

**Pre-commit hooks:**
```bash
pre-commit install  # One-time setup
pre-commit run --all-files  # Run manually
```

---

## Building and Deployment

### Building Plugin

```bash
cd /workspace/plugins/your-plugin-name
python -m build
```

This creates a `.whl` file in `dist/` directory.

### Manual Deployment

**To staging server:**
1. Build the plugin: `python -m build`
2. Copy `.whl` file to staging server
3. SSH to staging server
4. Install: `pip install your-plugin.whl`
5. Restart InvenTree: `systemctl restart inventree` (or equivalent)
6. Test plugin functionality in staging UI
7. Check InvenTree logs for errors

**To production server:**
- Only after thorough staging testing
- Follow same steps as staging
- Monitor production logs closely

---

## Common Development Tasks

### Adding a New API Endpoint

1. Create endpoint in `api.py` or `views.py`
2. Add URL routing in `api/urls.py`
3. Add serializer if needed
4. Write unit test for endpoint
5. Restart InvenTree server
6. Test endpoint via browser or API client

### Adding a New Frontend Panel

1. Create React component in `frontend/src/`
2. Register panel in plugin's `setup.py` or plugin class
3. Add API integration if needed
4. Test with hot reload (no restart needed)
5. Run linter: `npm run lint`

### Debugging Issues

**Backend issues:**
- Check InvenTree server logs in terminal
- Enable Django debug mode (already enabled in devcontainer)
- Use Python debugger: `import pdb; pdb.set_trace()`

**Frontend issues:**
- Check browser console for errors
- Check Vite dev server logs
- Use React DevTools browser extension

**Database issues:**
- Access PostgreSQL via Docker: `docker exec -it inventree-plugin-ai-toolkit_devcontainer-db-1 psql -U inventree_user -d inventree`
- Reset database: `cd /workspace/reference/inventree-source && invoke dev.reset-db`

---

## Session Cleanup

### Stopping Servers

**Stop InvenTree server:**
- Press `Ctrl+C` in the terminal running `invoke dev.server`

**Stop plugin dev server:**
- Press `Ctrl+C` in the terminal running `npm run dev`

### Closing Devcontainer

In VS Code:
1. Press `Ctrl+Shift+P`
2. Run: `Dev Containers: Close Remote Connection`

Or simply close VS Code.

---

## Troubleshooting

### Container won't start

**Issue:** "No space left on device"
```bash
# Free up Docker space
docker system prune -a
```

**Issue:** "Workspace does not exist"
```bash
# Rebuild container
# In VS Code: Dev Containers: Rebuild Container
```

### Server won't start

**Issue:** Database connection error
```bash
# Check database container
docker ps
# Should see inventree-plugin-ai-toolkit_devcontainer-db-1 running

# Restart database
docker restart inventree-plugin-ai-toolkit_devcontainer-db-1
```

**Issue:** Port already in use
```bash
# Check what's using port 8001
netstat -ano | findstr :8001  # Windows
lsof -i :8001  # Linux/Mac

# Change port in .devcontainer/docker-compose.yml if needed
```

### Tests failing

**Issue:** Module not found
```bash
# Ensure virtual environment is activated
source /workspace/reference/inventree-source/dev/venv/bin/activate
```

**Issue:** Database errors
```bash
# Reset database
cd /workspace/reference/inventree-source
invoke dev.reset-db
```

---

## Quick Reference

**Start development session:**
```bash
code .  # Open in VS Code
# Dev Containers: Reopen in Container
cd /workspace/reference/inventree-source && invoke dev.server
cd /workspace/plugins/your-plugin/frontend && npm run dev
```

**Run tests:**
```bash
cd /workspace/plugins/your-plugin
python -m pytest
```

**Build plugin:**
```bash
cd /workspace/plugins/your-plugin
python -m build
```

**Format code:**
```bash
ruff check . && ruff format .
npm run lint
```

---

## AI-Assisted Development Skills

The toolkit includes structured development workflows in `docs/skills/`:

**Creating a new plugin:**
- See `docs/skills/new-inventree-plugin.md`
- Covers plugin-creator usage, configuration, and initial setup
- Includes verification checklist

**Improving existing plugins:**
- See `docs/skills/improve-inventree-plugin.md`
- Provides change verification loop
- Ensures proper testing before committing

These skills are useful for both AI agents and manual development.

---

## Best Practices

1. **Always test locally before deployment**
2. **Use staging server for integration testing**
3. **Commit frequently with clear messages**
4. **Run tests before committing**
5. **Use hot reload for frontend development**
6. **Restart server only for backend changes**
7. **Monitor logs during development**
8. **Keep database changes in migrations**
9. **Document complex logic with comments**
10. **Review AI-generated code before committing**

---

## Getting Help

- **InvenTree Plugin Docs:** https://docs.inventree.org/en/latest/plugins/
- **InvenTree API Reference:** https://docs.inventree.org/en/latest/api/api/
- **Devcontainer Issues:** Check SETUP.md troubleshooting section
- **Plugin Issues:** Check InvenTree GitHub issues and discussions

---

Happy plugin development!
