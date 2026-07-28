# Context Map

This is the context map for the InvenTree Plugin AI Toolkit. The toolkit root context is documented in [`CONTEXT.md`](./CONTEXT.md). It hosts independent InvenTree plugin repositories under `plugins/` and provides two shared contexts: a generic InvenTree plugin context ([`docs/reference/inventree-plugins/CONTEXT.md`](./docs/reference/inventree-plugins/CONTEXT.md)) and the BOM/Build/Buy suite domain model ([`docs/reference/inventree-bom-build-buy-suite/CONTEXT.md`](./docs/reference/inventree-bom-build-buy-suite/CONTEXT.md)).

## Contexts

- [Toolkit root (this repo)](./CONTEXT.md) — the InvenTree Plugin AI Toolkit: shared tooling, cross-plugin discipline, and devcontainer conventions
- [Shared InvenTree Plugin Context](./docs/reference/inventree-plugins/CONTEXT.md) — generic plugin structure, mixins, workflow, and documentation standards that apply to any InvenTree plugin
- [BOM/Build/Buy Suite — Shared Domain](./docs/reference/inventree-bom-build-buy-suite/CONTEXT.md) — canonical glossary and boundary definitions for the Flat BOM, Build Order, and Purchase List plugins
  - Vision and philosophy: [`VISION.md`](./docs/reference/inventree-bom-build-buy-suite/VISION.md)
  - Architecture decisions: [`docs/adr/`](./docs/reference/inventree-bom-build-buy-suite/docs/adr/) (canonical), extraction pass archive: [`ARCHITECTURE-DECISIONS.md`](./docs/reference/inventree-bom-build-buy-suite/ARCHITECTURE-DECISIONS.md)
  - Plugin ownership boundaries: [`BOUNDARIES.md`](./docs/reference/inventree-bom-build-buy-suite/BOUNDARIES.md)
  - InvenTree platform reference: [`PLATFORM-REFERENCE.md`](./docs/reference/inventree-bom-build-buy-suite/PLATFORM-REFERENCE.md)
  - Build Order Generator spec: [`BUILD-ORDER.md`](./docs/reference/inventree-bom-build-buy-suite/BUILD-ORDER.md)
- [Flat BOM Generator](./plugins/inventree-flat-bom-generator/) — read-only flat BOM panel; lives on the Part detail page
- [Build Order Generator](./plugins/inventree-build-tree-generator/CONTEXT.md) — child Build Order planning and bulk creation; lives on the Build Order detail page
- [Purchase List Generator](./plugins/inventree-purchase-list-generator/) (`inventree-purchase-list-generator`) — shortfall purchasing and supplier routing; placeholder plugin directory
- [COGS Suite](./plugins/inventree-cogs-suite-plugin/) — landed/rolled cost tracking, specific-identification inventory accounting, and purchase-order finalization; not part of the BOM/Build/Buy suite
- [Reference source and examples](./reference/README.md) — `reference/inventree-source` (InvenTree core source) and `reference/plugin-creator` (plugin scaffold tool) used as live implementation reference

## Relationships

- **Toolkit → Shared InvenTree Plugin Context:** Every plugin in `plugins/` can rely on the generic plugin context for structure, workflow, and conventions.
- **Toolkit → BOM/Build/Buy Suite → Flat BOM / Build Order / Purchase List:** The suite plugins derive their language and ownership boundaries from the shared suite domain docs.
- **Flat BOM Generator ↔ Build Order Generator:** Flat BOM decides which BOM nodes become purchase lines and which are exploded into sub-assemblies; Build Order Generator creates child Build Orders for any exploded node that has no default supplier.
- **Build Order Generator ↔ Purchase List Generator:** Build Order Generator identifies Build Candidates (no default supplier) and leaves purchasable/purchased leaf requirements to Purchase List Generator. Purchase List Generator's shortfall calculation reads the same live open-PO data that Build Order Generator nets against so it does not re-propose a part already on order.
- **Flat BOM Generator ↔ Purchase List Generator:** Flat BOM Generator's internal-supplier list and explode-vs-purchase-line logic feed Purchase List Generator's supplier routing and PO creation decisions.
- **COGS Suite is out-of-suite:** It may consume purchase-order data but does not own the BOM/Build/Buy planning flow.
