# InvenTree Pencil Design System Library — Design Spec

**Date:** 2026-03-11
**Status:** Approved
**Author:** Claude (brainstorming session)

---

## Problem

The FlatBOM plugin has an empty `flat-bom-design.pen` placeholder with no usable design components. To design and theme the FlatBOM UI in Pencil, a design system component library matching InvenTree's actual visual language is needed — the same way `lunaris.lib.pen` and `shadcn.lib.pen` serve other design systems. No such library exists for InvenTree today.

## Goal

Create `design/inventree.lib.pen` — a ~96-component Pencil library that:
- Is faithful to InvenTree's Mantine v8 visual language (indigo primary, system fonts, subtle radius)
- Uses Pencil variables as CSS-like design tokens (never hardcoded values)
- Supports light and dark themes via a `mode` theme axis
- Lives at the toolkit level, importable by any future plugin design file

---

## File Structure

```
inventree-plugin-ai-toolkit/
├── design/
│   └── inventree.lib.pen          ← new library (this spec)
└── plugins/FlatBOMGenerator/docs/
    └── flat-bom-design.pen        ← updated after Phase 2 to import the library
```

**Consumer import syntax:**
```json
"imports": { "inv": "../../design/inventree.lib.pen" }
```

---

## Design Token System

Tokens are defined in `Document.variables` with theme-aware values. All component properties MUST reference `$variable-name` — zero hardcoded colors, spacing, or radius values.

### Theme Axis
```
themes: { mode: [light, dark] }
```

### Color Tokens

| Variable | Light | Dark | Source |
|---|---|---|---|
| `$color-primary` | `#4C6EF5` | `#4C6EF5` | Mantine indigo[6] — same in both modes (InvenTree uses Mantine default; contrast handled by background, not hue shift) |
| `$bg-primary` | `#ffffff` | `#1A1B1E` | Mantine dark[7] |
| `$bg-secondary` | `#f8f9fa` | `#25262B` | Mantine gray[0] / dark[6] |
| `$bg-elevated` | `#ffffff` | `#2C2E33` | Mantine dark[5] |
| `$border` | `#dee2e6` | `#373A40` | Mantine gray[2] / dark[4] |
| `$border-strong` | `#ced4da` | `#4B4F55` | Mantine gray[3] / dark[3] |
| `$text-primary` | `#000000` | `#C1C2C5` | Mantine dark[0] |
| `$text-secondary` | `#868e96` | `#909296` | Mantine gray[6] / dark[2] |
| `$text-placeholder` | `#adb5bd` | `#5C5F66` | Mantine gray[5] / dark[3] |
| `$color-success` | `#2f9e44` | `#2f9e44` | Mantine green[7] — intentionally same; InvenTree does not override semantic colors per mode |
| `$color-error` | `#e03131` | `#e03131` | Mantine red[7] |
| `$color-warning` | `#e8590c` | `#e8590c` | Mantine orange[7] |
| `$color-info` | `#1971c2` | `#1971c2` | Mantine blue[7] |
| `$color-success-bg` | `#ebfbee` | `#1a2e1e` | Mantine green[0] |
| `$color-error-bg` | `#fff5f5` | `#2e1a1a` | Mantine red[0] |
| `$color-warning-bg` | `#fff4e6` | `#2e2014` | Mantine orange[0] |
| `$color-info-bg` | `#e7f5ff` | `#141e2e` | Mantine blue[0] |

### Spacing Tokens
| Variable | Value |
|---|---|
| `$spacing-xs` | `4` |
| `$spacing-sm` | `8` |
| `$spacing-md` | `16` |
| `$spacing-lg` | `24` |
| `$spacing-xl` | `32` |

### Typography Tokens
| Variable | Value |
|---|---|
| `$font-family` | `system-ui, -apple-system, sans-serif` |
| `$font-size-xs` | `12` |
| `$font-size-sm` | `14` |
| `$font-size-md` | `16` |
| `$font-size-lg` | `18` |
| `$font-size-xl` | `20` |
| `$font-weight-normal` | `400` |
| `$font-weight-medium` | `500` |
| `$font-weight-bold` | `700` |
| `$line-height-tight` | `1.2` |
| `$line-height-normal` | `1.5` |

### Radius Tokens
| Variable | Value |
|---|---|
| `$radius-xs` | `2` |
| `$radius-sm` | `4` |
| `$radius-md` | `8` |
| `$radius-lg` | `16` |

---

## Component Inventory (~96 components, 4 phases)

### Phase 1 — Foundation (~28 components)

| Group | Components |
|---|---|
| Buttons | Button/Default, /Secondary, /Outline, /Ghost, /Destructive |
| Buttons Large | Button/Large/Default, /Large/Secondary, /Large/Outline, /Large/Ghost, /Large/Destructive |
| Icon Buttons | IconButton/Default, /Secondary, /Outline, /Ghost, /Destructive |
| Icon Buttons Large | IconButton/Large/Default, /Large/Secondary, /Large/Outline, /Large/Ghost |
| Form (basic) | Input/Default, Input/Filled, Input Group/Default, Input Group/Filled |
| Form (basic) | NumberInput/Default, Select Group/Default, Select Group/Filled |
| Form (basic) | Search Box/Default, Search Box/Filled |

### Phase 2 — Data & Feedback (~28 components)

| Group | Components |
|---|---|
| Form (continued) | Checkbox/Default, /Checked, Checkbox Description/Default, /Checked |
| Form (continued) | Radio/Default, /Selected, Radio Description/Default, /Selected |
| Form (continued) | Switch/Default, /Checked, Textarea/Default, Textarea Group |
| Feedback | Alert/Info, /Success, /Warning, /Error |
| Data Display | Badge/Primary, /Secondary, /Success, /Warning, /Error |
| Data Display | Avatar/Image, Avatar/Text, Progress |
| Data Display | Table, Table Row, Table Cell, Table Column Header |
| Data Display | Data Table, Data Table Header, Data Table Footer |

### Phase 3 — Navigation & Overlays (~26 components)

| Group | Components |
|---|---|
| Navigation | Sidebar, Sidebar Section Title, Sidebar Item/Default, /Active |
| Navigation | Tabs, Tab Item/Active, Tab Item/Inactive |
| Navigation | Breadcrumb Item/Default, /Active, /Separator, /Ellipsis |
| Navigation | Pagination, Pagination Item/Default, /Active, /Ellipsis |
| Overlays | Modal/Center, Modal/Left, Modal/Center Icon, Dialog, Drawer/Right, Tooltip |
| Content | Accordion/Open, Accordion/Closed, Dropdown |

### Phase 4 — InvenTree Custom Widgets + Content (~22 components)

InvenTree builds custom components on top of Mantine that are not part of the standard Mantine library. These are exported from InvenTree's own component layer and are the correct building blocks for plugin UIs — including FlatBOM. Sourced from `inventree-dev/InvenTree/src/frontend/src/components/`.

> **FlatBOM-specific components** (Part Type Badge color variants, Stats Panel, BOM Row, Column Visibility Toggle) are NOT part of this library — they are FlatBOM inventions and will be designed inline in `flat-bom-design.pen`. Before designing them as one-offs, check whether an InvenTree custom widget below already serves the need.

| Group | Components |
|---|---|
| Content | Card, Card Image, Card Action, Card Plain (4) |
| Content | List Item/Checked, /Unchecked, List Item Title, List Divider (4) |
| InvenTree Buttons | PrimaryActionButton, ActionButton, SplitButton, CopyButton (4) |
| InvenTree Badges | DetailsBadge/Default, DetailsBadge/Success, DetailsBadge/Error, DetailsBadge/Warning (4) |
| InvenTree Table Columns | StatusColumn, PartColumn, DateColumn, DescriptionColumn, LocationColumn (5) |
| InvenTree Admin | AdminButton (1) |

---

## Build Workflow

Each phase follows this session sequence:

1. `open_document("design/inventree.lib.pen")`
2. `get_editor_state()` — confirm file + list existing components
3. `get_guidelines("design-system")` — load Pencil design system rules
4. `get_variables()` — verify token system (Phase 1: define tokens via `set_variables` first)
5. Build in batches of ≤25 `batch_design` operations
6. `get_screenshot(sectionFrameId)` after each batch
7. Verify light/dark theme correctness
8. Remove `placeholder: true` when each section is done
9. After Phase 2: add `imports` to `flat-bom-design.pen`

**Phase 1 bootstrap:**
1. Create the `design/` directory at the repo root if it does not exist (the Pencil MCP `open_document` tool does not create directories automatically)
2. Call `open_document("new")` — this opens a new blank document in the Pencil editor
3. The file is saved to `design/inventree.lib.pen` when the first `batch_design` write occurs (the Pencil extension saves to the workspace path)
4. Call `set_variables()` with the full token system BEFORE drawing any components
5. Create the top-level frame "inventree: design system components"

> **Note on `get_guidelines("design-system")`:** `"design-system"` is a valid topic key for the Pencil MCP tool. If the call returns no content (e.g. network/extension issue), proceed without — the schema and this spec are sufficient.

---

## Critical Files

| File | Role |
|---|---|
| `design/inventree.lib.pen` | Library file to create |
| `plugins/FlatBOMGenerator/docs/flat-bom-design.pen` | Consumer — import after Phase 2 |
| `inventree-dev/InvenTree/src/frontend/src/components/buttons/` | Source for PrimaryActionButton, ActionButton, SplitButton, CopyButton (Phase 4) |
| `inventree-dev/InvenTree/src/frontend/src/components/details/DetailsBadge.tsx` | Source for DetailsBadge variants (Phase 4) |
| `inventree-dev/InvenTree/src/frontend/src/tables/` | Source for InvenTreeTable column type patterns (Phase 4) |
| `~/.vscode/extensions/highagency.pencildev-0.6.30/out/data/lunaris.lib.pen` | Reference library pattern — lives in VS Code extension install dir, not the repo |

---

## Verification

**Per phase:**
- Screenshot each completed section
- Toggle `mode: light` ↔ `mode: dark` — all components must render correctly in both
- Audit: zero hardcoded values, all properties reference `$variables`

**End-to-end (after Phase 4):**
- Open `flat-bom-design.pen`, add `imports: { "inv": "../../design/inventree.lib.pen" }`
- Place one representative component instance (e.g. a Button and a Data Table) to confirm symbol linking resolves correctly
- Screenshot to confirm it renders in both light and dark modes

> Full FlatBOM screen composition (designing the actual plugin UI) is a separate follow-on task, not part of this library build spec.

---

## Execution Sessions

| Session | Phase | Deliverable |
|---|---|---|
| 1 | Phase 1 | File created, full token system, buttons, basic form inputs |
| 2 | Phase 2 | Form controls, data display, feedback — library usable for FlatBOM |
| 3 | Phase 3 | Navigation, overlays, content |
| 4 | Phase 4 | Content components + InvenTree custom widgets (~22) + `flat-bom-design.pen` wired up and smoke-tested |
