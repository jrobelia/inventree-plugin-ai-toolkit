# InvenTree Plugin Development - Guided Creation Prompts

This file contains prompts designed to help GitHub Copilot guide you through creating InvenTree plugins intelligently.

---

## 🚀 CREATE NEW PLUGIN - Intelligent Guided Workflow

**Primary Prompt: Start here for new plugins**

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

**What makes this better:**
- Copilot understands context before recommending mixins
- You don't need to know InvenTree internals upfront
- Recommendations are based on actual requirements
- Avoids including unnecessary mixins

**IMPORTANT:** The plugin-creator tool is fully interactive and does NOT support piped input or answer files. After gathering requirements, provide all answers in a clean, copy-paste friendly format that the user can use while answering the prompts.

**ANSWER FORMAT REQUIREMENT:**
Always format the answers in a SINGLE code block with this exact structure:
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

This ensures consistency and makes it easy for the user to reference while running the interactive prompts.

---

## 📝 COMPLETE QUESTION REFERENCE

**All questions that plugin-creator will ask (in order):**

1. **Enter plugin name:** Human-readable name (e.g., "Flat BOM Viewer")
2. **Enter plugin description:** Brief description of what the plugin does
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

8. **[Only if UserInterfaceMixin selected] Select frontend features:** (spacebar to toggle)
   - Custom dashboard items
   - Custom panel items
   - Custom settings display

9. **[Only if UserInterfaceMixin selected] Enable translation support?** y/n
   - Choose 'n' unless you need multi-language support

10. **Enable Git integration?** y/n
    - Choose 'y' (recommended for version control)

11. **[Only if Git enabled] DevOps support (CI/CD)?** (arrow keys to select, enter to confirm)
    - **None** - No automated testing/deployment (recommended for beginners)
    - **GitHub Actions** - Automated tests run on GitHub when you push code
    - **GitLab CI/CD** - Automated tests run on GitLab when you push code
    
    **Recommendation:** Choose 'None' unless you're publishing to GitHub/GitLab and want automated testing

**Important Notes:**
- Use **spacebar** to toggle checkbox selections, **enter** to confirm
- Use **arrow keys** for single-choice selections (like license, DevOps)
- Plugin name becomes the class name (spaces removed)
- Plugin slug is auto-generated (lowercase with hyphens)
- Frontend features only appear if UserInterfaceMixin is selected
- DevOps question only appears if Git integration is enabled

---

## 🧠 MIXIN INTELLIGENCE - Get Smart Recommendations

**When you know what you want to do, but not which mixins:**

```
My InvenTree plugin needs to:
- [Describe requirement 1]
- [Describe requirement 2]  
- [Describe requirement 3]

For each requirement:
1. Tell me which mixin(s) to use
2. Explain what the mixin does
3. Show key methods I'll implement
4. Warn about any gotchas or dependencies
5. Provide a simple code example

Then give me a final recommendation of all mixins I should enable.
```

**Example use cases:**

```
My InvenTree plugin needs to:
- Send an email when a sales order ships
- Add a custom field validation for part numbers
- Display a custom dashboard showing low stock alerts

[Copilot will recommend EventMixin, ValidationMixin, ScheduleMixin, etc.]
```

---

## 📋 SCENARIO-BASED PLUGIN CREATION

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
1. Set up APIMixin and UrlsMixin
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

---

## 🎨 FRONTEND-ENABLED PLUGINS

**When your plugin needs React UI components:**

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

## 🔍 UNDERSTAND BEFORE BUILDING

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

## 🔧 ENHANCE EXISTING PLUGIN

### Add Functionality

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

### Optimize Performance

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

## 🐛 DEBUG & TROUBLESHOOT

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

---

## ✅ PRE-DEPLOYMENT CHECKLIST

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

## 💡 QUICK HELPERS

### Get Examples
```
Show me a complete example of an InvenTree plugin that [does X]
```

### Understand Errors
```
InvenTree error: [paste error message]

What does this mean and how do I fix it?
```

### API Documentation
```
Show me InvenTree API documentation for [model/endpoint]
```

### Best Practices
```
What are InvenTree plugin development best practices for [topic]?
```

---

## 🎯 WORKFLOW EXAMPLE

**Typical session flow:**

1. **Start:** Use the main "CREATE NEW PLUGIN" prompt
2. **Discuss:** Answer Copilot's questions about requirements
3. **Review:** Copilot recommends architecture and mixins
4. **Confirm:** Approve the recommendations
5. **Generate:** Copilot creates the answers file and command
6. **Create:** Execute plugin-creator with the answers
7. **Develop:** Use specific scenario prompts for implementation
8. **Test:** Use debugging prompts if issues arise
9. **Deploy:** Use pre-deployment checklist

---

## 📚 LEARNING RESOURCES

**Ask Copilot to explain concepts:**

```
Explain InvenTree [concept] with examples:
- Plugin lifecycle and hooks
- Event system and signals
- Status code architecture
- API authentication
- Frontend integration
- Custom states vs status codes
```

---

**Note:** These prompts are designed to make Copilot act as an InvenTree plugin development expert who asks clarifying questions and provides intelligent recommendations based on your actual requirements, not just template answers.
