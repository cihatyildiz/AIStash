// AssetType.swift
// Defines the enumeration of all supported AI asset types.
//
// This is a value type that is stored as a raw String in SwiftData,
// making it forward-compatible (new types can be added without migrations).
// Conforms to CaseIterable for use in pickers and filters.

import SwiftUI

public enum AssetType: String, Codable, CaseIterable, Identifiable {
    case prompt    = "Prompt"
    case skill     = "Skill"
    case agent     = "Agent"
    case workflow  = "Workflow"
    case template  = "Template"
    case note      = "Note"

    public var id: String { rawValue }

    /// The SF Symbol name used to represent this type in the UI.
    public var symbolName: String {
        switch self {
        case .prompt:   return "text.bubble"
        case .skill:    return "wrench.and.screwdriver"
        case .agent:    return "cpu"
        case .workflow: return "arrow.triangle.branch"
        case .template: return "doc.on.doc"
        case .note:     return "note.text"
        }
    }

    /// The accent color used for the type badge.
    public var color: Color {
        switch self {
        case .prompt:   return .blue
        case .skill:    return .green
        case .agent:    return .purple
        case .workflow: return .orange
        case .template: return .teal
        case .note:     return .gray
        }
    }
}
