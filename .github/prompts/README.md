# Reusable Prompts for InvenTree Plugin Toolkit

This folder contains reusable prompts that guide GitHub Copilot through common tasks in InvenTree plugin development.

## 📋 Available Prompts

### Script Usage Prompts

#### [build-plugin.prompt.md](build-plugin.prompt.md)
Guide user through building an InvenTree plugin with Build-Plugin.ps1

**Use when:**
- Building plugin for the first time
- Rebuilding after code changes
- Troubleshooting build issues
- Need clean build (recreate venv)

**Usage in Copilot Chat:**
```
@workspace /run build-plugin
```

#### [deploy-plugin.prompt.md](deploy-plugin.prompt.md)
Guide user through deploying plugin to server with Deploy-Plugin.ps1

**Use when:**
- Deploying to staging for testing
- Deploying to production
- Troubleshooting deployment issues
- Need to verify server configuration

**Usage in Copilot Chat:**
```
@workspace /run deploy-plugin
```

#### [test-plugin.prompt.md](test-plugin.prompt.md)
Guide user through running unit/integration tests with Test-Plugin.ps1

**Use when:**
- Running tests during development
- Pre-deployment verification
- Investigating test failures
- Setting up integration testing

**Usage in Copilot Chat:**
```
@workspace /run test-plugin
```

---

### Testing & Quality Prompts

#### [create-plugin-test.prompt.md](create-plugin-test.prompt.md)
Generate comprehensive unit tests for plugin code

**Use when:**
- Writing tests for new features (test-first)
- Adding tests for existing code (code-first)
- Improving test coverage
- Need examples of good tests

**Usage in Copilot Chat:**
```
@workspace /run create-plugin-test
```

**Mode:** `edit` - Will create test files directly

#### [review-test-quality.prompt.md](review-test-quality.prompt.md)
Evaluate test quality and provide improvement recommendations

**Use when:**
- Assessing test suite quality
- Identifying coverage gaps
- Planning test improvements
- Preparing for deployment

**Usage in Copilot Chat:**
```
@workspace /run review-test-quality
```

**Mode:** `ask` - Will analyze and provide detailed report

---

## 🎯 How to Use Prompts

### In VS Code

1. **Open Copilot Chat**: `Ctrl+Alt+I` (Windows) or `Cmd+Alt+I` (Mac)

2. **Run a prompt**: Type `@workspace /run prompt-name`

3. **Follow the conversation**: Copilot will ask for needed information

### Examples

**Build a plugin:**
```
@workspace /run build-plugin
> Which plugin do you want to build?
FlatBOMGenerator
> Do you want a clean build (recreate venv)?
No, just rebuild
```

**Create tests:**
```
@workspace /run create-plugin-test
> What code needs testing?
The calculate_shortfall function in calculations.py
> What's the expected behavior?
[Explain the function's purpose and edge cases]
```

**Review test quality:**
```
@workspace /run review-test-quality
> Which plugin should I review?
FlatBOMGenerator
```

---

## 📚 Prompt Best Practices

### When Writing Prompts

1. **Clear Mission**: State the goal upfront
2. **Structured Workflow**: Step-by-step process
3. **Context Gathering**: Ask for required information
4. **Validation**: Checklist of what to verify
5. **Examples**: Show good/bad patterns
6. **Troubleshooting**: Common issues and solutions

### When Using Prompts

1. **Have context ready**: Know what you want to accomplish
2. **Follow the conversation**: Answer Copilot's questions
3. **Verify results**: Check that actions completed successfully
4. **Learn patterns**: Understand why, not just what

---

## 🔧 Customizing Prompts

### Prompt Structure

```markdown
---
description: 'One-sentence description for quick reference'
mode: 'ask|edit|agent'  # ask=conversational, edit=modifies files, agent=autonomous
tools: ['read', 'edit', 'search', 'run']  # Minimal set needed
---

# Prompt Title

## Mission
What this prompt accomplishes

## Scope & Preconditions
When to use, what's required

## Workflow
Step-by-step process

## Output Expectations
What results to expect
```

### Modifying Existing Prompts

1. **Update workflow steps** if process changes
2. **Add troubleshooting** for new issues encountered
3. **Update examples** when patterns evolve
4. **Keep frontmatter accurate** (tools, mode, description)

---

## 🚀 Creating New Prompts

### When to Create a New Prompt

- Repetitive task done frequently
- Complex multi-step process
- Needs specific domain knowledge
- Would benefit from guided conversation

### Template

See [prompt.instructions.md](../.github/instructions/prompt.instructions.md) for guidelines.

### Example Use Cases

**Could add prompts for:**
- Setting up new plugin from template
- Updating plugin dependencies
- Creating migration guide for breaking changes
- Generating changelog entries
- Reviewing API endpoint design
- Troubleshooting InvenTree integration issues

---

## 📖 Reference

- **Prompt Guidelines**: `.github/instructions/prompt.instructions.md`
- **Toolkit Workflows**: `docs/toolkit/WORKFLOWS.md`
- **Quick Reference**: `QUICK-REFERENCE.md`
- **Awesome Copilot**: https://github.com/github/awesome-copilot

---

**Last Updated**: December 19, 2025
