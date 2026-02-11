import SwiftUI

// LUQID GLASSS YAYYYY
struct LiquidGlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 20, x: 0, y: 10)
            .overlay(
                RoundedRectangle(cornerRadius: 24)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1)
            )
    }
}

extension View {
    func liquidGlass() -> some View {
        modifier(LiquidGlassCard())
    }
}


struct LiquidBackground: View {
    var body: some View {
        Color.white.ignoresSafeArea()
    }
}
