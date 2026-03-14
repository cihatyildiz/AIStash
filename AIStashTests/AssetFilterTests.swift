// AssetFilterTests.swift
// Unit tests for AssetListViewModel's filtering logic.
//
// These tests run without a UI or a real SwiftData container by
// constructing Asset objects directly and passing them to the
// filteredAssets(from:selection:) method.

import XCTest
@testable import AIStashCore

// NOTE: Because SwiftData @Model classes require a model context to be
// fully functional, these tests use a lightweight in-memory container.
// This pattern is the recommended approach for testing SwiftData models.

final class AssetFilterTests: XCTestCase {

    var viewModel: AssetListViewModel!

    override func setUp() {
        super.setUp()
        viewModel = AssetListViewModel()
    }

    // MARK: - Search Tests

    func test_searchByTitle_returnsMatchingAssets() throws {
        // Given
        let assets = makeAssets([
            ("GPT-4 Prompt", .prompt),
            ("Claude Template", .template),
            ("RAG Agent", .agent)
        ])
        viewModel.searchQuery = "gpt"

        // When
        let result = viewModel.filteredAssets(from: assets, selection: .smartFilter(.all))

        // Then
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "GPT-4 Prompt")
    }

    func test_searchByContent_returnsMatchingAssets() throws {
        let assets = makeAssets([("My Asset", .note)])
        assets[0].content = "This contains the keyword chainofthought"
        viewModel.searchQuery = "chainofthought"

        let result = viewModel.filteredAssets(from: assets, selection: .smartFilter(.all))
        XCTAssertEqual(result.count, 1)
    }

    func test_emptySearch_returnsAllNonArchived() throws {
        let assets = makeAssets([("A", .note), ("B", .prompt), ("C", .agent)])
        assets[2].isArchived = true
        viewModel.searchQuery = ""

        let result = viewModel.filteredAssets(from: assets, selection: .smartFilter(.all))
        XCTAssertEqual(result.count, 2)
    }

    // MARK: - Type Filter Tests

    func test_typeFilter_returnsOnlyMatchingType() throws {
        let assets = makeAssets([
            ("Prompt 1", .prompt),
            ("Prompt 2", .prompt),
            ("Agent 1", .agent)
        ])
        viewModel.typeFilter = .prompt

        let result = viewModel.filteredAssets(from: assets, selection: .smartFilter(.all))
        XCTAssertEqual(result.count, 2)
        XCTAssertTrue(result.allSatisfy { $0.assetType == .prompt })
    }

    // MARK: - Smart Filter Tests

    func test_favoritesFilter_returnsOnlyFavorites() throws {
        let assets = makeAssets([("A", .note), ("B", .prompt)])
        assets[0].isFavorite = true

        let result = viewModel.filteredAssets(from: assets, selection: .smartFilter(.favorites))
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "A")
    }

    func test_archiveFilter_returnsOnlyArchived() throws {
        let assets = makeAssets([("A", .note), ("B", .prompt)])
        assets[1].isArchived = true

        let result = viewModel.filteredAssets(from: assets, selection: .smartFilter(.archive))
        XCTAssertEqual(result.count, 1)
        XCTAssertEqual(result.first?.title, "B")
    }

    // MARK: - Helpers

    private func makeAssets(_ specs: [(String, AssetType)]) -> [Asset] {
        specs.map { title, type in
            Asset(title: title, type: type)
        }
    }
}
