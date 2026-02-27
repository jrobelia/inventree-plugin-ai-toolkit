# Build Order BOM Viewer Plugin - Implementation Plan

> **Status:** Planning Phase  
> **Approach:** Copy-and-modify FlatBOMGenerator, refactor to shared library later  
> **Backup:** Create copy of entire project before starting

---

## Plugin Overview

**Name:** BuildOrderBOMViewer  
**Purpose:** Display flat BOM with stock analysis within an open Build Order, with ability to order required parts directly

**Key Difference from FlatBOMGenerator:**
- **Context:** Build Order page (not Part page)
- **Quantity:** Auto-populated from BO.quantity (not user input)
- **New Feature:** "Order Parts" button to create/add to Purchase Orders
- **Filtering:** Potentially exclude parts already allocated to this specific BO

---

## Phase 1: Research InvenTree Source Code

### 1.1 Build Order Panel Integration

**Files to examine:**
```
reference/inventree-source/src/backend/InvenTree/build/
├── models.py           # Build model structure
├── api.py              # Build Order API endpoints
└── serializers.py      # BO data serialization

reference/inventree-source/src/frontend/src/pages/build/
├── BuildDetail.tsx     # Build order detail page
└── BuildOrderDetail.tsx
```

**Questions to answer:**
- How do panels register for Build Order context?
- What data is available in `context.instance` for a Build Order?
- How to access BO.quantity, BO.part, BO.reference?

### 1.2 Purchase Order Creation

**Files to examine:**
```
reference/inventree-source/src/backend/InvenTree/order/
├── models.py           # PurchaseOrder, PurchaseOrderLineItem models
├── api.py              # PO creation endpoints
└── serializers.py      # PO data structure

reference/inventree-source/src/frontend/src/pages/purchasing/
└── PurchaseOrderDetail.tsx
```

**Questions to answer:**
- API endpoint for creating PurchaseOrder?
- API endpoint for adding line items to existing PO?
- Required fields (supplier, part, quantity, reference)?
- How does "Required Parts" panel implement ordering?

### 1.3 Part Allocation to Build Orders

**Files to examine:**
```
reference/inventree-source/src/backend/InvenTree/build/models.py
# Look for: BuildItem, StockItem.allocateToCustomer, etc.
```

**Questions to answer:**
- How to check if parts are already allocated to THIS build order?
- Should we exclude allocated stock from shortfall?
- Can we show "Allocated to This BO" column?

---

## Phase 2: Copy and Rename

### 2.1 Create Plugin Folder

```powershell
# From toolkit root
Copy-Item -Path "plugins/FlatBOMGenerator" -Destination "plugins/BuildOrderBOMViewer" -Recurse

# Remove git history from copy
Remove-Item -Path "plugins/BuildOrderBOMViewer/.git" -Recurse -Force
```

### 2.2 Rename Package

**Files to update:**
```
plugins/BuildOrderBOMViewer/
├── pyproject.toml                          # name, description
├── setup.cfg                               # name, metadata
├── build_order_bom_viewer/                 # RENAME from flat_bom_generator/
│   ├── __init__.py
│   ├── core.py                             # Plugin class name
│   ├── views.py                            # ViewSet name, URL routing
│   ├── bom_traversal.py                    # (no changes needed)
│   └── categorization.py                   # (no changes needed)
└── frontend/
    ├── package.json                        # name field
    └── src/
        └── Panel.tsx                       # Component name
```

**Naming convention:**
- Package: `inventree-build-order-bom-viewer`
- Python module: `build_order_bom_viewer`
- Plugin class: `BuildOrderBOMViewerPlugin`
- API ViewSet: `BuildOrderBOMView`
- React component: `BuildOrderBOMPanel`

### 2.3 File-by-file Rename Checklist

#### `pyproject.toml`
```toml
[project]
name = "inventree-build-order-bom-viewer"
description = "InvenTree plugin to view flat BOM for build orders with purchasing integration"
```

#### `setup.cfg`
```ini
[metadata]
name = inventree-build-order-bom-viewer
description = InvenTree plugin to view flat BOM for build orders with purchasing integration
```

#### `build_order_bom_viewer/core.py`
```python
class BuildOrderBOMViewerPlugin(PanelMixin, SettingsMixin, InvenTreePlugin):
    NAME = "BuildOrderBOMViewer"
    SLUG = "buildorderbomviewer"
    TITLE = "Build Order BOM Viewer"
    DESCRIPTION = "View flat BOM with stock analysis for build orders"
```

#### `build_order_bom_viewer/views.py`
```python
class BuildOrderBOMView(APIView):
    # API endpoint: /api/plugin/buildorderbomviewer/build-bom/<build_id>/
```

#### `frontend/package.json`
```json
{
  "name": "buildorderbomviewer-frontend",
  "description": "Frontend for Build Order BOM Viewer plugin"
}
```

#### `frontend/src/Panel.tsx`
```typescript
export default function BuildOrderBOMPanel({ context }: PanelProps) {
```

---

## Phase 3: Modify for Build Order Context

### 3.1 Update Panel Registration

**In `core.py`:**
```python
def get_panel_context(self, view, request, context):
    """Register panel for Build Order detail pages"""
    ctx = super().get_panel_context(view, request, context)
    
    # Only show on Build Order detail pages
    if view == 'build-detail':
        ctx['enabled'] = True
    
    return ctx

def get_custom_panels(self, view, request):
    """Define panel for Build Order pages"""
    panels = []
    
    if view == 'build-detail':
        panels.append({
            'title': 'Flat BOM Analysis',
            'description': 'View required parts with stock analysis',
            'icon': 'list',
            'content_template': 'buildorderbomviewer/panel.html',
            'javascript_template': 'buildorderbomviewer/panel.js',
        })
    
    return panels
```

### 3.2 Update API Endpoint

**In `views.py`:**
```python
# Change from part_id to build_id
def get(self, request, build_id, *args, **kwargs):
    """
    Get flattened BOM for a specific build order.
    
    Args:
        build_id: Build Order ID to get flat BOM for
        
    Returns:
        List of unique leaf parts with total quantities scaled by BO quantity
    """
    from build.models import Build
    
    try:
        build_order = Build.objects.select_related('part').get(pk=build_id)
        
        if not build_order.part.assembly:
            return Response(
                {'error': 'Build order part is not an assembly'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Get BOM for the build order's part
        part_id = build_order.part.pk
        build_quantity = build_order.quantity  # Use BO quantity
        
        # Generate flat BOM
        flat_bom = get_flat_bom(part_id, max_depth=None)
        
        # Scale quantities by build order quantity
        for item in flat_bom:
            item['total_qty'] = item['total_qty'] * build_quantity
        
        # Enrich with stock data (same as FlatBOM)
        enriched_bom = []
        for item in flat_bom:
            # ... enrichment logic ...
            
        return Response({
            'build_id': build_id,
            'build_reference': build_order.reference,
            'build_quantity': build_quantity,
            'part_id': part_id,
            'part_name': build_order.part.name,
            'ipn': build_order.part.IPN or '',
            'total_unique_parts': len(enriched_bom),
            'bom_items': enriched_bom
        }, status=status.HTTP_200_OK)
        
    except Build.DoesNotExist:
        return Response(
            {'error': 'Build order not found'},
            status=status.HTTP_404_NOT_FOUND
        )
```

### 3.3 Update Frontend Panel

**In `Panel.tsx`:**

Remove build quantity input (read from context):
```typescript
export default function BuildOrderBOMPanel({ context }: PanelProps) {
    const [loading, setLoading] = useState(false);
    const [bomData, setBomData] = useState<BomItem[] | null>(null);
    
    // Get build order data from context
    const buildId = context.instance?.pk;
    const buildQuantity = context.instance?.quantity || 1;
    const buildReference = context.instance?.reference || '';
    
    // Remove buildQuantity state - it's fixed from BO
    
    const fetchBomData = async () => {
        setLoading(true);
        try {
            const response = await fetch(
                `/api/plugin/buildorderbomviewer/build-bom/${buildId}/`,
                {
                    headers: {
                        'Authorization': `Token ${userToken}`
                    }
                }
            );
            // ... rest of fetch logic
        }
    };
    
    // Remove NumberInput for build quantity
    // Show build reference and quantity as read-only info
    return (
        <>
            <Text size="sm" c="dimmed">
                Build Order: {buildReference} (Qty: {buildQuantity})
            </Text>
            
            {/* Rest of UI - remove build qty controls */}
        </>
    );
}
```

---

## Phase 4: Add Purchase Order Creation Feature

### 4.1 Research Findings

> **TODO:** Document findings from InvenTree source code research  
> - PO creation API endpoint  
> - Required fields  
> - Line item structure  
> - How to batch-add multiple parts  

### 4.2 Add "Order Parts" Button

**UI mockup:**
```
[Generate Flat BOM]  [Include Allocations ☑] [Include On Order ☑]  [Order Selected Parts] [Export CSV]
```

**Features:**
- Checkbox column to select parts to order
- "Order Selected Parts" button (disabled if none selected)
- Opens modal to:
  - Select existing PO or create new one
  - Confirm quantities
  - Set reference/notes
- Shows success/error feedback

### 4.3 Backend API for PO Creation

**New endpoint in `views.py`:**
```python
class CreatePurchaseOrderView(APIView):
    """
    Create purchase order line items for selected parts
    """
    permission_classes = [IsAuthenticated]
    
    def post(self, request, *args, **kwargs):
        """
        Create PO line items for parts with shortfall
        
        Request body:
        {
            "build_id": 123,
            "purchase_order_id": 456,  // Optional - create new if omitted
            "supplier_id": 789,         // Required if creating new PO
            "parts": [
                {"part_id": 111, "quantity": 10},
                {"part_id": 222, "quantity": 5}
            ]
        }
        """
        from order.models import PurchaseOrder, PurchaseOrderLineItem
        
        # Validate and create PO items
        # ... implementation based on research ...
```

### 4.4 Frontend PO Creation Modal

**New component: `OrderPartsModal.tsx`**
```typescript
interface OrderPartsModalProps {
    opened: boolean;
    onClose: () => void;
    selectedParts: BomItem[];
    buildId: number;
}

function OrderPartsModal({ opened, onClose, selectedParts, buildId }: OrderPartsModalProps) {
    // Modal to:
    // 1. Select or create PO
    // 2. Confirm quantities
    // 3. Submit order
}
```

---

## Phase 5: Additional Enhancements

### 5.1 Show Parts Already Allocated to This BO

**New column:** "Allocated to This BO"
- Query `BuildItem` model for allocations
- Show allocated quantity
- Exclude from shortfall calculation (optional toggle)

### 5.2 Filter Options

**Additional checkboxes:**
- ☑ Show only parts with shortfall
- ☑ Group by supplier
- ☑ Hide parts already ordered

### 5.3 Bulk Actions

**Buttons:**
- "Allocate Available Stock" - Auto-allocate stock to this BO
- "Order All Shortfall" - Create PO for all parts needing order
- "Export for Supplier" - CSV grouped by default supplier

---

## Phase 6: Testing Checklist

### 6.1 Backend Tests
- [ ] API endpoint returns correct data for build order
- [ ] Quantities correctly scaled by BO quantity
- [ ] Stock calculations match FlatBOM plugin
- [ ] PO creation endpoint works
- [ ] Error handling (invalid build_id, permissions)

### 6.2 Frontend Tests
- [ ] Panel appears on Build Order detail page
- [ ] Build quantity read from context correctly
- [ ] Table displays all columns correctly
- [ ] Checkboxes affect calculations as expected
- [ ] Search and sorting work
- [ ] Order parts modal opens and functions
- [ ] CSV export includes all data

### 6.3 Integration Tests
- [ ] Create build order → panel shows correct BOM
- [ ] Change BO quantity → panel reflects new quantities
- [ ] Order parts → PO created with correct items
- [ ] Allocate stock → "Allocated to BO" column updates

---

## Phase 7: Documentation

### 7.1 Update README.md

**Sections:**
- Plugin purpose and use case
- How it differs from FlatBOMGenerator
- Purchase order creation workflow
- Column descriptions (including BO-specific ones)
- Screenshots of panel and order modal

### 7.2 Update COPILOT-GUIDE.md

**Add sections:**
- Build Order context integration
- PO creation API details
- Differences from FlatBOMGenerator
- Order parts workflow

---

## Refactoring Plan (Future)

### When to Refactor to Shared Library

**Triggers:**
- Both plugins working well
- Need to add third plugin (e.g., Sales Order BOM)
- Bug fixes getting tedious to apply twice
- New feature needed in both plugins

### Refactoring Steps

1. **Create `inventree-bom-toolkit` package**
   ```
   plugins/inventree-bom-toolkit/
   ├── bom_toolkit/
   │   ├── traversal.py
   │   ├── categorization.py
   │   ├── calculations.py
   │   └── components/      # Shared React components
   ├── pyproject.toml
   └── README.md
   ```

2. **Extract common code:**
   - BOM traversal algorithms
   - Part categorization
   - Stock calculations
   - DataTable component
   - Stats panel component

3. **Make plugins depend on toolkit:**
   ```toml
   # In each plugin's pyproject.toml
   dependencies = [
       "inventree-bom-toolkit>=0.1.0"
   ]
   ```

4. **Thin out plugin code:**
   - Plugins become ~200 lines each
   - Only context-specific logic remains
   - Import from `bom_toolkit`

---

## Questions to Resolve

### Before Starting
- [ ] Should we exclude parts already allocated to THIS build order from shortfall?
- [ ] How to handle partial allocations? (e.g., 5 allocated, need 10)
- [ ] Should "Order Parts" create new PO or add to existing?
- [ ] Do we need approval workflow for PO creation?

### During Development
- [ ] How to handle parts with multiple suppliers?
- [ ] Should we batch by supplier automatically?
- [ ] What permissions are needed for PO creation?
- [ ] How to handle parts that can't be purchased (Fab parts)?

---

## Success Criteria

### Minimum Viable Product (MVP)
- [ ] Panel appears on Build Order detail page
- [ ] Displays flat BOM with stock analysis
- [ ] Quantities auto-scaled by BO quantity
- [ ] All calculations match FlatBOMGenerator
- [ ] CSV export works

### Full Feature Set
- [ ] "Order Parts" button creates PO line items
- [ ] Shows parts allocated to this BO
- [ ] Filter and search work correctly
- [ ] Documentation complete
- [ ] Tested with real build orders

### Polish
- [ ] UI matches InvenTree design
- [ ] Error handling is robust
- [ ] Loading states are smooth
- [ ] Tooltips explain features
- [ ] Keyboard shortcuts work

---

## Timeline Estimate

**Phase 1 (Research):** 2-4 hours  
**Phase 2 (Copy/Rename):** 1-2 hours  
**Phase 3 (BO Integration):** 3-5 hours  
**Phase 4 (PO Creation):** 4-8 hours  
**Phase 5 (Enhancements):** 2-4 hours  
**Phase 6 (Testing):** 2-3 hours  
**Phase 7 (Documentation):** 1-2 hours  

**Total:** ~15-28 hours (2-4 days of focused work)

---

## Next Steps

1. **Create backup** of entire project
2. **Start Phase 1** - Research InvenTree source code
3. **Document findings** in this file
4. **Review plan** before proceeding to Phase 2
5. **Get approval** on approach and feature scope

---

## Notes

- Keep FlatBOMGenerator unchanged during development
- Test BuildOrderBOMViewer independently
- Consider creating staging branch for BO plugin work
- Document any InvenTree API quirks discovered
- Take screenshots for documentation as you build
