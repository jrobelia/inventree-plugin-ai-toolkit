# Allocate/Buy uses inline editApiForm, not a modal

Allocate and Buy use inline `editApiForm` rather than a modal, so the tree stays visible while deciding. This is needed to compare LCA sibling-branch quantities, and we accept the dynamic row-height cost over hiding the tree.
