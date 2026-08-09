import SwiftUI

enum ZodiacPalette {
    static let midnight = Color(red: 0.012, green: 0.024, blue: 0.075)
    static let cardNavy = Color(red: 0.035, green: 0.058, blue: 0.145)
    static let deepIndigo = Color(red: 0.065, green: 0.070, blue: 0.165)
    static let gold = Color(red: 0.90, green: 0.66, blue: 0.34)
    static let paleGold = Color(red: 0.98, green: 0.88, blue: 0.70)
    static let lavender = Color(red: 0.70, green: 0.62, blue: 0.88)
    static let text = Color(red: 0.97, green: 0.95, blue: 0.91)
}

struct MidnightBackground: View {
    var body: some View {
        LinearGradient(
            colors: [
                ZodiacPalette.midnight,
                Color(red: 0.015, green: 0.030, blue: 0.095),
                Color.black
            ],
            startPoint: .top,
            endPoint: .bottom
        )
        .overlay {
            RadialGradient(
                colors: [ZodiacPalette.deepIndigo.opacity(0.50), .clear],
                center: .topTrailing,
                startRadius: 0,
                endRadius: 430
            )
        }
        .ignoresSafeArea()
    }
}
