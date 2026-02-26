---
applyTo: "**/custom_state*,**/status*"
---

# InvenTree Custom States

Custom states in InvenTree are **database-driven, not plugin-driven**.
Plugins cannot create, modify, or override custom states programmatically.

---

## How Custom States Work

- Created via **Admin Center** (`/admin/` > Custom States), not code
- Supported models: Stock Item, Build Order, Purchase Order, Sales Order,
  Return Order
- Uniqueness constraint: `UNIQUE(model, state, logical_key)`
- Changes require a full page refresh (frontend caches state data)

---

## Adding a Custom State

| Field | Description | Example |
|---|---|---|
| Model | The InvenTree model | `SalesOrder` |
| State | The field on the model | `status` |
| Logical Key | Internal identifier (stable, used in API) | `awaiting_pickup` |
| Name | Human-readable display label | `Awaiting Pickup` |
| Color | UI badge color | `info` |

### Available Colors
`primary` (blue), `secondary` (grey), `success` (green), `warning` (orange),
`danger` (red), `info` (light blue)

---

## Overriding Default Status Colors

Use the **same logical key** as the default state. For example, to make
"Shipped" orange instead of green:

```
Model: SalesOrder | State: status | Logical Key: shipped | Color: warning
```

---

## API Access

```
GET /api/order/so/status/
```

Returns both default and custom states with their colors and labels.

---

## What Plugins CAN Do

- React to status changes via **EventMixin**
- Validate state transitions via **ValidationMixin**
- Provide custom UI for status management via **UserInterfaceMixin**

## What Plugins CANNOT Do

- Create custom states programmatically
- Override status colors through code
- Add new status codes via hooks

---

## Reference

- Docs: https://docs.inventree.org/en/latest/concepts/custom_states/
- Admin: `/admin/` endpoint on your InvenTree instance
