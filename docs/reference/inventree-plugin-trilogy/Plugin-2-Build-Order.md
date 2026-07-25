# Plugin 2 — Build Order Generator

> **Status:** Spec drafted (MVP scope only), implementation not started.
> **Purpose:** This is the thin, plugin-specific spec — it should reference
> `01-Vision-and-Philosophy.md`, `02-Domain-Model.md`,
> `03-InvenTree-Platform-Reference.md`, `04-Architecture-Decisions.md`, and
> `05-Plugin-Architecture.md` rather than redefining anything already
> settled there. If you find yourself re-explaining a concept here, it
> probably belongs in one of those five instead.

---

## The Problem

InvenTree only lets you create one child Build Order at a time, and there
is no view showing the full set of child BOs a parent BO needs — existing
or still outstanding. Building out a multi-level sub-assembly tree today
means: open a BO's Required Parts table, find an assembly line, click
"Build Stock" to create one child BO, then navigate into *that* BO's own
page and repeat the same one-row action for its children — one level, one
row, one navigation at a time, with no view of the whole nested picture at
any point in the process.

*(Full framing, including how this differs from InvenTree's native
background-automation plugins: `04-Architecture-Decisions.md` ADR-029.)*

---

## What Ships in v1 — MVP Bulk Create

A complete, direct answer to the problem above — not a placeholder for a
bigger plugin. See `02-Domain-Model.md`'s "MVP Bulk Create" entry and
`04-Architecture-Decisions.md` ADR-029/ADR-010 for the full reasoning
behind this being the confirmed v1 scope. For Plugin 2's ownership
boundaries, see `05-Plugin-Architecture.md` §Plugin 2.

- Lives as a panel on an existing parent Build Order's detail page
  *(`04-Architecture-Decisions.md` ADR-002)*
- Computes the full sub-assembly tree in **one server-side call** on load
  — every level, not fetched lazily per-expand *(ADR-014;
  `03-InvenTree-Platform-Reference.md`)*
- Classifies every node as **Existing** (real child BO already exists) or
  **Draft** (none yet, computed from BOM × cascaded quantity)
  *(`02-Domain-Model.md`, "Existing Node" / "Draft Node")*
- Computes each node's **Outstanding** quantity per `02-Domain-Model.md`:
  Required minus allocated stock minus unallocated stock on hand
  (togglable, default on, scoped to this BO tree only) minus already-building,
  with incoming on-order POs counted against it for purchasable nodes,
  unscoped by project — project-code match shown as a separate informational
  hint, never filtering the number itself *(`02-Domain-Model.md`, "Outstanding")*
- **Merges duplicate sub-assemblies** appearing in multiple branches into
  one canonical node, combined by default *(`02-Domain-Model.md`,
  "Canonical Node / Reference Node")*
- Renders **collapsed by default with rollup badges** (e.g. "4 need
  building, 2 covered") so the tree's shape is visible without expanding
  every branch *(`02-Domain-Model.md`, "Rollup Badge")*
- A **checkbox on every node**, selectable across the entire flattened
  tree at any depth *(ADR-012)*
- **One bulk "Create Build Orders" action** — a confirm modal, one row per
  selected node with editable part/quantity, creates all selected BOs in
  a single call
- **Refuses to create a child BO unless its parent is explicit** —
  either an already-real Existing BO or explicitly selected in the same
  bulk action. Surfaces a hard error otherwise; never silently creates
  an ancestor the user did not select (InvenTree requires
  parent-before-child creation) *(`02-Domain-Model.md`, "Creation Order
  Constraint")*
- A **"Show build candidates only" filter** — hides leaf nodes that
  already have a default supplier set; those are Plugin 3's concern, not
  build candidates *(`02-Domain-Model.md`, "Build Candidate" / "Show
  Build Candidates Only"; ADR-018, ADR-019)*
- **Nothing is written to InvenTree until the confirm click** — the whole
  tree is a live, disposable computation until that point
  *(`01-Vision-and-Philosophy.md`, Principles 1 and 3)*

---

## Explicitly Not in v1 (Enhancement Layer, Added Later)

Real, valuable design work — already specced in detail — but confirmed as
what gets added *on top of* a complete v1, not what v1 is missing:

- Per-node Allocate or Buy actions
- Partial-quantity splitting across Allocate/Build/Buy on a single node
- Inline stock-batch picking, supplier-part picking
- Live recalculation of a node's Build quantity as Allocate/Buy are staged

For v1, once Build Orders are created, the user leaves this plugin and
uses InvenTree's own existing bulk toolbar (Auto Allocate Stock / Order
Parts / Allocate Stock) to cover the rest. See `02-Domain-Model.md`'s
"Commit Decision Model" section for the full enhancement-layer design, and
`04-Architecture-Decisions.md` ADR-004, 006, 007, 009, 016, 017 for the
decisions behind it.

---

## Known Gaps Before Implementation Can Start

Pulled from the open-items lists in the architecture docs — these aren't
new, just collected here since they specifically block or shape v1:

- Exact rollup-badge behavior under the "Show build candidates only"
  filter (unresolved — ADR-019's open note)
- LCA-merge interaction with bulk create: don't double-create a combined
  node reached via two branches (inherited from the pre-merge Bulk Commit
  open questions, `02-Domain-Model.md`)
- Confirmation detail/wording when ancestor auto-creation cascades
  (unresolved)
- Depth/node-count threshold for large-tree handling (unresolved,
  `04-Architecture-Decisions.md` open items)
- LCA reference-node visual treatment: how a non-expandable reference row
  clearly reads as non-interactive is unresolved *(`02-Domain-Model.md`,
  "Canonical Node / Reference Node")*
- Indentation style: nested cards vs. column-aligned depth indentation
  (ADR-015, open)
