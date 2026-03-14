// Asset.swift
// The core SwiftData model representing any AI-related asset.
//
// This is the central entity of the app. Every prompt, skill, agent,
// workflow, template, or note is an Asset. Relationships to Folder and Tag
// are declared here and managed by SwiftData automatically.

import Foundation
import SwiftData

@Model
public final class Asset {

    // MARK: - Identity

    public var id: UUID
    public var title: String
    public var content: String

    // Stored as a raw String to avoid SwiftData enum migration issues.
    // Use the `assetType` computed property for type-safe access.
    public var typeRawValue: String

    // MARK: - Timestamps

    public var creationDate: Date
    public var modificationDate: Date

    // MARK: - Status Flags

    public var isFavorite: Bool
    public var isArchived: Bool

    // MARK: - Relationships

    // The folder this asset belongs to. Optional — assets can be unorganized.
    public var folder: Folder?

    // Many-to-many relationship with Tag.
    // SwiftData manages the join table automatically.
    @Relationship(deleteRule: .nullify, inverse: \Tag.assets)
    public var tags: [Tag]

    // MARK: - Flexible Metadata

    // A simple dictionary for storing arbitrary key-value pairs,
    // e.g., {"model": "gpt-4o", "temperature": "0.7", "source_url": "..."}
    // Stored as JSON-encoded Data internally.
    public var metadataJSON: Data?

    // MARK: - Computed Properties

    public var assetType: AssetType {
        get { AssetType(rawValue: typeRawValue) ?? .note }
        set { typeRawValue = newValue.rawValue }
    }

    public var metadata: [String: String] {
        get {
            guard let data = metadataJSON,
                  let dict = try? JSONDecoder().decode([String: String].self, from: data)
            else { return [:] }
            return dict
        }
        set {
            metadataJSON = try? JSONEncoder().encode(newValue)
        }
    }

    // MARK: - Initializer

    public init(
        id: UUID = UUID(),
        title: String = "Untitled",
        content: String = "",
        type: AssetType = .note,
        isFavorite: Bool = false,
        isArchived: Bool = false,
        folder: Folder? = nil,
        tags: [Tag] = [],
        metadata: [String: String] = [:]
    ) {
        self.id = id
        self.title = title
        self.content = content
        self.typeRawValue = type.rawValue
        self.creationDate = Date()
        self.modificationDate = Date()
        self.isFavorite = isFavorite
        self.isArchived = isArchived
        self.folder = folder
        self.tags = tags
        self.metadataJSON = try? JSONEncoder().encode(metadata)
    }

    /// Call this whenever the asset is edited to keep modificationDate current.
    public func touch() {
        modificationDate = Date()
    }
}
