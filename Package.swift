// swift-tools-version: 5.9
// Package.swift
//
// AIStash is primarily an Xcode project, but this Package.swift
// allows contributors to open the source in VS Code with Swift extension
// and enables CI tooling (e.g., swift build, swift test) without Xcode.
//
// Note: SwiftUI apps require Xcode to build and run on macOS.
// This file is provided for tooling and IDE support only.

import PackageDescription

let package = Package(
    name: "AIStash",
    platforms: [
        .macOS(.v14)  // SwiftData requires macOS 14 (Sonoma) or later
    ],
    products: [
        .library(name: "AIStashCore", targets: ["AIStashCore"]),
        .executable(name: "AIStashApp", targets: ["AIStashApp"])
    ],
    targets: [
        // Core library target: Models, Services, ViewModels
        // This can be unit tested independently of the UI.
        .target(
            name: "AIStashCore",
            path: "AIStash",
            exclude: ["App", "Views", "Resources"],
            sources: ["Models", "Services", "ViewModels"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .executableTarget(
            name: "AIStashApp",
            dependencies: ["AIStashCore"],
            path: "AIStash",
            exclude: ["Resources/Info.plist"],
            sources: ["App", "Views", "Resources"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "AIStashCoreTests",
            dependencies: ["AIStashCore"],
            path: "AIStashTests"
        )
    ]
)
