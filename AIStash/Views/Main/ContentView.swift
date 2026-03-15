// ContentView.swift
// The root view of the application. Coordinates the three-pane layout.
//
// Uses SwiftUI's NavigationSplitView to produce a native macOS three-column
// layout: Sidebar | Asset List | Asset Detail.
//
// ViewModels are instantiated here and passed down to child views.
// This keeps the dependency graph clear and avoids hidden global state.
//
// Phase 4 additions:
// - Import/Export sheet triggered by menu commands and toolbar button.

import SwiftUI
import SwiftData
#if canImport(AIStashCore)
import AIStashCore
#endif

struct ContentView: View {

    // MARK: - ViewModels

    @State private var sidebarVM  = SidebarViewModel()
    @State private var listVM     = AssetListViewModel()
    @State private var detailVM   = AssetDetailViewModel()

    // MARK: - Sheet State

    @State private var isShowingImportExport: Bool = false
    @State private var importExportLaunchAction: ImportExportLaunchAction = .none

    // MARK: - Data

    @Query private var allAssets: [Asset]
    @Query private var allFolders: [Folder]
    @Query private var allTags: [Tag]

    @Environment(\.modelContext) private var context

    // MARK: - Body

    var body: some View {
        NavigationSplitView {
            SidebarView(
                viewModel: sidebarVM,
                folders: allFolders,
                tags: allTags
            )
            .navigationSplitViewColumnWidth(min: 200, ideal: 220, max: 280)
        } content: {
            AssetListView(
                viewModel: listVM,
                sidebarSelection: sidebarVM.selection,
                allAssets: allAssets,
                allTags: allTags
            )
            .navigationSplitViewColumnWidth(min: 260, ideal: 300, max: 400)
        } detail: {
            AssetDetailView(
                asset: listVM.selectedAsset,
                viewModel: detailVM,
                allTags: allTags,
                allFolders: allFolders
            )
            .toolbar {
                ToolbarItem(placement: .secondaryAction) {
                    Button {
                        importExportLaunchAction = .none
                        isShowingImportExport = true
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }
                    .help("Import / Export")
                }
            }
        }
        // Import/Export Sheet
        .sheet(isPresented: $isShowingImportExport) {
            ImportExportView(launchAction: importExportLaunchAction)
        }
        // Cmd+N from menu bar
        .onReceive(NotificationCenter.default.publisher(for: .createNewAsset)) { _ in
            let currentFolder: Folder? = {
                if case .folder(let f) = sidebarVM.selection { return f }
                return nil
            }()
            _ = listVM.createAsset(in: context, folder: currentFolder)
        }
        // Cmd+Shift+E from menu bar
        .onReceive(NotificationCenter.default.publisher(for: .exportAssets)) { _ in
            importExportLaunchAction = .exportAssets
            isShowingImportExport = true
        }
        // Cmd+Shift+I from menu bar
        .onReceive(NotificationCenter.default.publisher(for: .importAssets)) { _ in
            importExportLaunchAction = .importAssets
            isShowingImportExport = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .saveLibraryFile)) { _ in
            importExportLaunchAction = .saveLibrary
            isShowingImportExport = true
        }
        .onReceive(NotificationCenter.default.publisher(for: .openLibraryFile)) { _ in
            importExportLaunchAction = .openLibrary
            isShowingImportExport = true
        }
        .onAppear {
            selectDefaultAssetIfNeeded()
        }
        .onChange(of: allAssets.count) { _, _ in
            selectDefaultAssetIfNeeded()
        }
        .onChange(of: isShowingImportExport) { _, isShowing in
            if !isShowing {
                importExportLaunchAction = .none
            }
        }
    }

    private func selectDefaultAssetIfNeeded() {
        guard listVM.selectedAsset == nil else { return }
        listVM.selectedAsset = listVM.filteredAssets(from: allAssets, selection: sidebarVM.selection).first
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Asset.self, Folder.self, Tag.self], inMemory: true)
}
