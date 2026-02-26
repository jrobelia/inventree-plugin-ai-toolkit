# Documentation Standards for InvenTree Plugins

**Purpose:** Naming conventions and structure for plugin documentation  
**Audience:** Plugin developers (human + AI)  
**Goal:** Make documentation purpose immediately obvious

---

## File Naming Conventions

### Core Principle
**Use standard, universally recognized names that anyone in software can understand.**

### ✅ Recommended Names

#### User-Facing Documentation
| Filename | Purpose | When to Create |
|----------|---------|----------------|
| `README.md` | Overview, features, installation, usage | Day 1 (required) |
| `CHANGELOG.md` | Version history, release notes | When releasing versions |
| `CONTRIBUTING.md` | How to contribute | When accepting PRs |
| `LICENSE` | Legal terms | Day 1 (auto-created) |

#### Technical Documentation
| Filename | Purpose | When to Create |
|----------|---------|----------------|
| `ARCHITECTURE.md` | Technical implementation details | After 3-5 features |
| `API.md` | API endpoint documentation | When you have 5+ endpoints |
| `DEPLOYMENT.md` | How to deploy/install | When deployment is complex |

#### Testing Documentation
| Filename | Purpose | When to Create |
|----------|---------|----------------|
| `TEST-PLAN.md` | Testing strategy, execution, coverage | When test count > 20 |
| `TESTING-GUIDE.md` | How to write/run tests | When onboarding contributors |

#### Planning Documentation (in docs/internal/)
| Filename | Purpose | When to Create |
|----------|---------|----------------|
| `ROADMAP.md` | Future features, priorities | When you have 10+ planned items |
| `TECHNICAL-DEBT.md` | Known issues to fix | When deferring refactoring |
| `DESIGN-DECISIONS.md` | Why certain choices were made | For controversial decisions |

#### Investigation Documentation (in docs/internal/)
| Filename | Purpose | When to Create |
|----------|---------|----------------|
| `[FEATURE]-RESEARCH.md` | Investigation notes | During feature exploration |
| `[FEATURE]-DESIGN.md` | Design options evaluated | Before complex feature |

### ❌ Names to Avoid

| Bad Name | Why Bad | Use Instead |
|----------|---------|-------------|
| `REFAC-PANEL-PLAN.md` | Abbreviation, unclear scope | `ROADMAP.md` or `TECHNICAL-DEBT.md` |
| `REFAC-HISTORY.md` | Abbreviation, duplicates git | Git history or `CHANGELOG.md` |
| `TEST-QUALITY-REVIEW.md` | Too specific | Section in `TEST-PLAN.md` |
| `COPILOT-GUIDE.md` | Tool-specific | `ARCHITECTURE.md` |
| `BOM-ERROR-WARNINGS-RESEARCH.md` | Too verbose | `WARNINGS-RESEARCH.md` |
| `PYPI-PUBLISHING-PLAN.md` | Too specific | `DEPLOYMENT.md` section |

---

## File Naming Rules

1. **Use UPPERCASE** for root-level documentation
   - `README.md`, `CHANGELOG.md`, `ARCHITECTURE.md`
   
2. **Use kebab-case** for feature-specific docs
   - `warnings-research.md`, `cost-calculator-design.md`

3. **Be descriptive but concise** (1-3 words max)
   - ✅ `TEST-PLAN.md`
   - ❌ `COMPREHENSIVE-TESTING-STRATEGY-AND-EXECUTION-PLAN.md`

4. **Use industry-standard names** when they exist
   - `README.md` (not `OVERVIEW.md`)
   - `CHANGELOG.md` (not `HISTORY.md`)
   - `CONTRIBUTING.md` (not `HOW-TO-CONTRIBUTE.md`)

5. **Avoid abbreviations** unless universally known
   - ✅ `API.md`, `FAQ.md`
   - ❌ `REFAC.md`, `IMPL.md`, `DEVDOC.md`

6. **Prefix with feature for specificity**
   - `WARNINGS-RESEARCH.md` (not `RESEARCH.md`)
   - `SERIALIZER-MIGRATION.md` (not `MIGRATION.md`)

---

## Documentation Structure

### Minimal Plugin (MVP)
```
my-plugin/
├── README.md           # Required
├── LICENSE             # Required
├── ARCHITECTURE.md     # Optional (after patterns emerge)
└── docs/
    └── internal/       # Planning docs
        └── ROADMAP.md  # Optional
```

### Mature Plugin (Production)
```
my-plugin/
├── README.md              # User guide
├── CHANGELOG.md           # Version history
├── LICENSE                # Legal
├── CONTRIBUTING.md        # For contributors
├── ARCHITECTURE.md        # Technical details
├── docs/
│   ├── API.md             # API reference
│   ├── DEPLOYMENT.md      # Deploy guide
│   ├── TEST-PLAN.md       # Testing strategy
│   └── internal/
│       ├── ROADMAP.md             # Future plans
│       ├── TECHNICAL-DEBT.md      # Known issues
│       ├── WARNINGS-RESEARCH.md   # Investigation
│       └── DESIGN-DECISIONS.md    # Why choices made
└── imgs/                  # Screenshots for README
```

---

## Document Templates

### README.md Template
```markdown
# Plugin Name

**Purpose:** [One sentence describing plugin]

![Screenshot](imgs/overview.png)

## Features

- Feature 1
- Feature 2
- Feature 3

## Installation

\`\`\`bash
pip install inventree-plugin-name
\`\`\`

## Usage

[How to use the plugin with examples]

## Configuration

| Setting | Default | Description |
|---------|---------|-------------|
| Setting 1 | value | What it does |

## Development

See [ARCHITECTURE.md](ARCHITECTURE.md) for technical details.

## License

MIT
```

### ARCHITECTURE.md Template
```markdown
# Architecture - Plugin Name

> Technical implementation details for developers

## Overview

[High-level architecture description]

## API Endpoints

### Endpoint Name
\`\`\`
GET /api/plugin/plugin-name/endpoint/{id}/
\`\`\`

**Parameters:** ...
**Response:** ...

## Data Structures

[Key classes, functions, data flows]

## File Organization

[What each file does]

## Development Patterns

[Common patterns, conventions]
```

### ROADMAP.md Template
```markdown
# Roadmap - Plugin Name

**Status:** [Current version/state]  
**Last Updated:** [Date]

## In Progress
- [ ] Feature being worked on

## Planned (High Priority)
- [ ] Important feature (2-3 hours)
- [ ] Critical bug fix (1 hour)

## Planned (Medium Priority)
- [ ] Nice-to-have feature (3-4 hours)

## Future Ideas
- [ ] Long-term enhancement

## Completed
- [x] Feature shipped in v1.0 (Dec 1, 2025)
```

### TECHNICAL-DEBT.md Template
```markdown
# Technical Debt - Plugin Name

**Purpose:** Known issues deferred for velocity  
**Goal:** Track what needs fixing and when

## Critical (Fix Soon)
- **Issue:** What's wrong
- **Impact:** Why it matters
- **Effort:** Time to fix
- **Deferred:** Why we didn't fix it yet

## Medium Priority
[Same structure]

## Low Priority
[Same structure]

## Resolved
- **Issue:** What was wrong
- **Fixed:** When/how resolved
```

---

## Documentation Maintenance

### When to Update

**After Every Feature:**
- [ ] README.md features list
- [ ] Inline code comments

**After Every Deployment:**
- [ ] CHANGELOG.md with version
- [ ] README.md if UI changed

**Monthly (or when docs grow stale):**
- [ ] ARCHITECTURE.md accuracy
- [ ] TEST-PLAN.md test count
- [ ] ROADMAP.md priorities

### Single Source of Truth

**Don't duplicate information across files.**

✅ **Good:**
```
README.md: "See ARCHITECTURE.md for API details"
ARCHITECTURE.md: [Complete API documentation]
```

❌ **Bad:**
```
README.md: [API documentation]
ARCHITECTURE.md: [Same API documentation]
```

### Documentation Debt Comments

If docs need updating but you're busy:

```markdown
<!-- NEEDS UPDATE: Column changed from "Part" to "Component" on 2025-12-10 -->
| **Part** | Part name with thumbnail |
```

Or at file top:
```markdown
> ⚠️ **Documentation Outdated**: Serializer refactoring not yet documented (see commit abc123)
```

---

## Documentation Anti-Patterns

### ❌ Over-Documentation

**Problem:** Writing docs before code exists

**Example:**
```markdown
# COMPLETE-PLUGIN-ARCHITECTURE.md (Day 1)
## All Classes (not written yet)
## All Endpoints (not implemented)
## All Algorithms (not designed)
```

**Solution:** Write docs AFTER patterns emerge (3-5 features in)

---

### ❌ Under-Documentation

**Problem:** No docs, or only README

**Example:**
```
my-plugin/
└── README.md  # 5 lines: "This plugin does stuff"
```

**Solution:** 
- Always have README with features, usage, config
- Add ARCHITECTURE.md after 3-5 features
- Add TEST-PLAN.md when tests > 20

---

### ❌ Stale Documentation

**Problem:** Code changed, docs didn't

**Example:**
```markdown
## API Endpoint
GET /api/plugin/old-name/endpoint/  <!-- Doesn't exist anymore -->
```

**Solution:**
- Update docs in same commit as code change
- Add "Last Updated" date to docs
- Periodic review (monthly)

---

### ❌ Documentation Duplication

**Problem:** Same info in 3 places

**Example:**
- README.md: "This plugin calculates BOM cost"
- ARCHITECTURE.md: "This plugin calculates BOM cost"
- COPILOT-GUIDE.md: "This plugin calculates BOM cost"

**Solution:** 
- README: User-facing "what and how"
- ARCHITECTURE: Technical "how it works"
- Link between them, don't duplicate

---

### ❌ Tool-Specific Documentation

**Problem:** Docs tied to specific tools/AI

**Example:**
- `COPILOT-GUIDE.md` - What if using Cursor? Claude?
- `VSCODE-SETUP.md` - What if using PyCharm?

**Solution:**
- Use generic names: `ARCHITECTURE.md`, `DEVELOPMENT.md`
- Tool-specific tips go in root `.github/copilot-instructions.md`

---

## FlatBOMGenerator Documentation Audit

### Current Structure (December 2025)
```
docs/
├── internal/
│   ├── ARCHITECTURE-WARNINGS.md            # ✅ Good (feature-specific)
│   ├── BOM-ERROR-WARNINGS-RESEARCH.md      # ⚠️ Verbose → WARNINGS-RESEARCH.md
│   ├── DEPLOYMENT-WORKFLOW.md              # ✅ Good
│   ├── Flat BOM Generator Table.csv        # ✅ Good (reference data)
│   ├── INTEGRATION-TEST-REVIEW.md          # ⚠️ Specific → section in TEST-PLAN.md
│   ├── PYPI-PUBLISHING-PLAN.md             # ⚠️ Specific → section in DEPLOYMENT.md
│   ├── README.md                           # ✅ Good (index)
│   ├── REFAC-HISTORY.md                    # ❌ Bad → git history or CHANGELOG.md
│   ├── REFAC-PANEL-PLAN.md                 # ❌ Bad → ROADMAP.md or TECHNICAL-DEBT.md
│   ├── TEST-QUALITY-REVIEW.md              # ⚠️ Specific → section in TEST-PLAN.md
│   ├── TEST-WRITING-METHODOLOGY.md         # ✅ Good
│   └── WARNINGS-ROADMAP.md                 # ✅ Good
```

### Recommended Changes
1. Rename `REFAC-PANEL-PLAN.md` → `ROADMAP.md`
2. Delete `REFAC-HISTORY.md` (git has full history)
3. Rename `BOM-ERROR-WARNINGS-RESEARCH.md` → `WARNINGS-RESEARCH.md`
4. Merge `TEST-QUALITY-REVIEW.md` into `TEST-PLAN.md` as section
5. Merge `INTEGRATION-TEST-REVIEW.md` into `TEST-PLAN.md` as section
6. Merge `PYPI-PUBLISHING-PLAN.md` into deployment docs

---

## Quick Reference Checklist

Before creating a new documentation file, ask:

- [ ] Is this information already documented elsewhere?
- [ ] Could this be a section in an existing file?
- [ ] Will the filename make sense to someone new?
- [ ] Am I using standard industry naming?
- [ ] Is this a temporary research doc? (Put in docs/internal/)
- [ ] Am I creating docs before patterns exist? (Wait!)

---

## Summary

**Good Documentation:**
- Uses standard, recognizable names
- Created when patterns emerge (not before)
- Single source of truth (no duplication)
- Updated with code changes
- Clear purpose from filename alone

**Bad Documentation:**
- Abbreviations and jargon (REFAC, IMPL, DEVDOC)
- Created on Day 1 before code exists
- Duplicated across multiple files
- Stale (code changed, docs didn't)
- Tool-specific names (COPILOT-GUIDE)

**Golden Rule:** If you have to explain what the file contains, the name is wrong.

---

_Last Updated: December 18, 2025_
