# No silent auto-creation of missing ancestor Build Orders

A child Build Order can only be created if its immediate parent Build Order already exists or is selected in the same bulk-create action. Build Order Generator does not silently create an ancestor the user did not ask for, so every created order reflects a deliberate human choice.
