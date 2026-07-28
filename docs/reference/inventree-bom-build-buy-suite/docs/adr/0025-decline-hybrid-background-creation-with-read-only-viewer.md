# Decline hybrid background creation with read-only viewer

We declined a hybrid model that forks `AutoCreateBuildsPlugin` to create Build Orders in the background and shows a read-only tree afterward. Background-created Build Orders are real database objects that are hard to reverse, LCA merging would become post-hoc cleanup, it would require a second netting implementation, and the visibility problem is better solved by a visibility-first design.
