// ImportExportService.swift
// Handles JSON import and export of assets.
//
// This service is the single point of responsibility for serializing
// and deserializing the app's data to/from JSON. It is implemented
// fully in Phase 4. The protocol and DTO types are defined here
// so the rest of the codebase can reference them without coupling
// to the implementation details.

import Foundation
import SwiftData

// MARK: - Data Transfer Objects (DTOs)
// These are plain Codable structs used for JSON serialization.
// They are intentionally separate from the SwiftData @Model classes
// to avoid coupling the persistence layer to the export format.

public struct AssetDTO: Codable {
    var id: UUID
    var title: String
    var content: String
    var type: String
    var creationDate: Date
    var modificationDate: Date
    var isFavorite: Bool
    var isArchived: Bool
    var folderID: UUID?
    var folderName: String?
    var tagIDs: [UUID]
    var tags: [String]
    var metadata: [String: String]
}

public struct ExportBundle: Codable {
    var version: Int = 1
    var exportDate: Date
    var assets: [AssetDTO]
    var folders: [FolderDTO]
    var tags: [TagDTO]
}

public struct FolderDTO: Codable {
    var id: UUID
    var name: String
    var iconName: String
    var colorHex: String
    var order: Int
}

public struct TagDTO: Codable {
    var id: UUID
    var name: String
    var colorHex: String
}

// MARK: - Service

@MainActor
public final class ImportExportService {

    public static let shared = ImportExportService()
    private init() {}

    // MARK: - Export

    /// Serializes all assets, folders, and tags into a JSON Data blob.
    public func exportAll(assets: [Asset], folders: [Folder], tags: [Tag]) throws -> Data {
        let folderDTOs = folders.map { FolderDTO(id: $0.id, name: $0.name, iconName: $0.iconName, colorHex: $0.colorHex, order: $0.order) }
        let tagDTOs    = tags.map    { TagDTO(id: $0.id, name: $0.name, colorHex: $0.colorHex) }
        let assetDTOs  = assets.map  { asset -> AssetDTO in
            AssetDTO(
                id: asset.id,
                title: asset.title,
                content: asset.content,
                type: asset.typeRawValue,
                creationDate: asset.creationDate,
                modificationDate: asset.modificationDate,
                isFavorite: asset.isFavorite,
                isArchived: asset.isArchived,
                folderID: asset.folder?.id,
                folderName: asset.folder?.name,
                tagIDs: asset.tags.map(\.id),
                tags: asset.tags.map(\.name),
                metadata: asset.metadata
            )
        }
        let bundle = ExportBundle(exportDate: Date(), assets: assetDTOs, folders: folderDTOs, tags: tagDTOs)
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try encoder.encode(bundle)
    }

    // MARK: - Import

    /// Deserializes a JSON Data blob and inserts new assets into the context.
    /// Existing assets (matched by ID) are skipped to avoid duplicates.
    @discardableResult
    public func importBundle(from data: Data, into context: ModelContext) throws -> ImportResult {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let bundle = try decoder.decode(ExportBundle.self, from: data)

        var inserted = 0
        var skipped  = 0

        // Build lookup maps for existing folders and tags by both ID and name.
        var folderMapByID: [UUID: Folder] = [:]
        var folderMap: [String: Folder] = [:]
        var tagMapByID: [UUID: Tag] = [:]
        var tagMap: [String: Tag] = [:]

        // Fetch existing folders and tags to avoid duplicates.
        let existingFolders = (try? context.fetch(FetchDescriptor<Folder>())) ?? []
        let existingTags    = (try? context.fetch(FetchDescriptor<Tag>()))    ?? []
        existingFolders.forEach {
            folderMapByID[$0.id] = $0
            folderMap[$0.name] = $0
        }
        existingTags.forEach {
            tagMapByID[$0.id] = $0
            tagMap[$0.name] = $0
        }

        // Fetch existing asset IDs to detect duplicates.
        let existingAssets = (try? context.fetch(FetchDescriptor<Asset>())) ?? []
        let existingIDs = Set(existingAssets.map(\.id))

        // Insert folders from bundle if they don't exist.
        for dto in bundle.folders {
            if folderMapByID[dto.id] == nil {
                let folder = Folder(id: dto.id, name: dto.name, iconName: dto.iconName, colorHex: dto.colorHex, order: dto.order)
                context.insert(folder)
                folderMapByID[dto.id] = folder
                folderMap[dto.name] = folder
            }
        }

        // Insert tags from bundle if they don't exist.
        for dto in bundle.tags {
            if tagMapByID[dto.id] == nil {
                let tag = Tag(id: dto.id, name: dto.name, colorHex: dto.colorHex)
                context.insert(tag)
                tagMapByID[dto.id] = tag
                tagMap[dto.name] = tag
            }
        }

        // Insert assets, skipping existing ones.
        for dto in bundle.assets {
            if existingIDs.contains(dto.id) {
                skipped += 1
                continue
            }
            let asset = Asset(
                id: dto.id,
                title: dto.title,
                content: dto.content,
                type: AssetType(rawValue: dto.type) ?? .note,
                isFavorite: dto.isFavorite,
                isArchived: dto.isArchived,
                folder: dto.folderID.flatMap { folderMapByID[$0] } ?? dto.folderName.flatMap { folderMap[$0] },
                tags: {
                    if !dto.tagIDs.isEmpty {
                        return dto.tagIDs.compactMap { tagMapByID[$0] }
                    }
                    return dto.tags.compactMap { tagMap[$0] }
                }(),
                metadata: dto.metadata
            )
            // Restore original dates
            asset.creationDate     = dto.creationDate
            asset.modificationDate = dto.modificationDate
            context.insert(asset)
            inserted += 1
        }

        try context.save()
        return ImportResult(inserted: inserted, skipped: skipped)
    }
}

// MARK: - Import Result

public struct ImportResult {
    public let inserted: Int
    public let skipped: Int
}
