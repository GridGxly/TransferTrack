import SwiftUI

@available(iOS 17.0, *)
struct TTAdaptiveGlassCard: ViewModifier {
    let radius: CGFloat
    let padding: CGFloat
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(
                        colorScheme == .light
                            ? Color(uiColor: .separator).opacity(0.3)
                            : Color.white.opacity(0.06),
                        lineWidth: 0.5
                    )
            )
            .shadow(
                color: colorScheme == .light
                    ? Color.black.opacity(0.06)
                    : Color.black.opacity(0.2),
                radius: colorScheme == .light ? 6 : 10,
                y: colorScheme == .light ? 2 : 4
            )
    }
}

@available(iOS 17.0, *)
extension View {
    func ttGlassCard(radius: CGFloat = 16, padding: CGFloat = 16) -> some View {
        modifier(TTAdaptiveGlassCard(radius: radius, padding: padding))
    }
}

@available(iOS 17.0, *)
struct TTAdaptiveCardBorder: ViewModifier {
    let radius: CGFloat
    let isHighlighted: Bool
    let highlightColor: Color
    @Environment(\.colorScheme) private var colorScheme

    func body(content: Content) -> some View {
        content
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(
                        isHighlighted
                            ? highlightColor.opacity(0.4)
                            : (colorScheme == .light
                                ? Color(uiColor: .separator).opacity(0.2)
                                : Color.white.opacity(0.06)),
                        lineWidth: isHighlighted ? 1.5 : 0.5
                    )
            )
            .shadow(
                color: colorScheme == .light
                    ? Color.black.opacity(isHighlighted ? 0.08 : 0.04)
                    : Color.black.opacity(isHighlighted ? 0.15 : 0.06),
                radius: isHighlighted ? 8 : 4,
                y: 2
            )
    }
}

@available(iOS 17.0, *)
extension View {
    func ttAdaptiveCardBorder(
        radius: CGFloat = 12,
        isHighlighted: Bool = false,
        highlightColor: Color = TTBrand.amber
    ) -> some View {
        modifier(TTAdaptiveCardBorder(
            radius: radius,
            isHighlighted: isHighlighted,
            highlightColor: highlightColor
        ))
    }
}

@available(iOS 17.0, *)
struct TTScoreAwareBackground: ViewModifier {
    let score: Int
    @Environment(\.colorScheme) private var colorScheme

    private var gradientColors: [Color] {
        TTBrand.gradient(for: score)
    }

    func body(content: Content) -> some View {
        content
            .background {
                if colorScheme == .dark {
                    LinearGradient(
                        colors: gradientColors.map { $0.opacity(0.05) },
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()
                } else {
                    Color(uiColor: .systemGroupedBackground)
                        .ignoresSafeArea()
                        .overlay(
                            LinearGradient(
                                colors: gradientColors.map { $0.opacity(0.03) },
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                            .ignoresSafeArea()
                        )
                }
            }
    }
}

@available(iOS 17.0, *)
extension View {
    func ttScoreAwareBackground(score: Int) -> some View {
        modifier(TTScoreAwareBackground(score: score))
    }
}
