# Toolkit Roadmap

**Purpose:** Feature wish list for the toolkit itself (not individual plugins)  
**Last Updated:** February 26, 2026

---

## Active

_Nothing currently in progress at the toolkit level._

---

## Planned

### Test-Plugin.ps1 Improvements
- Single-file test support
- Pattern matching for test names
- Direct invoke passthrough
- See [docs/planning/TEST-SCRIPT-IMPROVEMENTS.md](planning/TEST-SCRIPT-IMPROVEMENTS.md)

### Automated Deployment Verification
- Script to run basic smoke tests after deployment
- Check server health, plugin loaded, basic API calls work
- Reduce manual verification burden

---

## Future Ideas

### Plugin Template Improvements
- Add optional integration testing setup to plugin scaffolding
- Include deployment workflow checklist template
- Pre-configure Biome and pre-commit hooks by default

### CI/CD Templates
- GitHub Actions workflow templates for plugin testing
- Automated build and deployment pipelines

---

## Completed

### Documentation Reorganization (2026-02-26)
- Archived superseded `copilot/` folder and stale toolkit docs
- Created `docs/reference/`, `docs/planning/`, `docs/archive/`
- Created living docs: architecture.md, decisions.md, roadmap.md
- Distilled domain knowledge into `.github/instructions/`
