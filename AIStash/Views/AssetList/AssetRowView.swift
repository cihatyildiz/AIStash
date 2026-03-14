// AssetRowView.swift
// A single row in the asset list (middle pane).
//
// Displays:
// - Asset type icon (colored)
// - Title
// - Content preview (first line, truncated)
// - Tag chips
// - Favorite star and modification date

import SwiftUI
#if canImport(AIStashCore)
import AIStashCore
#endif

struct AssetRowView: View {

    let asset: Asset

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Row 1: Type icon + Title + Favorite
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Image(systemName: asset.assetType.symbolName)
                    .font(.caption)
                    .foregroundStyle(asset.assetType.color)
                    .frame(width: 14)

                Text(asset.title)
                    .font(.body)
                    .fontWeight(.medium)
                    .lineLimit(1)

                Spacer()

                if asset.isFavorite {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                        .foregroundStyle(.yellow)
                }
            }

            // Row 2: Content preview
            if !asset.content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                Text(asset.content)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(2)
            }

            // Row 3: Tags + Date
            HStack(spacing: 4) {
                // Show up to 3 tags
                ForEach(Array(asset.tags.prefix(3)), id: \.id) { tag in
                    TagChip(tag: tag)
                }
                if asset.tags.count > 3 {
                    Text("+\(asset.tags.count - 3)")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                }

                Spacer()

                Text(asset.modificationDate.formatted(.relative(presentation: .named, unitsStyle: .abbreviated)))
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }
}

// MARK: - Tag Chip

struct TagChip: View {
    let tag: Tag

    var body: some View {
        Text(tag.name)
            .font(.caption2)
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Color(hex: tag.colorHex).opacity(0.15), in: Capsule())
            .foregroundStyle(Color(hex: tag.colorHex))
            .lineLimit(1)
    }
}
