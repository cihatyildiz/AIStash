// Tag+Hashable.swift
// Extends Tag to conform to Hashable and Equatable so it can be used
// in Sets (for the tagFilter in AssetListViewModel).
//
// SwiftData @Model classes do not automatically synthesize Hashable.
// We implement it based on the stable `id` property.

import Foundation

extension Tag: Hashable {
    public static func == (lhs: Tag, rhs: Tag) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
