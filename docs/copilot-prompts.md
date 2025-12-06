# Ready-to-Use Copilot Prompts

Copy and paste these prompts into GitHub Copilot Chat to get help with common tasks.

Replace `[YOUR_DETAILS]` with your specific information.

---

## 🎨 Frontend / UI Prompts

### Create a Custom Panel

```
@workspace Create a custom panel for InvenTree Part pages in frontend/src/Panel.tsx that:
- Shows a table of custom data for the current part
- Uses Mantine Table component
- Has a refresh button
- Displays part name from context.instance
- Uses blue color theme

Also update core.py to register this panel with key 'custom-data-panel'
```

### Add API Call to Frontend

```
@workspace In frontend/src/Panel.tsx, add code to fetch data from my plugin API:
- Endpoint: /plugin/[YOUR_PLUGIN_SLUG]/[YOUR_ENDPOINT]/
- Use React Query (useQuery)
- Show loading spinner while fetching
- Display error message if it fails
- Show the data in a Mantine Alert component
```

### Create Dashboard Widget

```
@workspace Create a dashboard widget in frontend/src/Dashboard.tsx that:
- Shows statistics with numbers in large text
- Has 3 cards in a row using Mantine SimpleGrid
- Each card shows a label and a value
- Uses icons from tabler-icons
- Make it responsive

Also register this in core.py get_ui_dashboard_items
```

### Fix Frontend Build Error

```
I'm getting this error when building my InvenTree plugin frontend:
[PASTE ERROR HERE]

My setup:
- React 19
- Mantine 8
- TypeScript
- Vite 6

What's wrong and how do I fix it? Show me exactly what to change.
```

---

## 🐍 Backend / Python Prompts

### Add Plugin Setting

```
@workspace Add a new plugin setting to core.py:
- Name: [SETTING_NAME]
- Type: [string/int/bool]
- Default value: [DEFAULT]
- Description: "[WHAT IT DOES]"
- Protected: [yes/no]

Follow the existing SETTINGS pattern in the file.
```

### Create API Endpoint

```
@workspace Create a new API endpoint for my InvenTree plugin:

In views.py:
- Create a view called [ViewName]
- Method: [GET/POST]
- Accept parameters: [PARAMETERS]
- Return JSON with: [DATA STRUCTURE]
- Require authentication

In core.py:
- Register this endpoint at path '[PATH]'
```

### Add Database Model

```
@workspace Create a Django model in models.py:
- Model name: [ModelName]
- Fields:
  - [field1]: [type] - [description]
  - [field2]: [type] - [description]
- Add Meta class with app_label set to '[package_name]'
- Add __str__ method

Then show me how to create migrations for this.
```

### Add Scheduled Task

```
@workspace Add a scheduled task to my InvenTree plugin in core.py:
- Task name: [TASK_NAME]
- Schedule: [daily/hourly/weekly at specific time]
- Function: [WHAT IT DOES]

Show me:
1. How to add it to SCHEDULED_TASKS
2. How to create the function that runs
```

### Handle Events

```
@workspace Add event handling to my InvenTree plugin:
- Listen for event: [EVENT_NAME] (e.g., 'part_part.created')
- In core.py, implement wants_process_event and process_event
- When triggered: [WHAT TO DO]

Show me the complete code.
```

---

## 🔧 Configuration & Setup Prompts

### Add Python Dependency

```
@workspace I need to add a Python package dependency to my plugin.
- Package name: [PACKAGE_NAME]
- Version: [VERSION or 'latest']

Show me exactly where to add it in pyproject.toml
```

### Add Frontend Dependency

```
@workspace I want to use a new npm package in my plugin frontend.
- Package name: [PACKAGE_NAME]
- What it does: [DESCRIPTION]

Show me:
1. What to add to package.json
2. How to import and use it in my .tsx files
```

### Configure Plugin Icons

```
@workspace Help me find and use appropriate icons for my InvenTree plugin:
- I need icons for: [LIST WHAT YOU NEED ICONS FOR]
- Using tabler-icons (format: 'ti:icon-name')

Show me a list of good icon options and how to use them in:
1. Panel registration (core.py)
2. React components (Button, Alert, etc.)
```

---

## 🐛 Debugging Prompts

### Debug Python Error

```
My InvenTree plugin is throwing this error:
[PASTE FULL ERROR TRACEBACK]

Plugin details:
- Location: plugins/[PLUGIN_NAME]/
- Mixins used: [LIST MIXINS]
- Last thing I changed: [WHAT YOU CHANGED]

Help me diagnose and fix this.
```

### Debug Frontend Error

```
My plugin frontend has this error in the browser console:
[PASTE ERROR]

Component: [Panel/Dashboard/Settings]
File: frontend/src/[FILENAME]

What's wrong and how do I fix it?
```

### Plugin Not Loading

```
My plugin doesn't appear in InvenTree after deployment.

Plugin info:
- Name: [PLUGIN_NAME]
- Location on server: [PATH]
- Has __init__.py: yes/no
- Has core.py with plugin class: yes/no
- Deployed to: [staging/production]
- InvenTree restarted: yes/no

What should I check?
```

### Panel Not Showing

```
I registered a custom panel but it doesn't show up on the page.

In core.py get_ui_panels():
[PASTE YOUR CODE]

In Panel.tsx:
[PASTE YOUR CODE]

target_model: [MODEL_TYPE, e.g., 'part']

What's missing?
```

---

## 📖 Learning & Explanation Prompts

### Understand Context Object

```
@workspace Explain the InvenTreePluginContext object that gets passed to frontend components.
What properties does it have and what are they used for?
Give me examples of the most useful ones.
```

### Explain Mixin

```
@workspace Explain what the [MIXIN_NAME] mixin does in InvenTree plugins.
Show me:
1. What capabilities it adds
2. What methods I need to implement
3. A simple example of using it
```

### Understand API Response

```
I'm calling this InvenTree API endpoint: [ENDPOINT_URL]
What data does it return? Show me the structure.

Can you give me a TypeScript interface for this response?
```

### Compare Approaches

```
@workspace What's the difference between adding a panel and adding a dashboard item in InvenTree plugins?
When should I use each one?
Show me examples of both.
```

---

## ✨ Feature Request Prompts

### Create Complete Feature

```
@workspace I want to add a complete feature to my InvenTree plugin:

Feature: [DESCRIBE THE FEATURE]

Requirements:
- Backend API endpoint: [WHAT IT DOES]
- Frontend panel/dashboard: [WHERE IT SHOWS]
- Settings: [WHAT'S CONFIGURABLE]
- Data to display: [WHAT DATA]

Guide me through implementing this step by step.
```

### Add Search Functionality

```
@workspace Add search functionality to my plugin:
- Search through: [WHAT DATA]
- Display results in: [Panel/Dashboard]
- Use Mantine TextInput component
- Filter results as user types
- Show "No results" message when empty

Show me the complete implementation.
```

### Add Form for User Input

```
@workspace Create a form in my frontend panel where users can:
- Input fields: [LIST FIELDS AND TYPES]
- Submit button that calls: /plugin/[PLUGIN_SLUG]/[ENDPOINT]/
- Show success notification on submit
- Handle errors gracefully
- Use Mantine form components

Show me the complete code.
```

---

## 🎯 Specific Component Prompts

### Mantine Table

```
@workspace Create a Mantine Table in my Panel.tsx that:
- Displays data from API: [ENDPOINT]
- Columns: [LIST COLUMNS]
- Sortable: yes/no
- Has pagination: yes/no
- Row click action: [WHAT HAPPENS]
```

### Mantine Modal

```
@workspace Add a Mantine Modal to my frontend component that:
- Opens when: [TRIGGER]
- Contains: [FORM/CONTENT]
- Has buttons: [BUTTONS]
- On submit: [ACTION]
```

### Chart/Graph

```
@workspace I want to add a chart to my dashboard widget:
- Chart type: [bar/line/pie]
- Data source: [WHERE DATA COMES FROM]
- X-axis: [LABEL]
- Y-axis: [LABEL]

What library should I use with Mantine and how do I implement it?
```

---

## 🔄 Migration & Updates Prompts

### Update Plugin to New Version

```
@workspace I want to update my plugin dependencies:
- Update Mantine from [OLD_VERSION] to [NEW_VERSION]
- Update React from [OLD_VERSION] to [NEW_VERSION]

What do I need to change in:
1. package.json
2. My component code (any breaking changes?)
```

### Migrate from Old Pattern

```
@workspace I have old code that does [DESCRIBE OLD WAY].
Help me refactor it to use the current InvenTree plugin pattern.

Old code:
[PASTE OLD CODE]

What's the modern way to do this?
```

---

## 💼 Best Practices Prompts

### Code Review

```
@workspace Review this code from my InvenTree plugin:
[PASTE CODE]

Check for:
- Best practices
- Potential bugs
- Performance issues
- Security concerns
- InvenTree plugin patterns

Suggest improvements.
```

### Optimize Performance

```
@workspace This part of my plugin is slow:
[PASTE CODE]

It does: [DESCRIPTION]
Performance issue: [WHAT'S SLOW]

How can I optimize this?
```

---

## 📝 Documentation Prompts

### Generate Documentation

```
@workspace Generate documentation for my plugin feature:
[PASTE CODE]

Create:
1. Docstrings for functions
2. Comments explaining complex parts
3. README section describing this feature
```

### Create User Guide

```
@workspace Create a user guide section for my plugin's README:
- Feature name: [FEATURE]
- What it does: [DESCRIPTION]
- How to use it: [STEPS]
- Settings involved: [SETTINGS]

Write it for InvenTree users (not developers).
```

---

## 🎓 Template Prompts

Use these as starting points and fill in the details:

### General Feature Request
```
@workspace In my InvenTree plugin, I want to [ACTION]:
- Component: [frontend/backend/both]
- Triggered by: [USER ACTION/EVENT/SCHEDULE]
- Uses data from: [SOURCE]
- Displays/Returns: [OUTPUT]

Show me how to implement this following InvenTree plugin best practices.
```

### General Debug Request
```
I'm having this issue with my InvenTree plugin:
- Problem: [DESCRIBE ISSUE]
- Expected: [WHAT SHOULD HAPPEN]
- Actually happening: [WHAT'S HAPPENING]
- Error (if any): [ERROR MESSAGE]
- Recent changes: [WHAT YOU CHANGED]

Help me fix it.
```

---

## 💡 Pro Tips for Using These Prompts

1. **Be Specific:** The more details you provide, the better Copilot's suggestions
2. **Include Context:** Mention you're working on an InvenTree plugin
3. **Use @workspace:** This gives Copilot access to your whole project
4. **Paste Code:** Include relevant code snippets in your prompts
5. **Iterate:** If the first answer isn't perfect, ask follow-up questions

---

## 📚 Examples of Good vs. Bad Prompts

### ❌ Bad Prompt
```
Create a panel
```

### ✅ Good Prompt
```
@workspace Create a custom panel for InvenTree Part pages in frontend/src/Panel.tsx
that displays a table of recent stock movements using Mantine Table component.
Also register it in core.py with appropriate icon and title.
```

### ❌ Bad Prompt
```
Fix error
```

### ✅ Good Prompt
```
I'm getting "TypeError: Cannot read property 'id' of undefined" in Panel.tsx line 42.
The error happens when I try to access context.instance.name.
Here's my code: [PASTE CODE]
How do I safely access nested properties?
```

---

Save this file and copy these prompts whenever you need Copilot's help! 🚀
