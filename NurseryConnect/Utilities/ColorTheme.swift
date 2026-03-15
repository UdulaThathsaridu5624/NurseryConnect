// ColorTheme.swift — NurseryConnect
// Design token extensions for a warm, professional childcare colour palette.

import SwiftUI

extension Color {
    // MARK: - Brand colours
    /// Primary teal — main interactive elements, nav bars
    static let ncPrimary     = Color(red: 0.165, green: 0.616, blue: 0.561)  // #2A9D8F
    /// Warm amber — accents, highlights
    static let ncAccent      = Color(red: 0.914, green: 0.769, blue: 0.412)  // #E9C46A
    /// Coral — danger, incidents, severe alerts
    static let ncDanger      = Color(red: 0.906, green: 0.435, blue: 0.318)  // #E76F51
    /// Sandy orange — moderate warnings
    static let ncWarning     = Color(red: 0.957, green: 0.635, blue: 0.380)  // #F4A261
    /// Light off-white — screen backgrounds
    static let ncBackground  = Color(red: 0.973, green: 0.976, blue: 0.980)  // #F8F9FA
    /// Pure white — card surfaces
    static let ncCard        = Color.white
    /// Muted secondary text
    static let ncSecondary   = Color(red: 0.459, green: 0.486, blue: 0.533)  // #757C88

    // MARK: - Entry-type colours
    static let ncActivity    = Color.blue
    static let ncSleep       = Color.purple
    static let ncMeal        = Color.orange
    static let ncNappy       = Color.cyan
    static let ncMood        = Color.pink

    // MARK: - Helpers
    static func ncColor(forToken token: String) -> Color {
        switch token {
        case "blue":   return .ncActivity
        case "purple": return .ncSleep
        case "orange": return .ncMeal
        case "cyan":   return .ncNappy
        case "pink":   return .ncMood
        default:       return .ncPrimary
        }
    }
}

// MARK: - ShapeStyle extensions
// Allows dot-shorthand like .ncPrimary where any ShapeStyle is expected
// (same pattern Apple uses for .blue, .red, etc.)
extension ShapeStyle where Self == Color {
    static var ncPrimary:    Color { .ncPrimary }
    static var ncAccent:     Color { .ncAccent }
    static var ncDanger:     Color { .ncDanger }
    static var ncWarning:    Color { .ncWarning }
    static var ncBackground: Color { .ncBackground }
    static var ncCard:       Color { .ncCard }
    static var ncSecondary:  Color { .ncSecondary }
}

// MARK: - Reusable modifier for card styling
struct NCCardModifier: ViewModifier {
    var cornerRadius: CGFloat = 14

    func body(content: Content) -> some View {
        content
            .background(Color.ncCard)
            .clipShape(RoundedRectangle(cornerRadius: cornerRadius, style: .continuous))
            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 2)
    }
}

extension View {
    func ncCard(cornerRadius: CGFloat = 14) -> some View {
        modifier(NCCardModifier(cornerRadius: cornerRadius))
    }
}
