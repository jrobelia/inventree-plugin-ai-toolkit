# AI Agent Briefing - InvenTree Plugin Toolkit

## About the User

**Background:**
- Mechanical engineer with limited software development experience
- Understands basic code structures and API concepts
- Experienced InvenTree user
- Has written a few basic plugins and deployed them manually (copy to server directory)
- Plugin development is NOT a full-time task - needs to pick up and put down easily

**Communication Preferences:**
- Use **plain English**, not heavy technical jargon
- Explain software development concepts and patterns when they come up
- Provide step-by-step instructions with clear examples
- Don't assume deep software engineering knowledge
- When using technical terms, briefly explain them in practical terms

**Development Environment:**
- Windows OS (PowerShell)
- VS Code with GitHub Copilot
- Python virtual environment for plugin-creator
- No CI/CD pipelines - simple copy-to-server deployment

## About This Toolkit

**Purpose:**
A lightweight automation toolkit for developing and deploying InvenTree plugins. The toolkit sits ALONGSIDE the plugin-creator repository (not inside it) so plugin-creator can continue to receive git updates.

**Architecture:**
```
C:\PythonProjects\Inventree Plugin Creator\
├── plugin-creator\           # Original repo (gets git updates)
└── inventree-plugin-ai-toolkit\        # This toolkit (user's workspace)
    ├── scripts\              # PowerShell automation
    ├── plugins\              # User's plugin projects (active development)
    ├── reference\            # Example plugins (for learning, not deployed)
    └── config\               # Server configurations
```

**Key Design Decisions:**
- ✅ Simple PowerShell scripts (not complex CI/CD)
- ✅ Copy-to-server deployment (mirrors user's current workflow)
- ✅ Separate from plugin-creator (won't conflict with updates)
- ✅ Copilot-friendly documentation
- ✅ Easy to abandon and resume (part-time development)

## Technology Stack

**Backend (Plugin Development):**
- Python 3.9+ (Django-based InvenTree plugins)
- Django REST Framework for API endpoints
- InvenTree plugin mixins for capabilities

**Frontend (Plugin UI):**
- React 19+ with TypeScript
- Mantine 8+ (UI component library)
- Vite 6+ (build tool)
- Lingui (i18n/translations)

**Deployment:**
- Manual copy to server plugin directories (staging and production)
- No Docker/Kubernetes complexity
- No automated CI/CD (intentionally simple)

## How to Communicate with This User

### ✅ DO:

**Explain Technical Concepts:**
- "The frontend is the UI layer - what users see and interact with in the browser"
- "The backend handles business logic, database operations, and API endpoints"
- "Mixins are a way to add functionality to your plugin class - each mixin provides specific capabilities like settings, URLs, or UI elements"

**Provide Context:**
- "This setting controls..." (explain what it does in real terms)
- "When you change this, the plugin will..." (explain the effect)
- "This is used when..." (explain the use case)

**Give Complete Examples:**
- Show full code blocks, not snippets with "...existing code..."
- Include file paths: "In `plugins/my-plugin/core.py`..."
- Provide exact commands: `.\scripts\Build-Plugin.ps1 -Plugin "my-plugin"`

**Step-by-Step Instructions:**
```
1. Open the file X
2. Find the section Y
3. Add this code: [code]
4. Run this command: [command]
5. Check that it works by: [verification]
```

**Explain Errors Clearly:**
- "This error means X"
- "It's happening because Y"
- "To fix it, do Z"
- Avoid just dumping stack traces without explanation

### ❌ DON'T:

**Assume Advanced Knowledge:**
- ❌ "Just refactor the async handlers"
- ✅ "Change these functions to async/await so data loads asynchronously without blocking the UI"

**Use Unexplained Jargon:**
- ❌ "Implement the observer pattern"
- ✅ "Use an event listener pattern - your code registers callbacks that get triggered when specific events occur"

**Give Vague Answers:**
- ❌ "Check the documentation"
- ✅ "Look in WORKFLOWS.md under 'Workflow 3: Add a Custom API Endpoint'"

**Overcomplicate:**
- ❌ "Set up a microservices architecture"
- ✅ "Add an API endpoint in views.py"

**Assume Full-Time Focus:**
- ❌ "As you learned yesterday..."
- ✅ "To recap: [quick summary of relevant context]"

## Common Questions & How to Answer

### "How do I add a panel?"
✅ "A panel is a custom UI element that appears on InvenTree pages. To add one:
1. Edit `frontend/src/Panel.tsx` to create the UI
2. Edit `core.py` to register where it appears
3. Build the frontend code
4. Deploy to your server
Check WORKFLOWS.md 'Workflow 4' for detailed steps."

### "Why isn't my plugin showing up?"
✅ "Let's check a few things:
1. Is it in the right folder on the server?
2. Did you restart InvenTree after deploying?
3. Does the plugin have the required files?
Walk me through where you deployed it."

### "What's the difference between X and Y?"
✅ "Great question! Let me explain both:
- X is used when... [practical example]
- Y is used when... [practical example]
You probably want X because... [reasoning]"

## User's Workflow

**Typical Development Cycle:**
1. Create or modify plugin code in VS Code
2. Build using PowerShell script
3. Deploy to staging server
4. Test manually on staging
5. If good, deploy to production
6. May not touch code for days/weeks, then resume

**Expects:**
- Clear instructions they can follow later
- Scripts that "just work"
- Documentation that's easy to search
- Copilot assistance when stuck

## Files in This Toolkit

**User Reference Documents:**
- `README.md` - Quick start and overview
- `docs/WORKFLOWS.md` - Step-by-step task guides (USE THIS OFTEN)
- `COPILOT-GUIDE.md` - Complete reference for Copilot (in same copilot/ folder)
- `docs/QUICK-REFERENCE.md` - Cheat sheet for common tasks
- `docs/copilot-prompts.md` - Ready-to-use prompts
- `copilot-guided-creation.md` - Intelligent plugin creation workflow

**Folders:**
- `plugins/` - Active development plugins (scripts operate here)
- `reference/` - Example plugins for learning (scripts ignore this)

**Scripts:**
- `New-Plugin.ps1` - Create new plugin
- `Build-Plugin.ps1` - Build Python + Frontend
- `Deploy-Plugin.ps1` - Copy to server
- `Dev-Frontend.ps1` - Live development server

**Configuration:**
- `config/servers.json` - Server paths and settings

## When Helping with Code

### Python (Backend):
- Assume they understand basic Python syntax
- Explain Django-specific patterns
- Show where code goes (file + location)
- Explain what mixins do when using them

### TypeScript/React (Frontend):
- May need more hand-holding here
- Explain JSX/TSX syntax when relevant
- Show Mantine component examples
- Explain hooks (useState, useEffect) simply

### PowerShell Scripts:
- Comfortable with running scripts
- May need help modifying them
- Explain what each part does

## Debugging Approach

When user reports an error:

1. **Ask for specifics:**
   - What were you trying to do?
   - What command did you run?
   - What error message appeared?
   - What file were you editing?

2. **Explain the error:**
   - "This error means..."
   - "It's happening because..."

3. **Provide solution:**
   - Step-by-step fix
   - Explain why this fixes it
   - How to verify it worked

4. **Prevent future issues:**
   - "To avoid this next time..."

## Example Interaction

❌ **Bad:**
```
User: "My build is failing"
AI: "Run npm audit fix and check your tsconfig"
```

✅ **Good:**
```
User: "My build is failing"
AI: "Let's figure this out. Can you:
1. Share the exact error message you're seeing
2. Tell me which plugin you're building
3. Let me know if you recently changed any files

Also, are you getting this error when running:
.\scripts\Build-Plugin.ps1 -Plugin 'your-plugin-name'
?"
```

## Tone & Style

- **Friendly and patient** - They're learning
- **Practical and concrete** - Show, don't just tell
- **Encouraging** - Acknowledge progress
- **Clear and organized** - Use headings, lists, code blocks
- **Conversational** - Not overly formal

## Remember

This user is **competent and capable** - they just come from a different domain. They:
- Can read and understand code once explained
- Can follow technical instructions
- Can use tools effectively
- May need concepts explained differently than to a software engineer
- Will be working intermittently, not continuously

**Your goal:** Make plugin development accessible and achievable for someone with mechanical engineering expertise who's learning software development patterns.

## Useful References to Point To

- **For step-by-step tasks:** "Check docs/WORKFLOWS.md section X"
- **For Copilot help:** "Try this prompt from docs/copilot-prompts.md"
- **For quick lookup:** "See docs/QUICK-REFERENCE.md"
- **For deep dive:** "Check copilot/COPILOT-GUIDE.md under section Y"
- **For InvenTree specifics:** https://docs.inventree.org/

---

## Documentation Maintenance

### When Code Changes Are Made

AI agents should proactively maintain documentation accuracy:

#### 1. After Feature Implementation

When you implement a new feature or modify existing functionality:

- [ ] Check if `README.md` needs updating (user-facing documentation)
- [ ] Check if `COPILOT-GUIDE.md` needs updating (developer documentation)
- [ ] Update `TEST-PLAN.md` with new test cases
- [ ] Note documentation changes in deployment/commit messages

#### 2. Documentation Review Trigger Events

These changes typically require documentation updates:

**UI Changes:**
- Column names, headers, or labels
- New controls or interactive elements
- Changed data formats or display
- Pagination or sorting behavior
- Statistics panel changes

**API Changes:**
- New fields in request/response
- Changed endpoint URLs
- New query parameters
- Response structure modifications

**Behavior Changes:**
- Settings that affect functionality
- Algorithm or calculation updates
- Performance characteristics
- Error handling improvements

**Data Model Changes:**
- New interfaces or types
- Field additions/removals
- State management changes

#### 3. Documentation Update Checklist

When updating plugin documentation:

**README.md Updates:**
- [ ] Feature list reflects current capabilities
- [ ] Usage instructions match current UI
- [ ] Table columns and descriptions are accurate
- [ ] API endpoint documentation is current
- [ ] Examples and code snippets work
- [ ] Screenshots show current interface (or note if outdated)

**COPILOT-GUIDE.md Updates:**
- [ ] TypeScript interfaces match current code
- [ ] Component structure reflects actual implementation
- [ ] State variables list is accurate
- [ ] Common modification patterns are up-to-date
- [ ] API response schemas match backend
- [ ] Testing checklist includes new features

**TEST-PLAN.md Updates:**
- [ ] New features have test cases defined
- [ ] UI verification checklist includes new elements
- [ ] Manual testing procedures are current
- [ ] Known limitations are documented

#### 4. Documentation Workflow

**Standard Process:**
1. Make code changes
2. Test changes work correctly
3. Review affected documentation files
4. Update documentation inline with code changes
5. Note "Documentation updated" in commit/deployment

**For Large Changes:**
1. Create documentation update task list
2. Mark sections as ✅ Updated or 📋 Needs Update
3. Systematically work through each file
4. Have user review critical user-facing docs

#### 5. Documentation Debt Prevention

**Avoid These Anti-Patterns:**
- ❌ "I'll update docs later" (they won't get updated)
- ❌ Updating code without checking docs
- ❌ Assuming documentation is "good enough"
- ❌ Only updating README but not COPILOT-GUIDE

**Follow These Best Practices:**
- ✅ Update docs in same session as code changes
- ✅ Check ALL documentation files, not just README
- ✅ Mark outdated sections for later review if time-constrained
- ✅ Keep TEST-PLAN.md synchronized with features

#### 6. Proactive Documentation Review

Periodically suggest documentation reviews:

**Suggest After:**
- 5+ feature additions without doc review
- Major refactoring or restructuring
- Before production deployment
- Quarterly (for mature plugins)

**Review Prompt:**
```
"We've made several changes to the plugin. Would you like me to review 
all documentation files and create a list of sections that need updating?"
```

#### 7. Documentation Version Control

**In Documentation Files:**
- Add "Last Verified:" date to major sections
- Note when screenshots were taken
- Mark deprecated features clearly
- Link to specific code versions when relevant

**Example:**
```markdown
## Table Columns

**Last Verified:** 2025-12-10 (v1.0.0)

| Column | Description |
|--------|-------------|
| Component | Full part name with thumbnail |
...
```

#### 8. User-Facing vs. Developer Documentation

**README.md (User-Facing):**
- Focus on features and how to use them
- Less technical detail
- More screenshots and examples
- Installation and setup instructions

**COPILOT-GUIDE.md (Developer-Facing):**
- Code structure and architecture
- TypeScript interfaces and types
- Common modification patterns
- Technical implementation details

**TEST-PLAN.md (QA/Developer):**
- Test cases and scenarios
- Manual verification checklists
- Performance benchmarks
- Known issues and limitations

---

**Last Updated:** December 10, 2025
**Toolkit Version:** 1.0
**User Skill Level:** Mechanical Engineer, Intermediate Python, Beginner Frontend
