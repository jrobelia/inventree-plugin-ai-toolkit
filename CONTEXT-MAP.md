# Context Map

This is the context map for the InvenTree Plugin AI Toolkit. The toolkit root context is documented in [`CONTEXT.md`](./CONTEXT.md). It hosts independent InvenTree plugin repositories under `plugins/` and provides two shared contexts: a generic InvenTree plugin context ([`docs/reference/inventree-plugins/CONTEXT.md`](./docs/reference/inventree-plugins/CONTEXT.md)) and a special trilogy domain model ([`docs/reference/inventree-plugin-trilogy/02-Domain-Model.md`](./docs/reference/inventree-plugin-trilogy/02-Domain-Model.md)).

## Contexts

- [Toolkit root (this repo)](./CONTEXT.md) — the InvenTree Plugin AI Toolkit: shared tooling, cross-plugin discipline, and devcontainer conventions
- [Shared InvenTree Plugin Context](./docs/reference/inventree-plugins/CONTEXT.md) — generic plugin structure, mixins, workflow, and documentation standards that apply to any InvenTree plugin
- [Trilogy — Shared Domain](./docs/reference/inventree-plugin-trilogy/02-Domain-Model.md) — canonical glossary and boundary definitions for the three trilogy plugins
  - Vision and philosophy: [`01-Vision-and-Philosophy.md`](./docs/reference/inventree-plugin-trilogy/01-Vision-and-Philosophy.md)
  - Architecture decisions: [`04-Architecture-Decisions.md`](./docs/reference/inventree-plugin-trilogy/04-Architecture-Decisions.md)
  - Plugin ownership boundaries: [`05-Plugin-Architecture.md`](./docs/reference/inventree-plugin-trilogy/05-Plugin-Architecture.md)
  - InvenTree platform reference: [`03-InvenTree-Platform-Reference.md`](./docs/reference/inventree-plugin-trilogy/03-InvenTree-Platform-Reference.md)
- [Plugin 1 — Flat BOM Generator](./plugins/inventree-flat-bom-generator/) — read-only flat BOM panel; lives on the Part detail page
- [Plugin 2 — Build Order Generator](./docs/reference/inventree-plugin-trilogy/Plugin-2-Build-Order.md) — child Build Order planning and bulk creation; lives on the Build Order detail page
- [Plugin 3 — Purchase Order Generator](./docs/reference/inventree-plugin-trilogy/05-Plugin-Architecture.md) — shortfall purchasing and supplier routing; not yet implemented

## Relationships

- **Toolkit → Shared InvenTree Plugin Context:** Every plugin in `plugins/` can rely on the generic plugin context for structure, workflow, and conventions.
- **Toolkit → Trilogy → Plugin 1/2/3:** The trilogy plugins derive their language and ownership boundaries from the shared Trilogy domain docs.
- **Plugin 1 ↔ Plugin 2:** Plugin 1 decides which BOM nodes become purchase lines and which are exploded into sub-assemblies; Plugin 2 creates child Build Orders for any exploded node that has no default supplier.
- **Plugin 2 ↔ Plugin 3:** Plugin 2 identifies Build Candidates (no default supplier) and leaves purchasable/purchased leaf requirements to Plugin 3. Plugin 3's shortfall calculation reads the same live open-PO data that Plugin 2 nets against so it does not re-propose a part already on order.
- **Plugin 1 ↔ Plugin 3:** Plugin 1's internal-supplier list and explode-vs-purchase-line logic feed Plugin 3's supplier routing and PO creation decisions.
