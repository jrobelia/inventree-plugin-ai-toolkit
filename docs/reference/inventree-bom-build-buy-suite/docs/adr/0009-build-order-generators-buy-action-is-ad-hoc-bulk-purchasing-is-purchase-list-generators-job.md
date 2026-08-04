# Build Order Generator's Buy action is ad-hoc; bulk purchasing is Purchase List Generator's job

Build Order Generator's Buy action is one-off and single-node; bulk purchasing belongs to Purchase List Generator. The one required sync point is that Purchase List Generator's shortfall calculation reads live open purchase orders the same way Build Order Generator's netting does, so it does not re-propose a part already bought ad-hoc.
