// AssetDetailViewModel.swift
// Manages the state and logic for the asset detail/editor pane (right pane).
//
// This ViewModel acts as a buffer between the raw SwiftData model and the UI.
// Edits are applied directly to the @Model object (which SwiftData observes),
// but the ViewModel handles coordination like updating modificationDate,
// managing the metadata editor state, and tag assignment.

import SwiftUI
import SwiftData

@Observable
public final class AssetDetailViewModel {

    // MARK: - Metadata Editor State

    /// Controls whether the metadata key-value editor panel is expanded.
    public var isMetadataExpanded: Bool = false

    /// Holds the new key being typed in the metadata editor.
    public var newMetadataKey: String = ""

    /// Holds the new value being typed in the metadata editor.
    public var newMetadataValue: String = ""

    // MARK: - Tag Assignment State

    /// Controls whether the tag picker popover is shown.
    public var isTagPickerShown: Bool = false

    // MARK: - Folder Assignment State

    /// Controls whether the folder picker popover is shown.
    public var isFolderPickerShown: Bool = false

    // MARK: - Asset Editing

    /// Called whenever a field in the detail view changes.
    /// Updates the modification date on the asset.
    public init() {}

    public func didEdit(_ asset: Asset) {
        asset.touch()
    }

    // MARK: - Metadata Actions

    public func addMetadataEntry(to asset: Asset) {
        let key = newMetadataKey.trimmingCharacters(in: .whitespaces)
        let value = newMetadataValue.trimmingCharacters(in: .whitespaces)
        guard !key.isEmpty else { return }

        var meta = asset.metadata
        meta[key] = value
        asset.metadata = meta
        asset.touch()

        newMetadataKey = ""
        newMetadataValue = ""
    }

    public func removeMetadataEntry(key: String, from asset: Asset) {
        var meta = asset.metadata
        meta.removeValue(forKey: key)
        asset.metadata = meta
        asset.touch()
    }

    public func updateMetadataValue(key: String, value: String, in asset: Asset) {
        var meta = asset.metadata
        meta[key] = value
        asset.metadata = meta
        asset.touch()
    }

    // MARK: - Tag Actions

    public func toggleTag(_ tag: Tag, on asset: Asset) {
        if asset.tags.contains(where: { $0.id == tag.id }) {
            asset.tags.removeAll(where: { $0.id == tag.id })
        } else {
            asset.tags.append(tag)
        }
        asset.touch()
    }

    public func isTagApplied(_ tag: Tag, to asset: Asset) -> Bool {
        asset.tags.contains(where: { $0.id == tag.id })
    }

    // MARK: - Folder Actions

    public func assignFolder(_ folder: Folder?, to asset: Asset) {
        asset.folder = folder
        asset.touch()
    }
}
