# 03 — InvenTree Platform Reference

> **Status:** Extraction pass — consolidated from `BUILD-ORDER-GENERATOR-UX.md`
> and `BUILD-ORDER-GENERATOR-ROW-UX-AND-TREE-RENDERING.md`.
> **Purpose:** Raw, source-verified technical facts about InvenTree and its
> plugin SDK. This is the "what's actually true about the platform" doc —
> no business logic, no decisions (those are in `04-Architecture-Decisions.md`),
> no domain terms (those are in `02-Domain-Model.md`). Re-verify against
> current source before relying on anything here if InvenTree has been
> upgraded since the version baseline below.

---

## ⚠️ Version Baseline — Flag Before Trusting Anything Below

Two different version pins show up across the source docs:
- `BUILD-ORDER-GENERATOR-UX.md`: verified against `reference/inventree-source`
  at stable **1.4.2** and `plugin-creator` at **1.20.0** (both bumped July 17, 2026).
- `BUILD-ORDER-GENERATOR-ROW-UX...md`: verified against cloned
  `github.com/inventree/InvenTree` and `github.com/inventree/plugin-creator`
  (unpinned in that doc) plus **`@inventreedb/ui@1.4.5`** pulled via `npm pack`.

**Not yet confirmed whether `@inventreedb/ui@1.4.5` corresponds to the same
InvenTree release as `inventree-source@1.4.2`** — the UI package may version
independently from the core app. Don't assume these two facts sets are
necessarily from identical underlying source until checked. Worth a quick
verification pass before implementation starts, since several facts below
(e.g. `editApiForm` availability, `DataTableRowExpansionProps` in shipped
types) are version-sensitive.

---

## 1. Core Table Architecture

- InvenTree's core table wrapper: `src/frontend/src/components/tables/InvenTreeTable.tsx`
  (~1,000 lines). Built on **`mantine-datatable`** (the `icflorescu` npm
  package) — **not** `mantine-react-table` / TanStack Table. Confirmed via
  imports: `DataTable`, `DataTableRowExpansionProps`, `useDataTableColumns`.
- **There is no `subRows` / depth-indentation tree pattern anywhere in
  InvenTree's frontend.** Every multi-level display uses recursive
  composition of separate table instances via `mantine-datatable`'s
  single-level `rowExpansion` detail-panel API.
- `rowExpansion.expandable` — per-row boolean, decides if a row can expand.
- `rowExpansion.content` — React node rendered on expand; can itself be
  another full `InvenTreeTable` defining its own `rowExpansion`, recursing
  arbitrarily deep by component composition.
- Expansion state is tracked **per table instance**
  (`tableState.expandedRecords` / `tableState.isRowExpanded(pk)`), not a
  single global tree-expansion state.
- `RowExpansionIcon.tsx` — shared chevron component (`IconChevronRight` /
  `IconChevronDown`), reused for both recursive tree expansion and
  unrelated single-level expansions (e.g. `BuildLineTable.tsx` uses it for
  a flat stock-allocation list — one level, not recursive).
*Source: ROW-UX.md Part 3*

### Direct precedent: `BomTable.tsx` + `BomSubassemblyTable.tsx`
- Sub-assembly display gated behind user setting `SHOW_BOM_SUBASSEMBLY_LEVELS`
  — off by default, opt-in.
- A row is expandable if `record.sub_part_detail?.assembly` is true.
- Expanding renders `<BomSubassemblyTable partId={record.sub_part} />` — a
  **fresh, independent `InvenTreeTable`** that fires its own API call
  scoped to that part's BOM the moment the row expands (lazy, per-node).
- Nested table defines the same expansion logic again, recursing by
  component composition, not by a table walking a nested data structure.
- **Visual nesting is not column-aligned indentation.** Each expanded level
  renders as its own `Paper` card, prefixed with a small `IconCornerLeftUp`
  icon, wrapped in a flex-grow `Expand` div (fills width — does not add
  indent padding). The "this is nested" cue is the card boundary + icon,
  not padding-per-depth.
*Source: ROW-UX.md Part 3*

### Historical precedent (pre-1.0, `0.9.0` tag, pre-React frontend)
- `templates/js/translated/bom.js` used a `bootstrap-table-treegrid` plugin
  — one single flat table (`treeEnable: true`, `parentIdField: 'parentId'`).
- Expanding a row called `requestSubItems()`, fetched that node's direct
  children, and **appended them into the same table**
  (`table.bootstrapTable('append', response)`).
- Still lazy (one level per fetch, same as today's pattern) but
  architecturally one continuous indented table, not nested cards — a
  different visual model than the current React frontend uses.
*Source: ROW-UX.md Part 3*

---

## 2. Plugin SDK Boundary (`@inventreedb/ui`)

Checked by pulling `@inventreedb/ui@1.4.5` via `npm pack` and inspecting
shipped source directly:

- The plugin-facing `InvenTreeTable` component is a **thin ~40-line proxy**
  calling `context.tables.renderTable(...)` on the plugin context — not a
  separate reimplementation.
- `context.tables.renderTable` is backed by the **exact same** ~1,000-line
  `InvenTreeTable` the host app itself uses — same `mantine-datatable`
  engine, same `rowExpansion` mechanics.
- `DataTableRowExpansionProps` is present in `@inventreedb/ui`'s shipped
  types (`rowExpansion?: DataTableRowExpansionProps<T>`) — confirms the
  prop reaches plugins, isn't stripped at the boundary.
- `mantine-datatable` is a listed dependency of `@inventreedb/ui`
  (`"mantine-datatable": "^9.2.0"`) — separate from the short externalized-
  libs list the plugin build excludes from bundling (`react`, `react-dom`,
  `@mantine/core`, `@mantine/notifications`, lingui). Plugins get the
  host's real rendering, not their own copy.
*Source: ROW-UX.md Part 3*

### What plugins can and cannot access
- **Available:** generic `forms.create` / `forms.edit` / `forms.delete` /
  `forms.bulkEdit` (any endpoint, standard styling); a fixed `stockActions`
  set; `context.tables.renderTable` (full native table/tree engine);
  `forms.editApiForm` (**new as of v1.4.2 per the source docs** — renders a
  form directly as a React node inline, rather than only as a modal
  trigger; did not exist in the 1.1.7 baseline. Note: the source docs
  don't disambiguate whether "1.4.2" here refers to `inventree-source` or
  the `@inventreedb/ui` package version — see the Version Baseline flag
  at the top of this doc).
- **NOT available (internal-only, live in app's `src/` tree, not exported):**
  `OrderPartsWizard`, `useAllocateStockToBuildForm`, the internal
  build-order create modal. Confirmed: `@inventreedb/ui`'s full export list
  has no wizard or form-field-level component at that layer.
- **No generic "allocate to build line" action** exists in the SDK's fixed
  `stockActions` set.
*Source: UX.md*

---

## 3. Native Build Order UI — Actions & Endpoints

### `BuildLineTable.tsx` (host app, internal)
- Every required-parts line has three per-row actions, each pre-filled with
  that line's part and outstanding quantity, live since the pre-v1 legacy
  Django UI:
  - **Allocate Stock**
  - **Order Stock** (Buy) — via `OrderPartsWizard`
  - **Build Stock** — via a generic create-Build-Order modal
- "Build Stock" row action (wrench icon): shown when
  `canBuild = !consumable && user.hasAddRole(build) && part.assembly`.
  Opens create-Build-Order modal pre-filled with:
  ```
  { part: record.part, parent: build.pk, quantity: record.quantity - record.allocated }
  ```
- `on_order` is a real field on `BuildLineTable` — column, filter, tooltip
  line ("On order: X"). Confirmed at `BuildLineTable.tsx` lines 240–286
  and 509–511.
*Source: ROW-UX.md Part 1, Part 2*

### Bulk toolbar (above the Required Parts table, InvenTree demo server)
All driven by `table.selectedRecords`:

| Icon | Action | What it does |
|---|---|---|
| Wand | Auto Allocate Stock | auto-assigns existing stock to selected lines |
| Cart | Order Parts | opens `OrderPartsWizard` |
| Green arrow | Allocate Stock | separate modal, assigns stock to selected lines |
| Circle-minus | Deallocate Stock | removes existing allocations |
| Checkmark | Consume Stock | marks allocated stock as consumed |

**No bulk "Build Stock" action exists in this toolbar.** The table itself
only ever shows one build's immediate required lines — one level, not the
full nested tree.
*Source: ROW-UX.md Part 2*

### `OrderPartsWizard.tsx` flow (confirmed against source)
- **Supplier part is chosen first.** Purchase Order picker stays disabled
  until a supplier part is selected, then filters to that supplier's open
  orders (`supplier: <that supplier>, outstanding: true`).
- Both the Supplier Part picker and the PO picker have an inline "+" to
  create a new one on the spot without leaving the row.
- Per row: Supplier Part picker (filtered to the part, autofilled to
  primary supplier part), Purchase Order picker, Quantity field.
- **Not exported to plugins** — confirmed no wizard/form-field-level
  component at `@inventreedb/ui`'s export layer.
*Source: ROW-UX.md Part 3; UX.md*

### Relevant write endpoints
- **Allocate:** internal Allocate action posts to a **bulk** endpoint,
  `build/:id/allocate/`, with a multi-row table field — built for
  allocating many lines at once. For a single-node write, create one
  `BuildItem` directly against `build/item/` (`build_item_list`) instead —
  simpler match, not a reimplementation of the bulk table form. A real
  `BuildItem` requires picking a specific source `stock_item`, not just a
  quantity.
- **Build:** SDK's generic `forms.create`, pointed at `build_order_list`,
  pre-filled `{ part, parent, quantity }` — same pre-fill pattern the
  internal UI uses, via the public form-modal API instead of the internal one.
- **Buy:** SDK's generic `forms.create`, pointed at the purchase-order-
  line-item endpoint (`order/po-line/`), pre-filled with part/quantity plus
  a supplier part selector defaulting to the part's default supplier part.
*Source: UX.md*

---

## 4. Native Automation Plugins (Built-in, Event/Schedule-Driven)

### `AutoCreateBuildsPlugin` (`autocreatebuilds`)
`plugin/builtin/events/auto_create_builds.py`. Listens for
`BuildEvents.ISSUED`. When a BO is issued, walks its non-consumable
assembly-type BOM lines and auto-creates a child BO for any line with a
deficit:
```
required_quantity = build_quantity + minimum_stock + allocated_quantity
                     − stock_quantity − in_production_quantity
```
**This formula never nets against on-order POs** — inbound purchase orders
don't reduce the deficit at all in this native path.
New child builds are created `PENDING`, not auto-issued. On its own, this
plugin does not cascade further down the tree.
*Source: ROW-UX.md Part 2*

### `AutoIssueOrdersPlugin` (`autoiissueorders`)
Runs on a daily schedule. Auto-issues any `PENDING` build whose
`target_date` matches today — or is in the past, only if
`ISSUE_BACKDATED_ORDERS` is enabled (**off by default**).
Child builds inherit their `target_date` directly from the parent.
**Interaction effect:** with both plugins enabled and timing aligned, a
tree can cascade fully automatically with no human involved. If timing
doesn't align (child created after that day's scheduled run, or its
inherited date is in the past without backdating enabled), the child just
sits `PENDING` indefinitely.
*Source: ROW-UX.md Part 2*

---

## 5. Fields & Settings Reference

| Field / Setting | Location | Notes |
|---|---|---|
| `on_order` | `BuildLineTable` | column, filter, tooltip; native, already computed |
| `project_code` | Build Orders AND Purchase Orders (incl. PO **line items**, not just parent PO) | `AbstractLineItemSerializer.line_fields` (backend); surfaced via `usePurchaseOrderLineItemFields` (frontend). **Did not exist on PO line items in the 1.1.7 baseline** — confirmed added sometime before 1.4.2. |
| `ProjectCodeColumn` / `ProjectCodeFilter` / `HasProjectCodeFilter` | `PurchaseOrderTable.tsx` / `PurchaseOrderFilters.tsx` | confirms project_code is real, filterable on POs |
| `pack_quantity` | `SupplierPart`, `company/models.py` | real field; round suggested Buy qty up to a whole pack when set |
| `lead_time` | `SupplierPart`, `company/models.py` | **exists in model source but is commented out / unused** — no real value to read today. Re-enabling is a migration + serializer/form exposure, not new tracking from scratch. |
| `SHOW_BOM_SUBASSEMBLY_LEVELS` | global setting | gates `BomTable`'s sub-assembly drill-down; off by default |
| `ISSUE_BACKDATED_ORDERS` | global setting | gates whether `AutoIssueOrdersPlugin` issues past-due PENDING builds; off by default |
| `TableColumnSelect` | `@inventreedb/ui` | native column show/hide selector — already solved infra, no custom toggle needed |

---

## 6. Checked and Confirmed NOT to Exist (avoid re-searching these)

- `BUILDORDER_*` settings in `common/setting/system.py` — nothing relevant
  to child-BO automation.
- New Build Order form's field list (`useBuildOrderFields`) — no
  auto-create-children option.
- Backend `build` models/serializers — no `child_build` / `create_child` /
  `auto_create` pattern.
- (The actual mechanism for automated child-BO creation is the built-in
  **plugin** described in Section 4 above, `plugin/builtin/events/` — this
  is what the searches above were looking for and initially missed by
  checking settings/forms/models instead of the plugin directory.)
*Source: ROW-UX.md Part 2*

---

## 7. Notes on Confidence / Re-verification

- Everything in Sections 1–4 is marked "confirmed directly against source"
  in the originating docs (cloned repos + `npm pack` inspection), not
  inferred from documentation or memory.
- Given the version baseline flag at the top of this doc, re-confirm
  Section 2 (SDK boundary, `editApiForm` availability) specifically before
  relying on it if any InvenTree/`@inventreedb/ui` upgrade has happened
  since July 2026.
