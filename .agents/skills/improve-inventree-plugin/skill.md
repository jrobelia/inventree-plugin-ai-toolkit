---
name: improve-inventree-plugin
description: Use when modifying, extending, or fixing an existing InvenTree plugin. Guides the change verification loop from analysis through commit.
---

# Improve InvenTree Plugin Skill

**Purpose:** Change verification loop for existing InvenTree plugins

---

## Overview

This skill guides an AI agent through the process of making changes to an existing InvenTree plugin with proper testing and verification.

---

## Prerequisites

Complete the initial setup in [SETUP.md](../../SETUP.md) before using this skill. This includes:
- Docker Desktop installed and running
- VS Code with Dev Containers extension
- Devcontainer open and running
- Plugin exists in `/workspace/plugins/your-plugin-name`

For automated command execution (Docker exec), see [SESSION-ONBOARDING.md](../reference/SESSION-ONBOARDING.md#automated-command-execution).

---

## Workflow

### 1. Understand Change Request

Ask the user to describe:
- What functionality needs to be changed/added
- Which files/components are affected
- Expected behavior after change
- Any breaking changes

### 2. Analyze Current Implementation

```bash
cd /workspace/plugins/your-plugin-name
```

Review relevant files:
- Backend: `core.py`, `api.py`, `views.py`, `models.py`
- Frontend: `frontend/src/Panel.tsx`, components
- Tests: `tests/unit/`, `tests/integration/`, `frontend/e2e/`

### 3. Make Changes

**Backend changes:**
- Edit Python files
- Add/update API endpoints
- Add/update database models
- Create migrations if needed

**Frontend changes:**
- Edit React components
- Update API calls
- Test with hot reload (no server restart needed)

### 4. Run Tests

**Preflight - Code quality:**
```bash
# Python
ruff check flat_bom_generator
ruff format flat_bom_generator

# Frontend
cd frontend
npm run lint
cd ..
```

**Unit tests:**
```bash
python -m pytest tests/unit -v
```

**Integration tests:**
```bash
python -m pytest tests/integration -v
```

**Frontend unit tests:**
```bash
cd frontend
npm run test
cd ..
```

**E2E tests (if applicable):**
```bash
cd frontend
npm run test:e2e
cd ..
```

**Run all tests:**
```bash
./test-all.sh
```

### 5. Manual Verification

**Backend changes:**
- Restart InvenTree server: `cd /workspace/reference/inventree-source && invoke dev.server -a 0.0.0.0:8001`
- Log in to http://localhost:8001
- Navigate to plugin functionality
- Test the changed feature
- Check InvenTree logs for errors

**Frontend changes:**
- Plugin dev server should auto-reload
- Test UI changes in browser
- Check browser console for errors
- Verify API calls work correctly

### 6. Build Plugin

```bash
python -m build
```

Verify `.whl` file is created in `dist/`.

### 7. Document Changes

Update relevant documentation:
- `README.md` - new features, breaking changes
- `CHANGELOG.md` - if it exists
- Code comments for complex logic

### 8. Commit Changes

```bash
git add .
git commit -m "feat: description of change"
```

---

## Change Verification Loop

For each change, follow this loop:

1. **Make change** - Edit code
2. **Run preflight** - Code quality checks
3. **Run unit tests** - Fast feedback
4. **Run integration tests** - Database interaction
5. **Manual verification** - Test in UI
6. **Build** - Ensure package builds
7. **Document** - Update docs
8. **Commit** - Save work

**If any step fails:**
- Fix the issue
- Re-run from preflight
- Do not proceed until all steps pass

---

## Common Patterns

### Adding a New API Field

1. Add field to serializer
2. Update API endpoint
3. Write unit test for new field
4. Run integration tests
5. Test in browser with API client
6. Update documentation

### Changing Frontend Component

1. Edit React component
2. Check hot reload works
3. Run frontend lint
4. Run frontend unit tests
5. Test in browser
6. Run E2E tests if applicable

### Database Schema Change

1. Create migration
2. Update model
3. Update serializer
4. Write migration test
5. Run migration in dev
6. Test with integration tests
7. Document breaking changes

---

## Troubleshooting

**Tests failing after change:**
- Check if change broke existing functionality
- Update test fixtures if schema changed
- Verify test data is still valid
- Check for race conditions in integration tests

**Frontend not updating:**
- Check plugin dev server is running
- Clear browser cache
- Check for JavaScript errors in console
- Verify Vite hot reload is working

**Build failing:**
- Check for syntax errors
- Verify all dependencies are in `pyproject.toml`
- Check for missing files in MANIFEST
- Verify version number is valid

---

## Best Practices

1. **Test frequently** - Run tests after each significant change
2. **Small commits** - Commit often with clear messages
3. **Branch for features** - Use feature branches for larger changes
4. **Review changes** - Before committing, review diff
5. **Update docs** - Keep documentation in sync with code
6. **Check logs** - Monitor InvenTree logs during development
7. **Use hot reload** - Take advantage of frontend hot reload
8. **Test manually** - Automated tests don't catch everything

---

## Verification Checklist

- [ ] Code quality checks pass (ruff, biome)
- [ ] Unit tests pass
- [ ] Integration tests pass
- [ ] Frontend unit tests pass
- [ ] E2E tests pass (if applicable)
- [ ] Manual verification in UI successful
- [ ] Plugin builds successfully
- [ ] Documentation updated
- [ ] Changes committed with clear message
- [ ] No breaking changes (or documented)
