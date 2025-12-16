# InvenTree Plugin Creation Prompts

**Audience:** AI Agents | **Category:** Workflow Guides | **Purpose:** Ready-to-use prompts for creating InvenTree plugins | **Last Updated:** 2025-12-10

---

**For project architecture and patterns**, see `PROJECT-CONTEXT.md`.  
**For communication guidelines**, see `AGENT-BEHAVIOR.md`.

---

## 🚀 Primary Plugin Creation Workflow

### Start Here: Intelligent Guided Creation

```
I want to create a new InvenTree plugin. Please guide me through an intelligent creation process:

1. UNDERSTAND PURPOSE
   - Ask me what the plugin should do
   - Ask about specific use cases and workflows
   - Clarify the business requirements

2. RECOMMEND ARCHITECTURE
   Based on my answers, recommend:
   - Which InvenTree mixins I'll need (and why)
   - Whether I need frontend components
   - If custom API endpoints are needed
   - Whether background tasks are required
   - Any event handling requirements

3. COLLECT DETAILS
   - Plugin name (suggest based on purpose)
   - Display title
   - Description
   - Author information
   - License

4. CREATE PLUGIN
   - Provide all answers in a single formatted box
   - User will copy/paste answers into the interactive plugin-creator
   - **NOTE:** Plugin-creator is interactive and cannot accept piped input
   - Show the command to run: `.\scripts\New-Plugin.ps1`

Let's start - ask me about my plugin's purpose.
```

**Why use this approach:**
- Copilot understands context before recommending mixins
- No need to know InvenTree internals upfront
- Recommendations based on actual requirements
- Avoids including unnecessary mixins

---

## 📋 Answer Format for Plugin Creator

**IMPORTANT:** Plugin-creator is fully interactive and does NOT support piped input.

Provide answers in this format for user to reference:

```
Enter plugin name: <answer>
Enter plugin description: <answer>
Author name: <answer>
Author email: <answer>
Project URL: <answer>
Select a license: <answer>

Select plugin mixins (use space to toggle, enter when done):
- <MixinName1>
- <MixinName2>
...

[IF UserInterfaceMixin selected]
Select frontend features to enable (use space to toggle, enter when done):
- Custom dashboard items
- Custom panel items
- Custom settings display

Enable translation support? <y/n>

Enable Git integration? <y/n>

[IF Git enabled]
DevOps support (CI/CD)? <None/GitHub Actions/GitLab CI/CD>
```

---

## 📝 Plugin Creator Questions Reference

All questions plugin-creator will ask (in order):

1. **Enter plugin name:** Human-readable name (e.g., "Flat BOM Viewer")
2. **Enter plugin description:** Brief description of functionality
3. **Author name:** Your name
4. **Author email:** Your email (optional, can be blank)
5. **Project URL:** Repository URL (optional, can be blank)
6. **Select a license:** Choose from list (MIT, Apache-2.0, GPL-3.0, etc.)

7. **Select plugin mixins:** (spacebar to toggle, enter when done)
   - `AppMixin` - Django app with models and database migrations
   - `CurrencyExchangeMixin` - Currency conversion support
   - `EventMixin` - React to InvenTree events/signals
   - `LocateMixin` - Custom locate functionality
   - `ReportMixin` - Custom report generation
   - `ScheduleMixin` - Background scheduled tasks
   - `SettingsMixin` - Plugin configuration settings
   - `UrlsMixin` - Custom API endpoints
   - `UserInterfaceMixin` - Frontend UI components
   - `ValidationMixin` - Custom validation rules

8. **[Only if UserInterfaceMixin] Select frontend features:** (spacebar to toggle)
   - Custom dashboard items
   - Custom panel items
   - Custom settings display

9. **[Only if UserInterfaceMixin] Enable translation support?** y/n

10. **Enable Git integration?** y/n (recommended: y)

11. **[Only if Git enabled] DevOps support (CI/CD)?** (arrow keys, enter to confirm)
    - **None** - No CI/CD (recommended for beginners)
    - **GitHub Actions** - Automated tests on GitHub
    - **GitLab CI/CD** - Automated tests on GitLab

**Navigation:**
- **Spacebar** - Toggle checkboxes
- **Arrow keys** - Navigate single-choice selections
- **Enter** - Confirm selection

---

## 🧠 Scenario-Based Creation Prompts

### Event-Driven Plugins

```
I need a plugin that reacts when [specific event] happens in InvenTree.

Examples:
- When a sales order is marked as shipped
- When stock levels fall below threshold
- When a part is created with specific attributes
- When a purchase order is received

Help me:
1. Identify the correct InvenTree event/signal
2. Set up EventMixin properly
3. Implement the handler method
4. Add error handling and logging
5. Show how to test it

My specific scenario: [describe your trigger and desired action]
```

### Validation Plugins

```
I need to add custom validation rules in InvenTree for:
- [Model type: Part, StockItem, Order, etc.]
- [What should be validated]
- [The validation rules]
- [What happens if validation fails]

Help me implement this using ValidationMixin with:
- Proper hook method
- Clear error messages
- Edge case handling
```

### Background Task Plugins

```
I need a plugin that runs background tasks to:
- [Describe the task]
- Run on schedule: [daily, hourly, weekly, etc.]
- Process: [what data/operations]

Help me implement ScheduleMixin with:
- Task definition
- Scheduling configuration
- Error handling for failures
- Progress logging
```

### API Extension Plugins

```
I need to add custom REST API endpoints to InvenTree that:
- Endpoint 1: [purpose, HTTP method, parameters]
- Endpoint 2: [purpose, HTTP method, parameters]

Data source: [InvenTree models, external API, calculated, etc.]

Help me:
1. Set up UrlsMixin
2. Create Django Rest Framework views
3. Define serializers
4. Handle authentication
5. Return proper responses
6. Document the API
```

### Settings & Configuration Plugins

```
My plugin needs configurable settings for:
- [Setting 1]: [type, purpose, default value]
- [Setting 2]: [type, purpose, options]
- [Setting 3]: [type, validation rules]

Help me implement SettingsMixin with:
- Proper SETTINGS dictionary
- Input validation
- Type safety
- How to access settings in code
```

### Frontend-Enabled Plugins

```
I need an InvenTree plugin with frontend components that:

DISPLAY LOCATION: [Part detail page, Stock detail, Dashboard, etc.]

UI REQUIREMENTS:
- [What should be displayed]
- [User interactions needed]
- [Data sources]
- [Real-time updates?]

Help me:
1. Should I use frontend? (recommendations)
2. Set up the React component structure
3. Connect to InvenTree API or my plugin API
4. Register the UI panel/widget
5. Handle loading states and errors
```

---

## 🔧 Enhancement Prompts

### Add Functionality to Existing Plugin

```
I have an existing InvenTree plugin that currently:
[Describe current functionality]

I want to add:
[Describe new feature]

Current mixins used: [list current mixins]

Help me:
1. Do I need additional mixins?
2. What code should I add?
3. Any conflicts with existing code?
4. How to test the new feature?

[Paste relevant current code sections]
```

### Optimize Plugin Performance

```
My InvenTree plugin has performance issues:

PROBLEM: [slow queries, high memory, timeouts, etc.]

PLUGIN FUNCTIONALITY: [what it does]

CURRENT CODE:
[paste relevant code]

Help me:
1. Identify bottlenecks
2. Optimize database queries
3. Add caching if appropriate
4. Improve algorithm efficiency
5. Measure improvements
```

---

## 🔍 Understanding Prompts

### Explore InvenTree Capabilities

```
Before I build my plugin, help me understand if InvenTree already does [describe functionality].

If it does:
- Show me where/how
- Can I enhance it with a plugin?

If it doesn't:
- Confirm a plugin is the right approach
- Recommend the architecture
```

### Model & Data Understanding

```
My plugin will work with InvenTree [Part/Stock/Order/etc.] data.

Explain:
- What fields/attributes are available?
- How do I query and filter this data?
- What are the relationships to other models?
- What methods are available?
- Any important constraints or behaviors?
- Best practices for working with this model?
```

### Status & State Management

```
I need to work with [SalesOrder/PurchaseOrder/BuildOrder/StockItem] statuses.

Explain:
- What status codes exist?
- Can I add custom states? How?
- How do I check status programmatically?
- How do I change status?
- What events fire on status changes?
- Can my plugin intercept status transitions?
```

---

## 🐛 Debugging Prompts

### Plugin Not Working

```
My InvenTree plugin isn't behaving correctly:

EXPECTED: [what should happen]
ACTUAL: [what actually happens]
ERROR LOGS: [paste any errors]

PLUGIN CODE:
[paste relevant sections]

Help me debug this systematically.
```

### Import/Loading Issues

```
InvenTree isn't loading my plugin or I'm getting import errors:

ERROR MESSAGE:
[paste error]

PLUGIN STRUCTURE:
[describe folder/file structure]

Help me fix the plugin registration and imports.
```

### Frontend Build Errors

```
My InvenTree plugin frontend build is failing with:
[PASTE npm run build OUTPUT]

Plugin structure:
- Uses Mantine UI components
- Has Panel.tsx and Dashboard.tsx
- package.json lists these dependencies: [LIST KEY DEPENDENCIES]

What's wrong and how do I fix it?
```

---

## ✅ Pre-Deployment Review

```
Review my InvenTree plugin before deployment:

PLUGIN PURPOSE: [describe]

CHECK FOR:
- Security vulnerabilities
- Performance issues
- InvenTree best practices
- Proper error handling
- Missing documentation
- Test coverage gaps
- Dependency issues

PLUGIN CODE:
[paste or link to code]

Provide specific feedback and recommendations.
```

---

## 💡 Quick Reference Prompts

### Get Examples
```
Show me a complete example of an InvenTree plugin that [does X]
```

### Understand Errors
```
InvenTree error: [paste error message]

What does this mean and how do I fix it?
```

### Best Practices
```
What are InvenTree plugin development best practices for [topic]?
```

### Explain Concepts
```
Explain InvenTree [concept] with examples:
- Plugin lifecycle and hooks
- Event system and signals
- Status code architecture
- API authentication
- Frontend integration
```

---

## 🎯 Typical Workflow

1. **Start:** Use main "Intelligent Guided Creation" prompt
2. **Discuss:** Answer Copilot's questions about requirements
3. **Review:** Copilot recommends architecture and mixins
4. **Confirm:** Approve recommendations
5. **Generate:** Copilot provides formatted answers
6. **Create:** Run `.\scripts\New-Plugin.ps1` and paste answers
7. **Develop:** Use scenario prompts for implementation
8. **Test:** Use debugging prompts if issues arise
9. **Deploy:** Use pre-deployment checklist

---

## 🧪 Mixin Quick Reference

When Copilot asks which mixins you need, use this as a guide:

| Use Case | Recommended Mixin(s) |
|----------|---------------------|
| Plugin needs configuration | `SettingsMixin` |
| Add custom API endpoints | `UrlsMixin` |
| Custom UI panels/widgets | `UserInterfaceMixin` |
| React to InvenTree events | `EventMixin` |
| Background scheduled tasks | `ScheduleMixin` |
| Custom database models | `AppMixin` |
| Validate data before save | `ValidationMixin` |
| Custom reports | `ReportMixin` |
| Custom labels | `LabelMixin` |
| Currency conversion | `CurrencyExchangeMixin` |
| Custom locate functionality | `LocateMixin` |
| Add navigation menu items | `NavigationMixin` |

**Most Common Combinations:**
- **Simple plugin**: `SettingsMixin`
- **API plugin**: `SettingsMixin` + `UrlsMixin`
- **UI plugin**: `SettingsMixin` + `UserInterfaceMixin`
- **Full-stack plugin**: `SettingsMixin` + `UrlsMixin` + `UserInterfaceMixin`
- **Event handler**: `EventMixin` + `SettingsMixin`

---

## 📚 Documentation Standards for New Plugins

When creating a new plugin, establish documentation organization from the start:

### Initial Documentation Setup

**Create these files immediately:**
1. **README.md** - Feature overview, installation, basic usage
2. **tests/TEST-PLAN.md** - Testing strategy and workflow (even if just one test initially)
3. **COPILOT-GUIDE.md** - Plugin-specific development patterns for AI agents

**Optional (create as needed):**
- **docs/TEST-QUALITY-REVIEW.md** - Test quality analysis (when you have 20+ tests)
- **docs/REFAC-PLAN.md** - Refactoring plans (if doing major restructuring)

### Documentation Organization Principles

**Single Source of Truth:**
- Each document has ONE focused purpose
- Avoid duplicating information across files
- Link between docs instead of copying content

**Good Organization:**
```
README.md → What the plugin does, how to use it
tests/TEST-PLAN.md → How to test (strategy, workflow, commands)
docs/TEST-QUALITY-REVIEW.md → Test quality analysis and improvements
docs/REFAC-PLAN.md → What to refactor, current status, next steps
COPILOT-GUIDE.md → Development patterns for AI agents
```

**When Documents Exceed 500 Lines:**
1. Identify duplicate content across files
2. Link to other docs instead of duplicating
3. Trim historical progress logs (3-5 lines per session, reference git commits)
4. Focus on "what's next" rather than detailed historical narrative

**Progress Log Guidelines:**
```markdown
# Good - Brief with key insights
**2025-12-15**: Feature X (commit abc1234)
- Implemented SerializerClass (24 fields)
- Found 2 bugs through testing  
- Production validated with 117 items

# Bad - Too detailed, duplicates commit message
**2025-12-15 Morning Session**: Feature X Implementation
What We Did:
1. Created SerializerClass with 24 fields:
   - field1: IntegerField for...
   - field2: CharField for...
   [... 50 more lines ...]
```

**Cross-Reference Examples:**
```markdown
## Testing Strategy
See [TEST-PLAN.md](tests/TEST-PLAN.md) for complete testing workflow.

## Known Issues
See [TEST-QUALITY-REVIEW.md](docs/TEST-QUALITY-REVIEW.md) for test analysis.
```

### COPILOT-GUIDE.md Template

New plugins should include a COPILOT-GUIDE.md with these sections:

```markdown
# GitHub Copilot Guide - [PluginName]

## Quick Context
- Plugin type, description, purpose

## Development Guidelines  
- Communication style preferences
- Code quality standards
- Testing approach (test-first)

## Documentation Organization
- Single source of truth principle
- When to reorganize (>500 lines)
- Progress log guidelines
- Cross-referencing examples

## Plugin Architecture
- Backend/frontend structure
- Common InvenTree patterns
- Available mixins

## Development Workflow
- Feature development steps
- Refactoring workflow
- Testing commands
- Build & deployment

## Common Tasks
- Adding API endpoints
- Adding frontend panels
- Examples with code

## Debugging Tips
- Backend/frontend debugging
- Common issues

## Best Practices
- Code, documentation, testing

## Resources
- Links to toolkit and InvenTree docs
```

**Why this matters:**
- Future AI agents understand plugin-specific patterns
- Consistent documentation organization across all plugins
- Easy to maintain as plugin grows
- Clear guidance prevents documentation sprawl

---

**Last Updated**: December 15, 2025
**Compatible with**: InvenTree 0.16.x+

See `copilot/TERMINAL-TESTING-COMMANDS.md` for terminal commands to run tests, deploy, and fetch logs.
