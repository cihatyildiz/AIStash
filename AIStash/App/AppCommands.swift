// AppCommands.swift
// Defines custom macOS menu bar commands for AIStash.
//
// Using SwiftUI's CommandsBuilder, we add items to the native
// macOS menu bar. This is how macOS apps expose keyboard shortcuts
// and actions beyond the standard toolbar.

import SwiftUI

struct AppCommands: Commands {
    var body: some Commands {
        // File menu additions
        CommandGroup(replacing: .newItem) {
            Button("New Asset") {
                NotificationCenter.default.post(name: .createNewAsset, object: nil)
            }
            .keyboardShortcut("n", modifiers: .command)
        }

        CommandGroup(after: .importExport) {
            Button("Export Assets…") {
                NotificationCenter.default.post(name: .exportAssets, object: nil)
            }
            .keyboardShortcut("e", modifiers: [.command, .shift])

            Button("Import Assets…") {
                NotificationCenter.default.post(name: .importAssets, object: nil)
            }
            .keyboardShortcut("i", modifiers: [.command, .shift])
        }
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let createNewAsset = Notification.Name("createNewAsset")
    static let importAssets   = Notification.Name("importAssets")
    static let exportAssets   = Notification.Name("exportAssets")
}
