# 02 — Domain Model

> **Status:** Draft extraction pass — consolidated from `PLUGIN-TRILOGY.md`,
> `BUILD-ORDER-GENERATOR-UX.md`, `BUILD-ORDER-GENERATOR-ROW-UX-AND-TREE-RENDERING.md`,
> and `INTERNAL-FAB-AND-SCOPE-BOUNDARIES.md`.
> **Purpose:** One authoritative definition per concept. Other documents
> should reference terms defined here rather than redefining them.
> **How to read this doc:** Each entry has a definition, its source
> document(s), and — where the source docs actually disagreed — an
> explicit open question instead of a silently-picked answer.

---

## Core Tree Structure

### Planning Node
A single sub-assembly's position in the planning tree for one parent Build
Order. Every node is an **assembly** (has its own BOM) — leaf/purchased
parts never become nodes; they're Plugin 3's concern.
*Source: BUILD-ORDER-GENERATOR-UX.md ("Where This Lives")*

### Existing Node
A node where a real child Build Order already exists. Requirement data
comes from that BO's real `BuildLine`s (authoritative, not computed).
Rendered as a linked, status-badged row; traversal recurses into its real
children.
*Source: UX.md ("Existing vs. Draft Nodes")*

### Draft Node
A node with no child BO yet. Requirement is computed hypothetically
(part's BOM × cascaded parent quantity). Rendered as an editable row.
Nothing is written to InvenTree until the user commits. Promotes to
Existing the moment any part of a Commit Decision is written.
*Source: UX.md ("Existing vs. Draft Nodes")*

### Canonical Node / Reference Node (LCA Handling)
When the same sub-assembly is required by multiple branches, it is shown
**once**, at its lowest common ancestor position — the **canonical node** —
with a merged quantity and a badge listing which branches need it. Every
other branch shows a **reference node**: non-expandable, no chevron, no
independent `rowExpansion` state, just a pointer back to the canonical row
("→ see [Part] above, required 5 of 12").
*Source: UX.md ("LCA Placement"); ROW-UX.md ("LCA-Merged Nodes in This Model")*
**Open (ROW-UX.md, unresolved):** exact visual treatment for the reference
row still needs to read as clearly non-interactive — not yet designed.

### Combine vs. Split (LCA override)
Default behavior for a canonical node is **combine**: one Draft BO for the
merged quantity, parented to the branches' common ancestor (not to any
single consuming branch — this is a hard requirement, not a style choice,
since a combined BO's `parent` FK can't point at two branches at once).
**Split** (separate BOs per branch) is an available override, per-node or
global-setting, for cases like materially different due dates.
*Source: UX.md ("Combine by default; split as override")*
**Open:** global setting vs. purely per-node override — need both, or just one?

---

## Quantity & Netting

### Requirement
The quantity of a part needed at a node. For Draft nodes: BOM quantity ×
cascaded parent build quantity. For Existing nodes: pulled directly from
the child BO's real `BuildLine`.
*Source: UX.md; ROW-UX.md Part 1*

### Allocation
Stock already assigned to a specific `BuildLine`'s need, via a real
`BuildItem` record. Always reduces Outstanding — not a toggle-able
"available stock" concept, it's already committed.
*Source: UX.md ("Netting")*

### Outstanding
The authoritative "still need to cover this" quantity per node. Formula:

```
Required
− Allocated stock                         (always applied)
− Unallocated stock on hand                [if "Net against stock" toggle on]
− Incoming qty on open Purchase Orders     [if node is purchasable]
− Already-building (remaining output of Existing child BOs)
= Outstanding
```

Default toggle state: net against unallocated stock = on, scoped to this
BO tree only. **Open-PO netting is unscoped by project** — see the
resolution immediately below; this differs from UX.md's original draft,
which proposed project-scoping this term by default. Treat that line in
UX.md as superseded by the resolution here.
*Source: UX.md ("Netting: What Reduces 'Outstanding to Build'"), as amended below*

**✅ RESOLVED:** Plugin 2's Outstanding formula uses the raw, unscoped
`on_order` value — ROW-UX.md's decision wins. Project-code matching stays
a separate, informational-only column; it never filters or reduces the
number that feeds Outstanding.

**Rationale:** project scoping is a powerful, deliberate tool for
reasoning about specific items/assemblies — worth surfacing so a user can
judge whether incoming stock is really earmarked for this build — but it
isn't load-bearing for Plugin 2's core job. It becomes load-bearing in
**Plugin 3**, where detecting "already on order for this project" against
shortfall calculations is a primary function, not a nice-to-have. See
Project Scope section below.

### Netting Toggles
User-facing controls (not hidden settings), consistent with Flat BOM's
existing pattern:
- **Net against stock** — on/off.
- **Which allocations/stock count** — all / this BO tree only / none.
- **Open PO scoping** — unscoped (raw `on_order`) by default in Plugin 2;
  project-code match shown alongside as an informational column only, never
  auto-applied to the netting math (see resolution above).
*Source: UX.md; PLUGIN-TRILOGY.md ("Cross-Cutting Concern")*

### Project-Code Hint Column
A native, filterable `project_code` field exists on both Build Orders and
Purchase Orders. Displaying "of this node's on-order qty, N share this BO's
project code" is a **separate informational column**, never authoritative,
never feeding Outstanding math directly (see resolution above). Chosen over
a toggle specifically to prevent Outstanding from silently changing based on
a display setting.
*Source: ROW-UX.md Part 1*

### Rollup Badge
A summary shown on a **collapsed** node, computed server-side during the
same eager full-tree traversal (e.g. "6 sub-assemblies below · 4 need
building · 2 covered"). Available immediately, independent of whether the
node has ever been expanded. Gives disclosure without requiring manual
expansion of every branch.
*Source: UX.md ("Full Computation, Collapsible Display"); ROW-UX.md Part 3*
**Open (INTERNAL-FAB.md):** when the "Show build candidates only" filter is
on, should badge counts reflect the filtered view or the full unfiltered
computation? Not yet resolved.

---

## Candidacy & Routing

### Build Candidate
A node is a Build Candidate — something Plugin 2 might create a BO for —
**if and only if it has no default supplier set**, regardless of the
InvenTree `purchasable` flag's state. A purchasable-but-supplierless
assembly is still a build candidate.
*Source: INTERNAL-FAB.md ("Plugin 2: No Internal-Fab Awareness Needed")*
This definition supersedes any earlier framing based on the `purchasable`
flag alone — `purchasable` and "has a default supplier" are explicitly
**not** the same condition.

### Purchase Candidate
A leaf part, or an assembly-level node with a default supplier set
(internal or external). Plugin 2 skips these entirely as BO candidates;
Plugin 3 owns routing them to a real or internal PO.
*Source: INTERNAL-FAB.md*

### Opportunity
A required assembly line with no BO created yet **and** not fully
allocated. This is the specific condition that makes a Draft node
"actionable" — the thing the tree's whole design is oriented around
surfacing.
*Source: ROW-UX.md Part 1*

### Internal-Fab Supplier (Bucket)
Not a new metadata field or object type — just an internal "supplier"
record (or set of records) representing the company's own shop. Plugin 3's
existing group-by-supplier logic buckets parts under it automatically, no
special-casing at the grouping step. What Plugin 3 *does* with that bucket
(write an internal-only PO line instead of a real one) is the
company-specific part.
*Source: INTERNAL-FAB.md ("Plugin 3: Internal-Fab as a Supplier Bucket")*
Note: Plugin 1 still needs the internal-supplier list too (to decide
whether to explode an assembly-with-supplier node) — an earlier draft of
this concept incorrectly called the list removable; corrected in
INTERNAL-FAB.md itself.

### Show Build Candidates Only (display filter)
A pure rendering/disclosure toggle on Plugin 2's tree — hides leaf nodes
that have a default supplier (not shown as leaves, not shown as Buy
candidates) without changing the underlying computation. Full traversal
still runs regardless of toggle state.
*Source: INTERNAL-FAB.md*

---

## MVP Scope — What v1 Actually Ships

### MVP Bulk Create
The v1 deliverable, per `ROW-UX.md` Part 2 — **confirmed by the project
owner to be the same feature as what `UX.md` calls "Bulk Commit,"** not two
separate things (see `04-Architecture-Decisions.md` ADR-029/ADR-010). This
is a direct, complete answer to Plugin 2's actual problem — no cross-tree
view, one BO at a time, per `UX.md`'s own opening problem statement. It is
not a cut-down preview of a "real" plugin that comes later; the Commit
Decision Model below is an **enhancement layer added on top of this**, not
the thing this is a placeholder for.

The tree renders with a checkbox on every node; the user checks whichever
nodes they want built; one bulk action opens a confirmation modal (one row
per selected node, part/quantity, editable) and creates a real Build Order
for every checked node in one call — the same `part`/`parent`/`quantity`
shape the native single-row "Build Stock" action already uses, just
orchestrated across many rows and levels at once. No Allocate, no Buy, no
per-node quantity splitting in this mechanism. Once BOs exist, the user
uses InvenTree's own native bulk toolbar (Auto Allocate Stock / Order
Parts / Allocate Stock) to cover the rest — the plugin doesn't own that
part of the workflow in v1, by design, not by omission.
*Source: ROW-UX.md Part 2 ("MVP Definition"); UX.md ("Bulk Commit"), merged per project owner confirmation*
**Open, inherited from the pre-merge UX.md framing:** interaction with
LCA-merged nodes (don't double-create a combined node reached via two
branches) and parent-selection validation/error wording when a selected
child has a missing parent BO — both still need real design attention
even though the feature itself is confirmed single, not two.

### Creation Order Constraint
A child BO's `parent` field requires the ancestor to already have a real
ID — a hard technical dependency, not a preference. Since **review order is
free** but **creation order is forced** (top-down), the tool enforces
that a child BO is only created when its immediate parent BO already
exists or is also explicitly selected in the same bulk-create action. If
the user tries to include a deeper-committed node whose parent is neither
real nor selected, the tool surfaces a hard error; it does **not**
auto-create missing ancestor BOs on the user's behalf.
**Applies to both layers** — MVP Bulk Create and the per-node Commit
Decision enhancement layer: the set of selected nodes is created in
dependency order, and any missing ancestor that was not selected is
rejected with an error.
*Source: UX.md ("Creation Order Is Forced")*

---

## Commit Decision Model

> **Scope note:** the definitions below (Commit Decision, the Three
> Actions, per-node Allocate/Build/Buy) describe an **enhancement layer**
> that gets added on top of MVP Bulk Create (above) — not the MVP itself,
> and not a "fuller version" it's secretly aiming to become. v1 is complete
> and valuable on its own. Read this section as "what gets added later,"
> not "what v1 is missing." See `04-Architecture-Decisions.md` ADR-029.

### Commit Decision
The action that writes a node's decision into real InvenTree data in one
step, replacing any batch-at-the-end "Create" button. Solves the problem of
a single decision often spanning multiple writes (e.g. allocate 10, build 3,
buy 5 — losing any one part loses a third of the decision).
*Source: UX.md ("Making a Decision: Commit Decision")*
**Note:** ROW-UX.md Part 5 later reconsiders the exact row-level widget
design (checkbox+single-button vs. plain-text-resting-state+per-action
confirm) — that's an interaction-design revision, not a change to the
Commit Decision concept itself. Domain Model concept stands regardless of
which row widget ships, **whenever this ships** (see scope note above).

### The Three Actions (Allocate / Build / Buy)
- **Allocate** — assigns existing stock to the parent's real `BuildLine`,
  via a direct `BuildItem` create (`build/item/`), not the bulk
  `build/:id/allocate/` endpoint. Always actionable since the parent BO
  already exists by the time a node is reviewable.
- **Build** — creates or tops up the node's real child BO via `forms.create`
  against `build_order_list`, pre-filled `{ part, parent, quantity }`.
- **Buy** — the exception case: only for assembly nodes with a default
  supplier. Writes a real PO line tagged with the parent build's
  `project_code`, quantity rounded to `pack_quantity` if set.
*Source: UX.md*

---

## Scoping

### Project Scope
The lens that determines which allocations/stock/POs "count" for a given
calculation: all / this-BO-tree-only / none for allocations and stock.
Both the PO itself and an individual PO line item carry a `project_code`
and can persist different values — line-item-level is the more precise
signal where it's set.
*Source: PLUGIN-TRILOGY.md ("Cross-Cutting Concern"); UX.md*

**Criticality differs sharply by plugin — this is a deliberate, resolved
distinction, not an inconsistency:**
- **Plugin 2:** optional/informational. Useful for a user judging a
  specific node ("is that incoming stock really meant for this build?"),
  but never drives the authoritative Outstanding number by default (see
  Outstanding, above).
- **Plugin 3:** crucial. Project-scoped matching is a primary mechanism —
  detecting "already on order for this project" is core to avoiding
  duplicate PO lines and correctly grouping shortfall by supplier *and*
  project.
- **Plugin 1:** does not currently filter on-order by project at all
  (see PLUGIN-TRILOGY.md); an open question for whether it should gain
  this before Plugin 3 ships.

---

## Terms Deliberately Not Yet Defined Here

These are referenced in the source docs but still genuinely undecided —
listed so it's clear they're pending, not forgotten:
- Optional/consumable BOM line handling (excluded vs. shown-unchecked vs. filterable)
- Substitute/variant part handling in a BOM
- Depth/node-count threshold that triggers "stopped at depth N" large-tree behavior
- Buy overlay fallback when a node's part has no default supplier at all
- Third state between Draft/Existing for a row with partial (not-all-three) Commit Decision progress (raised in ROW-UX.md Part 5's later revision)

---

## Reconciliation Log

| Concept | Conflict found | Status |
|---|---|---|
| Outstanding / Open-PO scoping | UX.md says project-scoped by default; ROW-UX.md says project-match must stay hint-only, never touching Outstanding | **Resolved** — hint-only wins for Plugin 2 (unscoped Outstanding); project scoping is deferred to Plugin 3, where it's crucial rather than optional |
| Internal-fab supplier list ownership | Earlier draft in INTERNAL-FAB.md itself suggested Plugin 1 didn't need the list; corrected within the same doc | Resolved (self-corrected in source) |
| Build Candidate definition | Could be read as based on `purchasable` flag; INTERNAL-FAB.md explicitly names this as a distinct, wrong reading | Resolved — default-supplier-set is the operative condition |
| Plugin 2's actual v1 scope | Domain Model/ADR log initially treated the full per-node Commit Decision model as settled v1 design, missing that ROW-UX.md Part 2 explicitly scopes v1 to bulk BO creation only (Part 5 = "Deferred — Not MVP") | **Resolved, confirmed by project owner** — "MVP Bulk Create" and UX.md's "Bulk Commit" are the same feature; this is a complete v1 answer to Plugin 2's problem, not a placeholder. Commit Decision Model is an enhancement layer on top. See ADR-029. |
