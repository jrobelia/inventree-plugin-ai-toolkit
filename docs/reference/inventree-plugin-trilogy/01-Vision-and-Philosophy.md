# 01 — Vision and Philosophy

> **Status:** Extraction pass — principles distilled from all four source
> docs, cross-checked against `02-Domain-Model.md` and
> `04-Architecture-Decisions.md` for consistency.
> **Purpose:** The project's constitution. When a future design question
> comes up that isn't yet covered by the Domain Model or an ADR, this is
> the document that should settle which direction is *in character* for
> the platform. Plugin specs should defer to this rather than re-deriving
> philosophy per plugin.

---

## The Problem, Stated Plainly

InvenTree holds the real BOM, stock, and order data. What it doesn't do is
show a human the *whole shape* of a manufacturing plan at once, or make it
cheap to act on that whole shape in one sitting. Every plugin in this suite
exists to close that visibility-and-action gap — never to become a second
source of truth alongside InvenTree, and never to make decisions a human
didn't actually make.

---

## Core Principles

### 1. InvenTree is the system of record — always
The plugin computes, recommends, and displays. It never becomes the
authoritative store for anything. A Draft node isn't "half-real" data
sitting in our backend — it's a live computation that either becomes a
real InvenTree object the moment a human commits it, or ceases to exist
on next refresh. There is never a state where our plugin is the only place
a decision is recorded.
*Underpins: no Save Draft (ADR-005), transient computation below.*

### 2. Human-in-the-loop, not background automation
Every write happens because a human looked at a specific node and decided,
right then, to act. This is not a preference for a nicer UI — it's the
reason the "hybrid model" (background auto-creation + read-only viewer)
was declined (ADR-025) even though it would have been faster to ship. Speed
that removes the human from the decision is explicitly the wrong trade for
this platform.

### 3. Transient computation, not persisted state
The full tree recomputes fresh on every panel open, plus manual refresh.
Nothing is cached to disk. A cached plan can silently drift from live
InvenTree reality between visits — the risk is worse than the cost of
recomputing. (Possible future exception: caching BOM *structure*, which
rarely changes, separately from *live state*, which always does — not
built now.)

### 4. Immediate, atomic commitment
The moment a human approves any part of a decision — even one-third of a
three-part Allocate/Build/Buy split — it's written to real InvenTree data
immediately. Nothing valuable is ever allowed to exist only in the
plugin's in-memory state, where a refresh could lose it. *(The three-part
split describes the enhancement layer added on top of v1 — see
`04-Architecture-Decisions.md` ADR-029. The v1 MVP's single bulk "Create
Build Orders" action is the same principle in a simpler form: nothing is
held in the plugin's own state past the moment of the confirm click.)*

### 5. Deterministic and explainable, never a black box
Every number the user sees traces back to a computation they could, in
principle, inspect. Rollup badges are computed values from a real
traversal, not estimates. If a number can't be explained, it shouldn't be
shown as authoritative — see the Outstanding / project-code-hint split in
the Domain Model, where a "hint" is deliberately kept out of the
authoritative number specifically so the authoritative number stays fully
explainable.

### 6. Progressive disclosure, never hidden incompleteness
Full computation always happens up front, for the whole tree, in one call.
*Display* can collapse — that's just UI economy. But the underlying answer
is always complete, and honest about its own limits: if a tree is too
large for full eager computation, the UI says so explicitly ("stopped at
depth 6, expand to compute further") rather than silently truncating.
Silent gaps would undermine the entire reason this plugin exists.

### 7. Free review order, enforced write order
Users think about a build in whatever order makes sense to them — often
leaf-first, since that's where granular decisions live. InvenTree's data
model doesn't care about that order; it forces parent-before-child
creation. The tool preserves free review order but enforces the write
order: a child BO can only be created if its parent BO already exists or
is explicitly selected in the same bulk action. The tool surfaces a hard
error rather than silently creating an ancestor the user did not ask for.

### 8. Minimize unnecessary Build Order volume
This shows up everywhere, not just in one feature: LCA merging combines
duplicate sub-assembly requirements into one BO by default; Build
Candidate classification exists specifically to keep anything with a
committed supplier out of the BO pipeline entirely. If a future feature
proposal doesn't reduce or manage BO volume, it's very likely solving a
different problem than this platform is about — worth naming explicitly
when evaluating new ideas.

### 9. Reuse native primitives; don't duplicate what's already solved
Where InvenTree's own bulk toolbar already solves a problem (Allocate and
Buy, once real BOs exist), building a parallel bespoke version inside this
plugin isn't polish — it's duplicated maintenance surface for no user
benefit. This plugin's value is specifically the parts InvenTree doesn't
already do: the cross-level tree view, the rollup, the LCA merge. Build
those; don't rebuild the rest.

### 10. Company-specific logic lives in the plugin that owns the decision
When a feature turns out to be company-specific (internal-fab routing),
the fix isn't a hidden setting bolted onto a general-purpose plugin — it's
recognizing which plugin's actual job the decision belongs to (Plugin 3
owns supplier routing) and keeping the general-purpose plugins (1, 2)
free of that concept entirely. One concept, one owning plugin.

### 11. Prefer InvenTree's existing fields over inventing new metadata
Default supplier (already a field) over a custom `cf_fab_method` flag.
`project_code` (already a field, already on PO line items) over a parallel
tagging system. If InvenTree already models something close enough to what's
needed, extend the read of that field rather than adding a new one.

---

## Design Heuristics (secondary, follow from the above)

- **Toggles the user can see, not hidden settings** — netting scope,
  allocation scope, and the future build-candidates-only filter are all
  visible controls, not buried config.
- **Combine by default, split as override** — reducing count is the
  default; the exception is opt-in, not the reverse.
- **A number that can silently change based on a display setting is a
  bug, not a feature** — this is why project-code match stays a separate
  informational column rather than a toggle that reaches into Outstanding.
- **When native and plugin UX patterns can match, match them** — checkbox
  + bulk-toolbar-action in the tree mirrors InvenTree's own Required Parts
  table, so it feels like an extension, not a separate paradigm. Depart
  from native patterns only when there's a specific, stated reason (eager
  fetch vs. native lazy-per-node, because "see the whole picture" is the
  entire point).

---

## Explicitly Rejected Patterns

These aren't just past decisions (see ADR log for the reasoning behind
each) — they're patterns to actively recognize and push back on if a
similar idea resurfaces later, because they conflict with the principles
above:

- Event/schedule-driven auto-creation of real objects without a human
  reviewing first (ADR-021, ADR-025) — conflicts with Principle 2.
- New custom metadata fields where an existing InvenTree field already
  carries the needed signal (ADR-021) — conflicts with Principle 11.
- A shared library or monolith repo before a third plugin actually proves
  the need (ADR-001, ADR-023) — premature abstraction, not a philosophy
  violation per se, but a recurring temptation worth naming.
- Bundling asymmetric decisions under one shared confirm action just
  because they're adjacent in the UI (ADR-016's original checkbox+button
  design) — a control should represent what it actually does; a checkbox
  implying an optional toggle when inaction was already the valid default
  is its own kind of dishonesty, distinct from Principle 5's concern with
  computed numbers being traceable.

---

## Open Question This Doc Doesn't Resolve

Whether checking boxes across a large tree and firing one bulk "create
Build Orders" click still satisfies Principle 2 (human-in-the-loop) in the
way a considered per-node decision does, or whether "human approves 40
nodes with one click" is already a meaningfully different trust model than
"human approves one node at a time" — even though both are technically
human-initiated. **This isn't a future concern to revisit later — per
`04-Architecture-Decisions.md` ADR-029, bulk checkbox-select-then-create is
the actual v1 MVP mechanism, not a v2 refinement.** Worth thinking through
now, before v1 ships, not after.
