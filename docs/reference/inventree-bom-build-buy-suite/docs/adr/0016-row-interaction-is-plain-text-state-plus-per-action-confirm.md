# Row interaction is plain-text state plus per-action confirm

A row shows its current state as plain text, and each action has its own confirm step, instead of a single "Commit Decision" button. The old checkbox bundled a one-click action with two multi-field decisions and implied Build was optional when doing nothing already means build the full outstanding. A remaining open question is the exact state transition from Draft to Existing once the actions are no longer atomic.
