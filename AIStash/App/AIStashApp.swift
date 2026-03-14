// AIStashApp.swift
// The main entry point for the AIStash application.
//
// Responsibilities:
// - Declares the SwiftData model container (the local database).
// - Injects the container into the SwiftUI environment so all views can access it.
// - Seeds sample data on first launch via SeedData.

import SwiftUI
import SwiftData
#if canImport(AIStashCore)
import AIStashCore
#endif

@main
struct AIStashApp: App {

    // The model container is the root of the SwiftData stack.
    // It manages the persistent store (SQLite on disk) for all @Model types.
    let container: ModelContainer

    init() {
        do {
            let schema = Schema([Asset.self, Folder.self, Tag.self])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .modelContainer(container)
                .frame(minWidth: 960, minHeight: 620)
                .onAppear {
                    SeedData.insertIfNeeded(into: container.mainContext)
                }
        }
        .defaultSize(width: 1280, height: 820)
        .windowStyle(.titleBar)
        .windowToolbarStyle(.unified(showsTitle: true))
        .commands {
            AppCommands()
        }
    }
}
