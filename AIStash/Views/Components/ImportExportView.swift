// ImportExportView.swift
// A sheet that provides Import and Export functionality.
//
// Export: Serializes all assets to a JSON file and presents a save panel.
// Import: Opens a file picker for a .json file, parses it, and inserts
//         new assets into the SwiftData context.
//
// Uses macOS-native file panels via fileExporter and fileImporter modifiers.

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
#if canImport(AIStashCore)
import AIStashCore
#endif

struct ImportExportView: View {

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @Query private var allAssets: [Asset]
    @Query private var allFolders: [Folder]
    @Query private var allTags: [Tag]

    @State private var isExporting: Bool = false
    @State private var isImporting: Bool = false
    @State private var exportDocument: JSONDocument? = nil
    @State private var alertMessage: String? = nil
    @State private var showAlert: Bool = false
    @State private var importResult: ImportResult? = nil

    // MARK: - Body

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header
            HStack {
                Image(systemName: "arrow.up.arrow.down.circle.fill")
                    .font(.title2)
                    .foregroundStyle(Color.accentColor)
                Text("Import & Export")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button("Done") { dismiss() }
            }

            Divider()

            // Export Section
            VStack(alignment: .leading, spacing: 10) {
                Label("Export", systemImage: "square.and.arrow.up")
                    .font(.headline)

                Text("Export all \(allAssets.count) assets, \(allFolders.count) folders, and \(allTags.count) tags to a JSON file. You can use this file as a backup or to transfer your library to another device.")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Button {
                    prepareExport()
                } label: {
                    Label("Export All Assets…", systemImage: "square.and.arrow.up")
                }
                .buttonStyle(.borderedProminent)
            }

            Divider()

            // Import Section
            VStack(alignment: .leading, spacing: 10) {
                Label("Import", systemImage: "square.and.arrow.down")
                    .font(.headline)

                Text("Import assets from a previously exported AIStash JSON file. Existing assets (matched by ID) will be skipped to avoid duplicates.")
                    .font(.callout)
                    .foregroundStyle(.secondary)

                Button {
                    isImporting = true
                } label: {
                    Label("Import from JSON…", systemImage: "square.and.arrow.down")
                }
                .buttonStyle(.bordered)
            }

            // Import result feedback
            if let result = importResult {
                HStack(spacing: 8) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("Imported \(result.inserted) asset\(result.inserted == 1 ? "" : "s"). Skipped \(result.skipped) duplicate\(result.skipped == 1 ? "" : "s").")
                        .font(.callout)
                }
                .padding(10)
                .background(.green.opacity(0.1), in: RoundedRectangle(cornerRadius: 8))
            }

            Spacer()
        }
        .padding(24)
        .frame(width: 460, height: 400)
        // File exporter
        .fileExporter(
            isPresented: $isExporting,
            document: exportDocument,
            contentType: .json,
            defaultFilename: "AIStash-Export-\(Date().formatted(.iso8601.year().month().day()))"
        ) { result in
            switch result {
            case .success:
                alertMessage = "Export successful."
                showAlert = true
            case .failure(let error):
                alertMessage = "Export failed: \(error.localizedDescription)"
                showAlert = true
            }
        }
        // File importer
        .fileImporter(
            isPresented: $isImporting,
            allowedContentTypes: [.json],
            allowsMultipleSelection: false
        ) { result in
            switch result {
            case .success(let urls):
                guard let url = urls.first else { return }
                performImport(from: url)
            case .failure(let error):
                alertMessage = "Could not open file: \(error.localizedDescription)"
                showAlert = true
            }
        }
        .alert("AIStash", isPresented: $showAlert) {
            Button("OK") {}
        } message: {
            Text(alertMessage ?? "")
        }
    }

    // MARK: - Actions

    private func prepareExport() {
        do {
            let data = try ImportExportService.shared.exportAll(
                assets: allAssets,
                folders: allFolders,
                tags: allTags
            )
            exportDocument = JSONDocument(data: data)
            isExporting = true
        } catch {
            alertMessage = "Export failed: \(error.localizedDescription)"
            showAlert = true
        }
    }

    private func performImport(from url: URL) {
        guard url.startAccessingSecurityScopedResource() else {
            alertMessage = "Permission denied to access the file."
            showAlert = true
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            let data = try Data(contentsOf: url)
            let result = try ImportExportService.shared.importBundle(from: data, into: context)
            importResult = result
        } catch {
            alertMessage = "Import failed: \(error.localizedDescription)"
            showAlert = true
        }
    }
}

// MARK: - JSONDocument (FileDocument for fileExporter)

struct JSONDocument: FileDocument {
    static var readableContentTypes: [UTType] { [.json] }

    var data: Data

    init(data: Data) {
        self.data = data
    }

    init(configuration: ReadConfiguration) throws {
        data = configuration.file.regularFileContents ?? Data()
    }

    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        FileWrapper(regularFileWithContents: data)
    }
}
