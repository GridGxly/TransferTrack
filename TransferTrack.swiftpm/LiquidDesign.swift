import SwiftUI

// MARK: - 1. high-contrast liquid glass
struct LiquidGlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4) // crisp shadow
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.gray.opacity(0.1), lineWidth: 1) // subtle border
            )
    }
}

extension View {
    func liquidGlass() -> some View {
        modifier(LiquidGlassCard())
    }
}

// MARK: - 2. amazing  background
// using systemGroupedBackground to guarantee contrast against white cards
struct LiquidBackground: View {
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            // subtle top fade
            VStack {
                LinearGradient(
                    colors: [Color.white, Color.white.opacity(0.0)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .frame(height: 200)
                .opacity(0.6)
                
                Spacer()
            }
            .ignoresSafeArea()
        }
    }
}
