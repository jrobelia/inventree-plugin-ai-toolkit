---
description: 'Automatically update documentation when code changes require doc updates'
applyTo: ['**/*.md', '**/*.py', '**/views.py', '**/serializers.py', '**/core.py']
---

# Update Documentation on Code Change

## Overview

Ensure documentation stays synchronized with code changes by automatically detecting when README.md, API documentation, architecture guides, and other documentation files need updates based on code modifications.

**Applies to**: InvenTree plugin development toolkit and individual plugins

---

## When to Update Documentation

### Trigger Conditions

Automatically check if documentation updates are needed when:

- New features or functionality are added to plugins
- API endpoints, mixins, or interfaces change
- Breaking changes are introduced
- Plugin dependencies or InvenTree version requirements change
- Configuration options (settings, environment variables) are modified
- Installation or setup procedures change
- PowerShell scripts are updated or new scripts added
- Frontend components or UI panels change
- Test strategies or test files are added/modified

---

## Documentation Update Rules

### Plugin README.md Updates

**Always update plugin README.md when:**

- **Adding new features or capabilities**
  - Add feature description to "Features" section
  - Include usage examples if applicable
  - Update screenshots if UI changed

- **Modifying installation or setup process**
  - Update "Installation" section
  - Revise InvenTree version compatibility
  - Update plugin dependency requirements

- **Adding new settings or configuration**
  - Document setting names, types, defaults
  - Include configuration examples
  - Explain when to use each setting

- **Changing API endpoints or serializers**
  - Update API documentation section
  - Include request/response examples
  - Document query parameters

### ARCHITECTURE.md Updates

**Sync ARCHITECTURE.md when:**

- **Component structure changes**
  - Update file/folder organization descriptions
  - Revise component responsibility descriptions
  - Update architecture diagrams (if present)

- **New interfaces or data structures added**
  - Add TypeScript interface definitions
  - Document Python class structures
  - Include field descriptions

- **Calculation logic changes**
  - Update formulas and algorithms section
  - Revise examples with current logic
  - Document edge cases

- **Column or UI changes**
  - Update DataTable column descriptions
  - Revise state variable documentation
  - Update UI interaction patterns

### TEST-PLAN.md / TEST-QUALITY-REVIEW.md Updates

**Update test documentation when:**

- **New test files created**
  - Add to test suite overview table
  - Document test purpose and coverage
  - Update test count

- **Test strategy changes**
  - Update testing approach documentation
  - Revise test-first workflow instructions
  - Update quality standards

- **Critical gaps identified or filled**
  - Update coverage gap lists
  - Mark completed test improvements
  - Adjust priority recommendations

### ROADMAP.md Updates

**Update roadmap when:**

- **Features completed**
  - Mark phases/tasks as complete
  - Update "Current Work Status" section
  - Move items from planned to completed

- **New refactoring needs identified**
  - Add to refactoring priorities
  - Document technical debt
  - Estimate effort required

- **Architectural decisions made**
  - Document decision rationale
  - Update architecture section
  - Note alternatives considered

### Toolkit Documentation (docs/toolkit/)

**Update toolkit docs when:**

- **Scripts modified or added**
  - Update WORKFLOWS.md with new procedures
  - Update QUICK-REFERENCE.md command examples
  - Document new parameters or options

- **Development workflow changes**
  - Revise PLUGIN-DEVELOPMENT-WORKFLOW.md
  - Update TESTING-STRATEGY.md
  - Adjust DOCUMENTATION-STANDARDS.md

- **Integration testing setup changes**
  - Update INVENTREE-DEV-SETUP.md
  - Revise INTEGRATION-TESTING-SUMMARY.md
  - Document new gotchas or issues

---

## Documentation File Structure

### Standard Plugin Documentation

Each plugin should maintain:

- **README.md**: User-facing features, installation, usage
- **ARCHITECTURE.md**: Developer reference, tech stack, API, patterns
- **.github/copilot-instructions.md**: Quick reference for AI agents
- **docs/internal/TEST-PLAN.md**: Testing strategy and execution
- **docs/internal/TEST-QUALITY-REVIEW.md**: Test analysis and improvements
- **docs/internal/ROADMAP.md**: Refactoring plans and priorities
- **docs/internal/DEPLOYMENT-WORKFLOW.md**: Deployment checklist

### Toolkit Documentation

Maintain these files in toolkit root:

- **README.md**: Toolkit overview and quick start
- **SETUP.md**: Initial setup instructions
- **QUICK-REFERENCE.md**: Command cheat sheet
- **docs/toolkit/**: Detailed how-to guides
- **copilot/**: AI agent behavior and context guides

---

## Code Example Synchronization

**Verify and update code examples when:**

- **Function signatures change**
  - Update all code snippets using the function
  - Verify examples still work
  - Update import statements if needed

- **API interfaces change**
  - Update example requests and responses
  - Revise serializer examples
  - Update query parameter examples

- **Best practices evolve**
  - Replace outdated patterns in examples
  - Update to use current recommended approaches
  - Add deprecation notices for old patterns

---

## Documentation Verification

### Before Committing Changes

**Check documentation completeness:**

1. All new public APIs are documented
2. Code examples are accurate and current
3. Links in documentation are valid
4. Configuration examples match current code
5. Test descriptions match actual test behavior
6. README.md reflects current state

### Documentation Quality Standards

- Use clear, concise language (user is mechanical engineer, not software expert)
- Include working code examples
- Provide both basic and advanced examples where applicable
- Use consistent terminology across all docs
- Document edge cases and limitations
- **No emoji in code examples** (Windows compatibility)

---

## Common Documentation Patterns

### Feature Documentation Template

```markdown
## Feature Name

Brief description of the feature and its purpose.

### Usage

Basic usage example with code snippet.

### Configuration

Configuration options with examples and defaults.

### API

If feature exposes API endpoints, document them here.

### Troubleshooting

Common issues and solutions.
```

### API Endpoint Documentation Template

```markdown
### GET /api/plugin/{plugin-slug}/{endpoint}/

Description of what the endpoint does.

**Query Parameters:**
- `param_name` (type, optional): Description with default value

**Response:**
\`\`\`json
{
  "field": "value",
  "items": []
}
\`\`\`

**Status Codes:**
- 200: Success
- 400: Bad request - validation failed
- 404: Resource not found
```

---

## Best Practices

### Do's

- ✅ Update documentation in the same commit as code changes
- ✅ Include before/after examples for significant changes
- ✅ Test code examples before committing
- ✅ Use consistent formatting and terminology
- ✅ Document limitations and edge cases
- ✅ Keep documentation DRY (link instead of duplicating)
- ✅ Update progress logs in ROADMAP.md when completing work

### Don'ts

- ❌ Commit code changes without updating documentation
- ❌ Leave outdated examples in documentation
- ❌ Document features that don't exist yet
- ❌ Use vague or ambiguous language
- ❌ Ignore broken links or failing examples
- ❌ Document implementation details users don't need to know
- ❌ Use emoji in code examples (causes Windows parsing issues)

---

## Documentation Update Checklist

When making code changes, verify:

- [ ] Plugin README.md reflects new features/changes
- [ ] ARCHITECTURE.md updated if structure/patterns changed
- [ ] TEST-PLAN.md updated if tests added/modified
- [ ] ROADMAP.md updated if work completed/planned
- [ ] Toolkit docs updated if scripts/workflow changed
- [ ] Code examples tested and working
- [ ] No broken links or outdated references
- [ ] Terminology consistent across all docs
- [ ] User-facing language clear for mechanical engineer audience

---

## InvenTree Plugin-Specific Patterns

### When Documenting Mixins

Document which mixins are used and why:

```python
class MyPlugin(SettingsMixin, UrlsMixin, UserInterfaceMixin, InvenTreePlugin):
    """
    My plugin description.
    
    Uses:
    - SettingsMixin: Plugin configuration settings
    - UrlsMixin: Custom API endpoints
    - UserInterfaceMixin: React frontend panels
    """
```

### When Documenting Settings

Include type, default, and usage:

```python
SETTINGS = {
    'MY_SETTING': {
        'name': _('My Setting'),
        'description': _('Description of what this setting controls'),
        'default': 'default_value',
        'validator': str,
    }
}
```

### When Documenting API Endpoints

Note that plugin URLs are internal to InvenTree:

```markdown
**Note**: This endpoint is internal to InvenTree and not accessible externally.
It's called by the frontend Panel component.
```

---

## Maintenance Schedule

### Regular Reviews

- **Per feature**: Update docs with feature code
- **Per deployment**: Verify all docs current before staging/production
- **Monthly**: Quick audit of critical gaps
- **Quarterly**: Comprehensive documentation review

### When Refactoring

Follow test-first workflow:
1. Check if docs describe current behavior
2. Update docs to describe desired behavior
3. Refactor code to match docs
4. Verify docs still accurate

---

## Remember

This user:
- Values documentation that's clear and up-to-date
- Prefers **single source of truth** (link between docs, don't duplicate)
- Works part-time (needs docs to help resume work quickly)
- Documents lessons learned (what worked, what didn't)

**Your role**: Keep documentation synchronized so it remains a reliable reference for development and deployment.
