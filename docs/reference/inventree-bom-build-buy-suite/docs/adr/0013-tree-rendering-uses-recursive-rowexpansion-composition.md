# Tree rendering uses recursive rowExpansion composition

The tree uses recursive composition of separate table instances via single-level `rowExpansion`, not a nested-array/depth-indentation pattern. This matches the `BomTable`/`BomSubassemblyTable` precedent, which is built on `mantine-datatable`, not `mantine-react-table`.
