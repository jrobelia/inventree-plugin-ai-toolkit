# InvenTree Assembly BOM Plugin Suite

**Project Overview:** Suite of plugins for managing complex multi-level BOMs through build orders, purchase lists, and build order hierarchies.

**Last Updated:** December 12, 2025

**Status:** Planning Phase - Starting with Flat BOM Generator improvements

---

## General Workflow

End-to-end process for producing a product:

1. **Pre-Planning:** Use Flat BOM Viewer to get general idea of stock levels
2. **Create Build Order:** Make BO for top-level assembly with desired quantity
3. **Generate Child Build Orders:** Use Build List Generator to create child BOs for all assemblies (recursive, deduplicated)
4. **Purchase Parts:** Use Purchase List Generator to buy commercial and purchased assemblies, attach to POs with project codes
5. **Manufacturing:** Execute build orders, allocate stock, track progress

---

## Architecture Philosophy

**Goal:** Feel like part of InvenTree source code

**Principles:**
- Use InvenTree's built-in methods and patterns (selection, modals, tables)
- Live inside InvenTree ecosystem as much as possible
- Use built-in categorization system (not custom prefixes)
- Integrate with existing UI patterns (toolbars, panels, tables)

**Shared Library Strategy:**
- Start: Copy-and-modify to validate patterns
- Then: Extract to `inventree-bom-toolkit` with git dependency
- Method: `"inventree-bom-toolkit @ git+https://github.com/USERNAME/inventree-bom-toolkit.git@v0.1.0"`

---

## Plugin 1: Flat BOM Generator

### Current Status
- ✅ Built and deployed to staging (v0.9.0)
- ✅ Recursive BOM traversal working
- ✅ Deduplication and aggregation working
- ✅ Frontend panel with DataTable working
- ✅ CSV export with timestamps working
- ⚠️ Uses prefix-based categorization (NEEDS CHANGE)
- ❌ Cut-list feature not implemented

### Required Changes

#### 1. Switch to InvenTree Built-in Categories

**Current:** Uses part name prefixes (fab-, coml-) and internal supplier logic

**Needed:** Use InvenTree's Part Category system

**Design Questions:**
1. **Category Mapping Approach:**
   - Option A: Single category per type (dropdown: "Fab Parts Category: [select]")
   - Option B: Multi-select categories per type (checkboxes: "Fab Categories: [Cat1, Cat3, Cat7]")
   - **Decision Needed:** Which approach?

2. **Category Types to Support:**
   - Fabrication Parts (internal manufacturing)
   - Commercial Parts (purchased, no assembly)
   - Assemblies (internal build)
   - Purchased Assemblies (external build, leaf parts)
   - Cut-to-Length Parts (raw material with units)

3. **Settings Structure:**
   ```python
   SETTINGS = {
       'FAB_CATEGORIES': {
           'name': 'Fabrication Part Categories',
           'description': 'Categories for internally fabricated parts',
           'model': 'part.partcategory',
           'multiple': True,  # Allow multiple category selection
       },
       'COML_CATEGORIES': {
           'name': 'Commercial Part Categories',
           'description': 'Categories for purchased commercial parts',
           'model': 'part.partcategory',
           'multiple': True,
       },
       # ... more
   }
   ```

4. **Backward Compatibility:**
   - Keep prefix-based as fallback if categories not configured?
   - Or require configuration before use?

#### 2. Cut-List Feature Design

**Purpose:** Show how many stock lengths needed for parts with units (e.g., wire, tubing, bar stock)

**Data Sources Needed:**
- **Used length per unit:** Where does this come from?
  - BOM item parameter? (e.g., `length: 100mm`)
  - Part parameter? (standard length)
  - User input per build?
- **Purchased length:** Where does this come from?
  - Supplier part field?
  - Part parameter? (e.g., `stock_length: 300mm`)
  - Standard value in settings?

**Calculations:**
- Total length needed = qty × used_length_per_unit
- Stock lengths required = ceiling(total_length / purchased_length)
- Example: 5 parts × 100mm = 500mm total → fits in 2× 300mm stock lengths

**UI Design:**
- Separate expandable section below main table?
- Inline in table with expand arrow?
- Separate tab: "Parts List | Cut List"?
- Grouped by cut length (all 100mm cuts together)?

**Output Format:**
```
Cut List Summary:
- Wire, 22AWG, Red (300mm stock)
  - 5 parts × 100mm = 500mm
  - Requires: 2× 300mm lengths
  - Waste: 100mm

- Tubing, 1/4", Aluminum (1000mm stock)
  - 12 parts × 75mm = 900mm
  - Requires: 1× 1000mm length
  - Waste: 100mm
```

**Questions:**
1. How to identify CtL parts? Category? Part parameter? Units field?
2. Should cut-list respect existing stock? (e.g., if have 1× 300mm in stock, need 1 more)
3. Handle waste optimization? (arrange cuts to minimize waste)

### Implementation Priority
1. ✅ Complete category mapping design
2. Implement category-based categorization
3. Test with real InvenTree categories
4. Design cut-list feature
5. Implement cut-list feature
6. Update documentation

---

## Plugin 2: Purchase List Generator

### Status
**Not Started** - Complete Flat BOM first

### Specification

**Appears On:** All Build Order detail pages (parent and child BOs)

**Purpose:** Generate purchase orders for leaf parts needed by a build order tree

### Core Logic

**BOM Traversal:**
- Recursive Build Order traversal (parent → all children)
- Aggregate leaf parts: Commercial + Purchased Assemblies
- Deduplicate and sum quantities across entire BO tree

**Stock Awareness:**
- Check in_stock, on_order, allocated
- Calculate shortfall per part
- Optional: Filter by allocation status

**PO Integration:**
- Attach to POs using BO's project code
- Group by supplier
- Add to existing PO or create new

### Workflow - Manual Method (MVP)

1. **Generate Purchase List:**
   - Click "Generate Purchase List" button on BO detail page
   - Modal with options:
     - ☑ Include parts already allocated to this BO tree
     - ☑ Include on-order parts in calculations
     - Recursion depth: [All | 1-10 levels]

2. **Review Parts Table:**
   ```
   [☑] | Part | Category | Qty Needed | In Stock | On Order | Allocated | Shortfall | Default Supplier | [Supplier ▼] | Actions
   ```
   - User can:
     - Check/uncheck parts to include
     - Change supplier via dropdown
     - See real-time shortfall calculations

3. **Create Purchase Orders:**
   - Click "Add to Purchase Orders"
   - System groups by supplier
   - For each supplier:
     - Search for existing PO (same project + supplier + status=Pending)
     - Prompt: "Add to PO-1234?" or "Create new PO?"
     - Create PO line items with project code from BO

4. **Confirmation:**
   - Show summary: "Added 15 line items to 3 POs"
   - Provide links to created/updated POs

### Workflow - Automatic Method (Stretch Goal)

- Same as manual but:
  - Auto-checks all shortfall items
  - Uses default suppliers (no user selection)
  - Creates POs immediately
  - Shows summary only

### Implementation Details

**Allocation Filtering Options:**
- **None:** Show all stock
- **Exclude THIS BO tree:** Subtract allocations to this BO + children
- **Exclude ALL BOs:** Show only unallocated stock (available stock)

**Existing PO Detection:**
- Search criteria:
  - Supplier matches
  - Project code matches BO project
  - Status = Pending (configurable in settings?)
- User can:
  - Select existing PO from list
  - Create new PO
  - Skip adding to PO (manual later)

**BO Traversal Scope:**
- Respect BO status:
  - Include: Pending, Production, On Hold
  - Exclude: Complete, Cancelled
- Configurable in settings?

### Settings

```python
SETTINGS = {
    'DEFAULT_INCLUDE_ALLOCATED': BoolSetting(default=False),
    'DEFAULT_RECURSION_DEPTH': IntSetting(default=10),
    'PO_STATUS_FOR_ADDING': MultipleChoiceSetting(
        choices=['PENDING', 'PLACED'],
        default=['PENDING']
    ),
    'BO_STATUS_TO_INCLUDE': MultipleChoiceSetting(...),
}
```

### Questions to Resolve

1. **Project Code:**
   - Where does BO project code come from? (BO has project field in InvenTree?)
   - What if BO has no project? Use BO reference?

2. **Multi-BO Purchase List:**
   - Should user be able to select multiple BOs and generate combined purchase list?
   - Or always scope to single BO tree?

3. **Supplier Part Matching:**
   - If part has multiple supplier parts, how to choose?
   - Use default? Show all options? Lowest price?

4. **Cut-to-Length Parts:**
   - Defer until Flat BOM cut-list is working
   - Then add: "Record individual lengths of supplier part needed"

---

## Plugin 3: Build List Generator

### Status
**Not Started** - Complete Purchase List first

### Specification

**Appears On:** Top-level Build Order detail pages

**Purpose:** Generate child build orders for all assemblies in BOM tree

### Core Logic

**BOM Traversal:**
- Recursive BOM traversal to find all internal assemblies
- Exclude purchased assemblies (they're leaf parts for purchasing)
- Deduplicate assemblies across branches
- Place child BO at highest common parent level

**Stock Awareness:**
- Check current stock of each assembly
- Adjust build quantity if stock available (optional)

**Quantity Calculation:**
- Based on parent BO quantity × BOM quantity
- Propagates down tree

### Workflow

1. **Settings Modal:**
   - Click "Generate Build Orders" button
   - Modal shows:
     - Recursion depth: [slider: 1-10 levels | "All"]
     - ☑ Include internal fab parts (create BOs for fab work)
     - ☑ Adjust for available stock

2. **Preview Table:**
   ```
   [☑] | Assembly | Category | Qty Needed | In Stock | Qty to Build | Parent BO | Level
   ```
   - Shows hierarchical list of BOs to create
   - User can check/uncheck which to create
   - Quantities auto-calculated based on BOM tree

3. **Create Build Orders:**
   - Click "Create Selected Build Orders"
   - System creates child BOs:
     - Links to parent via `parent` field
     - Uses part from assembly
     - Sets quantity from calculation
     - Inherits project code from parent

4. **Confirmation:**
   - Show summary: "Created 12 child build orders"
   - Provide link to BO Hierarchy view

### Implementation Details

**Highest Common Parent Placement:**
- Example: Part X used in SubAssy A and SubAssy B, both under TopAssy
- Create child BO for X directly under TopAssy (not under A or B)
- Prevents duplicate BOs for same assembly
- **Algorithm:**
  - Build usage graph for each assembly
  - Find lowest common ancestor in BO tree
  - Place child BO at that level

**Stock-Adjusted Quantities:**
- If need 20, have 5 in stock:
  - Option A: Suggest building 15 (net quantity)
  - Option B: Build full 20, assume stock gets allocated
- **Decision:** Option A (net quantity) - More practical

**Internal Fab Parts:**
- If checkbox enabled, fab parts become Build Orders
- Purpose: Track internal manufacturing work
- User can create or skip these BOs (not required)

**Child BO Naming:**
- Use InvenTree's auto-reference (BO-0042, BO-0043, etc.)
- Or custom pattern: "BO-0042-001" (parent-child)?
- **Decision:** Use InvenTree default (simpler)

### Settings

```python
SETTINGS = {
    'DEFAULT_RECURSION_DEPTH': IntSetting(default=10),
    'DEFAULT_INCLUDE_FAB_PARTS': BoolSetting(default=False),
    'DEFAULT_ADJUST_FOR_STOCK': BoolSetting(default=True),
}
```

### Questions to Resolve

1. **Relationship to Purchase List:**
   - After creating child BOs, automatically open Purchase List Generator?
   - Or separate manual step?

2. **Existing Child BOs:**
   - What if parent already has some child BOs?
   - Skip existing? Show as "Already created"?
   - Update quantities if they've changed?

3. **Circular Dependencies:**
   - What if BOM has circular references (Part A uses Part B, Part B uses Part A)?
   - Detection and error handling needed

4. **Batch Creation Performance:**
   - Creating 50+ BOs could be slow
   - Show progress bar? Background task?

---

## Plugin 4: BO Hierarchy Display

### Status
**Not Started** - Standalone, lower priority

### Specification

**Appears On:** Build Order list page

**Purpose:** Display parent/child BO relationships in tree structure

### Goal: Integrate with Existing UI

**InvenTree BO List has:**
- List View (table)
- Calendar View (gantt-style)

**Add:**
- Tree View (hierarchical)

**UI Integration:**
- Add "Tree View" button to toolbar (List View | Calendar View | **Tree View**)
- Clicking switches entire panel to tree display

### What It Does

**Tree Display:**
- Collapsible/expandable tree structure
- Shows BO reference, part, quantity, status
- Click BO → navigate to detail page
- Visual hierarchy with indentation/lines

**Filtering:**
- Optional: "Hide child BOs in List View" toggle
- Affects whether children show in standard list/calendar views

### Implementation Options

**Option A: Add Button to Toolbar (Preferred)**
- Research: Can plugins add buttons to InvenTree main toolbar?
- Uses UserInterfaceMixin capabilities
- Feels most integrated

**Option B: Separate Panel (Fallback)**
- Add new panel to BO list page
- Panel contains tree view
- Less integrated but easier to implement

### Implementation Details

**Tree Data Structure:**
- **Lazy Loading:** Load children on expand (better performance)
- Cache tree structure in component state
- Refresh on BO create/delete

**Tree Node Format:**
```typescript
interface BOTreeNode {
  id: number;
  reference: string;
  part: {pk: number, name: string};
  quantity: number;
  status: number;
  parent: number | null;
  children: BOTreeNode[];
  isExpanded: boolean;
}
```

**Visual Design:**
- Use Mantine Tree component or react-complex-tree
- Icons: 📦 for assembly, 🔧 for fab, etc.
- Color code by status (pending=gray, production=blue, complete=green)

### Questions to Resolve

1. **Toolbar Integration:**
   - Research UserInterfaceMixin capabilities for toolbar buttons
   - If not possible, fallback to separate panel approach

2. **Tree Scope:**
   - Show all BOs in tree (forest of trees)?
   - Or only show top-level BOs with expandable children?

3. **Filtering Persistence:**
   - If "hide children" enabled in Tree View, persist to List View?
   - Or independent per view?

4. **Performance:**
   - Large BO trees (100+ BOs) could be slow
   - Virtual scrolling? Pagination? Lazy loading?

---

## Shared Toolkit Architecture

### When to Extract

**Now:** Keep code duplicated in plugins

**After Flat BOM v1.0:** Extract proven patterns to toolkit

**Trigger:** When 2+ plugins share same code

### Toolkit Structure

```
inventree-bom-toolkit/
├── bom_toolkit/
│   ├── __init__.py
│   ├── traversal.py              # BOM traversal algorithms
│   ├── categorization.py          # Part categorization
│   ├── stock.py                   # Stock calculations
│   ├── build_order.py             # BO tree traversal
│   └── utils.py                   # Shared utilities
├── pyproject.toml
├── LICENSE
└── README.md
```

### Shared Components (Python)

**From Flat BOM (proven):**
- `traverse_bom(part_id)` - Recursive part BOM traversal
- `get_leaf_parts_only()` - Filter to purchaseable leaves
- `deduplicate_and_sum()` - Aggregate quantities
- `get_flat_bom()` - Complete pipeline

**New (to be developed):**
- `traverse_build_order_tree(build_id)` - Recursive BO traversal
- `categorize_by_category(part, category_mappings)` - InvenTree category-based
- `calculate_shortfall(part, qty_needed, include_allocated)` - Stock math
- `find_common_ancestor()` - For BO placement logic

### Shared Components (Frontend)

**Consider Later:** React components are harder to share

**Possible Shared:**
- DataTable configuration patterns
- Stats panel component
- CSV export function
- Supplier dropdown component

**Approach:** Copy-paste initially, extract to npm package later if needed

### Git Dependency Pattern

**Toolkit Repository:**
- GitHub: `https://github.com/USERNAME/inventree-bom-toolkit`
- Versioning: Git tags (v0.1.0, v0.2.0, etc.)
- Branching: main = stable, develop = active work

**Plugin Dependencies:**
```toml
[project]
dependencies = [
    "inventree>=0.14.0",
    "inventree-bom-toolkit @ git+https://github.com/USERNAME/inventree-bom-toolkit.git@v0.1.0"
]
```

**Update Process:**
1. Fix bug in toolkit
2. Push to GitHub with new tag (v0.1.1)
3. Update plugin pyproject.toml to reference new tag
4. Rebuild plugin

---

## Development Roadmap

### Phase 1: Flat BOM Generator v1.0 ✅ CURRENT
1. ✅ Finalize category mapping design
2. Implement InvenTree category-based categorization
3. Update settings configuration
4. Test with real categories
5. Design cut-list feature
6. Implement cut-list feature
7. Update documentation
8. Deploy to production

### Phase 2: Extract Shared Toolkit
1. Create inventree-bom-toolkit repository
2. Extract proven patterns from Flat BOM
3. Create git tags and releases
4. Update Flat BOM to use toolkit
5. Test installation from git dependency
6. Document toolkit API

### Phase 3: Purchase List Generator
1. Copy Flat BOM as starting point
2. Adapt for Build Order context
3. Implement BO tree traversal
4. Add PO creation functionality
5. Test with real build orders
6. Deploy to staging
7. User testing and refinement

### Phase 4: Build List Generator
1. Copy plugin structure
2. Implement BO creation logic
3. Add stock awareness
4. Build preview/selection UI
5. Test recursive BO generation
6. Deploy to staging
7. User testing and refinement

### Phase 5: BO Hierarchy Display
1. Research toolbar integration options
2. Implement tree view component
3. Add lazy loading for performance
4. Test with large BO trees
5. Deploy to staging
6. User testing and refinement

### Phase 6: Polish and Production
1. Refine all plugins based on usage
2. Extract more shared components to toolkit
3. Add comprehensive documentation
4. Create video tutorials
5. Deploy all to production
6. Consider PyPI publishing

---

## Technical Considerations

### InvenTree Version Compatibility

**Target:** InvenTree 1.1.6 (apiVersion 421)

**Constraints:**
- No public `/api/plugin/` REST API
- UrlsMixin works for internal plugin endpoints
- Must use InvenTree models directly when needed

**API Availability (to verify):**
- ✅ `/api/part/` - Part CRUD
- ✅ `/api/bom/` - BOM items
- ✅ `/api/build/` - Build Orders
- ✅ `/api/order/purchase/` - Purchase Orders
- ✅ `/api/order/po-line/` - PO Line Items
- ❓ Project field on Build Orders?
- ❓ Project field on PO Line Items?

### Data Model Questions

**Need to verify in InvenTree 1.1.6:**
1. Build Order has `project` field?
2. PO Line Item has `project` field?
3. Can query allocations by Build Order?
4. Part Category structure and API endpoints?
5. Supplier Part model fields (for purchased lengths)?

### Performance Considerations

**Large BOMs:**
- 500+ part BOM could be slow to traverse
- Solution: Limit recursion depth, add progress indicators

**Many Build Orders:**
- 100+ BO tree could be slow to display
- Solution: Lazy loading, virtual scrolling

**Database Queries:**
- N+1 query problems in traversal
- Solution: select_related, prefetch_related optimizations

---

## Testing Strategy

### Unit Tests
- BOM traversal algorithms
- Deduplication logic
- Category mapping
- Stock calculations

### Integration Tests
- Full plugin workflows
- API endpoint interactions
- Database queries

### Manual Testing
- Real InvenTree instance
- Real BOMs with complex structures
- Performance testing with large datasets

---

## Documentation Requirements

### Plugin Documentation
- README with screenshots
- Feature descriptions
- Settings configuration
- Usage workflows
- Troubleshooting

### Toolkit Documentation
- API reference
- Function signatures
- Usage examples
- Contributing guide

### Copilot Documentation
- Update PROJECT-CONTEXT.md with architecture
- Update AGENT-BEHAVIOR.md with patterns
- Create plugin-specific COPILOT-GUIDE.md files

---

## Open Questions

### Flat BOM
- [ ] Category mapping UI pattern (single vs multi-select)?
- [ ] Cut-list data sources (where to get lengths)?
- [ ] Cut-list UI placement (separate section vs inline)?

### Purchase List
- [ ] Project code source (BO field exists in 1.1.6)?
- [ ] Multi-BO purchase list support?
- [ ] Supplier part selection logic?

### Build List
- [ ] Placement algorithm details (highest common parent)?
- [ ] Handle existing child BOs (skip, update, show)?
- [ ] Circular dependency detection?

### BO Hierarchy
- [ ] Toolbar integration possible via UserInterfaceMixin?
- [ ] Tree display performance (lazy vs upfront loading)?
- [ ] Filter persistence across views?

### Architecture
- [ ] Frontend shared components worth extracting?
- [ ] When to publish toolkit to PyPI?
- [ ] Multi-workspace support (different InvenTree instances)?

---

## Success Criteria

### Flat BOM v1.0
- Uses InvenTree built-in categories
- Cut-list feature working
- Deployed to production
- Documentation complete

### Purchase List v1.0
- Creates POs with project codes
- Groups by supplier
- Handles allocations correctly
- Tested with real build orders

### Build List v1.0
- Creates child BOs recursively
- Deduplicates correctly
- Stock-aware quantity calculation
- User can select which BOs to create

### BO Hierarchy v1.0
- Tree view displays parent/child relationships
- Integrates with InvenTree UI
- Performance acceptable with 100+ BOs
- Navigation works correctly

---

**Document Owner:** User + GitHub Copilot

**Review Cycle:** Update as decisions are made and implementations progress

**Status Tracking:** Update completion checkboxes as work proceeds
