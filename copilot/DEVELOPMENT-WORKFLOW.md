# Universal Development Workflow

**Audience:** AI Agents (GitHub Copilot) | **Purpose:** Standard workflow for plugin development | **Last Updated:** January 18, 2026

---

## Overview

This workflow applies to **ALL plugin development** in this toolkit. It ensures incremental progress, frequent verification, and easy resumability for part-time development.

**Key Principles:**
- **Small changes** - 1-3 files at a time
- **Frequent testing** - After every change
- **Frequent commits** - After every verification
- **Phase-based work** - Break large tasks into 3-5 phases
- **Manual verification** - Always test on staging before marking complete

---

## Before Starting Work

### 1. Check Project Status

```powershell
# Check git status
git status

# Check recent commits
git log --oneline -10

# Check what's deployed vs uncommitted
git diff HEAD
```

**Questions to answer:**
- What's the last commit?
- Are there uncommitted changes?
- What version is on staging/production?
- Any WIP branches?

### 2. Create TODO List (if 3+ steps)

> **Rules:** See `.github/instructions/taming-copilot.instructions.md` → "Work Breakdown & Progress Tracking" for mandatory TODO list requirements.

**Quick reminder:**
- Use `manage_todo_list` tool for 3+ steps, 5+ files, or 30+ minutes work
- Create FIRST before touching code
- Mark ONE item in-progress at a time
- Mark completed IMMEDIATELY after verification

### 3. Review Documentation

**Always check:**
- [ ] Plugin's `ARCHITECTURE.md` - Understand structure
- [ ] Plugin's `ROADMAP.md` - What's planned, what's complete
- [ ] Plugin's `TEST-PLAN.md` - Testing strategy
- [ ] Toolkit's `.github/instructions/*.md` - Coding patterns

---

## During Development

### Incremental Change Pattern

**Make changes in small, verifiable increments:**

1. **Plan the change** - What files need to change?
2. **Make 1-3 file changes** - Keep it small
3. **Run unit tests** - Verify logic works
4. **Run integration tests** - Verify with InvenTree models (if applicable)
5. **Build plugin** - Ensure code compiles
6. **Deploy to staging** - Test in real environment
7. **Manual browser test** - Verify UI works
8. **Commit** - Save checkpoint

**DO NOT** skip steps. If a step fails, fix it before proceeding.

### Code → Test → Deploy → Verify Loop

```
┌─────────────────────────────────────────────────┐
│ 1. WRITE CODE (1-3 files)                      │
└──────────────────┬──────────────────────────────┘
                   ↓
┌─────────────────────────────────────────────────┐
│ 2. RUN UNIT TESTS                               │
│    .\scripts\Test-Plugin.ps1 -Plugin "X" -Unit │
└──────────────────┬──────────────────────────────┘
                   ↓ (if pass)
┌─────────────────────────────────────────────────┐
│ 3. RUN INTEGRATION TESTS (if applicable)        │
│    .\scripts\Test-Plugin.ps1 -Plugin "X" -Int  │
└──────────────────┬──────────────────────────────┘
                   ↓ (if pass)
┌─────────────────────────────────────────────────┐
│ 4. BUILD PLUGIN                                 │
│    .\scripts\Build-Plugin.ps1 -Plugin "X"      │
└──────────────────┬──────────────────────────────┘
                   ↓ (if succeeds)
┌─────────────────────────────────────────────────┐
│ 5. DEPLOY TO STAGING                            │
│    .\scripts\Deploy-Plugin.ps1 -Plugin "X"     │
│           -Server staging                       │
└──────────────────┬──────────────────────────────┘
                   ↓ (after deploy)
┌─────────────────────────────────────────────────┐
│ 6. MANUAL BROWSER TEST                          │
│    - Open staging server                        │
│    - Test feature in UI                         │
│    - Check F12 console for errors               │
└──────────────────┬──────────────────────────────┘
                   ↓ (if works)
┌─────────────────────────────────────────────────┐
│ 7. COMMIT                                       │
│    git add <files>                              │
│    git commit -m "type: description"            │
└─────────────────────────────────────────────────┘
```

### When to Pause and Ask User

> **Rules:** See `.github/instructions/taming-copilot.instructions.md` → "Agent Pause Points" for full guidance.

**Quick reminder - STOP and request user verification after:**
- [ ] Phase 1 of multi-phase work complete
- [ ] First deployment of new feature
- [ ] After fixing a bug (confirm fix works on server)
- [ ] After 1 hour of continuous work

---

## After Each Phase

### Phase Completion Checklist

> **Rules:** See `.github/instructions/taming-copilot.instructions.md` → "Phase Completion Definition" for full criteria.

**Quick reminder - Phase complete when ALL verified:**
- [ ] Tests pass → Build succeeds → Deployed → Browser works → Committed

**DO NOT** start next phase until current phase is fully verified.

### Commit Standards

> **Rules:** See `.github/instructions/taming-copilot.instructions.md` → "Version Control Discipline" for commit frequency and message format.

**Quick reminder:**
- Commit IMMEDIATELY after tests pass + manual verification
- Commit BEFORE deploying or starting next phase
- NEVER commit failing tests or broken code
- Use conventional commits: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`

### Update TODO List

**After completing each item:**
1. Mark item as completed in TODO list
2. Update list if next steps changed based on learnings
3. Show user progress summary if significant milestone

---

## Manual Testing Checklist

**Run this after EVERY deployment:**

### Backend Testing
- [ ] API endpoint returns 200 status
- [ ] Response structure matches TypeScript interface
- [ ] No server errors in InvenTree logs
- [ ] Database queries are efficient (check Django debug toolbar)

### Frontend Testing
- [ ] Panel/page loads without errors
- [ ] UI components display correctly
- [ ] Interactive features work (buttons, checkboxes, inputs)
- [ ] Browser console shows no errors (F12 → Console)
- [ ] Network tab shows successful API calls (F12 → Network)
- [ ] Data displays correctly in all columns/fields

### Integration Testing
- [ ] Feature works with real InvenTree data
- [ ] Edge cases handled gracefully (empty data, None values)
- [ ] Pagination/filtering works if applicable
- [ ] Export/print features work if applicable

---

## When Tests Fail

### Recovery Workflow

If test/build/deploy fails:

1. **Read error completely** - Don't skim, understand the full message
2. **Identify which code change broke it** - Use `git diff` if needed
3. **Explain to user** - What went wrong and WHY it happened
4. **Propose fix** - Don't just implement, explain the approach first
5. **Get approval** - Wait for user confirmation before changing code
6. **After fix: re-run ALL tests** - Not just the one that failed

**Example explanation:**
```
"The integration test failed because Part.DoesNotExist exception wasn't caught 
in views.py line 45. This happened when I added the stock enrichment logic but 
didn't account for parts being deleted between BOM traversal and enrichment.

I propose wrapping the enrichment in a try-except block that logs the error 
and continues with partial data rather than crashing. This allows the API to 
return results for the parts that still exist.

Should I proceed with this approach?"
```

### Common Failure Patterns

**Test failures:**
- Read test output carefully - what was expected vs actual?
- Check if test data setup is correct
- Verify test is testing the right thing (not a stub function)

**Build failures:**
- TypeScript errors: check for type mismatches, missing imports
- Python syntax errors: check for indentation, missing colons
- Missing dependencies: check package.json or pyproject.toml

**Deployment failures:**
- File copy errors: check file paths, permissions
- Server restart errors: check InvenTree logs
- Import errors: check Python module structure

**Browser test failures:**
- Check F12 console for JavaScript errors
- Check F12 Network tab for API errors (status codes, response bodies)
- Check InvenTree server logs for backend errors
- Verify data is actually reaching the frontend (console.log)

---

## Phase-Based Refactoring Example

**Scenario:** Refactor serializers (3 phases)

### Phase 1: BOMWarningSerializer

```
1. Implement serializer in serializers.py
2. Write 7 tests in test_serializers.py
3. Run unit tests: .\scripts\Test-Plugin.ps1 -Plugin "X" -Unit
4. Run integration tests: .\scripts\Test-Plugin.ps1 -Plugin "X" -Integration
5. Build: .\scripts\Build-Plugin.ps1 -Plugin "X"
6. Deploy: .\scripts\Deploy-Plugin.ps1 -Plugin "X" -Server staging
7. Manual test: Verify warnings still display correctly in UI
8. Commit: git commit -m "refactor: extract BOMWarningSerializer (Phase 1/3)"
9. ✅ STOP - Ask user: "Phase 1 complete and verified on staging. Confirm before Phase 2?"
```

### Phase 2: FlatBOMItemSerializer

```
1. Wait for user approval from Phase 1
2. Implement serializer in serializers.py
3. Write 16 tests in test_serializers.py
4. Run unit tests
5. Run integration tests
6. Build
7. Deploy to staging
8. Manual test: Verify BOM items display correctly
9. Commit: git commit -m "refactor: extract FlatBOMItemSerializer (Phase 2/3)"
10. ✅ STOP - Ask user: "Phase 2 complete and verified. Confirm before Phase 3?"
```

### Phase 3: FlatBOMResponseSerializer

```
1. Wait for user approval from Phase 2
2. Implement serializer in serializers.py
3. Write 8 tests in test_serializers.py
4. Run unit tests
5. Run integration tests
6. Build
7. Deploy to staging
8. Manual test: Verify full response structure
9. Commit: git commit -m "refactor: complete serializer migration (Phase 3/3)"
10. ✅ ALL PHASES COMPLETE - Update TODO list, mark project milestone
```

**Key Point:** Each phase is independently verified before starting the next.

---

## Common Pitfalls to Avoid

### Don't Do This ❌

**Stacking unverified changes:**
```
❌ Write serializer → Write tests → Write views → Deploy
   (Too many changes without checkpoints)
```

**Vague commits:**
```
❌ git commit -m "updates"
❌ git commit -m "fix"
❌ git commit -m "wip"
```

**Skipping manual testing:**
```
❌ Tests pass → Deploy → Assume it works → Start next feature
   (Broken code can reach production)
```

**Giant TODO items:**
```
❌ "Refactor entire frontend"
❌ "Fix all bugs"
❌ "Improve code quality"
```

### Do This Instead ✅

**Incremental verified changes:**
```
✅ Write serializer → Test → Deploy → Verify in browser → Commit
   Write tests → Test → Deploy → Verify → Commit
   Write views → Test → Deploy → Verify → Commit
```

**Clear commits:**
```
✅ git commit -m "feat: add BOMWarningSerializer with 7 tests"
✅ git commit -m "fix: handle Part.DoesNotExist in stock enrichment"
✅ git commit -m "refactor: extract FlatBOMItemSerializer (Phase 2/3, verified on staging)"
```

**Always manual test:**
```
✅ Tests pass → Build → Deploy → Open browser → Test feature → Check console → Commit
```

**Specific TODO items:**
```
✅ "Extract FlatBOMItemSerializer + write 16 tests (Phase 2/3)"
✅ "Deploy to staging and verify warnings display in UI"
✅ "Fix Part.DoesNotExist crash in views.py stock enrichment"
```

---

## Quick Reference Commands

```powershell
# Test plugin
.\scripts\Test-Plugin.ps1 -Plugin "PluginName" -Unit          # Unit tests only
.\scripts\Test-Plugin.ps1 -Plugin "PluginName" -Integration   # Integration tests only
.\scripts\Test-Plugin.ps1 -Plugin "PluginName" -All           # All tests

# Build plugin
.\scripts\Build-Plugin.ps1 -Plugin "PluginName"

# Deploy plugin
.\scripts\Deploy-Plugin.ps1 -Plugin "PluginName" -Server staging
.\scripts\Deploy-Plugin.ps1 -Plugin "PluginName" -Server production

# Git workflow
git status                                    # Check uncommitted changes
git log --oneline -10                         # Recent commits
git diff HEAD                                 # What's changed since last commit
git add <files>                               # Stage files
git commit -m "type: description"             # Commit with clear message
```

---

## Remember

This user:
- Works **part-time** on plugins (needs easy resume after breaks)
- Prefers **simple solutions** over complex automation
- Values **clear explanations** over assumed knowledge
- Comfortable with Python, learning frontend
- Deploys manually (no CI/CD complexity)

**Your goal:** Make it easy for user to:
1. Pick up where they left off (TODO lists)
2. Understand what changed and why (clear commits)
3. Trust that code works (verified every step)
4. Learn patterns through clear explanations

---

_Last updated: January 18, 2026_
