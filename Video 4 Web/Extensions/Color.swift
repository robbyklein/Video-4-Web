import SwiftUI

extension Color {
    init(hex: String) {
        let hexString = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var hexInt: UInt64 = 0

        Scanner(string: hexString).scanHexInt64(&hexInt)

        let alpha, red, green, blue: UInt64

        switch hexString.count {
            case 6:
                (alpha, red, green, blue) = (
                    255,
                    (hexInt >> 16) & 0xFF,
                    (hexInt >> 8) & 0xFF,
                    hexInt & 0xFF
                )
            default:
                (alpha, red, green, blue) = (255, 255, 255, 255)
        }

        self.init(
            .sRGB,
            red: Double(red) / 255,
            green: Double(green) / 255,
            blue: Double(blue) / 255,
            opacity: Double(alpha) / 255
        )
    }
}
