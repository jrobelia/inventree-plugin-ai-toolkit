# Tree always reflects live state

The tree recomputes fresh on every panel load and has no explicit resync action. Existing child Build Orders and allocations reduce Outstanding automatically on recompute, and previously committed nodes render as Existing on the next load.
