# Documentation Restructure & Git Hook Implementation Plan

**Date:** December 10, 2025
**Status:** PENDING REVIEW - Implementation paused for docs/ folder analysis

---

## Completed Changes

### 1. Copilot Folder Restructure 

**Old Structure:**
- AI-AGENT-BRIEFING.md (517 lines) - Mixed behavior + architecture
- COPILOT-GUIDE.md (530 lines) - Mixed InvenTree patterns + architecture
- copilot-guided-creation.md (487 lines) - Plugin creation prompts

**New Structure:**
- AGENT-BEHAVIOR.md (220 lines) - Communication style, user context, code rules
- PROJECT-CONTEXT.md (717 lines) - Architecture, tech stack, InvenTree patterns
- plugin-creation-prompts.md (367 lines) - Creation workflow prompts

**Key Improvements:**
-  Clear separation of concerns
-  No overlap between files
-  Toolkit vs Plugin distinction added to PROJECT-CONTEXT.md

### 2. GitHub Copilot Integration 

**Created:**
- .github/copilot-instructions.md - Auto-discovered entry point for agents

**Benefits:**
- GitHub Copilot automatically reads this file
- Points agents to the 3 specialized copilot/ files
- Guarantees agent context discovery

---

## Pending Implementation

### 3. Git Post-Commit Hook (READY TO IMPLEMENT)

**Purpose:** Remind about toolkit documentation updates after committing toolkit infrastructure changes

**File:** .git/hooks/post-commit

**Behavior:**
- Automatically runs after every git commit
- Analyzes changed files (scripts/, copilot/, config/)
- Shows prominent colored reminder in terminal
- Lists specific docs to review
- Visible to AI agents watching terminal output

**What It Shows:**
`
==========================================================================
  TOOLKIT DOCUMENTATION REMINDER
==========================================================================

You modified toolkit infrastructure. Consider updating:

  [SCRIPTS CHANGED]
    - scripts/Build-Plugin.ps1
  Review:
    - docs/QUICK-REFERENCE.md (command usage)
    - docs/WORKFLOWS.md (workflows using these scripts)
    - Script help text in .ps1 files

==========================================================================
`

**Implementation Steps:**
1. Create .git/hooks/post-commit file
2. Copy PowerShell script content (provided above)
3. Test with a dummy commit to scripts/
4. Verify output appears and is visible

### 4. Update PROJECT-CONTEXT.md Documentation Section

**Changes Needed:**
- Add section explaining the git post-commit hook
- Update Documentation Update Routine with git-based workflow
- Clarify when hook triggers (toolkit changes only, not plugin changes)

---

## PAUSED: docs/ Folder Analysis

### Current docs/ Structure:

1. **copilot-prompts.md** (515 lines)
   - Ready-to-use Copilot prompts for common tasks
   - Frontend prompts, backend prompts, debugging prompts
   - Similar purpose to copilot/plugin-creation-prompts.md?

2. **QUICK-REFERENCE.md** (225 lines)
   - Command cheat sheet
   - File reference table
   - Mantine components quick ref
   - InvenTree API endpoints

3. **WORKFLOWS.md** (706 lines)
   - Step-by-step how-to guides
   - Covers: create plugin, add settings, API endpoints, panels, etc.
   - Detailed instructions with code examples

4. **CUSTOM-STATES-GUIDE.md**
   - InvenTree-specific feature documentation
   - How to add custom states via admin panel
   - Not toolkit-specific, more InvenTree knowledge

5. **TESTING-FRAMEWORK-RESEARCH.md** (270 lines)
   - Research notes on Django/InvenTree testing
   - Found during Test-Plugin.ps1 creation
   - Historical context document

### Questions to Answer:

**1. copilot-prompts.md vs copilot/plugin-creation-prompts.md**
- Are these duplicates or different audiences?
- copilot-prompts.md = User-facing prompt library?
- plugin-creation-prompts.md = Agent-facing creation workflow?
- Should we merge or keep separate?

**2. CUSTOM-STATES-GUIDE.md Purpose**
- Is this toolkit documentation or InvenTree knowledge base?
- Should it be in reference/ folder instead?
- Or is it genuinely helpful for toolkit users?

**3. TESTING-FRAMEWORK-RESEARCH.md Purpose**
- Is this historical/archive or active reference?
- Does it belong in docs/ or reference/?
- Should agents be expected to read this?

**4. User-Facing vs Agent-Facing**
- copilot/ = Agent-facing documentation
- docs/ = User-facing documentation?
- Or are docs/ files ALSO for agents to reference?

**5. Overlap Analysis Needed:**
- Compare WORKFLOWS.md with copilot/PROJECT-CONTEXT.md patterns
- Check if copilot-prompts.md duplicates plugin-creation-prompts.md
- Identify any circular references or contradictions

---

## Approved docs/ Restructure

### Final Structure

```
docs/
├── toolkit/                    # Toolkit usage (user + agent)
│   ├── WORKFLOWS.md           # How-to guides
│   └── QUICK-REFERENCE.md     # Command cheat sheet
├── inventree/                  # InvenTree knowledge base (agent-focused)
│   ├── CUSTOM-STATES.md       # Custom states guide
│   └── TESTING-FRAMEWORK.md   # Testing research
└── (DELETE) copilot-prompts.md # Removed - conversational dev doesn't need this
```

### Rationale

**1. copilot-prompts.md → DELETE**
- Development happens conversationally, not via copy/paste prompts
- copilot/plugin-creation-prompts.md serves different purpose (agent-facing workflows)
- Users naturally ask questions without needing prompt templates

**2. Subdirectory Categorization**
- `docs/toolkit/` - How to use the toolkit (workflows, commands)
- `docs/inventree/` - InvenTree internals knowledge (for understanding how things work)
- Clearer than filename prefixes
- Easier to browse and organize
- Scales better as documentation grows

**3. Dual Audience (User + Agent)**
- WORKFLOWS.md - Users follow steps, agents reference patterns
- QUICK-REFERENCE.md - Users look up commands, agents check syntax
- CUSTOM-STATES.md - Users learn feature, agents understand implementation
- TESTING-FRAMEWORK.md - Agents primarily (referenced by PROJECT-CONTEXT.md)

**4. Purpose Headers on All .md Files**
- Adds clear header to every documentation file:
  ```markdown
  **Audience:** Users / AI Agents / Both
  **Category:** Toolkit Usage / InvenTree Knowledge / Agent Guidance
  **Purpose:** [one-line description]
  **Last Updated:** YYYY-MM-DD
  ```
- Helps git post-commit hook provide specific guidance
- Makes documentation intent immediately clear
- Provides context for when to update each file

---

## Recommendations

### Immediate Action: Analyze docs/ Overlap

**Before implementing git hook, answer:**

1. Read all 5 docs/ files completely
2. Map overlapping content between:
   - copilot-prompts.md  plugin-creation-prompts.md
   - WORKFLOWS.md  PROJECT-CONTEXT.md patterns
   - CUSTOM-STATES-GUIDE.md relevance to toolkit
3. Identify intended audience for each file
4. Check if agents should read docs/ or just copilot/

### Implementation Order

**Phase 1: Reorganize docs/ folder**
1. Create `docs/toolkit/` subdirectory
2. Create `docs/inventree/` subdirectory
3. Move WORKFLOWS.md → docs/toolkit/
4. Move QUICK-REFERENCE.md → docs/toolkit/
5. Move CUSTOM-STATES-GUIDE.md → docs/inventree/CUSTOM-STATES.md
6. Move TESTING-FRAMEWORK-RESEARCH.md → docs/inventree/TESTING-FRAMEWORK.md
7. Delete docs/copilot-prompts.md

**Phase 2: Add purpose headers to all .md files**
Add to every documentation file in toolkit:
- copilot/AGENT-BEHAVIOR.md
- copilot/PROJECT-CONTEXT.md
- copilot/plugin-creation-prompts.md
- .github/copilot-instructions.md
- docs/toolkit/WORKFLOWS.md
- docs/toolkit/QUICK-REFERENCE.md
- docs/inventree/CUSTOM-STATES.md
- docs/inventree/TESTING-FRAMEWORK.md
- README.md
- SETUP.md

**Phase 3: Update references to moved files**
1. Update .github/copilot-instructions.md → Point to new docs/ structure
2. Update copilot/PROJECT-CONTEXT.md → Update Documentation Update Routine
3. Search for any cross-references in moved files and update paths

**Phase 4: Implement git post-commit hook**
1. Create .git/hooks/post-commit file with PowerShell script
2. Update script to reference new docs/ paths (docs/toolkit/, docs/inventree/)
3. Add section to PROJECT-CONTEXT.md explaining git hook

**Phase 5: Test and verify**
1. Test git hook with dummy commit to scripts/
2. Verify all file references work
3. Check agents can find documentation
4. Confirm no broken links

---

## Success Criteria

**Documentation System Should:**
-  Clear separation: copilot/ (agent-facing) vs docs/ (user-facing)
-  No duplicate content across files
-  Each file has single clear purpose
-  Toolkit vs Plugin distinction clear everywhere
-  Git hook reminds about toolkit doc updates
-  Agents know which files to read when
-  Users know where to find answers

**Completion Checklist:**
- [x] All overlap identified and resolved
- [x] Git hook implemented and tested
- [x] PROJECT-CONTEXT.md updated with git workflow
- [x] All files have clear purpose headers
- [x] Cross-references updated
- [x] User can navigate docs intuitively
- [x] Agents get correct context automatically

---

## Implementation Status

✅ **ALL PHASES COMPLETED**

- [x] Copilot folder restructured (AGENT-BEHAVIOR.md, PROJECT-CONTEXT.md, plugin-creation-prompts.md)
- [x] GitHub Copilot integration (.github/copilot-instructions.md auto-discovered)
- [x] Toolkit vs Plugin distinction added to PROJECT-CONTEXT.md
- [x] docs/ restructure executed (docs/toolkit/ and docs/inventree/ subdirectories)
- [x] copilot-prompts.md deleted (not needed for conversational development)
- [x] Purpose headers added to all 10 .md files
- [x] File references updated in README.md, SETUP.md, .github/copilot-instructions.md, AGENT-BEHAVIOR.md, QUICK-REFERENCE.md
- [x] Git post-commit hook installed (.git/hooks/post-commit and post-commit.ps1)
- [x] Git hook tested successfully (detects toolkit changes, displays reminders)
- [x] Documentation Update System section added to PROJECT-CONTEXT.md

**Final Structure:**
```
copilot/
  AGENT-BEHAVIOR.md (Communication guidelines)
  PROJECT-CONTEXT.md (Technical architecture)
  plugin-creation-prompts.md (Workflow prompts)
docs/
  toolkit/
    WORKFLOWS.md (How-to guides)
    QUICK-REFERENCE.md (Command reference)
  inventree/
    CUSTOM-STATES.md (InvenTree knowledge)
    TESTING-FRAMEWORK.md (Django testing patterns)
.github/
  copilot-instructions.md (Auto-discovered entry point)
README.md (Toolkit overview)
SETUP.md (Installation guide)
```

**Verification:**
- Git hook triggers on script changes: ✅ Tested with Test-Plugin.ps1
- Documentation paths resolve: ✅ All references updated
- Purpose headers formatted correctly: ✅ All 10 files updated
- Agents can discover docs: ✅ .github/copilot-instructions.md in place
- [ ] Adding purpose headers to all .md files (Phase 2)
- [ ] Updating file references (Phase 3)
- [ ] Implementing git post-commit hook (Phase 4)
- [ ] Testing and verification (Phase 5)

---

**Plan Author:** GitHub Copilot Agent
**Status:** APPROVED - Implementation in progress
**Last Updated:** December 10, 2025
