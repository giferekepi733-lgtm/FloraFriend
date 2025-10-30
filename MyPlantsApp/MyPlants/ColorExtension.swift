import SwiftUI

// Let's define our pastel color palette here
// We can use them across the app like Color.primaryGreen
extension Color {
    static let primaryGreen = Color(hex: "#A3C9A8")
    static let secondaryGreen = Color(hex: "#84B59F")
    static let backgroundLight = Color(hex: "#F5F5F5")
    static let textPrimary = Color(hex: "#4A4A4A")
    static let textSecondary = Color(hex: "#888888")
    static let accentYellow = Color(hex: "#FFDDA1")
}

// This extension allows us to initialize a Color using a HEX string.
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
