import SwiftUI

struct LiquidGlassCard: ViewModifier {
    func body(content: Content) -> some View {
        content
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .shadow(color: Color.black.opacity(0.08), radius: 10, x: 0, y: 4)
            .overlay(
                RoundedRectangle(cornerRadius: 20)
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
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack {
                LinearGradient(
                    colors: [
                        Color(uiColor: .systemBackground),
                        Color(uiColor: .systemBackground).opacity(0.0)
                    ],
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
