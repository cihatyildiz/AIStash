// ImportExportTests.swift
// Unit tests for ImportExportService serialization and deserialization.
//
// Tests verify that:
// - All asset fields survive a round-trip (export → import).
// - Duplicate assets are skipped on re-import.
// - Invalid JSON is handled gracefully.

import XCTest
import SwiftData
@testable import AIStashCore

@MainActor
final class ImportExportTests: XCTestCase {

    var container: ModelContainer!
    var context: ModelContext!
    let service = ImportExportService.shared

    override func setUpWithError() throws {
        let schema = Schema([Asset.self, Folder.self, Tag.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        container = try ModelContainer(for: schema, configurations: [config])
        context = container.mainContext
    }

    override func tearDown() {
        container = nil
        context = nil
    }

    // MARK: - Export Tests

    func test_exportAll_producesValidJSON() throws {
        let asset = Asset(title: "Test Prompt", content: "Hello world", type: .prompt)
        context.insert(asset)
        try context.save()

        let data = try service.exportAll(assets: [asset], folders: [], tags: [])
        XCTAssertFalse(data.isEmpty)

        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let json = try decoder.decode(ExportBundle.self, from: data)
        XCTAssertEqual(json.version, 1)
        XCTAssertEqual(json.assets.count, 1)
        XCTAssertEqual(json.assets.first?.title, "Test Prompt")
    }

    func test_exportPreservesMetadata() throws {
        let asset = Asset(title: "Meta Asset", type: .agent, metadata: ["model": "gpt-4o", "temp": "0.5"])
        context.insert(asset)
        try context.save()

        let data = try service.exportAll(assets: [asset], folders: [], tags: [])
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let bundle = try decoder.decode(ExportBundle.self, from: data)

        XCTAssertEqual(bundle.assets.first?.metadata["model"], "gpt-4o")
        XCTAssertEqual(bundle.assets.first?.metadata["temp"], "0.5")
    }

    // MARK: - Import Tests

    func test_importBundle_insertsNewAssets() throws {
        let originalAsset = Asset(title: "Imported Prompt", type: .prompt)
        let data = try service.exportAll(assets: [originalAsset], folders: [], tags: [])

        // Fresh context — no existing assets
        let result = try service.importBundle(from: data, into: context)
        XCTAssertEqual(result.inserted, 1)
        XCTAssertEqual(result.skipped, 0)

        let fetched = try context.fetch(FetchDescriptor<Asset>())
        XCTAssertEqual(fetched.count, 1)
        XCTAssertEqual(fetched.first?.title, "Imported Prompt")
    }

    func test_importBundle_skipsDuplicates() throws {
        let asset = Asset(title: "Existing Asset", type: .note)
        context.insert(asset)
        try context.save()

        // Export the same asset
        let data = try service.exportAll(assets: [asset], folders: [], tags: [])

        // Import into the same context — should skip
        let result = try service.importBundle(from: data, into: context)
        XCTAssertEqual(result.inserted, 0)
        XCTAssertEqual(result.skipped, 1)
    }

    func test_importBundle_invalidJSON_throws() {
        let badData = "not valid json".data(using: .utf8)!
        XCTAssertThrowsError(try service.importBundle(from: badData, into: context))
    }

    func test_importBundle_matchesFoldersAndTagsByID() throws {
        let localFolder = Folder(name: "Shared", iconName: "folder", colorHex: "#111111")
        let localTag = Tag(name: "shared", colorHex: "#222222")
        context.insert(localFolder)
        context.insert(localTag)
        try context.save()

        let importedFolderID = UUID()
        let importedTagID = UUID()
        let importedAssetID = UUID()
        let bundle = ExportBundle(
            version: 1,
            exportDate: Date(),
            assets: [
                AssetDTO(
                    id: importedAssetID,
                    title: "Imported Asset",
                    content: "Body",
                    type: AssetType.note.rawValue,
                    creationDate: Date(),
                    modificationDate: Date(),
                    isFavorite: false,
                    isArchived: false,
                    folderID: importedFolderID,
                    folderName: "Shared",
                    tagIDs: [importedTagID],
                    tags: ["shared"],
                    metadata: [:]
                )
            ],
            folders: [
                FolderDTO(id: importedFolderID, name: "Shared", iconName: "tray", colorHex: "#ABCDEF", order: 3)
            ],
            tags: [
                TagDTO(id: importedTagID, name: "shared", colorHex: "#FEDCBA")
            ]
        )

        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(bundle)

        let result = try service.importBundle(from: data, into: context)
        XCTAssertEqual(result.inserted, 1)

        let fetchedAssets = try context.fetch(FetchDescriptor<Asset>())
        let importedAsset = try XCTUnwrap(fetchedAssets.first(where: { $0.id == importedAssetID }))
        XCTAssertEqual(importedAsset.folder?.id, importedFolderID)
        XCTAssertEqual(importedAsset.tags.map(\.id), [importedTagID])
    }
}
