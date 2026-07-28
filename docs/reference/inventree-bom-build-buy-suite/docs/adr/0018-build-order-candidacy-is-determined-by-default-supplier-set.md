# Build Order candidacy is determined by default supplier set

A part is a Build Order candidate when it has no default supplier set, regardless of the `purchasable` flag. The `purchasable` flag only marks whether a part can be bought, not whether a committed source actually exists.
