// SidebarViewModel.swift
// Manages the state and logic for the sidebar (left pane).
//
// The sidebar has three sections:
//   1. Smart Filters (All, Favorites, Archive)
//   2. Folders (user-created collections)
//   3. Tags (for tag-based browsing)
//
// The `SidebarSelection` enum represents what the user has selected,
// which drives what the AssetListView displays.

import SwiftUI
import SwiftData

// MARK: - Sidebar Selection

/// Represents the currently selected item in the sidebar.
/// This is the single source of truth for what the list pane shows.
public enum SidebarSelection: Hashable {
    case smartFilter(SmartFilter)
    case folder(Folder)
    case tag(Tag)
}

/// Built-in smart filter options that appear at the top of the sidebar.
public enum SmartFilter: String, CaseIterable, Identifiable {
    case all       = "All Assets"
    case favorites = "Favorites"
    case archive   = "Archive"

    public var id: String { rawValue }

    public var symbolName: String {
        switch self {
        case .all:       return "tray.2"
        case .favorites: return "star"
        case .archive:   return "archivebox"
        }
    }

    public var color: Color {
        switch self {
        case .all:       return .primary
        case .favorites: return .yellow
        case .archive:   return .secondary
        }
    }
}

// MARK: - ViewModel

@Observable
public final class SidebarViewModel {

    // The currently selected sidebar item. Defaults to showing all assets.
    public var selection: SidebarSelection = .smartFilter(.all)

    // Controls the sheet for creating a new folder.
    public var isCreatingFolder: Bool = false

    // Controls the sheet for creating a new tag.
    public var isCreatingTag: Bool = false

    // The folder being renamed (if any).
    public var folderBeingRenamed: Folder? = nil

    // MARK: - Folder Actions

    public init() {}

    public func createFolder(name: String, iconName: String, colorHex: String, in context: ModelContext) {
        let folder = Folder(name: name, iconName: iconName, colorHex: colorHex)
        context.insert(folder)
        selection = .folder(folder)
    }

    public func deleteFolder(_ folder: Folder, in context: ModelContext) {
        // Assets in this folder will have their `folder` set to nil (nullify rule).
        context.delete(folder)
        selection = .smartFilter(.all)
    }

    // MARK: - Tag Actions

    public func createTag(name: String, colorHex: String, in context: ModelContext) {
        let tag = Tag(name: name, colorHex: colorHex)
        context.insert(tag)
        selection = .tag(tag)
    }

    public func deleteTag(_ tag: Tag, in context: ModelContext) {
        context.delete(tag)
        selection = .smartFilter(.all)
    }
}
