// AssetListView.swift
// The middle pane showing a filtered, searchable list of assets.
//
// Phase 3 additions:
// - Replaced inline search with the reusable SearchBar component.
// - Added the collapsible FilterPanel for type and tag filters.
// - Added a sort menu (by modification date, creation date, title).
// - Added group-by-type view mode.

import SwiftUI
import SwiftData
#if canImport(AIStashCore)
import AIStashCore
#endif

// MARK: - Sort Options

enum AssetSortOrder: String, CaseIterable, Identifiable {
    case modifiedDesc  = "Recently Modified"
    case modifiedAsc   = "Oldest Modified"
    case createdDesc   = "Newest First"
    case createdAsc    = "Oldest First"
    case titleAsc      = "Title A → Z"
    case titleDesc     = "Title Z → A"

    var id: String { rawValue }
}

// MARK: - View

struct AssetListView: View {

    @Bindable var viewModel: AssetListViewModel
    let sidebarSelection: SidebarSelection
    let allAssets: [Asset]
    let allTags: [Tag]

    @Environment(\.modelContext) private var context

    @State private var sortOrder: AssetSortOrder = .modifiedDesc
    @State private var groupByType: Bool = false

    // MARK: - Computed

    private var displayedAssets: [Asset] {
        let filtered = viewModel.filteredAssets(from: allAssets, selection: sidebarSelection)
        return sorted(filtered)
    }

    private var navigationTitle: String {
        switch sidebarSelection {
        case .smartFilter(let f): return f.rawValue
        case .folder(let f):     return f.name
        case .tag(let t):        return "#\(t.name)"
        }
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 0) {
            searchBar
            FilterPanel(
                typeFilter: $viewModel.typeFilter,
                tagFilter: $viewModel.tagFilter,
                availableTags: allTags,
                onClear: { viewModel.clearFilters() }
            )
            assetList
        }
        .navigationTitle(navigationTitle)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                sortMenu
                groupToggle
                newAssetButton
            }
        }
    }

    // MARK: - Search Bar

    private var searchBar: some View {
        SearchBar(text: $viewModel.searchQuery, placeholder: "Search assets…")
            .padding(.horizontal, 12)
            .padding(.top, 10)
            .padding(.bottom, 6)
    }

    // MARK: - Asset List

    private var assetList: some View {
        Group {
            if displayedAssets.isEmpty {
                emptyState
            } else if groupByType {
                groupedList
            } else {
                flatList
            }
        }
    }

    private var flatList: some View {
        List(displayedAssets, selection: Binding(
            get: { viewModel.selectedAsset },
            set: { viewModel.selectedAsset = $0 }
        )) { asset in
            AssetRowView(asset: asset)
                .tag(asset)
                .contextMenu { contextMenu(for: asset) }
        }
        .listStyle(.plain)
    }

    private var groupedList: some View {
        List(selection: Binding(
            get: { viewModel.selectedAsset },
            set: { viewModel.selectedAsset = $0 }
        )) {
            ForEach(AssetType.allCases) { type in
                let group = displayedAssets.filter { $0.assetType == type }
                if !group.isEmpty {
                    Section {
                        ForEach(group) { asset in
                            AssetRowView(asset: asset)
                                .tag(asset)
                                .contextMenu { contextMenu(for: asset) }
                        }
                    } header: {
                        Label(type.rawValue, systemImage: type.symbolName)
                            .foregroundStyle(type.color)
                            .font(.caption)
                            .fontWeight(.semibold)
                    }
                }
            }
        }
        .listStyle(.sidebar)
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: viewModel.hasActiveFilters ? "magnifyingglass" : "tray")
                .font(.system(size: 40))
                .foregroundStyle(.tertiary)
            Text(viewModel.hasActiveFilters ? "No results found" : "No assets yet")
                .font(.headline)
                .foregroundStyle(.secondary)
            if viewModel.hasActiveFilters {
                Text("Try adjusting your search or filters")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                Button("Clear Filters") { viewModel.clearFilters() }
                    .buttonStyle(.bordered)
            } else {
                Text("Press ⌘N to create your first asset")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Toolbar Items

    private var sortMenu: some View {
        Menu {
            ForEach(AssetSortOrder.allCases) { order in
                Button {
                    sortOrder = order
                } label: {
                    HStack {
                        Text(order.rawValue)
                        if sortOrder == order {
                            Image(systemName: "checkmark")
                        }
                    }
                }
            }
        } label: {
            Image(systemName: "arrow.up.arrow.down")
        }
        .help("Sort order")
    }

    private var groupToggle: some View {
        Button {
            groupByType.toggle()
        } label: {
            Image(systemName: groupByType ? "rectangle.grid.1x2.fill" : "rectangle.grid.1x2")
        }
        .help(groupByType ? "Ungroup" : "Group by type")
    }

    private var newAssetButton: some View {
        Button {
            let currentFolder: Folder? = {
                if case .folder(let f) = sidebarSelection { return f }
                return nil
            }()
            _ = viewModel.createAsset(in: context, folder: currentFolder)
        } label: {
            Label("New Asset", systemImage: "plus")
        }
        .help("New Asset (⌘N)")
    }

    // MARK: - Context Menu

    @ViewBuilder
    private func contextMenu(for asset: Asset) -> some View {
        Button {
            viewModel.toggleFavorite(asset)
        } label: {
            Label(
                asset.isFavorite ? "Remove from Favorites" : "Add to Favorites",
                systemImage: asset.isFavorite ? "star.slash" : "star"
            )
        }

        Button {
            viewModel.toggleArchive(asset)
        } label: {
            Label(
                asset.isArchived ? "Unarchive" : "Archive",
                systemImage: asset.isArchived ? "arrow.uturn.up" : "archivebox"
            )
        }

        Button {
            viewModel.toggleLock(asset)
        } label: {
            Label(
                asset.isLocked == true ? "Unlock from Deletion" : "Lock from Deletion",
                systemImage: asset.isLocked == true ? "lock.open" : "lock"
            )
        }

        Divider()

        Button("Delete", role: .destructive) {
            viewModel.deleteAsset(asset, in: context)
        }
        .disabled(asset.isLocked == true)
    }

    // MARK: - Sorting

    private func sorted(_ assets: [Asset]) -> [Asset] {
        switch sortOrder {
        case .modifiedDesc:  return assets.sorted { $0.modificationDate > $1.modificationDate }
        case .modifiedAsc:   return assets.sorted { $0.modificationDate < $1.modificationDate }
        case .createdDesc:   return assets.sorted { $0.creationDate > $1.creationDate }
        case .createdAsc:    return assets.sorted { $0.creationDate < $1.creationDate }
        case .titleAsc:      return assets.sorted { $0.title.localizedCompare($1.title) == .orderedAscending }
        case .titleDesc:     return assets.sorted { $0.title.localizedCompare($1.title) == .orderedDescending }
        }
    }
}
