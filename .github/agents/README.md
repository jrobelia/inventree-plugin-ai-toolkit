# GitHub Copilot Agents

**Purpose**: Specialized agent configurations for InvenTree plugin development  
**Created**: December 19, 2025

---

## Available Agents

### InvenTree Plugin Expert

**File**: [inventree-plugin.agent.md](inventree-plugin.agent.md)  
**Purpose**: Comprehensive assistant for developing, reviewing, and debugging InvenTree plugins

**Expertise**:
- Plugin architecture and lifecycle
- Django/DRF backend patterns
- React/TypeScript frontend integration
- Testing strategies (unit + integration)
- Fail-fast philosophy and code quality
- InvenTree-specific gotchas and best practices

**When to Use**:
- Creating new plugin features
- Reviewing code for quality and compatibility
- Debugging plugin issues
- Refactoring existing code
- Understanding InvenTree patterns

**How to Invoke** (in GitHub Copilot Chat):
```
@workspace /agent inventree-plugin

[Your question or task]
```

**Example Prompts**:
```
@workspace /agent inventree-plugin
I want to add a custom API endpoint that calculates BOM costs. 
Walk me through the approach.

@workspace /agent inventree-plugin
Review this serializer for fail-fast violations and InvenTree best practices.
[paste code]

@workspace /agent inventree-plugin
My plugin isn't loading in InvenTree. What should I check?

@workspace /agent inventree-plugin
I need to test this APIView. Show me the as_view() pattern.
```

---

## Agent Features

### 1. Context-Aware Guidance

The agent automatically references:
- Instruction files in `.github/instructions/`
- Comprehensive docs in `copilot/PROJECT-CONTEXT.md`
- Plugin-specific `copilot-instructions.md` (if exists)
- Testing documentation and methodologies

### 2. Fail-Fast Philosophy

Enforces decision tree for defensive code:
- Optional by design? → Use default
- Breaks functionality? → Fail loudly
- User can fix? → Clear error

### 3. Critical Gotcha Detection

Automatically checks for:
- ✅ Plugin URLs in tests (use `as_view()`, not HTTP client)
- ✅ External dependencies (externalize, don't bundle)
- ✅ Entry point format (exact syntax)
- ✅ React hooks violations (top-level only)
- ✅ N+1 query problems (QuerySet optimization)

### 4. User-Appropriate Communication

Tailored for mechanical engineer learning software development:
- Plain English explanations
- Complete examples with context
- Explains WHY, not just WHAT
- Collaborative approach (explain → discuss → approve)

---

## Agent vs Direct Copilot

**Use Agent When**:
- Need architectural guidance
- Reviewing code for InvenTree compatibility
- Unsure about best approach
- Want fail-fast evaluation
- Need comprehensive explanation

**Use Direct Copilot When**:
- Simple code completion
- Obvious pattern implementation
- Quick edits to existing code
- Documentation updates

---

## Creating New Agents (Future)

**Potential Specialized Agents**:

### Testing Agent
**Focus**: Test creation, quality evaluation, code-first methodology  
**Expertise**: AAA pattern, mocking, fixtures, integration test setup

### Frontend Agent
**Focus**: React/TypeScript, InvenTree context, Mantine UI  
**Expertise**: Hooks, state management, TypeScript types, build config

### Debugging Agent
**Focus**: Systematic debugging, root cause analysis  
**Expertise**: 5 Whys, binary search debugging, logging, stack trace analysis

### Refactoring Agent
**Focus**: Safe refactoring patterns, test-first workflow  
**Expertise**: Strangler fig pattern, code review, SOLID principles

---

## Agent Development Guidelines

**When creating new agents**:

1. **Clear Scope** - Single area of expertise
2. **Reference Documentation** - Point to instruction files and comprehensive docs
3. **Decision Trees** - Provide clear decision frameworks
4. **User Context** - Remember user is mechanical engineer, learning
5. **Real Examples** - Use actual plugin code, not generic examples
6. **Critical Gotchas** - Document known issues specific to scope

**Format**:
```markdown
name: Agent Name
description: Brief description
tools: [read, edit, search, test]

---

[Agent instructions in markdown]
```

---

## Testing Agents

**Before deploying new agent**:

1. **Test common scenarios** - Does agent provide good guidance?
2. **Check documentation references** - Are they accurate and helpful?
3. **Validate decision trees** - Do they lead to correct decisions?
4. **Review examples** - Are they clear and applicable?
5. **User feedback** - Does it help the target user (mechanical engineer)?

---

## Maintenance

**Review agents when**:
- Instruction files updated
- New InvenTree version changes patterns
- User reports confusion or errors
- New gotchas discovered

**Update cycle**: Same as instruction files (every 3-6 months or after major changes)

---

**Last Updated**: December 19, 2025  
**Agents**: 1 (InvenTree Plugin Expert)  
**Status**: Production-ready
