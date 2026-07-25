# 05 — Plugin Architecture

> **Status:** Extraction pass — consolidated from `PLUGIN-TRILOGY.md` and
> `INTERNAL-FAB-AND-SCOPE-BOUNDARIES.md`.
> **Purpose:** For each plugin — inputs, outputs, what it owns, what it
> explicitly does not own. This is the doc to check before adding a feature
> to any one plugin: if the feature belongs to a different plugin's
> ownership per this doc, it goes there instead, even if it'd be easier to
> bolt on locally. Concepts referenced here (Build Candidate, Outstanding,
> etc.) are defined once in `02-Domain-Model.md` — not redefined here.

---

## Cross-Cutting: Every Plugin Must Be Allocation-Aware and Project-Aware

Not optional per-plugin behavior — a baseline requirement across all three:
- **Allocations** affect every stock calculation. "In stock" is meaningless
  without knowing how much is already spoken for. Each plugin lets users
  choose whether to account for allocations and which ones (all / this BO
  tree / none).
- **On-order parts belong to projects.** Knowing something is on order only
  matters if it's earmarked for *this* project or someone else's.
- Criticality of project-scoping differs sharply by plugin — see
  `02-Domain-Model.md`'s Project Scope entry. Optional/informational in
  Plugin 2, crucial in Plugin 3.
*Source: PLUGIN-TRILOGY.md*

---

## The Single Goal Behind All Plugin Boundaries

Every ownership line drawn below — assembly vs. leaf, purchasable vs. not,
internal vs. external supplier — serves one goal: **keeping Build Order
volume manageable.** If a future feature proposal doesn't reduce or manage
BO volume, it's very likely solving a different problem than these
boundaries are drawn around.
*Source: INTERNAL-FAB.md*

---

## Plugin 1 — Flat BOM Generator

**Status:** v0.11.53, functional MVP, deployed to staging.
**Lives on:** Part detail page panel.

**Input:** A Part's full BOM tree.
**Output:** A flat purchasing-focused table — every leaf part with stock
levels, build margin, and warnings.

### What it owns
- The **explode vs. purchase-line decision** per node — the only plugin
  that makes this call. Two independent flags, not one combined category:

  | Assembly? | Default supplier set? | Purchase line? | Explode? | Case |
  |---|---|---|---|---|
  | No | No | — | — | Undefined case; flag if it comes up |
  | No | Yes | Yes | No | Ordinary leaf part |
  | Yes | No | No | Yes | Plain build assembly — only its leaf material appears; the assembly itself is Plugin 2's concern |
  | Yes | Yes, external vendor | Yes | No | Bought-complete assembly — one line, no explosion |
  | Yes | Yes, internal supplier | Yes | Yes | Hybrid case — gets both a purchase line (routed to internal supplier) and explosion (we produce it, need its raw material) |

  Rule 2 (explode) requires knowing the **internal-supplier list** to
  distinguish row 4 from row 5 — both are "assembly + purchasable," and the
  purchasable flag alone can't tell them apart. This list is load-bearing
  here, not redundant with "has default supplier" (an earlier draft of
  INTERNAL-FAB.md incorrectly suggested it was removable; self-corrected in
  the same doc).
- Cut-to-length / internal-fab display settings, off by default.
- Allocation-margin toggles: include/exclude allocations in build margin,
  include/exclude on-order in build margin.

### What it explicitly does NOT own
- **No side effects.** Flat BOM is read-only today — no PO or BO writes.
  (Worth noting: this is one of the reasons "PO generation as a Flat BOM
  feature" — Option C in Plugin 3's still-undecided entry-point question —
  is the least attractive of the four options considered, not a formally
  rejected one. See Plugin 3's section below; the entry point remains open.)
- **Project-aware on-order filtering.** Currently shows all on-order
  regardless of project. Open question (see Domain Model / ADR log):
  should this be added before Plugin 3 ships, since Plugin 3 depends on
  project-aware on-order detection being reliable somewhere in the stack?
- Supplier routing logic (real PO vs. internal PO) — that decision is
  Plugin 3's, even though Plugin 1 is the one that decides a node *gets* a
  purchase line at all.

### Shared concepts consumed
Build Candidate / Purchase Candidate distinction (Plugin 1 is where the
purchase-line half of this gets decided), default-supplier-vs-purchasable
distinction, internal-fab supplier bucket (list is shared with Plugin 3,
used for a different purpose in each).

---

## Plugin 2 — Build Order Generator

**Status:** UX/flow spec drafted, implementation not started.
**Lives on:** Build Order detail page (resolved — ADR-002).

**Input:** An existing parent Build Order (already has a build quantity
and project code defined).
**Output — v1 (MVP Bulk Create):** Real InvenTree Build Orders, created in
bulk from checkbox-selected tree nodes — a complete, direct answer to
Plugin 2's core problem (no cross-tree view, one BO at a time). Allocations
and PO lines aren't part of this plugin's v1 output; the user covers those
via InvenTree's own native bulk toolbar once BOs exist.
**Output — enhancement layer, added later:** Also stock allocations and
ad-hoc PO lines, via the full per-node Commit Decision.

> **Scope note:** `ROW-UX.md` Part 2 defines v1 as bulk BO creation
> (checkbox-select → one bulk "Create Build Orders" action) — confirmed
> with the project owner to be the same feature as `UX.md`'s "Bulk
> Commit," not a separate one, and confirmed as a complete v1 deliverable
> rather than a placeholder for something bigger. The rich per-node Commit
> Decision (Allocate/Build/Buy together, detailed in `ROW-UX.md` Part 5 —
> literally titled "Deferred — Not MVP") is an enhancement layer added on
> top afterward. See `04-Architecture-Decisions.md` ADR-029 / ADR-010.
> "What it owns" below is tagged by which layer each item belongs to.

### What it owns
- The core traversal/planning engine: one-call full-tree computation,
  Existing/Draft classification, netting, Outstanding calculation. **v1.**
- LCA merge and placement (canonical/reference node logic). **v1** — needed
  even for bulk BO creation, so duplicate branches don't create duplicate BOs.
- **MVP Bulk Create** (= "Bulk Commit," confirmed same feature) — checkbox
  multi-select + one bulk "Create Build Orders" action. **v1 — the actual
  deliverable, complete on its own.**
- **Build Candidate determination:** a node with no default supplier set is
  a candidate, full stop — see ADR-018. This is the one condition Plugin 2
  checks; it does not distinguish internal vs. external suppliers at all
  (see below). **v1** — needed for opportunity identification.
- The tree-rendering component itself (rowExpansion-based, per Platform
  Reference doc) — built once here, potentially reused by Plugin 4. **v1.**
- The Commit Decision write path — Allocate, Build, and the *ad-hoc*
  single-node Buy. **Enhancement layer, added on top of v1.**

### What it explicitly does NOT own
- **General/bulk leaf-part purchasing.** Plugin 2's Buy action (part of
  the enhancement layer, not v1) is explicitly ad-hoc and single-node —
  "one part, one quantity, right now." A bulk, end-of-review sweep across
  the whole tree's shortfall is Plugin 3's job entirely.
- **Internal vs. external supplier distinction.** Both are just "has a
  default supplier, skip as BO candidate" to Plugin 2. Whether Plugin 3
  later routes that supplier to a real PO or an internal one is entirely
  outside Plugin 2's concern — confirmed explicitly in INTERNAL-FAB.md as
  a rejected fourth Commit Decision action (ADR-024).
- **Read-only historical BO hierarchy display** for trees this plugin
  didn't generate — that's Plugin 4's use case, though it may end up as a
  display-flag mode of this same component rather than a separate plugin
  (see Plugin 4 section below).

### Shared concepts consumed
Requirement, Outstanding, Allocation, Existing/Draft, Canonical/Reference
node, Commit Decision, Project Scope (informational only here — see
Domain Model resolution), Build Candidate.

---

## Plugin 3 — Purchase Order Generator

**Status:** Not started — most uncertain of the three, entry point
genuinely undecided.

**Lives on:** **Open** — leaning toward BO detail page (Option B: tied to
a real BO with a project code, natural allocation scoping) over the Part
page (Option A: works before any BOs exist, but disconnected from project
codes) — not committed. See ADR log's open-items list.

**Input:** A shortfall list of parts needing purchasing — either Flat
BOM's output (Option A) or a BO tree's leaf parts (Option B) — plus live
open POs (to detect what Plugin 2 already bought ad-hoc).
**Output:** Real Purchase Orders and PO line items, grouped by supplier,
tagged with project codes.

### What it owns
- Supplier-grouping logic (find existing pending PO with matching project
  code per supplier, or offer to create a new one).
- **Project-scoped "already on order for this project" detection** — this
  is the one place in the whole suite where project scoping is genuinely
  load-bearing, not just a nice-to-have (see Domain Model's Project Scope
  entry).
- Internal-fab supplier routing: the internal-fab list is just a
  "supplier" bucket that falls out of Plugin 3's existing group-by-supplier
  logic automatically — no special-casing at the grouping step. What's
  company-specific is only what happens *after* grouping (write an
  internal-only PO line, tagged with the parent build's `project_code`,
  instead of a real vendor PO line).
- **Cascading material requirement for internally-fabbed parts:** an
  internal-fab PO isn't the end of the chain — it should also trigger a
  check of *that part's own BOM* for deficits (raw filament, stock tubing,
  etc.), generating a real external PO for underlying material where
  needed. This should fall out of the same recursive netting/traversal
  engine as everything else, not need special-case code — it's just
  another node to net and group, one BOM layer down.
- Supplier selection when multiple supplier parts exist for one part
  (default + override — precedent set by Plugin 2's Buy action, reused
  here for the bulk case).
- `pack_quantity` rounding (same logic Plugin 2's Buy action needs — build
  once, reuse).

### What it explicitly does NOT own
- Ad-hoc, in-the-moment single-node purchase decisions made mid-review of
  Plugin 2's tree — that stays Plugin 2's Buy action.
- Build Order creation of any kind.

### The one required sync point with Plugin 2
Plugin 3's shortfall calculation must read live open POs the same way
Plugin 2's netting stack does. As long as both consistently read live
InvenTree data, this is automatic — no special coordination code needed
between the two plugins.

### Shared concepts consumed
Purchase Candidate, Project Scope (crucial here), internal-fab supplier
bucket (defined and primarily used here).

---

## Plugin 4 (Maybe) — BO Hierarchy Display

**Status:** Idea only, deferred until Plugin 2 is built and proven.

**What it would do:** A Tree View of Build Order parent/child
relationships, alongside InvenTree's existing List/Calendar views.

**Current thinking:** If Plugin 2's tree component is solid, a read-only
"existing-BOs-only" mode of that same component likely covers this without
a separate plugin — hide the Build/Allocate/Buy controls and Commit
Decision button, keep badges/indentation/rollups/LCA handling identical
(see `04-Architecture-Decisions.md` and ROW-UX.md Part 4).

**Open fork, not yet resolved:** the shared-component assumption may only
hold for *visual rendering*, not *fetch strategy*. Plugin 2's MVP wants
eager, one-call, whole-tree fetching — right for a bounded, mostly-Draft
opportunity tree. A pure status-viewer over an **already fully-built**
tree could be much larger in practice (months of completed nested builds),
where eager-fetch-everything may be the wrong default. Same visual
component, possibly different fetch strategy underneath — worth deciding
once Plugin 2 exists to test this against, not now.

**Standalone justification, if it comes to that:** useful even without the
generator, for any user with manually-created BO hierarchies. Not yet
judged worth a full separate plugin on its own.

---

## Decision Ownership — Quick Reference

| Decision | Owning plugin | Rule |
|---|---|---|
| Does this node get a purchase-list line? | Plugin 1 | Default supplier set (Y/N) |
| Does this node get exploded to leaf material? | Plugin 1 | No supplier, or supplier is on the internal-fab list |
| Is this node a Build Candidate? | Plugin 2 | No default supplier set — internal/external distinction irrelevant here |
| Does incoming on-order stock reduce this node's Outstanding? | Plugin 2 | Yes, unconditionally — unscoped by project (see Domain Model) |
| Does a project-code match affect Outstanding? | Plugin 2 | No — informational column only |
| Does this supplier route to a real PO or an internal one? | Plugin 3 | Supplier matches internal-fab bucket, or not |
| Is a shortfall already covered by an open PO for this project? | Plugin 3 | Project-scoped match — crucial, not optional |
| Does an internally-fabbed part's own raw material get purchased? | Plugin 3 | Cascading check via the same traversal engine |

---

## Open Architecture Questions (pointer — full detail in ADR log)

- Plugin 3's entry point (Part page vs. BO page vs. standalone vs. folded
  into Plugin 2) — genuinely undecided.
- Whether Plugin 1 needs project-aware on-order filtering before Plugin 3
  ships, given Plugin 3 leans on that concept being reliable somewhere.
- Plugin 4's fetch-strategy fork (eager vs. lazy) once Plugin 2 exists to
  test the shared-component assumption against.
