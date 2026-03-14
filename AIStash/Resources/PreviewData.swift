// PreviewData.swift
// Provides in-memory sample data for SwiftUI Previews.
//
// Using a real ModelContainer in preview mode ensures previews are
// accurate representations of the real app. The `inMemory: true`
// flag prevents preview data from polluting the real database.

import SwiftUI
import SwiftData
#if canImport(AIStashCore)
import AIStashCore
#endif

@MainActor
enum PreviewData {

    /// A pre-configured in-memory ModelContainer with sample data.
    static let container: ModelContainer = {
        let schema = Schema([Asset.self, Folder.self, Tag.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: schema, configurations: [config])
        SeedData.insertIfNeeded(into: container.mainContext)
        return container
    }()

    /// A single sample asset for component-level previews.
    static let sampleAsset: Asset = {
        let asset = Asset(
            title: "System Prompt: Helpful Assistant",
            content: "You are a helpful, harmless, and honest AI assistant.",
            type: .prompt,
            isFavorite: true,
            metadata: ["model": "gpt-4o", "temperature": "0.7"]
        )
        return asset
    }()

    /// A sample tag for component-level previews.
    static let sampleTag: Tag = Tag(name: "gpt-4o", colorHex: "#10A37F")
}
