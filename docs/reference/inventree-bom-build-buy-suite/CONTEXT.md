# Context: InvenTree BOM/Build/Buy Suite

This context covers the shared domain language for the `inventree-bom-build-buy-suite` plugin line: Flat BOM Generator, Build Order Generator, and Purchase List Generator.

## Scope

- Terms that cross plugin boundaries.
- Ownership boundaries between the three suite plugins.
- Shared platform conventions used by the suite.

It does not cover:
- Generic InvenTree plugin mechanics (see `C:\Software Projects\inventree-plugin-ai-toolkit\docs\reference\inventree-plugins\CONTEXT.md`).
- Build Order Generator internals (see `C:\Software Projects\inventree-plugin-ai-toolkit\plugins\inventree-build-tree-generator\CONTEXT.md`).

## Language

**BOM/Build/Buy Suite**:
The product line of Flat BOM Generator, Build Order Generator, and Purchase List Generator.
_Avoid_: trilogy, plugin trilogy

**Flat BOM Generator**:
The plugin (`inventree-flat-bom-generator`) that flattens a nested BOM into a single-level, purchase-focused view.
_Avoid_: BOM flattener

**Build Order Generator**:
The plugin (`inventree-build-tree-generator`) that plans and creates child Build Orders for a parent Build Order.
_Avoid_: build tree generator, BO generator

**Purchase List Generator**:
The plugin (`inventree-purchase-list-generator`) that turns shortfall lists into grouped Purchase Orders and PO line items.
_Avoid_: Purchase Order Generator, Plugin 3

**Build Candidate**:
A part or assembly with no default supplier set; the Build Order Generator may create a child Build Order for it.
_Avoid_: buildable part

**Purchase Candidate**:
A leaf part or assembly with a default supplier set; routed to a Purchase Order by the Purchase List Generator.
_Avoid_: purchasable part

**Internal-Fab Supplier**:
A supplier record (or set of records) representing the company's own shop; used by Flat BOM Generator to decide explosion and by Purchase List Generator to route internal PO lines.
_Avoid_: internal vendor

**Project Scope**:
The lens that determines which allocations, stock, and Purchase Orders count for a calculation; criticality differs by plugin.
_Avoid_: project filter

**Netting**:
The process of reducing a required quantity by allocated stock, unallocated stock on hand, and incoming supply already on order.
_Avoid_: netting calculation

**Allocation**:
Stock already assigned to a `BuildLine` need via a real `BuildItem` record.
_Avoid_: assigned stock
