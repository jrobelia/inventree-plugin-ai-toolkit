# 04 — Architecture Decisions

> **Status:** Extraction pass — consolidated from `suite source docs`,
> `BUILD-ORDER-GENERATOR-UX.md`, `BUILD-ORDER-GENERATOR-ROW-UX-AND-TREE-RENDERING.md`,
> and `INTERNAL-FAB-AND-SCOPE-BOUNDARIES.md`.
> **Scope note:** This log captures *decisions* — what was chosen, what was
> rejected, and why. Raw technical facts about InvenTree/SDK internals
> (endpoint names, component locations, plugin behaviors) that informed
> these decisions are **not** duplicated here — they belong in
> `PLATFORM-REFERENCE.md` (next extraction pass). Where a
> decision leans heavily on a platform fact, this log references it briefly
> without re-deriving it.
> **Status field key:** Accepted / Rejected / Declined / Open (not yet decided).
> Where a decision revises an earlier one from the same source doc, that's
> noted as a parenthetical on the Accepted entry (e.g. ADR-016) rather than
> a separate "Superseded" status.

---

### ADR-001 — No shared library across the three plugins
**Status:** Accepted
Each plugin is its own repo/codebase. Extract a shared `inventree-bom-toolkit`
only if a third plugin proves the need — not preemptively.
*Source: suite source docs*

### ADR-002 — Build Order Generator lives on the Build Order detail page, not the Part page
**Status:** Accepted
A parent BO already has a defined build quantity and project code; a
Part-page version would require guessing a hypothetical quantity.
*Source: suite source docs; UX.md ("Where It Lives")*

### ADR-003 — LCA-merged nodes combine by default; split is an override
**Status:** Accepted
Reduces BO count (a stated core goal). Combined node parents to the common
ancestor, not to either consuming branch — required by the DB's parent FK
constraint, not a style choice.
*Source: suite source docs; UX.md*

### ADR-004 — Stock coverage splits across Allocate/Build/Buy per node
**Status:** Accepted (⚠️ v2+ scope — see ADR-029)
Rejected alternative: a single binary "build all vs. build net" choice per
node. The Commit Decision model allows any mix, written atomically per node.
**v1 MVP does not include this** — v1 only bulk-creates Build Orders;
Allocate/Buy happen via InvenTree's native toolbar afterward, not via this
mechanism.
*Source: suite source docs; UX.md*

### ADR-005 — No persisted "Save Draft" state
**Status:** Accepted
Tree recomputes fresh on every panel open plus manual refresh; nothing
cached to disk in v1. Rationale: a saved draft's numbers can silently drift
from live InvenTree state between visits — the exact staleness risk the
"transitory" principle exists to avoid. The Commit Decision model (write
immediately on action) solves the underlying "don't lose my work" problem
without needing draft persistence.
*Source: UX.md ("No Save Draft")*

### ADR-006 — Allocate action targets a single `BuildItem` create, not the bulk allocate endpoint
**Status:** Accepted (⚠️ v2+ scope — see ADR-029; v1 has no plugin-built Allocate action at all)
InvenTree's native Allocate UI posts to a bulk, multi-row endpoint built for
a different UI shape. A single-node Commit Decision is simpler served by a
direct create against the item-level endpoint.
*Source: UX.md*

### ADR-007 — Build/Buy implemented via generic SDK `forms.create`, not internal rich components
**Status:** Accepted (Build half is v1 MVP; Buy half is ⚠️ v2+ scope — see ADR-029)
InvenTree's internal wizards (e.g. the multi-part/supplier-picker wizard,
the specialized allocation table) aren't exported to `@inventreedb/ui`.
Plugin uses plainer generic forms against the same underlying endpoints.
**v1 note:** the Build half of this is real MVP scope — bulk BO creation
uses exactly this `forms.create` / `build_order_list` pattern. The Buy
half only matters once per-node Buy exists, which is v2+.
**Escape hatch, not committed:** bespoke modals modeled on the internal
wizards are an explicit optional v2 polish item if the generic forms feel
too bare — not a v1 blocker.
*Source: UX.md*

### ADR-008 — Critical-path / lead-time analysis is out of scope for v1
**Status:** Accepted
Rationale: `SupplierPart.lead_time` exists in InvenTree's model but is
commented out/unused — there's no real value to compute a critical path
from today. Flagged as a genuinely promising future direction (re-enabling
is a migration + serializer exposure, not new tracking from scratch), and
noted that this plugin's tree traversal is the natural place to add it
later, but not building a parallel data source to get there sooner.
*Source: UX.md*

### ADR-009 — Build Order Generator's Buy action is ad-hoc/single-node; bulk purchasing is Purchase List Generator's job
**Status:** Accepted (⚠️ the Buy action itself is v2+ scope — see ADR-029; the boundary principle with Purchase List Generator holds regardless)
Boundary decision. The one required sync point: Purchase List Generator's shortfall calc
must read live open POs the same way Build Order Generator's netting does, so it
doesn't re-propose a line Build Order Generator already bought ad-hoc. No special
coordination code — both just read live InvenTree data. **v1 note:** with
no plugin-built Buy action in v1, this sync point only becomes live once
Buy ships in v2 — worth remembering it's not yet load-bearing.
*Source: UX.md*

### ADR-010 — Bulk Commit *is* ADR-029's MVP — same feature, confirmed
**Status:** Accepted — **confirmed merged with ADR-029** (not "likely,"
verified with the project owner)
This entry's "coarse first version — build everything outstanding, no
partial allocate/buy splits" and ADR-029's bulk "Create Build Orders"
action are the same feature, described independently in two source docs
written at different points. Treat ADR-029 as the canonical statement of
what this actually is; this entry is preserved as the earlier framing of
the same decision, not a separate one to build.
*Source: UX.md; suite source docs*

### ADR-011 — Project-code match is a separate informational column, not a toggle
**Status:** Accepted
Rejected alternative: a toggle that filters the `on_order` column itself
down to project-matched POs. Rejected because it would make the row's
authoritative Outstanding number depend on a display setting. See
`suite CONTEXT.md` for the fuller resolution (Build Order Generator = informational
only; Purchase List Generator = this becomes the crucial mechanism).
*Source: ROW-UX.md Part 1*

### ADR-012 — Tree uses checkbox multi-select + bulk-toolbar-action pattern
**Status:** Accepted
Matches the native Required Parts table's existing bulk pattern
(Auto-Allocate / Order / Allocate / Deallocate / Consume) rather than
introducing a separate interaction paradigm.
*Source: ROW-UX.md Part 2*

### ADR-013 — [Correction] Tree rendering is recursive `rowExpansion` composition, not `subRows`/depth-indentation
**Status:** Accepted (supersedes earlier wrong assumption)
An earlier pass assumed InvenTree's tables were `mantine-react-table`
(TanStack) with a `subRows` tree prop. Confirmed wrong against source:
the actual foundation is `mantine-datatable`, and every multi-level display
in InvenTree (the direct precedent: `BomTable`/`BomSubassemblyTable`) uses
recursive composition of separate table instances via single-level
`rowExpansion`, not a nested-array/indentation pattern. This plugin adopts
the same mechanism. Full technical detail → Platform Reference doc.
*Source: ROW-UX.md Part 3*

### ADR-014 — Eager fetch, lazy render
**Status:** Accepted
Full tree computed server-side in one call on panel load (keeps "confidence
from a computed rollup badge, not manual expansion"). Rendering still uses
`rowExpansion` for the native nested-card look, but `content` reads from
already-fetched data per branch rather than refetching per expand — a
deliberate departure from `BomSubassemblyTable`'s per-expand refetch model.
*Source: ROW-UX.md Part 3*

### ADR-015 — Indentation style: nested cards vs. column-aligned depth indentation
**Status:** Open — not yet decided
Two real options, both technically buildable on `rowExpansion`. Prototyped
in `bo-tree-spike.jsx` alongside the Part 5 row-interaction revision (see
ADR-016) — check that file for current thinking, this is a UX call not a
technical constraint.
*Source: ROW-UX.md Part 3*

### ADR-016 — [Superseded] Row interaction: checkbox+single-Commit-button → plain-text state + per-action confirm
**Status:** Accepted (revision; supersedes the row design in the same doc) — ⚠️ **entirely v2+ scope, see ADR-029.** This whole ADR describes Part 5 content, which v1 doesn't build at all.
**Original design:** Build checkbox (checked by default) + single "Commit
Decision" button firing whatever's staged across all three actions.
**Revised to:** Build becomes a plain-text resting state ("Build 12", no
widget) that live-shrinks as Allocate/Buy are staged; Allocate and Buy
become fully independent actions with their own scoped Confirm buttons.
**Rationale for the revision:** a checkbox implies Build is an optional
toggle, when doing nothing already means "build the full outstanding" —
that's not a real choice to elevate to a checkbox. Bundling one one-click
action (Build) with two genuinely multi-field decisions (Allocate, Buy)
under one button also overstated how symmetric the three actions are.
**Reopens an unresolved question:** with no single atomic commit anymore,
when does a row flip from Draft to Existing? Possibly a third state
("2 of 3 actions done") — not yet resolved.
*Source: ROW-UX.md Part 5*

### ADR-017 — Modal vs. inline for Allocate/Buy: inline wins, via `editApiForm`
**Status:** Accepted (⚠️ v2+ scope, see ADR-029 — no plugin-built Allocate/Buy UI exists in v1 to be modal or inline)
Rationale: keeps tree context visible while deciding — specifically needed
for comparing LCA sibling-branch quantities while allocating, which a
modal would hide. One consistent interaction pattern across all three
actions, less to learn.
**Known cost, accepted:** dynamic row height — an expanded row pushes rows
below it down, more layout churn in a deep tree than a modal would cause.
**Open sub-question:** cap on how many rows can have Allocate/Buy expanded
simultaneously — not yet resolved.
*Source: ROW-UX.md Part 5*

### ADR-018 — BO candidacy is determined by "default supplier set," not the `purchasable` flag
**Status:** Accepted
This is the resolving decision for what was previously an ambiguous
boundary between Plugins 1/2/3. `purchasable` marks a part as *capable* of
being bought; it says nothing about whether a source has actually been
committed. Build Order Generator only treats "no default supplier set" as a build
candidate, regardless of the purchasable flag's state.
*Source: INTERNAL-FAB.md*

### ADR-019 — "Show Build Candidates Only" toggle: generic display filter
**Status:** Accepted
Pure rendering/disclosure change — full traversal still computes every
node regardless of toggle state; the toggle only changes what's displayed.
Deliberately generic naming ("show build candidates only," not "hide
internal fab parts") so it's legible to any user, not just internal-fab
shops.
*Source: INTERNAL-FAB.md*
**Open:** does the collapsed-node rollup badge math need to reflect the
filtered view, or always show the unfiltered full computation? Not resolved.

### ADR-020 — Internal-fab handled as a Purchase List Generator supplier bucket, not new Build Order Generator metadata
**Status:** Accepted
No new custom field, no new object type. An internal "supplier" record is
grouped by Purchase List Generator's existing group-by-supplier logic like any other
supplier; what's company-specific is only what Purchase List Generator does with that one
bucket (write an internal PO line instead of a real one).
*Source: INTERNAL-FAB.md*

### ADR-021 — [Rejected] `cf_fab_method` custom field + forked `AutoCreateBuildsPlugin`
**Status:** Rejected
Proposed a three-way dispatch field (`BUILD`/`INTERNAL_FAB`/`PURCHASED`)
evaluated inside a forked event-driven plugin. Rejected: event-driven
automation directly contradicts the human-in-the-loop Commit Decision
model that's Build Order Generator's core design principle.
*Source: INTERNAL-FAB.md*

### ADR-022 — [Rejected] Dedicated `Internal_Fab_Batch` object with a "Release Batch" control
**Status:** Rejected
Duplicates work already planned as Bulk Commit (ADR-010). No separate
batch object needed.
*Source: INTERNAL-FAB.md*

### ADR-023 — [Rejected] "Modular Monolith" shared repo for all three plugins
**Status:** Rejected
Conflicts directly with ADR-001. Nothing about internal-fab scope changes
that calculus.
*Source: INTERNAL-FAB.md (reaffirms ADR-001)*

### ADR-024 — [Rejected] A fourth Commit Decision action ("Work Order"/internal PO) inside Build Order Generator
**Status:** Rejected
Superseded by the simpler realization (ADR-020): Build Order Generator doesn't need to
distinguish internal from external suppliers at all. The display filter
(ADR-019) is sufficient on Build Order Generator's side; sourcing is entirely Purchase List Generator's
concern.
*Source: INTERNAL-FAB.md*

### ADR-025 — [Declined] Forking native automation for a "hybrid model" (background BO creation + read-only viewer)
**Status:** Declined
Proposed forking `AutoCreateBuildsPlugin` to create real BOs in the
background (framed as "Draft"), with a read-only tree viewer for
after-the-fact human review. Declined for four reasons:
1. Background-created BOs are real DB objects the instant the signal
   fires — reversing means cancelling real records, not discarding a form.
   Materially weaker safety property than Commit Decision's
   nothing-written-until-a-human-acts model.
2. LCA merging would become post-hoc cleanup (human notices duplicate BOs,
   manually consolidates) instead of being prevented before creation.
3. Would require a second, independent netting/traversal implementation
   living in the forked plugin — a drift risk against Build Order Generator's engine.
4. The proposal's own stated problem (lack of visibility) is better solved
   by visibility-first design (see the tree, then decide) than an invisible
   background process with a viewer bolted on after.
*Source: INTERNAL-FAB.md*

### ADR-026 — No manual tree restructuring in v1
**Status:** Accepted, revisit if requested
LCA placement, combine/split — no drag-and-drop or manual override of the
computed tree structure itself in v1.
*Source: suite source docs (Open Questions, resolved)*

### ADR-027 — Tree always reflects live state; no explicit "resync" action
**Status:** Accepted
Existing child BOs/allocations reduce Outstanding automatically on
recompute; previously committed nodes just render as Existing on next
load. Applies to LCA-combined nodes too — a later Commit Decision tops up
the existing combined BO rather than creating a second one.
*Source: UX.md ("After You Commit")*

### ADR-028 — Plugin 4 deferred; a read-only mode of Build Order Generator's tree likely covers it
**Status:** Accepted (deferred scope)
Defer building a standalone BO Hierarchy Display plugin until Build Order Generator
exists. If Build Order Generator's tree component is solid, extending it with an
existing-BOs-only read-only mode (hide Build/Allocate/Buy controls and
Commit Decision, keep badges/indentation/rollups/LCA handling identical)
should cover Plugin 4's use case without a separate codebase — only build
Plugin 4 standalone if the scope clearly diverges once tested.
**Practical implication:** worth building the read-only toggle early —
even before full Allocate/Buy polish — specifically as a way to validate
the tree-rendering foundation in isolation, not just as a bonus once
everything else is done.
**Open fork this doesn't resolve:** the shared-component bet may only hold
for *visual rendering*, not *fetch strategy*. Build Order Generator's MVP wants eager,
one-call, whole-tree fetching — right for a bounded, mostly-Draft
opportunity tree. A pure status-viewer over an **already fully-built**
tree (months of completed nested builds) could be large enough that
eager-fetch-everything is the wrong default there. Same visual component,
possibly different fetch strategy underneath — not resolved, deliberately
left as an open fork rather than assumed compatible.
*Source: suite source docs ("Plugin 4"); ROW-UX.md Part 4*

### ADR-029 — The MVP *is* the answer to Build Order Generator's actual problem; Commit Decision is an enhancement layer on top
**Status:** Accepted — confirmed with the project owner
**This is the single most important scope clarification in the whole log,
and it was missing from earlier passes of this document.**

`ROW-UX.md` Part 2 explicitly and narrowly defines Build Order Generator's actual v1 as
four things: (1) a full descendant-tree view, one screen; (2)
BO-opportunity identification (Existing/Draft, Outstanding); (3) checkbox
multi-select across the whole tree; (4) **one bulk "Create Build Orders"
action** — a modal, one row per selected node, single confirm, creates
all selected BOs in one go. Nothing else.

**Reframing, per the project owner:** this MVP isn't a cut-down stand-in
for some larger "real" plugin — it's the direct, complete answer to the
problem Build Order Generator exists to solve, stated plainly in `UX.md`'s own opening:
*"InvenTree only lets you create one child Build Order at a time, and
there is no view that shows the full set of child BOs a parent BO needs."*
A full tree view plus one bulk BO-creation action is a whole, shippable
answer to exactly that gap. Nothing about it is missing or provisional.

The rich, per-node **Commit Decision model** described at length in
`UX.md` — per-node Allocate/Build/Buy together, live recalculating
quantities, inline `editApiForm` widgets — lives in `ROW-UX.md` Part 5,
explicitly titled "(Deferred — Not MVP)." This is an **enhancement layer**
for users who want granular per-node control once BOs exist, not the "real"
version of which the MVP is a shrunken preview. For v1, Allocate and Buy
against newly-created BOs happen entirely through InvenTree's own existing
native bulk toolbar — not through anything this plugin builds. Quote:
*"building bespoke inline per-row Allocate/Buy controls inside this
plugin's tree is duplicating a solved problem, not filling a gap... no
reinvention needed."*

**Confirmed merge with ADR-010:** `UX.md`'s own "Bulk Commit" (ADR-010)
and this MVP's bulk "Create Build Orders" action are **the same feature**,
described independently in two docs written at different points — verified
with the project owner, not a guess. This entry is the canonical statement
of what it is; ADR-010 is kept as the earlier framing, not a second thing
to build.

**Practical effect on every ADR below that references "Commit Decision"
as if it were day-one scope (ADR-004, ADR-006, ADR-007, ADR-009, ADR-016,
ADR-017):** that content is real, valuable design work for the enhancement
layer — correctly scoped as v2+, not incorrectly scoped as "lesser" or
"not really the point." v1 is complete and valuable on its own: see
everything, check some boxes, create the Build Orders, then use
InvenTree's own screens for the rest.
*Source: ROW-UX.md Part 2 ("MVP Definition"), Part 5 header; UX.md ("The Problem")*

### ADR-030 — No silent auto-creation of missing ancestor Build Orders
**Status:** Accepted
A child Build Order can only be created if its immediate parent BO already
exists as a real InvenTree object or is explicitly selected in the same
bulk-create action. If neither is true, the tool surfaces a hard error and
refuses to proceed. Build Order Generator does not silently create an ancestor the user
did not ask for. This preserves "Free review order, enforced write order"
while ensuring every BO the plugin writes reflects a deliberate human
choice. Future spikes may explore alternative ancestor-creation UX, but v1
ships with this fail-fast behavior.
*Source: discussion with project owner; corrects the parenthetical in
`VISION.md` Principle 7 and `suite CONTEXT.md`
"Creation Order Constraint".*

---

- **ADR-015** — indentation style (nested cards vs. column-aligned)
- **ADR-016's reopened question** — Draft→Existing state when no single atomic commit exists (possible third state)
- **ADR-017's sub-question** — cap on simultaneous expanded Allocate/Buy rows
- **ADR-019's sub-question** — rollup badge math under the build-candidates-only filter
- Purchase List Generator's entry point (Part page vs. BO page vs. feature of Build Order Generator vs. standalone) — still genuinely undecided, leaning BO-page (Option B) per suite source docs but not committed
- Depth/node-count threshold that triggers "stopped at depth N" large-tree handling
- Bulk Commit's full behavior at scale (ADR-010 only covers the deferred-first-version scope)
- Whether Flat BOM Generator should gain project-aware on-order filtering before Purchase List Generator ships (flagged in Domain Model's Project Scope entry)
- **ADR-028's open fork** — whether Plugin 4's read-only mode should inherit Build Order Generator's eager-fetch strategy or use a different (likely lazy) one for already-large existing-BO trees

## Platform Facts Referenced Above — Full Detail in `PLATFORM-REFERENCE.md`

The raw technical facts behind several ADRs above now have their own
authoritative home rather than living only inside ADR rationale:
`mantine-datatable` vs. `mantine-react-table`, `rowExpansion`/
`DataTableRowExpansionProps` API, `@inventreedb/ui`'s `InvenTreeTable`
proxy and `context.tables.renderTable`, native `BuildLineTable` per-row
actions (Build Stock/Allocate/Order Stock), `OrderPartsWizard` flow order
and non-exported status, `AutoCreateBuildsPlugin` / `AutoIssueOrdersPlugin`
behavior and scheduling, `on_order` field location, `ProjectCodeColumn`/
`ProjectCodeFilter` locations, `project_code` as a genuine field on PO line
items, `editApiForm` (version caveat noted in that doc's Version Baseline
section — don't over-trust the "1.4.2" pin), `TableColumnSelect`,
`SupplierPart.pack_quantity`, the pre-1.0 `bootstrap-table-treegrid`
historical precedent. Check that doc first if you need the underlying
"why do we know this" detail — this log only carries what's needed to
understand the decision itself.
