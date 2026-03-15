// AssetListViewModel.swift
// Manages the state and logic for the asset list (middle pane).
//
// Responsibilities:
// - Filtering assets based on the current sidebar selection.
// - Applying the search query (Phase 3).
// - Applying type and tag filters (Phase 3).
// - Creating and deleting assets.
// - Tracking the selected asset for the detail pane.

import SwiftUI
import SwiftData

@Observable
public final class AssetListViewModel {

    // MARK: - State

    /// The asset currently selected in the list. Drives the detail pane.
    public var selectedAsset: Asset? = nil

    /// The current text in the search bar.
    public var searchQuery: String = ""

    /// The asset type filter. nil means "show all types".
    public var typeFilter: AssetType? = nil

    /// Tag filter: only show assets that have ALL of these tags.
    public var tagFilter: Set<Tag> = []

    // MARK: - Derived Filtering

    /// Returns the filtered list of assets based on the current sidebar selection,
    /// search query, type filter, and tag filter.
    ///
    /// Note: We accept the full `assets` array from the @Query in the View
    /// and filter in-memory. For very large datasets, this could be moved
    /// to a predicate-based @Query, but in-memory is simpler and fast enough
    /// for typical use cases (thousands of assets).
    public init() {}

    public func filteredAssets(
        from assets: [Asset],
        selection: SidebarSelection
    ) -> [Asset] {
        var result = assets

        // 1. Apply sidebar selection filter
        switch selection {
        case .smartFilter(let filter):
            switch filter {
            case .all:
                result = result.filter { !$0.isArchived }
            case .favorites:
                result = result.filter { $0.isFavorite && !$0.isArchived }
            case .archive:
                result = result.filter { $0.isArchived }
            }
        case .folder(let folder):
            result = result.filter { $0.folder?.id == folder.id && !$0.isArchived }
        case .tag(let tag):
            result = result.filter { asset in
                asset.tags.contains(where: { $0.id == tag.id }) && !asset.isArchived
            }
        }

        // 2. Apply type filter
        if let typeFilter {
            result = result.filter { $0.assetType == typeFilter }
        }

        // 3. Apply tag filter
        if !tagFilter.isEmpty {
            let tagIDs = tagFilter.map(\.id)
            result = result.filter { asset in
                tagIDs.allSatisfy { id in asset.tags.contains(where: { $0.id == id }) }
            }
        }

        // 4. Apply search query
        if !searchQuery.trimmingCharacters(in: .whitespaces).isEmpty {
            let q = searchQuery.lowercased()
            result = result.filter {
                $0.title.lowercased().contains(q) ||
                $0.content.lowercased().contains(q) ||
                $0.tags.contains(where: { $0.name.lowercased().contains(q) })
            }
        }

        // 5. Sort: favorites first, then by modification date descending
        return result.sorted {
            if $0.isFavorite != $1.isFavorite { return $0.isFavorite }
            return $0.modificationDate > $1.modificationDate
        }
    }

    // MARK: - Asset Actions

    public func createAsset(in context: ModelContext, folder: Folder? = nil) -> Asset {
        let asset = Asset(title: "Untitled", type: .note, folder: folder)
        context.insert(asset)
        selectedAsset = asset
        return asset
    }

    public func deleteAsset(_ asset: Asset, in context: ModelContext) {
        guard asset.isLocked != true else { return }
        if selectedAsset?.id == asset.id {
            selectedAsset = nil
        }
        context.delete(asset)
    }

    public func toggleFavorite(_ asset: Asset) {
        asset.isFavorite.toggle()
        asset.touch()
    }

    public func toggleArchive(_ asset: Asset) {
        asset.isArchived.toggle()
        asset.touch()
        if asset.isArchived && selectedAsset?.id == asset.id {
            selectedAsset = nil
        }
    }

    public func toggleLock(_ asset: Asset) {
        asset.isLocked = !(asset.isLocked ?? false)
        asset.touch()
    }

    // MARK: - Filter Helpers

    public func clearFilters() {
        searchQuery = ""
        typeFilter = nil
        tagFilter = []
    }

    public var hasActiveFilters: Bool {
        typeFilter != nil || !tagFilter.isEmpty || !searchQuery.isEmpty
    }
}
