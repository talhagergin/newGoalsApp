import SwiftUI

struct Theme: Identifiable, Codable {
    var id = UUID()
    var name: String
    var primaryColorHex: String
    var secondaryColorHex: String
    var accentColorHex: String
    var backgroundPattern: String
    
    var primaryColor: Color {
        Color(hex: primaryColorHex)
    }
    
    var secondaryColor: Color {
        Color(hex: secondaryColorHex)
    }
    
    var accentColor: Color {
        Color(hex: accentColorHex)
    }
    
    static let themes = [
        Theme(
            name: "Klasik Yılbaşı",
            primaryColorHex: "#FF0000",
            secondaryColorHex: "#00FF00",
            accentColorHex: "#FFD700",
            backgroundPattern: "snowflake"
        ),
        Theme(
            name: "Minimalist",
            primaryColorHex: "#000000",
            secondaryColorHex: "#808080",
            accentColorHex: "#0000FF",
            backgroundPattern: "dots"
        ),
        Theme(
            name: "Pastel",
            primaryColorHex: "#98FF98",
            secondaryColorHex: "#FFB6C1",
            accentColorHex: "#E6E6FA",
            backgroundPattern: "waves"
        )
    ]
}

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
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
} 