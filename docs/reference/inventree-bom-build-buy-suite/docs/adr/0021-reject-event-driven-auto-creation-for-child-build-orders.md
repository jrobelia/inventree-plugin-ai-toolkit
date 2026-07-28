# Reject event-driven auto-creation for child Build Orders

We considered a forked `AutoCreateBuildsPlugin` with a three-way dispatch field, but rejected it. Event-driven automation directly contradicts Build Order Generator's human-in-the-loop Commit Decision model, so child Build Orders will not be created automatically in the background.
