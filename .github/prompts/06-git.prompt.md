# Git Conventions

Use these rules whenever creating a branch or committing in this workspace.

## Before any git operation
- Run `git submodule status` to identify submodule directories.
- **Never commit inside a submodule** — changes there belong to the upstream repo.
- Run `git status` from the **repo root**, not from inside a subdirectory.


## Branch names
- Lowercase letters and hyphens only.
- 40 characters maximum.
- Descriptive enough to identify the feature.
  e.g. `push-revision-to-inventree`, `fix-bom-quantity-rounding`.

## Creating a branch
```
git checkout -b [branch-name]
```
Always branch before writing any code. Never work directly on `main` or `master`.

## Committing
```
git add -A
git commit -m "[type]: [short summary]

- [what was built or changed]
- [what was tested]"
```

### Type prefixes
| Prefix | Use for |
|---|---|
| `feat:` | New feature |
| `fix:` | Bug fix |
| `refactor:` | Code restructure, no behaviour change |
| `build:` | Build system, packaging, CI |
| `ui:` | Visual or layout change only |
| `docs:` | Documentation only |
| `test:` | Adding or fixing tests only |
| `process:` | Pipeline, instructions, or workflow change |

### Commit message rules
- Line 1: type prefix + summary, 50 characters maximum.
- Blank line.
- 2-5 bullet points describing what was built or changed.

## Merging to main
Only merge after the manual verification gate (Stage 8) has been passed.
```
git checkout main
git merge [branch-name] --no-ff -m "merge: [feature description]"
```

## When to commit
- After all tests pass.
- After build succeeds.
- After manual verification confirms the feature works.
- After each completed phase in a multi-phase feature.

Never commit: failing tests, compilation errors, broken functionality,
or diagnostic/debug code.