// Color+Hex.swift
// A SwiftUI Color extension for initializing colors from hex strings.
//
// Used throughout the app for folder and tag colors stored as "#RRGGBB" strings.
// Supports 6-character hex codes with or without the leading "#".

import SwiftUI

extension Color {

    /// Initialize a Color from a hex string like "#FF6B6B" or "FF6B6B".
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)

        let r, g, b: Double
        switch hex.count {
        case 6: // RGB (no alpha)
            r = Double((int >> 16) & 0xFF) / 255.0
            g = Double((int >> 8)  & 0xFF) / 255.0
            b = Double(int         & 0xFF) / 255.0
        default:
            r = 0.5; g = 0.5; b = 0.5
        }
        self.init(red: r, green: g, blue: b)
    }

    /// Returns a hex string representation of the color (approximate, sRGB).
    var hexString: String {
        let resolved = self.resolve(in: EnvironmentValues())
        let r = Int(resolved.red   * 255)
        let g = Int(resolved.green * 255)
        let b = Int(resolved.blue  * 255)
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
