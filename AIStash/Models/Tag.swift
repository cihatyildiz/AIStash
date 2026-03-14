// Tag.swift
// SwiftData model for tagging Assets with descriptive labels.
//
// Tags have a many-to-many relationship with Assets. A single Tag
// can be applied to many Assets, and a single Asset can have many Tags.
// SwiftData manages the join table automatically via the @Relationship
// declared on Asset.

import Foundation
import SwiftData

@Model
public final class Tag {

    // MARK: - Properties

    public var id: UUID
    public var name: String

    // Hex color string for the tag chip color, e.g. "#FF6B6B"
    public var colorHex: String

    public var creationDate: Date

    // MARK: - Relationships

    // This is the inverse side of the many-to-many.
    // SwiftData uses both sides to build the relationship graph.
    public var assets: [Asset]

    // MARK: - Initializer

    public init(
        id: UUID = UUID(),
        name: String,
        colorHex: String = "#888888"
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.creationDate = Date()
        self.assets = []
    }
}
