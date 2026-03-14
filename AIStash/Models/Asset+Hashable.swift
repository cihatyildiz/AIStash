// Asset+Hashable.swift
// Extends Asset to conform to Hashable and Equatable so it can be used
// as a List selection type in SwiftUI.
//
// Identity is based solely on `id` (UUID), which is stable and unique.

import Foundation

extension Asset: Hashable {
    public static func == (lhs: Asset, rhs: Asset) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
