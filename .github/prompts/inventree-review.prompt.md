---
description: 'InvenTree plugin domain review -- architecture, compatibility, and security checklist'
---

# InvenTree Plugin Review

Run a structured domain-specific review of InvenTree plugin code.
Checks architecture, InvenTree compatibility, and security. Use after
building or before committing plugin changes.

---

## Step 1 -- Architecture Check

- [ ] Plugin metadata correct? (`NAME`, `SLUG`, `VERSION`, `TITLE`)
- [ ] Only necessary mixins included? (SettingsMixin, UrlsMixin, etc.)
- [ ] Mixin order correct? (most specific -> most general -> InvenTreePlugin last)
- [ ] Entry point format exact in `pyproject.toml`?
  `MyPlugin = "my_plugin.core:MyPlugin"`
- [ ] Settings use `protected: True` for secrets?
- [ ] Imports inside `setup_urls()` to prevent circular imports?

---

## Step 2 -- Code Quality

- [ ] Fail-fast applied? (no silent `.get()` defaults on required fields)
- [ ] Specific exceptions, not bare `except:`?
- [ ] QuerySets optimized? (`select_related`, `prefetch_related`)
- [ ] Type hints present on public functions?
- [ ] Views stay thin -- business logic in separate modules?

---

## Step 3 -- InvenTree Compatibility

- [ ] Using public InvenTree APIs only? (no private internals)
- [ ] Frontend dependencies externalized? (React, Mantine not bundled)
- [ ] Tests use `as_view()` pattern, not Django test client for plugin URLs?
- [ ] YAML fixtures include MPTT fields? (`tree_id`, `level`, `lft`, `rght`)
- [ ] `MIN_VERSION` / `MAX_VERSION` set if using version-specific APIs?

---

## Step 4 -- Security

- [ ] User input validated with serializers?
- [ ] Permissions checked? (`request.user.has_perm()`)
- [ ] No raw SQL? (Django ORM only)
- [ ] CSRF protection not disabled?
- [ ] Protected settings for API keys and secrets?

---

## Step 5 -- Frontend (if applicable)

- [ ] Components use `InvenTreePluginContext`, not standalone routing?
- [ ] `checkPluginVersion(context)` called in `useEffect`?
- [ ] React Query uses `context.queryClient`?
- [ ] No bundled copies of React, Mantine, or other externalized libs?
- [ ] Vite config externalizes all shared libraries?

---

## Output Format

```markdown
# InvenTree Plugin Review - {Plugin Name}

**Architecture:** PASS / {N} issues
**Code Quality:** PASS / {N} issues
**Compatibility:** PASS / {N} issues
**Security:** PASS / {N} issues
**Frontend:** PASS / {N} issues / N/A

## Issues Found
[List each with: category, file path, description, suggested fix]

## Overall: PASS / NEEDS FIXES
```
