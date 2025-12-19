# GitHub Copilot Instructions - InvenTree Plugin Toolkit

**Purpose**: Comprehensive instruction files for AI-assisted InvenTree plugin development  
**Created**: December 19, 2025  
**Source**: Based on plugin creator templates and real-world FlatBOMGenerator patterns

---

## Instruction File Structure

### Backend Instructions

| File | Applies To | Purpose |
|------|-----------|---------|
| [python.instructions.md](python.instructions.md) | `**/*.py` | General Python conventions + fail-fast philosophy |
| [backend.core.instructions.md](backend.core.instructions.md) | `**/core.py`, `**/__init__.py` | Plugin class, mixins, settings, event handlers |
| [backend.api.instructions.md](backend.api.instructions.md) | `**/serializers.py`, `**/views.py` | Django REST Framework, serializers, API views, QuerySet optimization |
| [backend.testing.instructions.md](backend.testing.instructions.md) | `**/test_*.py`, `**/tests/**/*.py` | Unit/integration testing, code-first methodology, test quality standards |

### Frontend Instructions

| File | Applies To | Purpose |
|------|-----------|---------|
| [frontend.react.instructions.md](frontend.react.instructions.md) | `frontend/src/**/*.tsx`, `frontend/src/**/*.ts` | React patterns, TypeScript, InvenTree context, Mantine UI, hooks |
| [frontend.build.instructions.md](frontend.build.instructions.md) | `**/vite.config.ts`, `**/tsconfig*.json` | Vite build config, external dependencies, TypeScript config |

### Packaging Instructions

| File | Applies To | Purpose |
|------|-----------|---------|
| [packaging.instructions.md](packaging.instructions.md) | `**/setup.py`, `**/pyproject.toml`, `**/MANIFEST.in` | Python packaging, versioning, PyPI publishing, entry points |

---

## Key Principles Across All Files

### 1. Fail-Fast Philosophy

**Avoid arbitrary defensive fallbacks**:
- Use `.get()` with defaults only for **optional by design** fields (UI preferences)
- Fail loudly with specific errors for **required fields** (calculations, data integrity)
- Never swallow exceptions with bare `except:` blocks

**Decision Tree** (in every instruction file):
1. Is field optional by design? → Use default
2. Does missing value break functionality? → Fail loudly
3. Can user fix the error? → Clear error message

**Real-World Example**: FlatBOMGenerator had 2 incorrect fallbacks that hid bugs for months. Found during code-first test analysis.

### 2. Industry Best Practices

**Django/DRF**:
- Use `select_related()` / `prefetch_related()` to prevent N+1 queries
- Proper HTTP status codes (200, 201, 400, 404, 500)
- Validate all user input with serializers
- Never trust client data

**React/TypeScript**:
- Follow Rules of Hooks (top-level only, no conditions)
- Use `useMemo` for expensive calculations
- Use `useCallback` for stable function references
- Type safety with explicit interfaces

**Testing**:
- AAA pattern (Arrange-Act-Assert)
- Code-first for refactoring, test-first for new features
- Plugin URLs don't work in tests (use `as_view()` pattern)
- Test edge cases and error conditions

**Packaging**:
- Semantic versioning (MAJOR.MINOR.PATCH)
- Externalize shared dependencies (React, Mantine)
- Entry point format: `Plugin = "package.module:ClassName"`
- Don't duplicate InvenTree's dependencies

### 3. Template-Based Patterns

**All code examples extracted from**:
- `plugin-creator/plugin_creator/template/` (cookiecutter templates)
- `plugins/FlatBOMGenerator/` (real production plugin)

**Ensures consistency**:
- Generated plugins follow instruction patterns
- Instructions match actual code
- Updates to templates = updates to instructions

---

## When to Use Each File

### Writing Plugin Core Logic
→ [backend.core.instructions.md](backend.core.instructions.md)
- Plugin class structure
- Mixin selection (SettingsMixin, EventMixin, ScheduleMixin)
- Settings configuration
- Scheduled tasks
- Event handlers

### Creating API Endpoints
→ [backend.api.instructions.md](backend.api.instructions.md)
- DRF serializers (validation, nested fields)
- APIView patterns (GET/POST/PUT/DELETE)
- Django QuerySet optimization
- HTTP status codes
- Error handling

### Building Frontend UI
→ [frontend.react.instructions.md](frontend.react.instructions.md)
- InvenTree context interface
- React hooks (useState, useEffect, useMemo)
- Mantine UI components
- API calls with React Query
- TypeScript type safety

### Configuring Build
→ [frontend.build.instructions.md](frontend.build.instructions.md)
- Vite production/dev config
- Externalized dependencies (why + how)
- TypeScript configuration
- Build scripts
- Troubleshooting build issues

### Writing Tests
→ [backend.testing.instructions.md](backend.testing.instructions.md)
- Unit vs integration test decision
- Testing views with `as_view()` pattern (critical!)
- Code-first methodology for refactoring
- Test-first workflow for new features
- Test quality standards (High/Medium/Low)

### Packaging Plugin
→ [packaging.instructions.md](packaging.instructions.md)
- pyproject.toml structure
- Entry point configuration (most common issue!)
- MANIFEST.in patterns
- Semantic versioning
- Dependency management

### General Python
→ [python.instructions.md](python.instructions.md)
- PEP 8 style guide
- Docstring conventions
- Type hints
- Fail-fast decision tree

---

## Critical Gotchas Documented

### 1. Plugin URLs in Tests (6-hour discovery)
**Problem**: `self.client.get('/api/plugin/...')` returns 404 in tests  
**Solution**: Use `MyView.as_view()` pattern with `APIRequestFactory`  
**File**: [backend.testing.instructions.md](backend.testing.instructions.md)

### 2. External Dependencies (Bundle Size)
**Problem**: Bundling React with every plugin = MB per plugin  
**Solution**: Externalize with `viteExternalsPlugin`  
**File**: [frontend.build.instructions.md](frontend.build.instructions.md)

### 3. Entry Point Configuration
**Problem**: Plugin won't load if entry point format wrong  
**Solution**: `Plugin = "package.module:ClassName"` (exact match)  
**File**: [packaging.instructions.md](packaging.instructions.md)

### 4. Rules of Hooks
**Problem**: Conditional hooks break React  
**Solution**: Call at top level, use options for conditions  
**File**: [frontend.react.instructions.md](frontend.react.instructions.md)

### 5. N+1 Query Problem
**Problem**: 1 query per item in loop = slow  
**Solution**: `select_related()` for ForeignKey, `prefetch_related()` for ManyToMany  
**File**: [backend.api.instructions.md](backend.api.instructions.md)

---

## Integration with Existing Documentation

**Instruction files are concise quick references**  
**For comprehensive information, see**:

- [PROJECT-CONTEXT.md](../../copilot/PROJECT-CONTEXT.md) - Complete InvenTree architecture (962 lines)
- [TESTING-STRATEGY.md](../../docs/toolkit/TESTING-STRATEGY.md) - Testing philosophy and setup
- [TEST-PLAN.md](../../plugins/FlatBOMGenerator/flat_bom_generator/tests/TEST-PLAN.md) - Testing workflow
- [TEST-QUALITY-REVIEW.md](../../plugins/FlatBOMGenerator/docs/TEST-QUALITY-REVIEW.md) - Test quality analysis
- [TEST-WRITING-METHODOLOGY.md](../../plugins/FlatBOMGenerator/docs/TEST-WRITING-METHODOLOGY.md) - Code-first approach

**Hierarchy**:
1. **Instruction files** → Quick patterns for active coding
2. **Comprehensive docs** → Deep dives, architectural decisions
3. **Plugin templates** → Working examples

---

## Maintenance

**When to Update Instruction Files**:
- Plugin creator templates change
- New best practices discovered
- Common mistakes identified
- InvenTree API changes

**How to Update**:
1. Update template code first
2. Test generated plugins
3. Update instruction file with new pattern
4. Cross-reference comprehensive docs

**Review Cycle**: Every 3-6 months or after major InvenTree version

---

## Future Enhancements

**When Needed** (instruction files are production-ready now):

### Documentation Optimization (If Token Budget Issues Arise)

**Current Status** (December 2025):
- Total AI-facing documentation: ~4,845 lines
- Context utilization: ~30% of Claude Sonnet 4.5 (50-60K of 200K tokens)
- **Assessment**: Comfortable, no optimization needed yet

**Optimization Strategies** (apply if responses slow or token budget exceeded):

1. **Split PROJECT-CONTEXT.md** (962 lines → 3 smaller files)
   - `copilot/ARCHITECTURE.md` - Folder structure, design philosophy
   - `copilot/TECH-STACK.md` - Django, React, build tools
   - `copilot/DEVELOPMENT-PATTERNS.md` - Workflows, debugging
   - **Impact**: Save ~30-40K tokens when only architecture needed

2. **Extract Fail-Fast Tree to Single Reference** (currently in 4 files)
   - Create `copilot/FAIL-FAST-PHILOSOPHY.md` as canonical reference
   - Update instruction files to reference instead of duplicate
   - **Impact**: Save ~5-10K tokens

3. **Add "Quick Patterns" TL;DR Sections**
   - Top of each instruction file: essential patterns only
   - Deep explanations below for when needed
   - **Impact**: Faster scanning, reduced token load for simple tasks

4. **Progressive Disclosure Pattern**
   - Tag sections: `<!-- @essential -->`, `<!-- @detailed -->`
   - Agents load essential first, detailed on demand
   - **Impact**: ~40-50% token reduction for routine tasks

5. **Reduce Cross-File Redundancy**
   - Testing patterns: Consolidate to backend.testing.instructions.md
   - InvenTree context: Keep in PROJECT-CONTEXT.md, reference from others
   - **Impact**: ~15-20% token reduction

**When to Optimize**: 
- If context utilization exceeds 50% (100K+ tokens)
- If response generation slows noticeably
- If agent reports difficulty holding context

**Current Recommendation**: Use as-is, monitor performance

---

### Feature Enhancements

### High Priority
- **Prompt Libraries** (`copilot/prompts/`)
  - `debugging-workflows.md` - Common failure scenarios, systematic debugging steps
  - `refactoring-workflows.md` - Pre-refactoring checklist, code analysis prompts
  - `code-review-prompts.md` - Quality checklist, pattern violations

### Medium Priority
- **Enhanced PROJECT-CONTEXT.md**
  - EventMixin usage examples (observer pattern, event-driven architecture)
  - ScheduleMixin patterns (Celery best practices, idempotency, retry logic)
  - ValidationMixin examples (custom validation hooks, error messages)
  - DataExportMixin integration (replacing manual CSV exports)
  - InvenTree model relationships diagram (Part → BomItem → Sub_Part chains)

### Low Priority
- **Plugin-Specific Instruction Files**
  - Use FlatBOMGenerator as template for complex plugins
  - Document plugin-specific patterns (BOM traversal, stock calculations)
  - Add to each plugin's `.github/instructions/` folder

### Optional
- **Advanced Testing Patterns**
  - Mocking InvenTree models (fixtures, factories)
  - Common test patterns for each mixin type
  - Performance testing guidance (large BOMs, 1000+ parts)
  - Load testing strategies

---

## Questions & Defensive Code

**If defensive code looks suspicious**:
1. Check against fail-fast decision tree
2. Consider if null/default is valid state
3. **Ask user if unsure** - silent bugs worse than loud errors

**Examples of when to ask**:
- Field defaulting to 0 (is 0 valid?)
- Silent exception handling (what's the recovery?)
- Multiple fallbacks (which is correct?)
- Optional chaining everywhere (is null expected?)

---

**Last Updated**: December 19, 2025  
**Files Created**: 7 instruction files (2 existing + 5 new)  
**Total Lines**: ~2000 lines of actionable patterns  
**Source**: Plugin creator templates + FlatBOMGenerator production code
