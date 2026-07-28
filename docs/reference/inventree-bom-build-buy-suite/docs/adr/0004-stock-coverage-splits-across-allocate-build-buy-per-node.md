# Stock coverage splits across Allocate/Build/Buy per node

We use a per-node Commit Decision model instead of a single binary "build all vs. build net" choice. Any mix of allocate, build, and buy can be written atomically per node, though the v1 MVP only bulk-creates Build Orders.
