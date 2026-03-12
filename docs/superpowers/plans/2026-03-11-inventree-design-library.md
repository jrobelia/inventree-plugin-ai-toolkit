# InvenTree Design System Library Implementation Plan

> **For agentic workers:** REQUIRED: Use superpowers:subagent-driven-development (if subagents available) or superpowers:executing-plans to implement this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Create `design/inventree.lib.pen` — a ~96-component Pencil design library faithful to InvenTree's Mantine v8 visual language, with full light/dark theme support via CSS-like Pencil variables.

**Architecture:** A single `.pen` file acting as a reusable component library. All design tokens (colors, spacing, typography, radius) are defined as Pencil `variables` with light/dark theme-aware values. Components reference `$variable-name` exclusively — no hardcoded values. The library is organized into a single top-level frame with labeled sections per component category.

**Tech Stack:** Pencil MCP tools (`mcp__pencil__*`), `.pen` file format v2.8+, Mantine v8 color scale reference, Tabler Icons (icon_font type, `feather` or `lucide` family as closest match), InvenTree source at `inventree-dev/InvenTree/src/frontend/`

**Spec:** `docs/superpowers/specs/2026-03-11-inventree-design-library-design.md`

---

## Design Token Reference (use throughout all phases)

All components MUST use these variable names. Never hardcode a hex value.

### Color tokens (theme-aware)
| Variable | Light | Dark |
|---|---|---|
| `$color-primary` | `#4C6EF5` | `#4C6EF5` |
| `$bg-primary` | `#ffffff` | `#1A1B1E` |
| `$bg-secondary` | `#f8f9fa` | `#25262B` |
| `$bg-elevated` | `#ffffff` | `#2C2E33` |
| `$border` | `#dee2e6` | `#373A40` |
| `$border-strong` | `#ced4da` | `#4B4F55` |
| `$text-primary` | `#000000` | `#C1C2C5` |
| `$text-secondary` | `#868e96` | `#909296` |
| `$text-placeholder` | `#adb5bd` | `#5C5F66` |
| `$color-success` | `#2f9e44` | `#2f9e44` |
| `$color-error` | `#e03131` | `#e03131` |
| `$color-warning` | `#e8590c` | `#e8590c` |
| `$color-info` | `#1971c2` | `#1971c2` |
| `$color-success-bg` | `#ebfbee` | `#1a2e1e` |
| `$color-error-bg` | `#fff5f5` | `#2e1a1a` |
| `$color-warning-bg` | `#fff4e6` | `#2e2014` |
| `$color-info-bg` | `#e7f5ff` | `#141e2e` |

### Static tokens (same in all themes)
| Variable | Value | Note |
|---|---|---|
| `$font-family` | `system-ui, -apple-system, sans-serif` | String type. Pencil MCP may not support string variables for fontFamily — if `set_variables` rejects it, apply the font family directly as `fontFamily: "system-ui, -apple-system, sans-serif"` on each text node instead of via variable. |
| `$spacing-xs` | `4` | |
| `$spacing-sm` | `8` |
| `$spacing-md` | `16` |
| `$spacing-lg` | `24` |
| `$spacing-xl` | `32` |
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
| `$radius-xs` | `2` |
| `$radius-sm` | `4` |
| `$radius-md` | `8` |
| `$radius-lg` | `16` |

### Button visual spec (Mantine defaults)
- Normal height: `36px`, padding: `[0, 16]`, gap: `8px`
- Large height: `44px`, padding: `[0, 20]`, gap: `10px`
- Icon button size: `36x36` (normal), `44x44` (large)
- Font: `$font-size-sm`, `$font-weight-medium`
- Radius: `$radius-sm`
- Icon size: `16px` (normal), `18px` (large) — use `icon_font`, family `lucide`

### Button fill/stroke by variant
| Variant | Fill | Text | Stroke |
|---|---|---|---|
| Default | `$color-primary` | `#ffffff` | none |
| Secondary | `$bg-secondary` | `$text-primary` | `$border` 1px inside |
| Outline | transparent | `$color-primary` | `$color-primary` 1px inside |
| Ghost | transparent | `$text-primary` | none |
| Destructive | `$color-error` | `#ffffff` | none |

---

## Chunk 1: Phase 1 — Foundation (file, tokens, buttons, basic form inputs)

### Task 1: Bootstrap — create file and define token system

**Files:**
- Create: `design/inventree.lib.pen`

- [ ] **Step 1: Create the `design/` directory**

  ```bash
  mkdir -p "c:/PythonProjects/Inventree Plugin Creator/inventree-plugin-ai-toolkit/design"
  ```

- [ ] **Step 2: Open a new Pencil document**

  Call `mcp__pencil__open_document` with `filePathOrTemplate: "new"`.
  Expected: Editor opens with a blank document.

- [ ] **Step 3: Confirm editor state**

  Call `mcp__pencil__get_editor_state`. Confirm a new blank document is active.

- [ ] **Step 4: Load design-system guidelines**

  Call `mcp__pencil__get_guidelines` with `topic: "design-system"`. If empty, proceed — the spec is sufficient.

- [ ] **Step 5: Define the full token system**

  Call `mcp__pencil__set_variables` with the complete variable set below. Theme-aware variables use the array format; static variables use the scalar format.

  ```json
  {
    "color-primary": { "type": "color", "value": "#4C6EF5" },
    "bg-primary": { "type": "color", "value": [
      { "value": "#ffffff", "theme": { "mode": "light" } },
      { "value": "#1A1B1E", "theme": { "mode": "dark" } }
    ]},
    "bg-secondary": { "type": "color", "value": [
      { "value": "#f8f9fa", "theme": { "mode": "light" } },
      { "value": "#25262B", "theme": { "mode": "dark" } }
    ]},
    "bg-elevated": { "type": "color", "value": [
      { "value": "#ffffff", "theme": { "mode": "light" } },
      { "value": "#2C2E33", "theme": { "mode": "dark" } }
    ]},
    "border": { "type": "color", "value": [
      { "value": "#dee2e6", "theme": { "mode": "light" } },
      { "value": "#373A40", "theme": { "mode": "dark" } }
    ]},
    "border-strong": { "type": "color", "value": [
      { "value": "#ced4da", "theme": { "mode": "light" } },
      { "value": "#4B4F55", "theme": { "mode": "dark" } }
    ]},
    "text-primary": { "type": "color", "value": [
      { "value": "#000000", "theme": { "mode": "light" } },
      { "value": "#C1C2C5", "theme": { "mode": "dark" } }
    ]},
    "text-secondary": { "type": "color", "value": [
      { "value": "#868e96", "theme": { "mode": "light" } },
      { "value": "#909296", "theme": { "mode": "dark" } }
    ]},
    "text-placeholder": { "type": "color", "value": [
      { "value": "#adb5bd", "theme": { "mode": "light" } },
      { "value": "#5C5F66", "theme": { "mode": "dark" } }
    ]},
    "color-success": { "type": "color", "value": "#2f9e44" },
    "color-error": { "type": "color", "value": "#e03131" },
    "color-warning": { "type": "color", "value": "#e8590c" },
    "color-info": { "type": "color", "value": "#1971c2" },
    "color-success-bg": { "type": "color", "value": [
      { "value": "#ebfbee", "theme": { "mode": "light" } },
      { "value": "#1a2e1e", "theme": { "mode": "dark" } }
    ]},
    "color-error-bg": { "type": "color", "value": [
      { "value": "#fff5f5", "theme": { "mode": "light" } },
      { "value": "#2e1a1a", "theme": { "mode": "dark" } }
    ]},
    "color-warning-bg": { "type": "color", "value": [
      { "value": "#fff4e6", "theme": { "mode": "light" } },
      { "value": "#2e2014", "theme": { "mode": "dark" } }
    ]},
    "color-info-bg": { "type": "color", "value": [
      { "value": "#e7f5ff", "theme": { "mode": "light" } },
      { "value": "#141e2e", "theme": { "mode": "dark" } }
    ]},
    "spacing-xs": { "type": "number", "value": 4 },
    "spacing-sm": { "type": "number", "value": 8 },
    "spacing-md": { "type": "number", "value": 16 },
    "spacing-lg": { "type": "number", "value": 24 },
    "spacing-xl": { "type": "number", "value": 32 },
    "font-size-xs": { "type": "number", "value": 12 },
    "font-size-sm": { "type": "number", "value": 14 },
    "font-size-md": { "type": "number", "value": 16 },
    "font-size-lg": { "type": "number", "value": 18 },
    "font-size-xl": { "type": "number", "value": 20 },
    "font-weight-normal": { "type": "number", "value": 400 },
    "font-weight-medium": { "type": "number", "value": 500 },
    "font-weight-bold": { "type": "number", "value": 700 },
    "line-height-tight": { "type": "number", "value": 1.2 },
    "line-height-normal": { "type": "number", "value": 1.5 },
    "radius-xs": { "type": "number", "value": 2 },
    "radius-sm": { "type": "number", "value": 4 },
    "radius-md": { "type": "number", "value": 8 },
    "radius-lg": { "type": "number", "value": 16 }
  }
  ```

- [ ] **Step 6: Verify variables were set**

  Call `mcp__pencil__get_variables`. Confirm all 35 variables are present with correct values.

- [ ] **Step 7: Create the top-level library frame**

  Call `mcp__pencil__batch_design`. Create one top-level frame as the library container:
  ```javascript
  mainFrame=I("document", {
    type: "frame", id: "inventree-lib-frame",
    name: "inventree: design system components",
    layout: "vertical", gap: 80, padding: 40,
    width: 1200, height: "fit_content(800)",
    fill: "$bg-primary"
  })
  ```

- [ ] **Step 8: Screenshot and verify**

  Call `mcp__pencil__get_screenshot` on `inventree-lib-frame`. Confirm the frame renders with the correct background color in light mode.

- [ ] **Step 9: Commit**

  ```bash
  cd "c:/PythonProjects/Inventree Plugin Creator/inventree-plugin-ai-toolkit"
  git add design/inventree.lib.pen
  git commit -m "feat(design): bootstrap inventree.lib.pen with full token system"
  ```

---

### Task 2: Button/Default through Button/Destructive (5 normal-size button components)

**Files:** Modify: `design/inventree.lib.pen`

- [ ] **Step 1: Open the file and confirm state**

  Call `mcp__pencil__open_document` with the full path to `design/inventree.lib.pen`.
  Call `mcp__pencil__get_editor_state`. Confirm `mainFrame` (`inventree-lib-frame`) exists and token variables are present.

- [ ] **Step 2: Create the Buttons section frame**

  ```javascript
  btnSection=I("inventree-lib-frame", {
    type: "frame", name: "— Buttons —",
    layout: "horizontal", gap: 16, padding: 0,
    width: "fit_content", height: "fit_content",
    placeholder: true
  })
  ```

- [ ] **Step 3: Create Button/Default (reusable component)**

  Visual spec: horizontal layout, height 36, padding `[0, 16]`, gap 8, radius `$radius-sm`, fill `$color-primary`.
  Contains: an `icon_font` (lucide, "plus", 16×16, fill `#ffffff`) + text label (14px, weight 500, fill `#ffffff`, content "Button").

  ```javascript
  btnDefault=I("inventree-lib-frame", {
    type: "frame", reusable: true, name: "Button/Default",
    layout: "horizontal", gap: "$spacing-sm", padding: [0, "$spacing-md"],
    height: 36, width: "fit_content(100)",
    fill: "$color-primary", cornerRadius: "$radius-sm",
    alignItems: "center", justifyContent: "center"
  })
  btnDefaultIcon=I(btnDefault, {
    type: "icon_font", iconFontFamily: "lucide", iconFontName: "plus",
    width: 16, height: 16, fill: "#ffffff"
  })
  btnDefaultLabel=I(btnDefault, {
    type: "text", content: "Button",
    fontSize: "$font-size-sm", fontWeight: "$font-weight-medium",
    fill: "#ffffff"
  })
  ```

- [ ] **Step 4: Create Button/Secondary**

  Same structure as Default. Fill: `$bg-secondary`. Text fill: `$text-primary`. Icon fill: `$text-primary`. Stroke: `{ fill: "$border", thickness: 1, align: "inside" }`.

- [ ] **Step 5: Create Button/Outline**

  Same structure. Fill: transparent (omit fill). Text fill: `$color-primary`. Icon fill: `$color-primary`. Stroke: `{ fill: "$color-primary", thickness: 1, align: "inside" }`.

- [ ] **Step 6: Create Button/Ghost**

  Same structure. Fill: transparent. Text fill: `$text-primary`. Icon fill: `$text-primary`. No stroke.

- [ ] **Step 7: Create Button/Destructive**

  Same structure as Default. Fill: `$color-error`. Text fill: `#ffffff`. Icon fill: `#ffffff`. No stroke.

- [ ] **Step 8: Remove placeholder from Buttons section, screenshot**

  ```javascript
  U("btnSection", { placeholder: false })
  ```
  Call `mcp__pencil__get_screenshot` on the buttons section. Confirm 5 distinct button styles are visible.

- [ ] **Step 9: Commit**

  ```bash
  git add design/inventree.lib.pen
  git commit -m "feat(design): add Button/Default through Button/Destructive"
  ```

---

### Task 3: Button/Large variants (5 components)

**Files:** Modify: `design/inventree.lib.pen`

- [ ] **Step 1: Confirm file state**

  `get_editor_state` — confirm 5 Button/* components exist as reusable.

- [ ] **Step 2: Create Button/Large/Default by copying Button/Default**

  Copy the `Button/Default` component and update to Large spec: height 44, padding `[0, 20]`, font-size `$font-size-md`, icon 18×18.

  ```javascript
  btnLgDefault=C("Button/Default-id", "inventree-lib-frame", {
    name: "Button/Large/Default", height: 44, placeholder: true
  })
  U(btnLgDefault+"/icon-child-id", { width: 18, height: 18 })
  U(btnLgDefault+"/label-child-id", { fontSize: "$font-size-md" })
  U(btnLgDefault, { padding: [0, 20], placeholder: false })
  ```

  > **Note:** After copying, call `get_editor_state` to get the new descendant IDs before updating them.

- [ ] **Step 3: Create Button/Large/Secondary**

  Call `get_editor_state` to get the current ID of `Button/Secondary`. Copy it:
  ```javascript
  btnLgSecondary=C("<Button/Secondary-id>", "inventree-lib-frame", {
    name: "Button/Large/Secondary", height: 44, placeholder: true
  })
  U(btnLgSecondary+"/icon-child-id", { width: 18, height: 18 })
  U(btnLgSecondary+"/label-child-id", { fontSize: "$font-size-md" })
  U(btnLgSecondary, { padding: [0, 20], placeholder: false })
  ```
  Fill: `$bg-secondary`, text: `$text-primary`, stroke: `{ fill: "$border", thickness: 1, align: "inside" }`.

- [ ] **Step 4: Create Button/Large/Outline**

  Copy `Button/Outline`, same large dimensions. Fill: transparent, text: `$color-primary`, stroke: `{ fill: "$color-primary", thickness: 1, align: "inside" }`.

- [ ] **Step 5: Create Button/Large/Ghost**

  Copy `Button/Ghost`, same large dimensions. Fill: transparent, text: `$text-primary`, no stroke.

- [ ] **Step 6: Create Button/Large/Destructive**

  Copy `Button/Destructive`, same large dimensions. Fill: `$color-error`, text: `#ffffff`, no stroke.

- [ ] **Step 7: Screenshot large buttons section**

  `get_screenshot` on the large buttons area. Confirm they are visibly taller than normal buttons.

- [ ] **Step 8: Commit**

  ```bash
  git add design/inventree.lib.pen
  git commit -m "feat(design): add Button/Large variants"
  ```

---

### Task 4: IconButton variants (5 components)

**Files:** Modify: `design/inventree.lib.pen`

- [ ] **Step 1: Create IconButton/Default (reusable)**

  Square component: 36×36, centered icon, radius `$radius-sm`. No text label. Same fill/stroke rules as Button variants.

  ```javascript
  iconBtnDefault=I("inventree-lib-frame", {
    type: "frame", reusable: true, name: "IconButton/Default",
    layout: "horizontal", width: 36, height: 36,
    fill: "$color-primary", cornerRadius: "$radius-sm",
    alignItems: "center", justifyContent: "center"
  })
  I(iconBtnDefault, {
    type: "icon_font", iconFontFamily: "lucide", iconFontName: "settings",
    width: 16, height: 16, fill: "#ffffff"
  })
  ```

- [ ] **Step 2: Create IconButton/Secondary**

  36×36 frame, fill `$bg-secondary`, stroke `{ fill: "$border", thickness: 1, align: "inside" }`, radius `$radius-sm`. Icon: 16×16, fill `$text-primary`.

- [ ] **Step 3: Create IconButton/Outline**

  36×36 frame, fill transparent, stroke `{ fill: "$color-primary", thickness: 1, align: "inside" }`, radius `$radius-sm`. Icon: 16×16, fill `$color-primary`.

- [ ] **Step 4: Create IconButton/Ghost**

  36×36 frame, fill transparent, no stroke, radius `$radius-sm`. Icon: 16×16, fill `$text-primary`.

- [ ] **Step 5: Create IconButton/Destructive**

  36×36 frame, fill `$color-error`, no stroke, radius `$radius-sm`. Icon: 16×16, fill `#ffffff`.

- [ ] **Step 6: Screenshot**

  `get_screenshot` on the icon buttons row. Confirm 5 square icon button styles with distinct fills/strokes.

- [ ] **Step 7: Commit**

  ```bash
  git add design/inventree.lib.pen
  git commit -m "feat(design): add IconButton variants"
  ```

---

### Task 5: IconButton/Large variants (4 components)

**Files:** Modify: `design/inventree.lib.pen`

- [ ] **Step 1: Confirm file state**

  `get_editor_state` — retrieve IDs of the 4 source IconButton variants to copy from.

- [ ] **Step 2: Create IconButton/Large/Default**

  Copy `IconButton/Default`, set name `IconButton/Large/Default`, width 44, height 44. Update icon child: width 18, height 18.

- [ ] **Step 3: Create IconButton/Large/Secondary**

  Copy `IconButton/Secondary`, set name `IconButton/Large/Secondary`, width 44, height 44. Update icon child: width 18, height 18.

- [ ] **Step 4: Create IconButton/Large/Outline**

  Copy `IconButton/Outline`, set name `IconButton/Large/Outline`, width 44, height 44. Update icon child: width 18, height 18.

- [ ] **Step 5: Create IconButton/Large/Ghost**

  Copy `IconButton/Ghost`, set name `IconButton/Large/Ghost`, width 44, height 44. Update icon child: width 18, height 18.

- [ ] **Step 6: Screenshot**

  `get_screenshot` on the large icon button row. Confirm 4 larger squares (44×44 vs 36×36 for normal).

- [ ] **Step 7: Commit**

  ```bash
  git add design/inventree.lib.pen
  git commit -m "feat(design): add IconButton/Large variants"
  ```

---

### Task 6: Input components (Input/Default, Input/Filled, Input Group/Default, Input Group/Filled)

**Files:** Modify: `design/inventree.lib.pen`

**Input visual spec (Mantine):**
- Height: 36px, width: 200px (fixed-width for library display)
- Padding: `[0, 12]`, radius: `$radius-sm`
- Default variant: fill transparent, stroke `$border` 1px inside
- Filled variant: fill `$bg-secondary`, stroke `$border-strong` 1px inside
- Contains: optional left icon (16×16, fill `$text-placeholder`) + placeholder text (fill `$text-placeholder`, 14px)
- Input Group = label text above + Input below, vertical layout, gap 4

- [ ] **Step 1: Create Input/Default (reusable)**

  ```javascript
  inputDefault=I("inventree-lib-frame", {
    type: "frame", reusable: true, name: "Input/Default",
    layout: "horizontal", gap: "$spacing-sm", padding: [0, 12],
    height: 36, width: 200,
    cornerRadius: "$radius-sm",
    stroke: { fill: "$border", thickness: 1, align: "inside" },
    alignItems: "center"
  })
  I(inputDefault, {
    type: "icon_font", iconFontFamily: "lucide", iconFontName: "search",
    width: 16, height: 16, fill: "$text-placeholder"
  })
  I(inputDefault, {
    type: "text", content: "Placeholder...",
    fontSize: "$font-size-sm", fill: "$text-placeholder"
  })
  ```

- [ ] **Step 2: Create Input/Filled**

  Copy Input/Default, set `fill: "$bg-secondary"`, stroke `$border-strong`.

- [ ] **Step 3: Get IDs for Input refs**

  Call `get_editor_state`. Note the IDs of `Input/Default` and `Input/Filled` — needed for the `ref` values in Steps 4 and 5.

- [ ] **Step 4: Create Input Group/Default (reusable)**

  Vertical frame, gap 4, fit_content. Contains: label text + ref to Input/Default (substitute the actual ID from Step 3).

  ```javascript
  inputGroupDefault=I("inventree-lib-frame", {
    type: "frame", reusable: true, name: "Input Group/Default",
    layout: "vertical", gap: 4, width: "fit_content", height: "fit_content"
  })
  I(inputGroupDefault, {
    type: "text", content: "Label",
    fontSize: "$font-size-xs", fontWeight: "$font-weight-medium",
    fill: "$text-primary"
  })
  I(inputGroupDefault, { type: "ref", ref: "<Input/Default-id from Step 3>" })
  ```

- [ ] **Step 5: Create Input Group/Filled**

  Same structure as Input Group/Default but the `ref` points to `Input/Filled` (use its ID from Step 3).

- [ ] **Step 6: Screenshot and commit**

  `get_screenshot` on the inputs section. Confirm 4 components: 2 bare inputs (different fill) and 2 grouped (label + input).

  ```bash
  git add design/inventree.lib.pen
  git commit -m "feat(design): add Input and Input Group components"
  ```

---

### Task 7: NumberInput, Select Group, Search Box (5 components)

**Files:** Modify: `design/inventree.lib.pen`

**NumberInput spec:** Same as Input/Default but includes up/down stepper arrows on the right side — two 12×12 icon_font chevrons stacked in a sub-frame.

**Select Group spec:** Same structure as Input Group but the input field has a chevron-down icon on the RIGHT side (right-aligned) instead of a left search icon. Label + Select input, vertical layout.

**Search Box spec:** Input with magnifying glass icon on left, no label wrapper. Two variants: Default (stroke border) and Filled (fill bg-secondary).

- [ ] **Step 1: Create NumberInput/Default**

  Horizontal layout, 36px height, 120px width (narrower for number input). Left: text "0" (fill `$text-primary`, 14px). Right: sub-frame with two 10×10 chevron icons (fill `$text-secondary`), vertical layout.

- [ ] **Step 2: Create Select Group/Default**

  Vertical frame (label + select input). Select input: horizontal layout, fill transparent, stroke `$border`, height 36, width 200. Left: placeholder text (fill `$text-placeholder`). Right: chevron-down icon (fill `$text-secondary`).

- [ ] **Step 3: Create Select Group/Filled**

  Copy Select Group/Default, change input fill to `$bg-secondary`, stroke to `$border-strong`.

- [ ] **Step 4: Create Search Box/Default**

  Horizontal, height 36, width 220. Left: magnifying glass icon (lucide, "search", 16×16, fill `$text-placeholder`). Text "Search..." (fill `$text-placeholder`). Stroke: `$border` 1px. Reusable: true.

- [ ] **Step 5: Create Search Box/Filled**

  Copy Search Box/Default, fill `$bg-secondary`, stroke `$border-strong`.

- [ ] **Step 6: Screenshot Phase 1 — light mode**

  `get_screenshot` on `inventree-lib-frame`. Confirm all Phase 1 components are visible and well-organized.

- [ ] **Step 7: Verify dark mode**

  Switch the Pencil editor theme to `mode: dark` (via editor UI or `batch_design` theme override). Call `get_screenshot` again. Confirm: backgrounds flip to dark values, borders lighten, text colors invert correctly. Switch back to `mode: light` when done.

- [ ] **Step 8: Commit Phase 1 complete**

  ```bash
  git add design/inventree.lib.pen
  git commit -m "feat(design): complete Phase 1 — foundation components (28 total)"
  ```

---

## Chunk 2: Phase 2 — Data & Feedback

### Task 8: Checkbox variants (4 components)

**Files:** Modify: `design/inventree.lib.pen`

**Checkbox visual spec (Mantine):**
- Box: 18×18, radius `$radius-xs`, stroke `$border-strong` 1px
- Checked state: fill `$color-primary`, checkmark icon_font (lucide "check", 12×12, fill `#ffffff`) inside
- Checkbox Description = checkbox + label text to the right, horizontal layout, gap 8, plus optional description text below (small, secondary color)

- [ ] **Step 1: Open file and confirm Phase 1 components exist**

  `get_editor_state` — confirm 28 reusable components from Phase 1 are listed.

- [ ] **Step 2: Create Checkbox/Default (reusable)**

  18×18 frame, radius `$radius-xs`, stroke `{ fill: "$border-strong", thickness: 1, align: "inside" }`, fill transparent. No children (empty box).

- [ ] **Step 3: Create Checkbox/Checked (reusable)**

  Copy Checkbox/Default. Add fill `$color-primary`, stroke none. Add child: icon_font (lucide "check", 12×12, fill `#ffffff`, centered).

- [ ] **Step 4: Create Checkbox Description/Default (reusable)**

  Vertical layout, gap 2. Row 1: horizontal frame, gap 8, contains ref to Checkbox/Default + label text (14px, fill `$text-primary`, "Checkbox label"). Row 2: description text (12px, fill `$text-secondary`, "Optional description").

- [ ] **Step 5: Create Checkbox Description/Checked (reusable)**

  Copy Checkbox Description/Default. Replace Checkbox/Default ref with Checkbox/Checked ref.

- [ ] **Step 6: Screenshot and commit**

  ```bash
  git add design/inventree.lib.pen
  git commit -m "feat(design): add Checkbox variants"
  ```

---

### Task 9: Radio, Switch, Textarea (8 components)

**Files:** Modify: `design/inventree.lib.pen`

**Radio spec:** 18×18 ellipse. Default: stroke `$border-strong` 1px, fill transparent. Selected: stroke `$color-primary` 2px, inner 8×8 ellipse fill `$color-primary`. Radio Description = same wrapper pattern as Checkbox Description.

**Switch spec:** 36×20 pill shape (radius 10). Default: fill `$border`, 16×16 circle on left (fill white, x=2). Checked: fill `$color-primary`, circle on right (x=18).

**Textarea spec:** Same as Input/Default but height 80px, no left icon, text aligns to top-left, shows multi-line placeholder text. Textarea Group = label + Textarea.

- [ ] **Step 1: Create Radio/Default and Radio/Selected**

  Radio/Default: ellipse 18×18, stroke `$border-strong` 1px, fill transparent.
  Radio/Selected: ellipse 18×18, stroke `$color-primary` 2px, fill transparent. Child: ellipse 8×8, fill `$color-primary`, centered (x=5, y=5, using layout none on parent).

- [ ] **Step 2: Create Radio Description/Default and Radio Description/Selected**

  Same wrapper pattern as Checkbox Description. Radio Description/Default uses Radio/Default. Radio Description/Selected uses Radio/Selected.

- [ ] **Step 3: Create Switch/Default**

  Frame: 36×20, radius 10, fill `$border`, layout none. Child: rectangle 16×16, radius 8, fill `#ffffff`, x=2, y=2.

- [ ] **Step 4: Create Switch/Checked**

  Copy Switch/Default. Fill: `$color-primary`. Move circle child to x=18, y=2.

- [ ] **Step 5: Create Textarea/Default**

  Frame: 200×80, radius `$radius-sm`, stroke `$border` 1px, padding 12. Child: text "Placeholder text...", 14px, fill `$text-placeholder`, textGrowth `fixed-width`, width `fill_container`.

- [ ] **Step 6: Create Textarea Group**

  Vertical layout, gap 4. Label text + ref to Textarea/Default.

- [ ] **Step 7: Screenshot and commit**

  ```bash
  git add design/inventree.lib.pen
  git commit -m "feat(design): add Radio, Switch, Textarea variants"
  ```

---

### Task 10: Alert variants (4 components)

**Files:** Modify: `design/inventree.lib.pen`

**Alert spec (Mantine):**
- Width: 320px, padding: 16px, radius: `$radius-sm`, layout: vertical, gap: 4
- Background: semantic-bg token (e.g. `$color-info-bg` for info)
- Left border: 4px solid semantic color (use stroke with left-only thickness)
- Top row: horizontal layout, gap 8 — icon_font (16×16) + bold title text (14px, `$font-weight-bold`)
- Bottom: description text (13px, `$font-size-xs`, fill `$text-secondary`)

- [ ] **Step 1: Create Alert/Info (reusable)**

  ```javascript
  alertInfo=I("inventree-lib-frame", {
    type: "frame", reusable: true, name: "Alert/Info",
    layout: "vertical", gap: "$spacing-xs", padding: "$spacing-md",
    width: 320, height: "fit_content",
    fill: "$color-info-bg", cornerRadius: "$radius-sm",
    stroke: { fill: "$color-info", thickness: { top: 0, right: 0, bottom: 0, left: 4 }, align: "inside" }
  })
  alertInfoHeader=I(alertInfo, { type: "frame", layout: "horizontal", gap: "$spacing-sm", alignItems: "center", width: "fill_container", height: "fit_content" })
  I(alertInfoHeader, { type: "icon_font", iconFontFamily: "lucide", iconFontName: "info", width: 16, height: 16, fill: "$color-info" })
  I(alertInfoHeader, { type: "text", content: "Info title", fontSize: "$font-size-sm", fontWeight: "$font-weight-bold", fill: "$text-primary" })
  I(alertInfo, { type: "text", content: "Alert description text goes here.", fontSize: "$font-size-xs", fill: "$text-secondary", textGrowth: "fixed-width", width: "fill_container" })
  ```

- [ ] **Step 2: Create Alert/Success**

  Copy Alert/Info. Update: fill `$color-success-bg`, stroke fill `$color-success`, icon `lucide:check-circle`, icon fill `$color-success`, title "Success title".

- [ ] **Step 3: Create Alert/Warning**

  Copy Alert/Info. Update: fill `$color-warning-bg`, stroke fill `$color-warning`, icon `lucide:alert-triangle`, icon fill `$color-warning`, title "Warning title".

- [ ] **Step 4: Create Alert/Error**

  Copy Alert/Info. Update: fill `$color-error-bg`, stroke fill `$color-error`, icon `lucide:alert-circle`, icon fill `$color-error`, title "Error title".

- [ ] **Step 5: Screenshot all 4 alerts, commit**

  ```bash
  git add design/inventree.lib.pen
  git commit -m "feat(design): add Alert variants (Info, Success, Warning, Error)"
  ```

---

### Task 11: Badges, Avatars, Progress (10 components)

**Files:** Modify: `design/inventree.lib.pen`

**Badge spec (Mantine):**
- Height: 20px, padding: `[0, 8]`, radius: 10 (pill shape), horizontal layout
- Font: 12px, `$font-weight-medium`, uppercase letter-spacing 0.5
- Filled variant (default): colored background + white text
- Variants: Primary=`$color-primary`, Secondary=`$bg-secondary`+`$text-primary`+`$border` stroke, Success=`$color-success`, Warning=`$color-warning`, Error=`$color-error`

**Avatar spec:** 36×36 circle.
- Image: filled with a gray placeholder (fill `$bg-secondary`), icon_font "user" centered (fill `$text-placeholder`)
- Text: fill `$color-primary`, centered initials text "AB" (14px, weight 700, fill `#ffffff`)

**Progress spec:** Full-width strip, height 8, radius 4. Background track: fill `$border`. Inner bar: fill `$color-primary`, width 60% of parent, radius 4.

- [ ] **Step 1: Create Badge/Primary through Badge/Error (5 components)**

  Each is a reusable horizontal frame, height 20, padding `[0, 8]`, radius 10. Text: `$font-size-xs` (12px), weight `$font-weight-medium`, uppercase letter-spacing 0.5. Adjust fill/text/stroke per variant:
  - Primary: fill `$color-primary`, text `#ffffff`, no stroke
  - Secondary: fill `$bg-secondary`, text `$text-primary`, stroke `$border` 1px
  - Success: fill `$color-success`, text `#ffffff`, no stroke
  - Warning: fill `$color-warning`, text `#ffffff`, no stroke
  - Error: fill `$color-error`, text `#ffffff`, no stroke

- [ ] **Step 2: Create Avatar/Image and Avatar/Text (2 components)**

  Avatar/Image: 36×36 ellipse, fill `$bg-secondary`. Child: icon_font "user", 20×20, centered, fill `$text-placeholder`.
  Avatar/Text: 36×36 ellipse, fill `$color-primary`. Child: text "AB", 14px, weight 700, fill `#ffffff`, centered.

- [ ] **Step 3: Create Progress (1 component)**

  Outer frame: width 200, height 8, radius 4, fill `$border`, layout none.
  Inner frame: width 120, height 8, radius 4, fill `$color-primary`, x=0, y=0.

- [ ] **Step 4: Screenshot and commit**

  ```bash
  git add design/inventree.lib.pen
  git commit -m "feat(design): add Badge, Avatar, Progress components"
  ```

---

### Task 12: Table primitives (4 components)

**Files:** Modify: `design/inventree.lib.pen`

**Table structure:**
- Table Column Header: horizontal frame, width "fill_container", height 40, padding `[0, 12]`, fill `$bg-secondary`, border-bottom stroke `$border`. Contains: label text (12px, weight 600, fill `$text-secondary`, uppercase) + optional sort icon.
- Table Cell: horizontal frame, width "fill_container", height 40, padding `[0, 12]`, fill `$bg-primary`, border-bottom stroke `$border`. Contains: cell content text (14px, fill `$text-primary`).
- Table Row: horizontal frame, layout horizontal, width 600, height "fit_content". Contains 3 Table Cell instances.
- Table: vertical frame, width 600, fit_content height. Contains 1 Column Header row + 3 Table Row instances.

- [ ] **Step 1: Create Table Column Header (reusable)**

  ```javascript
  tableColHeader=I("inventree-lib-frame", {
    type: "frame", reusable: true, name: "Table Column Header",
    layout: "horizontal", gap: "$spacing-sm", padding: [0, 12],
    width: "fill_container(200)", height: 40,
    fill: "$bg-secondary",
    stroke: { fill: "$border", thickness: { top: 0, right: 0, bottom: 1, left: 0 }, align: "inside" },
    alignItems: "center"
  })
  I(tableColHeader, { type: "text", content: "Column", fontSize: 12, fontWeight: "$font-weight-bold", fill: "$text-secondary" })
  I(tableColHeader, { type: "icon_font", iconFontFamily: "lucide", iconFontName: "chevrons-up-down", width: 14, height: 14, fill: "$text-placeholder" })
  ```

- [ ] **Step 2: Create Table Cell (reusable)**

  Same dimensions as Column Header but fill `$bg-primary`, content text 14px `$text-primary` "Cell value". No sort icon.

- [ ] **Step 3: Get component IDs for refs**

  Call `get_editor_state`. Note the IDs of `Table Column Header` and `Table Cell` — required for the `ref` values in Steps 4 and 5.

- [ ] **Step 4: Create Table Row (reusable)**

  Horizontal frame, width 600, height "fit_content". Contains 3 refs to Table Cell (use ID from Step 3).

- [ ] **Step 5: Create Table (reusable)**

  Call `get_editor_state` to get the current ID of `Table Row`. Then:
  Vertical frame, width 600, height "fit_content", stroke `$border` 1px, radius `$radius-sm`. Contains: 1 header row (horizontal frame with 3 × Table Column Header refs), then 3 × Table Row refs.

- [ ] **Step 6: Screenshot and commit**

  `get_screenshot` on the table section. Confirm column header row is distinguishable from data rows (different background).

  ```bash
  git add design/inventree.lib.pen
  git commit -m "feat(design): add Table primitives"
  ```

---

### Task 13: Data Table (3 components) + wire up flat-bom-design.pen

**Files:**
- Modify: `design/inventree.lib.pen`
- Modify: `plugins/FlatBOMGenerator/docs/flat-bom-design.pen`

**Data Table spec (InvenTree's mantine-datatable wrapper):**
- Data Table Header: horizontal frame, full-width, height 48. Contains: search box (left) + action icon buttons (right) in a group.
- Data Table Footer: horizontal frame, full-width, height 40, fill `$bg-secondary`, border-top `$border`. Contains: rows-per-page selector (left) + pagination (right).
- Data Table: vertical frame, width 800, fit_content. Contains: Data Table Header + Table (with column headers + rows) + Data Table Footer.

- [ ] **Step 1: Create Data Table Header (reusable)**

  Horizontal frame, width "fill_container(800)", height 48, padding `[0, 12]`, fill `$bg-primary`, border-bottom stroke `$border`, justify content `space_between`.
  Left child: ref to Search Box/Default (width 220).
  Right child: horizontal frame, gap 8, contains 3 × IconButton/Default refs.

- [ ] **Step 2: Create Data Table Footer (reusable)**

  Horizontal frame, width "fill_container(800)", height 40, padding `[0, 12]`, fill `$bg-secondary`, border-top stroke `$border`, justify content `space_between`, align items center.
  Left: text "10 rows per page", 12px, fill `$text-secondary`.
  Right: horizontal frame, gap 4, contains "1-10 of 47" text + prev/next icon buttons.

- [ ] **Step 3: Create Data Table (reusable)**

  Vertical frame, width 800, fit_content, stroke `$border` 1px, radius `$radius-sm`. Children: Data Table Header + Table + Data Table Footer.

- [ ] **Step 4: Screenshot Phase 2 complete**

  `get_screenshot` on the full frame. Confirm all Phase 2 components visible.

- [ ] **Step 5: Verify Phase 2 dark mode**

  Switch to `mode: dark` theme. `get_screenshot` on the main frame. Confirm Phase 2 components (alerts, badges, tables) render correctly in dark mode. Switch back to `mode: light`.

- [ ] **Step 6: Add import to flat-bom-design.pen**

  Open `plugins/FlatBOMGenerator/docs/flat-bom-design.pen` in Pencil via `open_document`.
  In the Pencil document, add the import by calling `batch_design` to set the `imports` field on the document root node:
  ```javascript
  U("document", { imports: { "inv": "../../design/inventree.lib.pen" } })
  ```
  Expected: no error. The library components should now be available for ref use in `flat-bom-design.pen`.

- [ ] **Step 8: Commit Phase 2**

  ```bash
  git add design/inventree.lib.pen plugins/FlatBOMGenerator/docs/flat-bom-design.pen
  git commit -m "feat(design): complete Phase 2 — data display, feedback; wire flat-bom-design.pen import"
  ```

---

## Chunk 3: Phase 3 — Navigation & Overlays

> **Session start:** Call `mcp__pencil__open_document` with the full path to `design/inventree.lib.pen`. Then call `get_editor_state` to confirm the file is open and the ~56 Phase 1+2 components exist. Call `get_variables` to confirm the token system is in place.

### Task 14: Sidebar (4 components)

**Files:** Modify: `design/inventree.lib.pen`

**Sidebar visual spec (InvenTree's NavigationDrawer pattern):**
- Sidebar: vertical frame, width 240, height 600, fill `$bg-secondary`, stroke-right `$border` 1px, padding `[16, 0]`, gap 4
- Sidebar Section Title: text label, 11px, weight 700, fill `$text-secondary`, uppercase, padding `[4, 16]`
- Sidebar Item/Default: horizontal frame, width "fill_container", height 36, padding `[0, 16]`, gap 8, fill transparent, radius `$radius-sm`. Icon (16×16, fill `$text-secondary`) + text (14px, fill `$text-primary`).
- Sidebar Item/Active: Copy of Default, fill `$color-primary` at 10% opacity (use hex `#4C6EF51A`), text fill `$color-primary`, icon fill `$color-primary`.

- [ ] **Step 1: Create Sidebar Section Title (reusable)**
- [ ] **Step 2: Create Sidebar Item/Default (reusable)**
- [ ] **Step 3: Create Sidebar Item/Active (reusable)** — copy Default, update fills
- [ ] **Step 4: Create Sidebar (reusable)** — outer container with 1 section title + 3 items (2 default, 1 active). Call `get_editor_state` first to get IDs of Sidebar Section Title, Sidebar Item/Default, and Sidebar Item/Active for use as refs.

- [ ] **Step 5: Screenshot**

  `get_screenshot` on the sidebar component. Confirm: section title visible, active item has tinted background, default items are transparent.

- [ ] **Step 6: Commit**

  ```bash
  git add design/inventree.lib.pen
  git commit -m "feat(design): add Sidebar components"
  ```

---

### Task 15: Tabs + Breadcrumb (7 components)

**Files:** Modify: `design/inventree.lib.pen`

**Tab spec:** Tab Item: horizontal frame, height 36, padding `[0, 16]`, border-bottom 2px solid.
- Active: border-bottom `$color-primary`, text `$color-primary`, weight 500
- Inactive: border-bottom transparent, text `$text-secondary`
- Tabs: horizontal frame containing 3 tabs (1 active, 2 inactive), border-bottom `$border` full-width

**Breadcrumb spec:** Inline horizontal items.
- Default: text 14px fill `$text-secondary`
- Active (current page): text 14px fill `$text-primary` weight 500
- Separator: "/" text, fill `$text-placeholder`
- Ellipsis: "..." text, fill `$text-secondary`

- [ ] **Step 1: Create Tab Item/Active (reusable)**

  Horizontal frame, height 36, padding `[0, 16]`, width "fit_content", layout horizontal, align center. Stroke bottom only: `{ fill: "$color-primary", thickness: { top:0, right:0, bottom:2, left:0 } }`. Text: 14px, `$font-weight-medium`, fill `$color-primary`.

- [ ] **Step 2: Create Tab Item/Inactive (reusable)**

  Copy Tab Item/Active. Remove bottom stroke (set fill transparent or omit stroke). Text fill: `$text-secondary`, weight `$font-weight-normal`.

- [ ] **Step 3: Create Tabs (reusable)**

  Call `get_editor_state` for IDs of Tab Item/Active and Tab Item/Inactive. Then:
  Horizontal frame, width "fit_content", height 36. Stroke bottom `$border` 1px full-width. Contains 1 × Tab Item/Active ref + 2 × Tab Item/Inactive refs.

- [ ] **Step 4: Create Breadcrumb Item/Default (reusable)**

  Text only: 14px, fill `$text-secondary`, content "Section".

- [ ] **Step 5: Create Breadcrumb Item/Active (reusable)**

  Text: 14px, fill `$text-primary`, weight `$font-weight-medium`, content "Current Page".

- [ ] **Step 6: Create Breadcrumb Item/Separator (reusable)**

  Text: 14px, fill `$text-placeholder`, content "/".

- [ ] **Step 7: Create Breadcrumb Item/Ellipsis (reusable)**

  Text: 14px, fill `$text-secondary`, content "...".

- [ ] **Step 8: Screenshot**

  `get_screenshot` on the tabs and breadcrumb section. Confirm active tab has colored underline, inactive tabs are muted.

- [ ] **Step 9: Commit**

  ```bash
  git add design/inventree.lib.pen
  git commit -m "feat(design): add Tabs and Breadcrumb components"
  ```

---

### Task 16: Pagination (4 components)

**Files:** Modify: `design/inventree.lib.pen`

**Pagination spec:** Each item is a 32×32 frame, radius `$radius-sm`, centered content.
- Default: fill transparent, stroke `$border` 1px, text `$text-primary` 14px
- Active: fill `$color-primary`, text `#ffffff` 14px
- Ellipsis: fill transparent, no stroke, "..." text `$text-secondary`
- Pagination: horizontal frame, gap 4, contains prev-arrow + 3 items + ellipsis + last item + next-arrow

- [ ] **Step 1: Create Pagination Item/Default (reusable)**

  Frame 32×32, radius `$radius-sm`, fill transparent, stroke `$border` 1px. Centered text: 14px, fill `$text-primary`, content "3".

- [ ] **Step 2: Create Pagination Item/Active (reusable)**

  Frame 32×32, radius `$radius-sm`, fill `$color-primary`, no stroke. Centered text: 14px, fill `#ffffff`, content "3".

- [ ] **Step 3: Create Pagination Item/Ellipsis (reusable)**

  Frame 32×32, fill transparent, no stroke. Centered text: 14px, fill `$text-secondary`, content "...".

- [ ] **Step 4: Create Pagination (reusable)**

  Call `get_editor_state` for IDs of the 3 pagination item variants. Then:
  Horizontal frame, gap 4, fit_content. Children: icon_font chevron-left (32×32, fill `$text-primary`) + 2 × Pagination Item/Default refs + Pagination Item/Active ref + Pagination Item/Ellipsis ref + Pagination Item/Default ref + icon_font chevron-right (32×32, fill `$text-primary`).

- [ ] **Step 5: Screenshot**

  `get_screenshot` on the pagination row. Confirm active item has filled indigo background.

- [ ] **Step 6: Commit**

  ```bash
  git add design/inventree.lib.pen
  git commit -m "feat(design): add Pagination components"
  ```

---

### Task 17: Modals and Dialog (4 components)

**Files:** Modify: `design/inventree.lib.pen`

**Modal spec (Mantine Modal pattern):**
- Width: 480px, radius: `$radius-md`, fill: `$bg-elevated`, padding: 24
- Has: title bar (title text + X close button), divider, content area, footer (cancel + confirm buttons)
- Modal/Center: centered, standard layout
- Modal/Left: left-aligned content (for form-heavy modals)
- Modal/Center Icon: like Center but header has a large centered icon above the title
- Dialog: smaller (360px), no title bar divider, simpler structure — icon + title + description + buttons

- [ ] **Step 1: Create Modal/Center (reusable)**

  Vertical frame, width 480, fit_content, fill `$bg-elevated`, radius `$radius-md`, padding 24, gap 16.
  Children: header row (title text bold 18px + X icon button), divider rectangle (1px height, fill `$border`, width fill_container), content area (text placeholder), footer (cancel Button/Secondary + confirm Button/Default).

- [ ] **Step 2: Create Modal/Left**

  Copy Modal/Center. Content text alignment left (same as center but noted for left-heavy forms).

- [ ] **Step 3: Create Modal/Center Icon**

  Copy Modal/Center. Add icon_font (40×40, fill `$color-primary`) centered above title in header area.

- [ ] **Step 4: Create Dialog**

  Vertical frame, width 360, fit_content, fill `$bg-elevated`, radius `$radius-md`, padding 24, gap 12, align items center.
  Children: icon (32×32 `$color-warning`), title (16px bold, center), description (14px `$text-secondary`, center, fixed-width), button row.

- [ ] **Step 5: Screenshot**

  `get_screenshot` on the modals section. Confirm: Modal/Center has center-aligned content with title + divider + footer buttons; Modal/Center Icon shows large icon above title; Dialog is smaller and simpler.

- [ ] **Step 6: Commit**

  ```bash
  git add design/inventree.lib.pen
  git commit -m "feat(design): add Modal and Dialog components"
  ```

---

### Task 18: Drawer and Tooltip (2 components)

**Files:** Modify: `design/inventree.lib.pen`

**Drawer/Right spec (InvenTree's DetailDrawer):**
- Width: 360px, height: 600px (fixed for library display), fill `$bg-primary`, border-left `$border` 1px
- Header: title (16px bold) + X close icon button, border-bottom `$border`
- Body: scrollable content area with padding 16, placeholder text

**Tooltip spec:** Small floating label.
- Background: `#000000CC` (semi-transparent black), radius `$radius-xs`, padding `[4, 8]`
- Text: 12px, fill `#ffffff`, content "Tooltip text"
- Small triangular pointer at bottom (path shape)

- [ ] **Step 1: Create Drawer/Right (reusable)**

  Vertical frame, width 360, height 600, fill `$bg-primary`, stroke-left `$border` 1px, layout vertical.
  Header: horizontal frame, height 52, padding `[0, 16]`, fill `$bg-primary`, border-bottom `$border` 1px, justify `space_between`, align center. Contains: title text (16px, weight `$font-weight-bold`, fill `$text-primary`) + ref to IconButton/Ghost (X icon, lucide "x").
  Body: frame, fill transparent, padding 16, fit_content. Child: placeholder text (14px, fill `$text-secondary`, "Drawer content area").

- [ ] **Step 2: Create Tooltip (reusable)**

  Frame, fit_content, padding `[4, 8]`, radius `$radius-xs`, fill `#000000CC`. Child: text "Tooltip text", 12px, fill `#ffffff`.

- [ ] **Step 3: Screenshot**

  `get_screenshot` on the drawer and tooltip area.

- [ ] **Step 4: Commit**

  ```bash
  git add design/inventree.lib.pen
  git commit -m "feat(design): add Drawer and Tooltip components"
  ```

---

### Task 19: Accordion and Dropdown (3 components)

**Files:** Modify: `design/inventree.lib.pen`

**Accordion spec:**
- Width: 320px, radius `$radius-sm`, stroke `$border` 1px
- Header row: horizontal, height 44, padding `[0, 16]`, text 14px weight 500 + chevron icon right-aligned
- Closed: chevron-right, no body
- Open: chevron-down, + body frame below (padding 16, text content)

**Dropdown spec:** Floating menu panel.
- Width: 180px, fill `$bg-elevated`, radius `$radius-sm`, stroke `$border` 1px, shadow `{ type: "shadow", offset: {x:0,y:4}, blur: 12, color: "#0000001A" }`
- Contains: 3 × menu item rows (height 36, padding `[0, 12]`, horizontal layout, gap 8, icon 16×16 + text 14px)
- First item: fill transparent, normal text. Hover hint via background: show one item with fill `$bg-secondary`.

- [ ] **Step 1: Create Accordion/Closed (reusable)**
- [ ] **Step 2: Create Accordion/Open (reusable)** — copy Closed, add body content
- [ ] **Step 3: Create Dropdown (reusable)**
- [ ] **Step 4: Screenshot Phase 3 complete — light mode**

  `get_screenshot` on main frame. Confirm all navigation and overlay components are present.

- [ ] **Step 5: Verify dark mode**

  Switch to `mode: dark`. `get_screenshot`. Confirm sidebar, tabs, modals all render correctly in dark mode (dark backgrounds, correct text colors). Switch back to `mode: light`.

- [ ] **Step 6: Commit Phase 3**

  ```bash
  git add design/inventree.lib.pen
  git commit -m "feat(design): complete Phase 3 — navigation and overlay components"
  ```

---

## Chunk 4: Phase 4 — InvenTree Custom Widgets + Content + Smoke Test

> **Session start:** Call `mcp__pencil__open_document` with the full path to `design/inventree.lib.pen`. Call `get_editor_state` to confirm the file is open and the ~82 Phase 1–3 components exist. Call `get_variables` to confirm the token system is intact.

### Task 20: Cards (4 components)

**Files:** Modify: `design/inventree.lib.pen`

**Card spec (Mantine Paper-based):**
- Card: vertical frame, width 280, fit_content, fill `$bg-elevated`, radius `$radius-sm`, stroke `$border` 1px, shadow `{type:"shadow", offset:{x:0,y:2}, blur:8, color:"#0000001A"}`, padding 16, gap 8.
- Card Image: card with top image placeholder (frame 280×160, fill `$bg-secondary`, centered image icon) above content.
- Card Action: card with footer row of action buttons below content.
- Card Plain: minimal card, no shadow, just border.

- [ ] **Step 1: Create Card (reusable)** — title text (16px bold) + description text (14px secondary) + body content placeholder
- [ ] **Step 2: Create Card Image** — copy Card, add image header frame above content
- [ ] **Step 3: Create Card Action** — copy Card, add button footer (Button/Secondary + Button/Default) below content
- [ ] **Step 4: Create Card Plain** — copy Card, remove shadow, fill `$bg-primary`
- [ ] **Step 5: Screenshot and commit**

  ```bash
  git add design/inventree.lib.pen
  git commit -m "feat(design): add Card variants"
  ```

---

### Task 21: List components (4 components)

**Files:** Modify: `design/inventree.lib.pen`

**List spec:**
- List Item Title: text only, 12px, weight 700, fill `$text-secondary`, uppercase — acts as a section header
- List Divider: 1px horizontal rule, width "fill_container(280)", fill `$border`
- List Item/Unchecked: horizontal frame, height 36, padding `[0, 12]`, gap 8. Left: empty circle 16×16 stroke `$border`. Right: text 14px `$text-primary`.
- List Item/Checked: copy Unchecked. Circle: fill `$color-primary`, stroke none. Contains checkmark icon inside.

- [ ] **Step 1: Create List Item Title, List Divider, List Item/Unchecked, List Item/Checked**
- [ ] **Step 2: Screenshot and commit**

  ```bash
  git add design/inventree.lib.pen
  git commit -m "feat(design): add List components"
  ```

---

### Task 22: InvenTree custom buttons (4 components)

**Files:**
- Read: `inventree-dev/InvenTree/src/frontend/src/components/buttons/PrimaryActionButton.tsx`
- Read: `inventree-dev/InvenTree/src/frontend/src/components/buttons/ActionButton.tsx`
- Read: `inventree-dev/InvenTree/src/frontend/src/components/buttons/SplitButton.tsx`
- Read: `inventree-dev/InvenTree/src/frontend/src/components/buttons/CopyButton.tsx`
- Modify: `design/inventree.lib.pen`

- [ ] **Step 1: Read PrimaryActionButton source**

  Read `inventree-dev/InvenTree/src/frontend/src/components/buttons/PrimaryActionButton.tsx`.
  Note: expected to be a Button with mandatory icon, tooltip support, color prop, variant prop. Map visual properties to Pencil.

- [ ] **Step 2: Read ActionButton source**

  Read `inventree-dev/InvenTree/src/frontend/src/components/buttons/ActionButton.tsx`.
  Answer: Does it render a text label or only a tooltip? What is the default size/variant? Does it wrap an existing Mantine button or define custom styling? Use the answers to confirm or adjust the spec in Step 4.

- [ ] **Step 3: Read SplitButton source**

  Read `inventree-dev/InvenTree/src/frontend/src/components/buttons/SplitButton.tsx`.
  Answer: How wide is the chevron section? Is there a visual divider between the main button and the chevron? Confirm the split layout matches the spec in Step 5.

- [ ] **Step 4: Read CopyButton source**

  Read `inventree-dev/InvenTree/src/frontend/src/components/buttons/CopyButton.tsx`.
  Answer: Does CopyButton add any visual treatment beyond a standard icon button (e.g. a checkmark flash on copy)? If so, note it as a tooltip/state annotation on the Pencil component.

- [ ] **Step 5: Create PrimaryActionButton (reusable)**

  Based on source reading: Button/Default structure but icon is REQUIRED (not optional), tooltip is implied by the name. Visual: indigo fill (`$color-primary`), white text, icon left (16×16). Height 36, padding `[0, 16]`, gap 8, radius `$radius-sm`.

- [ ] **Step 6: Create ActionButton (reusable)**

  Based on source (confirm from Step 2): if it renders label + icon — horizontal frame, gap 4, fit_content; icon 16×16 fill `$text-primary`, label text 10px `$text-secondary` below icon. If it renders only an icon with tooltip: use same spec as IconButton/Secondary (36×36, fill `$bg-secondary`, stroke `$border`). Annotate with a note shape: "Shows tooltip on hover".

- [ ] **Step 7: Create SplitButton (reusable)**

  Based on source (confirm from Step 3): horizontal frame, height 36, fit_content. Left part: padding `[0, 12]`, fill `$color-primary`, text "Action" 14px white, weight 500. Divider: 1×36 rectangle, fill `#FFFFFF33`. Right part: 28×36 frame, fill `$color-primary`, centered chevron-down 14×14 fill white. Use layout none on the outer frame (absolute position left/right parts side by side).

- [ ] **Step 8: Create CopyButton (reusable)**

  Based on source (confirm from Step 4): IconButton/Ghost with copy icon (lucide "copy"), 36×36. If source shows a checkmark state, add a note annotation on the component: "Icon switches to check on copy (transient state, not modeled in library)".

- [ ] **Step 9: Screenshot and commit**

  `get_screenshot` on the InvenTree buttons section. Confirm: PrimaryActionButton is visually identical to Button/Default; SplitButton shows a split design; ActionButton and CopyButton are icon-only.

  ```bash
  git add design/inventree.lib.pen
  git commit -m "feat(design): add InvenTree custom button widgets"
  ```

---

### Task 23: DetailsBadge variants (4 components)

**Files:**
- Read: `inventree-dev/InvenTree/src/frontend/src/components/details/DetailsBadge.tsx`
- Modify: `design/inventree.lib.pen`

- [ ] **Step 1: Read DetailsBadge source**

  Read `inventree-dev/InvenTree/src/frontend/src/components/details/DetailsBadge.tsx`.
  Note: it renders a Mantine Badge with configurable color, label, size (`lg` default, `filled` variant). Colors map to Mantine color names.

- [ ] **Step 2: Create DetailsBadge/Default**

  Badge spec (larger than our standard Badge — size lg means height 24, padding `[0, 10]`):
  Fill `$bg-secondary`, stroke `$border`, text `$text-primary`, 12px, weight 500.

- [ ] **Step 3: Create DetailsBadge/Success, /Error, /Warning**

  Copy Default. Success: fill `$color-success-bg`, text `$color-success`, stroke `$color-success`.
  Error: fill `$color-error-bg`, text `$color-error`, stroke `$color-error`.
  Warning: fill `$color-warning-bg`, text `$color-warning`, stroke `$color-warning`.

- [ ] **Step 4: Screenshot and commit**

  ```bash
  git add design/inventree.lib.pen
  git commit -m "feat(design): add DetailsBadge variants"
  ```

---

### Task 24: InvenTree table column types (5 components)

**Files:**
- Read: `inventree-dev/InvenTree/src/frontend/src/tables/` (scan for column type files)
- Modify: `design/inventree.lib.pen`

These components represent the visual content rendered inside a Table Cell for each InvenTree column type. They are cell-content components (not full columns), meant to be placed inside a Table Cell instance.

- [ ] **Step 1: Read InvenTree column type sources**

  Read these specific files (or the closest matches if names differ):
  - `inventree-dev/InvenTree/src/frontend/src/tables/ColumnRenderers.tsx` (or `columns.tsx`) — look for cell renderer functions for Date, Part, Status, Description, Location
  - `inventree-dev/InvenTree/src/frontend/src/components/details/DetailsBadge.tsx` — for status badge rendering used in StatusColumn

  For each column type, answer: what React elements does the cell renderer return? (text only, icon+text, badge, thumbnail+text?) Use answers to confirm or adjust Steps 2–6 below.

- [ ] **Step 2: Create StatusColumn cell content (reusable)**

  Based on source: renders a colored Badge indicating status. Design as: DetailsBadge/Default with status-specific color. Show as horizontal frame, fit_content, containing a colored filled badge (small, pill shape, with dot + text).

- [ ] **Step 3: Create PartColumn cell content (reusable)**

  Based on source: shows a part thumbnail (small avatar/image circle) + part name text. Design: horizontal frame, gap 8, height "fit_content". Left: 24×24 circle fill `$bg-secondary` (thumbnail placeholder). Right: text 14px `$text-primary` "Part Name".

- [ ] **Step 4: Create DateColumn cell content (reusable)**

  Simple text: 14px `$text-secondary`, content "2024-01-15" (ISO date format).

- [ ] **Step 5: Create DescriptionColumn cell content (reusable)**

  Text with truncation: 14px `$text-primary`, content "Description text...", textGrowth `fixed-width`, width 200.

- [ ] **Step 6: Create LocationColumn cell content (reusable)**

  Like PartColumn: small location pin icon (lucide "map-pin", 14×14, fill `$text-secondary`) + text 14px `$text-primary` "Location Name".

- [ ] **Step 7: Screenshot Phase 4 complete**

  `get_screenshot` on full frame. Confirm all Phase 4 components visible.

- [ ] **Step 8: Commit**

  ```bash
  git add design/inventree.lib.pen
  git commit -m "feat(design): add InvenTree table column type components"
  ```

---

### Task 25: AdminButton (1 component)

**Files:**
- Read: `inventree-dev/InvenTree/src/frontend/src/components/buttons/AdminButton.tsx`
- Modify: `design/inventree.lib.pen`

- [ ] **Step 1: Read AdminButton source**

  Read `inventree-dev/InvenTree/src/frontend/src/components/buttons/AdminButton.tsx`.
  Answer: Is AdminButton a styled link/button to the Django admin interface? What visual treatment — icon, label, color? Use the answer to set correct fill and icon.

- [ ] **Step 2: Create AdminButton (reusable)**

  Based on source: likely a small button or icon button linking to the admin interface. Expected visual: IconButton/Secondary variant with a shield or settings icon (lucide "shield"), 36×36, fill `$bg-secondary`, stroke `$border`, icon fill `$text-primary`. If source shows a different treatment, apply that instead.

- [ ] **Step 3: Screenshot and commit**

  `get_screenshot` on the AdminButton component.

  ```bash
  git add design/inventree.lib.pen
  git commit -m "feat(design): add AdminButton component"
  ```

---

### Task 26: Smoke test — wire flat-bom-design.pen and verify library import

**Files:**
- Modify: `plugins/FlatBOMGenerator/docs/flat-bom-design.pen`

- [ ] **Step 1: Open flat-bom-design.pen**

  `mcp__pencil__open_document` with full path to `plugins/FlatBOMGenerator/docs/flat-bom-design.pen`.

- [ ] **Step 2: Confirm import is in place**

  `get_editor_state`. Confirm the `imports` field references `inventree.lib.pen`. If not (import was planned for Phase 2 completion), add it now via `batch_design` on the document root.

- [ ] **Step 3: Place a Button/Default instance**

  Insert a ref to the Button/Default component from the library:
  ```javascript
  testBtn=I("document", { type: "ref", ref: "<Button/Default-id-from-library>" })
  ```
  If the import is correctly in place, the ref should resolve.

- [ ] **Step 4: Place a Data Table instance**

  ```javascript
  testTable=I("document", { type: "ref", ref: "<Data-Table-id-from-library>" })
  ```

- [ ] **Step 5: Screenshot in light mode**

  `get_screenshot`. Confirm both components render correctly with correct fills and text.

- [ ] **Step 6: Verify Phase 4 dark mode**

  Switch to `mode: dark`. `get_screenshot`. Confirm dark theme values apply (dark backgrounds, adjusted text). Switch back to `mode: light`.

- [ ] **Step 7: Final commit**

  ```bash
  git add design/inventree.lib.pen plugins/FlatBOMGenerator/docs/flat-bom-design.pen
  git commit -m "feat(design): complete inventree.lib.pen — all 4 phases, smoke test passed"
  ```

---

## Summary

| Phase | Tasks | Components | Session |
|---|---|---|---|
| 1 — Foundation | 1–7 | ~28 (buttons, icon buttons, basic inputs) | Session 1 |
| 2 — Data & Feedback | 8–13 | ~28 (checkboxes, radios, alerts, badges, tables) | Session 2 |
| 3 — Navigation & Overlays | 14–19 | ~26 (sidebar, tabs, pagination, modals, drawers) | Session 3 |
| 4 — Content & InvenTree Widgets | 20–26 | ~22 (cards, lists, custom widgets, AdminButton, smoke test) | Session 4 |

**Total: ~104 components across 26 tasks in 4 sessions.**
