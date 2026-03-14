// FilterPanel.swift
// A collapsible filter panel for the asset list.
//
// Provides:
//   - Asset type filter (pill buttons, single-select)
//   - Tag filter (multi-select checkboxes)
//   - "Clear Filters" button when filters are active
//
// This component is purely presentational — it binds to the
// AssetListViewModel's filter state and delegates all logic to it.

import SwiftUI
#if canImport(AIStashCore)
import AIStashCore
#endif

struct FilterPanel: View {

    @Binding var typeFilter: AssetType?
    @Binding var tagFilter: Set<Tag>
    let availableTags: [Tag]
    let onClear: () -> Void

    @State private var isExpanded: Bool = false

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header toggle
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    Label("Filters", systemImage: "line.3.horizontal.decrease.circle")
                        .font(.caption)
                        .foregroundStyle(hasActiveFilters ? Color.accentColor : Color.secondary)
                        .fontWeight(hasActiveFilters ? .semibold : .regular)

                    if hasActiveFilters {
                        Text("Active")
                            .font(.caption2)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(Color.accentColor.opacity(0.15), in: Capsule())
                            .foregroundStyle(Color.accentColor)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)

            if isExpanded {
                Divider()
                filterContent
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(.bar)
        .overlay(alignment: .bottom) {
            Divider()
        }
    }

    // MARK: - Filter Content

    private var filterContent: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Type filter
            VStack(alignment: .leading, spacing: 6) {
                Text("Type")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
                    .fontWeight(.semibold)
                    .padding(.horizontal, 12)

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 6) {
                        TypePill(label: "All", color: .primary, isSelected: typeFilter == nil) {
                            typeFilter = nil
                        }
                        ForEach(AssetType.allCases) { type in
                            TypePill(
                                label: type.rawValue,
                                color: type.color,
                                isSelected: typeFilter == type
                            ) {
                                typeFilter = (typeFilter == type) ? nil : type
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                }
            }

            // Tag filter (only shown if there are tags)
            if !availableTags.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Tags")
                        .font(.caption2)
                        .foregroundStyle(.tertiary)
                        .fontWeight(.semibold)
                        .padding(.horizontal, 12)

                    FlowLayout(spacing: 6) {
                        ForEach(availableTags.sorted(by: { $0.name < $1.name })) { tag in
                            TagFilterPill(
                                tag: tag,
                                isSelected: tagFilter.contains(where: { $0.id == tag.id })
                            ) {
                                if tagFilter.contains(where: { $0.id == tag.id }) {
                                    tagFilter.remove(tag)
                                } else {
                                    tagFilter.insert(tag)
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                }
            }

            // Clear button
            if hasActiveFilters {
                Button("Clear All Filters", action: onClear)
                    .font(.caption)
                    .foregroundStyle(Color.accentColor)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 4)
            }
        }
        .padding(.vertical, 10)
    }

    // MARK: - Helpers

    private var hasActiveFilters: Bool {
        typeFilter != nil || !tagFilter.isEmpty
    }
}

// MARK: - Type Pill

private struct TypePill: View {
    let label: String
    let color: Color
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .fontWeight(isSelected ? .semibold : .regular)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(isSelected ? color.opacity(0.15) : Color.clear, in: Capsule())
                .overlay(Capsule().stroke(isSelected ? color : Color.secondary.opacity(0.3), lineWidth: 1))
                .foregroundStyle(isSelected ? color : .secondary)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Tag Filter Pill

private struct TagFilterPill: View {
    let tag: Tag
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 4) {
                if isSelected {
                    Image(systemName: "checkmark")
                        .font(.caption2)
                }
                Text(tag.name)
                    .font(.caption)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(
                isSelected
                    ? Color(hex: tag.colorHex).opacity(0.2)
                    : Color.clear,
                in: Capsule()
            )
            .overlay(
                Capsule().stroke(
                    isSelected
                        ? Color(hex: tag.colorHex)
                        : Color.secondary.opacity(0.3),
                    lineWidth: 1
                )
            )
            .foregroundStyle(
                isSelected ? Color(hex: tag.colorHex) : .secondary
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flow Layout
// A simple left-to-right wrapping layout for tag chips.

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxWidth = proposal.width ?? .infinity
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth && currentX > 0 {
                currentX = 0
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        return CGSize(width: maxWidth, height: currentY + rowHeight)
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let maxWidth = bounds.width
        var currentX = bounds.minX
        var currentY = bounds.minY
        var rowHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > bounds.maxX && currentX > bounds.minX {
                currentX = bounds.minX
                currentY += rowHeight + spacing
                rowHeight = 0
            }
            subview.place(at: CGPoint(x: currentX, y: currentY), proposal: ProposedViewSize(size))
            currentX += size.width + spacing
            rowHeight = max(rowHeight, size.height)
        }
        _ = maxWidth // suppress warning
    }
}
