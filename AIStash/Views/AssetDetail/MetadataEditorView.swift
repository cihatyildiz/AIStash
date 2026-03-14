// MetadataEditorView.swift
// A key-value editor for the flexible metadata dictionary on an Asset.
//
// Allows users to store arbitrary structured data alongside an asset,
// such as model name, temperature, API endpoint, version, etc.
// Rows are editable in-place; new rows can be added at the bottom.

import SwiftUI
#if canImport(AIStashCore)
import AIStashCore
#endif

struct MetadataEditorView: View {

    let asset: Asset
    @Bindable var viewModel: AssetDetailViewModel

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            // Existing entries
            let sortedKeys = asset.metadata.keys.sorted()

            if sortedKeys.isEmpty && viewModel.newMetadataKey.isEmpty {
                Text("No metadata. Add key-value pairs below.")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
                    .padding(.vertical, 4)
            }

            ForEach(sortedKeys, id: \.self) { key in
                MetadataRow(
                    key: key,
                    value: Binding(
                        get: { asset.metadata[key] ?? "" },
                        set: { viewModel.updateMetadataValue(key: key, value: $0, in: asset) }
                    ),
                    onDelete: {
                        viewModel.removeMetadataEntry(key: key, from: asset)
                    }
                )
            }

            // New entry row
            HStack(spacing: 8) {
                TextField("Key", text: $viewModel.newMetadataKey)
                    .textFieldStyle(.roundedBorder)
                    .frame(maxWidth: 140)

                TextField("Value", text: $viewModel.newMetadataValue)
                    .textFieldStyle(.roundedBorder)

                Button {
                    viewModel.addMetadataEntry(to: asset)
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.accentColor)
                }
                .buttonStyle(.plain)
                .disabled(viewModel.newMetadataKey.trimmingCharacters(in: .whitespaces).isEmpty)
                .help("Add metadata entry")
            }
        }
        .padding(10)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 8))
    }
}

// MARK: - Metadata Row

private struct MetadataRow: View {
    let key: String
    @Binding var value: String
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: 8) {
            Text(key)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundStyle(.secondary)
                .frame(maxWidth: 140, alignment: .leading)
                .lineLimit(1)

            TextField("Value", text: $value)
                .font(.caption)
                .textFieldStyle(.roundedBorder)

            Button(action: onDelete) {
                Image(systemName: "minus.circle.fill")
                    .foregroundStyle(.red.opacity(0.7))
            }
            .buttonStyle(.plain)
            .help("Remove entry")
        }
    }
}
