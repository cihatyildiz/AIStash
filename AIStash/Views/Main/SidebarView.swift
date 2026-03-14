// SidebarView.swift
// The left pane of the three-column layout.
//
// Sections:
//   1. Smart Filters: All Assets, Favorites, Archive
//   2. Folders: User-created collections with context menus
//   3. Tags: All tags with colored chips
//
// The sidebar drives navigation by updating `sidebarVM.selection`,
// which the AssetListView observes to filter its content.

import SwiftUI
import SwiftData
#if canImport(AIStashCore)
import AIStashCore
#endif

struct SidebarView: View {

    @Bindable var viewModel: SidebarViewModel
    let folders: [Folder]
    let tags: [Tag]

    @Environment(\.modelContext) private var context

    // MARK: - State for creation sheets

    @State private var newFolderName: String = ""
    @State private var newFolderIcon: String = "folder"
    @State private var newFolderColor: String = "#4A90D9"

    @State private var newTagName: String = ""
    @State private var newTagColor: String = "#888888"

    // MARK: - Body

    var body: some View {
        List(selection: Binding(
            get: { viewModel.selection },
            set: { if let v = $0 { viewModel.selection = v } }
        )) {
            smartFiltersSection
            foldersSection
            tagsSection
        }
        .listStyle(.sidebar)
        .navigationTitle("AIStash")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                newAssetButton
            }
        }
        // New Folder Sheet
        .sheet(isPresented: $viewModel.isCreatingFolder) {
            NewFolderSheet(
                name: $newFolderName,
                iconName: $newFolderIcon,
                colorHex: $newFolderColor,
                onSave: {
                    viewModel.createFolder(
                        name: newFolderName,
                        iconName: newFolderIcon,
                        colorHex: newFolderColor,
                        in: context
                    )
                    newFolderName = ""
                    viewModel.isCreatingFolder = false
                },
                onCancel: {
                    newFolderName = ""
                    viewModel.isCreatingFolder = false
                }
            )
        }
        // New Tag Sheet
        .sheet(isPresented: $viewModel.isCreatingTag) {
            NewTagSheet(
                name: $newTagName,
                colorHex: $newTagColor,
                onSave: {
                    viewModel.createTag(
                        name: newTagName,
                        colorHex: newTagColor,
                        in: context
                    )
                    newTagName = ""
                    viewModel.isCreatingTag = false
                },
                onCancel: {
                    newTagName = ""
                    viewModel.isCreatingTag = false
                }
            )
        }
    }

    // MARK: - Sections

    private var smartFiltersSection: some View {
        Section("Library") {
            ForEach(SmartFilter.allCases) { filter in
                Label(filter.rawValue, systemImage: filter.symbolName)
                    .foregroundStyle(filter.color)
                    .tag(SidebarSelection.smartFilter(filter))
            }
        }
    }

    private var foldersSection: some View {
        Section {
            ForEach(folders.sorted(by: { $0.order < $1.order })) { folder in
                Label(folder.name, systemImage: folder.iconName)
                    .tag(SidebarSelection.folder(folder))
                    .contextMenu {
                        Button("Rename") {
                            viewModel.folderBeingRenamed = folder
                        }
                        Divider()
                        Button("Delete Folder", role: .destructive) {
                            viewModel.deleteFolder(folder, in: context)
                        }
                    }
            }
        } header: {
            HStack {
                Text("Folders")
                Spacer()
                Button {
                    viewModel.isCreatingFolder = true
                } label: {
                    Image(systemName: "plus")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var tagsSection: some View {
        Section {
            ForEach(tags.sorted(by: { $0.name < $1.name })) { tag in
                HStack(spacing: 6) {
                    Circle()
                        .fill(Color(hex: tag.colorHex))
                        .frame(width: 8, height: 8)
                    Text(tag.name)
                }
                .tag(SidebarSelection.tag(tag))
                .contextMenu {
                    Button("Delete Tag", role: .destructive) {
                        viewModel.deleteTag(tag, in: context)
                    }
                }
            }
        } header: {
            HStack {
                Text("Tags")
                Spacer()
                Button {
                    viewModel.isCreatingTag = true
                } label: {
                    Image(systemName: "plus")
                        .font(.caption)
                }
                .buttonStyle(.plain)
            }
        }
    }

    private var newAssetButton: some View {
        Button {
            NotificationCenter.default.post(name: .createNewAsset, object: nil)
        } label: {
            Image(systemName: "square.and.pencil")
        }
        .help("New Asset (⌘N)")
    }
}

// MARK: - New Folder Sheet

private struct NewFolderSheet: View {
    @Binding var name: String
    @Binding var iconName: String
    @Binding var colorHex: String
    let onSave: () -> Void
    let onCancel: () -> Void

    private let iconOptions = ["folder", "brain", "cpu", "star", "doc.text", "wand.and.stars", "bolt", "network"]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("New Folder")
                .font(.headline)

            TextField("Folder name", text: $name)
                .textFieldStyle(.roundedBorder)

            HStack {
                Text("Icon:")
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(iconOptions, id: \.self) { icon in
                            Image(systemName: icon)
                                .padding(6)
                                .background(iconName == icon ? Color.accentColor.opacity(0.2) : Color.clear)
                                .cornerRadius(6)
                                .onTapGesture { iconName = icon }
                        }
                    }
                }
            }

            HStack {
                Spacer()
                Button("Cancel", action: onCancel)
                Button("Create") { onSave() }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 340)
    }
}

// MARK: - New Tag Sheet

private struct NewTagSheet: View {
    @Binding var name: String
    @Binding var colorHex: String
    let onSave: () -> Void
    let onCancel: () -> Void

    private let colorOptions = [
        "#E74C3C", "#E67E22", "#F1C40F", "#2ECC71",
        "#1ABC9C", "#3498DB", "#9B59B6", "#888888"
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("New Tag")
                .font(.headline)

            TextField("Tag name", text: $name)
                .textFieldStyle(.roundedBorder)

            HStack {
                Text("Color:")
                HStack(spacing: 8) {
                    ForEach(colorOptions, id: \.self) { hex in
                        Circle()
                            .fill(Color(hex: hex))
                            .frame(width: 20, height: 20)
                            .overlay(
                                Circle()
                                    .stroke(Color.primary, lineWidth: colorHex == hex ? 2 : 0)
                            )
                            .onTapGesture { colorHex = hex }
                    }
                }
            }

            HStack {
                Spacer()
                Button("Cancel", action: onCancel)
                Button("Create") { onSave() }
                    .buttonStyle(.borderedProminent)
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
            }
        }
        .padding(20)
        .frame(width: 340)
    }
}
