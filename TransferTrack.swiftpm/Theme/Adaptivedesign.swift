import SwiftUI


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
