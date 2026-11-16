import SwiftUI

enum FCCColors {
    static let gold = Color(hex: "D4AF37")
    static let goldLight = Color(hex: "F0C040")
    static let green = Color(hex: "1B4332")
    static let greenDark = Color(hex: "081C15")
    static let bgDark = Color(hex: "0D1F16")
    static let cardBg = Color(hex: "152B1E")
    static let cardLight = Color(hex: "1E3D2A")
    static let textPrimary = Color(hex: "F5F0E8")
    static let textSecondary = Color(hex: "AAB5A8")
    static let errorRed = Color(hex: "EF4444")
    static let successGreen = Color(hex: "10B981")
}

extension Color {
    init(hex: String) {
        let cleanHex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: cleanHex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch cleanHex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
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
