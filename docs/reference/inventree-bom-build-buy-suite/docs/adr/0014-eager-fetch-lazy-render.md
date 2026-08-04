# Eager fetch, lazy render

The full tree is computed server-side in one call on panel load, so the rollup badge is computed rather than manually expanded. Rendering still uses `rowExpansion`, but each expansion reads from the already-fetched branch data instead of refetching per expand.
