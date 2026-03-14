// Folder.swift
// SwiftData model for organizing Assets into named collections.
//
// Folders are the primary organizational unit. An Asset belongs to
// at most one Folder. Deleting a Folder nullifies the folder reference
// on its Assets (they become "unorganized") rather than deleting them.

import Foundation
import SwiftData

@Model
public final class Folder {

    // MARK: - Properties

    public var id: UUID
    public var name: String

    // SF Symbol name for the folder icon, e.g. "folder", "brain", "star"
    public var iconName: String

    // Hex color string for the folder icon tint, e.g. "#FF6B6B"
    public var colorHex: String

    // Used for manual ordering in the sidebar.
    public var order: Int

    public var creationDate: Date

    // MARK: - Relationships

    // One-to-many: a Folder has many Assets.
    // When a Folder is deleted, assets' `folder` property is set to nil.
    @Relationship(deleteRule: .nullify, inverse: \Asset.folder)
    public var assets: [Asset]

    // MARK: - Initializer

    public init(
        id: UUID = UUID(),
        name: String,
        iconName: String = "folder",
        colorHex: String = "#4A90D9",
        order: Int = 0
    ) {
        self.id = id
        self.name = name
        self.iconName = iconName
        self.colorHex = colorHex
        self.order = order
        self.creationDate = Date()
        self.assets = []
    }
}
