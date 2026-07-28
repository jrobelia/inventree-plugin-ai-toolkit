# LCA-merged nodes combine by default

LCA-merged nodes combine by default, and split is an override. Combining reduces Build Order count, which is a core suite goal, and the combined node parents to the common ancestor because the database's parent foreign-key constraint requires it.
