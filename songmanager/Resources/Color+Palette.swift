import SwiftUI

// Centralizes access to the shared palette from docs/internal/palette.md
extension Color {
    static let paletteBackground = Color("Background")
    static let paletteForeground = Color("Foreground")
    static let paletteJasmine = Color("Jasmine")
    static let paletteBrick = Color("BrickEmber")
    static let paletteBlood = Color("BloodRed")

    static var paletteSurface: Color {
        Color.paletteJasmine.opacity(0.18)
    }
}
