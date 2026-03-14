// AssetDetailView.swift
// The right pane: a full editor for the selected asset.
//
// Layout (top to bottom):
//   1. Title field (large, editable)
//   2. Type picker + status badges (Favorite, Archived)
//   3. Folder and Tag assignment
//   4. Content editor (TextEditor, monospaced for code-like content)
//   5. Metadata key-value editor (collapsible)
//   6. Footer: creation date and modification date

import SwiftUI
import SwiftData
#if canImport(AIStashCore)
import AIStashCore
#endif

struct AssetDetailView: View {

    let asset: Asset?
    @Bindable var viewModel: AssetDetailViewModel
    let allTags: [Tag]
    let allFolders: [Folder]

    @Environment(\.modelContext) private var context

    // MARK: - Body

    var body: some View {
        Group {
            if let asset {
                editorView(for: asset)
            } else {
                placeholderView
            }
        }
    }

    // MARK: - Placeholder

    private var placeholderView: some View {
        VStack(spacing: 12) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundStyle(.tertiary)
            Text("Select an asset to view or edit")
                .font(.title3)
                .foregroundStyle(.secondary)
            Text("Or press ⌘N to create a new one")
                .font(.caption)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Editor

    private func editorView(for asset: Asset) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                titleSection(asset)
                typeAndStatusSection(asset)
                organizationSection(asset)
                Divider()
                contentSection(asset)
                Divider()
                metadataSection(asset)
                footerSection(asset)
            }
            .padding(20)
        }
        .background(.background)
        .toolbar {
            ToolbarItemGroup(placement: .primaryAction) {
                favoriteButton(asset)
                archiveButton(asset)
            }
        }
    }

    // MARK: - Title Section

    private func titleSection(_ asset: Asset) -> some View {
        TextField("Asset Title", text: Binding(
            get: { asset.title },
            set: { asset.title = $0; viewModel.didEdit(asset) }
        ))
        .font(.title2)
        .fontWeight(.semibold)
        .textFieldStyle(.plain)
    }

    // MARK: - Type and Status Section

    private func typeAndStatusSection(_ asset: Asset) -> some View {
        HStack(spacing: 12) {
            // Type Picker
            Picker("Type", selection: Binding(
                get: { asset.assetType },
                set: { asset.assetType = $0; viewModel.didEdit(asset) }
            )) {
                ForEach(AssetType.allCases) { type in
                    Label(type.rawValue, systemImage: type.symbolName)
                        .tag(type)
                }
            }
            .pickerStyle(.menu)
            .labelsHidden()
            .frame(maxWidth: 140)

            if asset.isFavorite {
                Label("Favorite", systemImage: "star.fill")
                    .font(.caption)
                    .foregroundStyle(.yellow)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.yellow.opacity(0.1), in: Capsule())
            }

            if asset.isArchived {
                Label("Archived", systemImage: "archivebox")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 3)
                    .background(.secondary.opacity(0.1), in: Capsule())
            }

            Spacer()
        }
    }

    // MARK: - Organization Section (Folder + Tags)

    private func organizationSection(_ asset: Asset) -> some View {
        HStack(spacing: 12) {
            // Folder Picker
            folderPicker(asset)

            // Tag Picker
            tagPicker(asset)

            Spacer()
        }
    }

    private func folderPicker(_ asset: Asset) -> some View {
        Menu {
            Button("No Folder") {
                viewModel.assignFolder(nil, to: asset)
            }
            Divider()
            ForEach(allFolders.sorted(by: { $0.name < $1.name })) { folder in
                Button {
                    viewModel.assignFolder(folder, to: asset)
                } label: {
                    Label(folder.name, systemImage: folder.iconName)
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: asset.folder?.iconName ?? "folder.badge.questionmark")
                Text(asset.folder?.name ?? "No Folder")
            }
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
        }
        .menuStyle(.borderlessButton)
    }

    private func tagPicker(_ asset: Asset) -> some View {
        Menu {
            ForEach(allTags.sorted(by: { $0.name < $1.name })) { tag in
                Button {
                    viewModel.toggleTag(tag, on: asset)
                } label: {
                    HStack {
                        if viewModel.isTagApplied(tag, to: asset) {
                            Image(systemName: "checkmark")
                        }
                        Text(tag.name)
                    }
                }
            }
            if allTags.isEmpty {
                Text("No tags yet — create one in the sidebar")
                    .foregroundStyle(.secondary)
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "tag")
                if asset.tags.isEmpty {
                    Text("Add Tags")
                } else {
                    Text("\(asset.tags.count) tag\(asset.tags.count == 1 ? "" : "s")")
                }
            }
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 6))
        }
        .menuStyle(.borderlessButton)
    }

    // MARK: - Content Section

    private func contentSection(_ asset: Asset) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("Content", systemImage: "doc.text")
                .font(.caption)
                .foregroundStyle(.secondary)
                .fontWeight(.semibold)

            TextEditor(text: Binding(
                get: { asset.content },
                set: { asset.content = $0; viewModel.didEdit(asset) }
            ))
            .font(.system(.body, design: .monospaced))
            .frame(minHeight: 200)
            .scrollContentBackground(.hidden)
            .padding(8)
            .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
        }
    }

    // MARK: - Metadata Section

    private func metadataSection(_ asset: Asset) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.isMetadataExpanded.toggle()
                }
            } label: {
                HStack {
                    Label("Metadata", systemImage: "list.bullet.rectangle")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fontWeight(.semibold)
                    Spacer()
                    Image(systemName: viewModel.isMetadataExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if viewModel.isMetadataExpanded {
                MetadataEditorView(asset: asset, viewModel: viewModel)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    // MARK: - Footer

    private func footerSection(_ asset: Asset) -> some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Created \(asset.creationDate.formatted(date: .abbreviated, time: .shortened))")
                Text("Modified \(asset.modificationDate.formatted(date: .abbreviated, time: .shortened))")
            }
            .font(.caption2)
            .foregroundStyle(.tertiary)
        }
        .padding(.top, 8)
    }

    // MARK: - Toolbar Buttons

    private func favoriteButton(_ asset: Asset) -> some View {
        Button {
            asset.isFavorite.toggle()
            asset.touch()
        } label: {
            Image(systemName: asset.isFavorite ? "star.fill" : "star")
                .foregroundStyle(asset.isFavorite ? .yellow : .secondary)
        }
        .help(asset.isFavorite ? "Remove from Favorites" : "Add to Favorites")
    }

    private func archiveButton(_ asset: Asset) -> some View {
        Button {
            asset.isArchived.toggle()
            asset.touch()
        } label: {
            Image(systemName: asset.isArchived ? "arrow.uturn.up" : "archivebox")
        }
        .help(asset.isArchived ? "Unarchive" : "Archive")
    }
}
