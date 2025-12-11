# InvenTree Custom States Guide

**Audience:** Users and AI Agents | **Category:** InvenTree Knowledge Base | **Purpose:** Understanding and implementing InvenTree custom states | **Last Updated:** 2025-12-10

---

## Overview

InvenTree supports custom states for several models (Stock Items, Build Orders, Purchase Orders, Sales Orders, Return Orders). **Custom states are NOT created through plugins** - they are database entries added through the Admin Center.

## Important Discovery

The reference plugin approach using `extra_sales_order_status_codes()` hook **does not exist in InvenTree**. After extensive research of the InvenTree source code and documentation, custom states must be created through the Admin UI, not programmatically via plugins.

## How to Add Custom States

### Step 1: Access Admin Center

1. Log into your InvenTree instance
2. Navigate to **Admin** (Django admin panel) - usually at `/admin/`
3. You need superuser/admin permissions

### Step 2: Navigate to Custom States

1. In the Admin Center, find the **Custom States** section
2. Click on **Custom States** to view existing states

### Step 3: Add a New Custom State

Click "Add Custom State" and fill in:

| Field | Description | Example (Override Shipped Color) |
|-------|-------------|----------------------------------|
| **Model** | The InvenTree model | `SalesOrder` |
| **State** | The field on the model | `status` |
| **Logical Key** | Internal identifier used in code | `shipped` (to override default) |
| **Name** | Human-readable display name | `Shipped` |
| **Color** | Visual color in UI | `warning` (orange) or `success` (green) |

### Step 4: Apply Changes

1. Click "Save"
2. **Reload the InvenTree web interface** (full page refresh)
3. Changes to custom states require a full UI reload to take effect

## Override Existing Status Colors

To override the color of an existing status like "Shipped":

1. Use the **same logical key** as the default state
2. For Sales Order "Shipped", the logical key is: `shipped`
3. Change the **color** field to your desired value
4. The custom state will override the default

### Available Colors

- `primary` - Blue
- `secondary` - Gray
- `success` - Green
- `warning` - Orange
- `danger` - Red
- `info` - Light blue

## Add New Custom States

To add completely new states (not overriding defaults):

1. Choose a **unique logical key** (e.g., `awaiting_pickup`, `ready_for_collection`)
2. Provide a descriptive **name** for the UI
3. Select appropriate **color**
4. Assign to the correct **model** and **state** field

## Uniqueness Constraints

InvenTree enforces uniqueness using a composite key:
- **Database constraint**: `UNIQUE(model, state, logical_key)`
- You **cannot** have two states with the same logical key for the same model/state combination
- You **can** reuse names across different models
- The **logical key** should be stable and used in API calls/business logic

## Example: Sales Order Custom States

### Override "Shipped" to Orange

```
Model: SalesOrder
State: status  
Logical Key: shipped
Name: Shipped
Color: warning
```

### Add "Awaiting Pickup" State

```
Model: SalesOrder
State: status
Logical Key: awaiting_pickup
Name: Awaiting Pickup
Color: info
```

### Add "Ready for Collection" State

```
Model: SalesOrder
State: status
Logical Key: ready_for_collection
Name: Ready for Collection  
Color: primary
```

## Verification

After adding custom states:

1. Go to a Sales Order in InvenTree
2. Click the status dropdown
3. Your custom states should appear in the list
4. Select a custom state and save
5. The status badge should display with your custom color

## Troubleshooting

### Custom states don't appear in UI
- **Solution**: Perform a full page refresh (Ctrl+F5 or Cmd+Shift+R)
- Custom states are cached in the frontend

### "Logical key already exists" error
- **Cause**: Another state already uses that logical key for the same model
- **Solution**: Choose a different logical key or edit the existing state

### Changes not visible
- **Check**: Ensure you saved the custom state in Admin Center
- **Check**: Verify you reloaded the web interface
- **Check**: Check browser console for errors

## API Access

Custom states are accessible via the InvenTree API:

```bash
# Get all status codes for Sales Orders
GET /api/order/so/status/

# The response includes both default and custom states
{
  "values": {
    "10": {"key": "pending", "label": "Pending", "color": "secondary"},
    "20": {"key": "shipped", "label": "Shipped", "color": "warning"},  # Custom override
    "25": {"key": "awaiting_pickup", "label": "Awaiting Pickup", "color": "info"}  # Custom state
  }
}
```

## Plugin Limitations

**Plugins cannot**:
- Programmatically create custom states
- Override status colors through code
- Add new status codes via hooks

**Plugins can**:
- React to status changes via Event Mixin
- Validate state transitions via Validation Mixin  
- Provide custom UI for status management

## Reference

- InvenTree Documentation: https://docs.inventree.org/en/latest/concepts/custom_states/
- Supported Models: Stock Item, Build Order, Purchase Order, Sales Order, Return Order
- Admin Center: `/admin/` endpoint on your InvenTree instance

## Conclusion

The `OASalesOrderStatusColor` plugin created in this toolkit was based on incorrect assumptions about InvenTree's architecture. Custom state management in InvenTree is:

1. **Database-driven** (not code-driven)
2. **Admin UI-based** (not plugin hook-based)
3. **Display-only** (doesn't affect business logic)

For changing status colors or adding custom states, use the **Admin Center → Custom States** interface instead of creating a plugin.
