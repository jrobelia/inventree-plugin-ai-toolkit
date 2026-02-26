# Decision Log

**Purpose:** Append-only log of non-obvious technical decisions  
**Rule:** Add new entries at the bottom. Never edit or remove past entries.

---

## Template

```
### YYYY-MM-DD -- [Short title]

**Context:** [What prompted the decision]
**Decision:** [What we chose]
**Reason:** [Why -- 1-2 sentences]
**Alternatives considered:** [What we rejected and why]
```

---

### 2026-02-26 -- Reorganize toolkit documentation

**Context:** Workspace had dual documentation systems: old `copilot/` folder
(4 monolithic files) and new `.github/` system (instructions, prompts, agents).
Old files were fully superseded but not cleaned up, creating confusion.

**Decision:** Archive old `copilot/` and stale `docs/toolkit/` files. Reorganize
surviving docs into `docs/reference/` (how things work) and `docs/planning/`
(future work). Create three living docs at `docs/` root: architecture, decisions,
roadmap.

**Reason:** Single source of truth per topic. The `.github/` system is the
canonical location for AI guidance; `docs/` is for human-readable reference and
planning.

**Alternatives considered:** Deleting old files entirely -- rejected because git
history makes recovery harder than just archiving locally.

### 2026-02-26 -- Custom export endpoint over DataExportMixin

**Context:** FlatBOMGenerator needs server-side export (CSV/JSON/XLSX).
InvenTree provides DataExportMixin for generic list exports.

**Decision:** Use a custom endpoint with tablib instead of DataExportMixin.

**Reason:** DataExportMixin is designed for list views (export many items).
Our plugin takes a single assembly and generates a custom flat BOM -- the
mixin doesn't fit this workflow.

**Alternatives considered:** DataExportMixin -- rejected because it would
require forcing our single-assembly workflow into a list-export pattern.
