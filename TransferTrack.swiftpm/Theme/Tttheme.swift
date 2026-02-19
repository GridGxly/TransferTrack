import SwiftUI



enum TTBrand {
    static let mint      = Color(red: 0.30, green: 0.85, blue: 0.65)
    static let teal      = Color(red: 0.18, green: 0.72, blue: 0.74)
    static let coral     = Color(red: 1.00, green: 0.42, blue: 0.42)
    static let amber     = Color(red: 1.00, green: 0.72, blue: 0.22)
    static let indigo    = Color(red: 0.38, green: 0.36, blue: 0.90)
    static let violet    = Color(red: 0.58, green: 0.34, blue: 0.92)
    static let skyBlue   = Color(red: 0.30, green: 0.60, blue: 1.00)


    static func accent(for score: Int) -> Color {
        if score >= 75 { return mint }
        else if score >= 50 { return amber }
        else { return coral }
    }


    static func gradient(for score: Int) -> [Color] {
        if score >= 75 { return [mint, teal] }
        else if score >= 50 { return [amber, Color(red: 0.95, green: 0.55, blue: 0.20)] }
        else { return [coral, Color(red: 0.85, green: 0.25, blue: 0.35)] }
    }
}


enum TTColors {
    static let brandGreen  = TTBrand.mint
    static let brandOrange = TTBrand.amber

    static let accent   = TTBrand.skyBlue
    static let success  = TTBrand.mint
    static let warning  = TTBrand.amber
    static let danger   = TTBrand.coral
    static let points   = TTBrand.mint


    static let pageBg   = Color(uiColor: .systemGroupedBackground)
    static let cardBg   = Color(uiColor: .secondarySystemGroupedBackground)
    static let subtle   = Color(uiColor: .tertiarySystemGroupedBackground)
    static let mutedIconBg = Color(uiColor: .tertiarySystemFill)
}



@available(iOS 17.0, *)
struct ScoreAwareBackground: View {
    let score: Int
    @Environment(\.colorScheme) private var colorScheme

    private var baseGradient: [Color] {
        TTBrand.gradient(for: score)
    }

    private var orbOpacity: Double {
        colorScheme == .light ? 0.08 : 0.18
    }

    private var baseColor: Color {
        colorScheme == .light
            ? Color(uiColor: .systemGroupedBackground)
            : Color(red: 0.06, green: 0.06, blue: 0.08)
    }

    var body: some View {
        ZStack {
            baseColor.ignoresSafeArea()

            GeometryReader { geo in
                let w = geo.size.width
                let h = geo.size.height

                Circle()
                    .fill(
                        RadialGradient(
                            colors: [baseGradient[0].opacity(orbOpacity), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: w * 0.6
                        )
                    )
                    .frame(width: w * 1.2, height: w * 1.2)
                    .offset(x: -w * 0.2, y: -h * 0.1)
                    .blur(radius: 60)

                let secondColor = baseGradient.count > 1 ? baseGradient[1] : baseGradient[0]
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [secondColor.opacity(orbOpacity), .clear],
                            center: .center,
                            startRadius: 0,
                            endRadius: w * 0.5
                        )
                    )
                    .frame(width: w * 0.9, height: w * 0.9)
                    .offset(x: w * 0.4, y: h * 0.5)
                    .blur(radius: 50)
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.6), value: colorScheme)
        .animation(.easeInOut(duration: 1.5), value: score)
    }
}




struct GlassCard: ViewModifier {
    var radius: CGFloat = 20
    var padding: CGFloat = 16
    @Environment(\.colorScheme) private var colorScheme

    private var strokeColor: Color {
        colorScheme == .light
            ? Color(uiColor: .separator).opacity(0.3)
            : Color.white.opacity(0.08)
    }

    private var shadowColor: Color {
        colorScheme == .light
            ? Color.black.opacity(0.08)
            : Color.black.opacity(0.3)
    }

    private var shadowRadius: CGFloat {
        colorScheme == .light ? 8 : 12
    }

    func body(content: Content) -> some View {
        content
            .padding(padding)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: radius, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: radius, style: .continuous)
                    .stroke(strokeColor, lineWidth: 0.5)
            )
            .shadow(color: shadowColor, radius: shadowRadius, y: 4)
    }
}

extension View {
    func glassCard(radius: CGFloat = 20, padding: CGFloat = 16) -> some View {
        self.modifier(GlassCard(radius: radius, padding: padding))
    }

    func glassCardNoPad(radius: CGFloat = 20) -> some View {
        self.modifier(GlassCard(radius: radius, padding: 0))
    }
}



struct RoundedFontDesign: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.1, *) {
            content.fontDesign(.rounded)
        } else {
            content
        }
    }
}

extension View {
    func roundedDesign() -> some View {
        self.modifier(RoundedFontDesign())
    }
}



struct StaggerFadeModifier: ViewModifier {
    @State private var isVisible = false
    var delay: Double
    var yOffset: CGFloat
    var scale: CGFloat

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : yOffset)
            .scaleEffect(isVisible ? 1.0 : scale)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func staggerFade(delay: Double = 0, yOffset: CGFloat = 20, scale: CGFloat = 0.97) -> some View {
        self.modifier(StaggerFadeModifier(delay: delay, yOffset: yOffset, scale: scale))
    }

    func framerFade(delay: Double = 0, yOffset: CGFloat = 18) -> some View {
        self.modifier(StaggerFadeModifier(delay: delay, yOffset: yOffset, scale: 0.98))
    }
}



extension View {
    func cardBorder(colorScheme: ColorScheme, radius: CGFloat = 16) -> some View {
        self.overlay(
            RoundedRectangle(cornerRadius: radius, style: .continuous)
                .stroke(
                    colorScheme == .light
                        ? Color(uiColor: .separator).opacity(0.25)
                        : Color.white.opacity(0.06),
                    lineWidth: 0.5
                )
        )
    }
}



@available(iOS 17.0, *)
struct ScorePill: View {
    let score: Int
    let label: String

    private var color: Color { TTBrand.accent(for: score) }

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 8, height: 8)
            Text(label)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(0.12))
        .clipShape(Capsule())
    }
}




@available(iOS 17.0, *)
struct OnboardingBackground: View {
    let step: Int
    let totalSteps: Int

    private var gradientColors: [Color] {
        switch step {
        case 0: return [Color(red: 0.15, green: 0.20, blue: 0.45), Color(red: 0.08, green: 0.10, blue: 0.25)]
        case 1: return [Color(red: 0.18, green: 0.22, blue: 0.50), Color(red: 0.10, green: 0.08, blue: 0.28)]
        case 2: return [Color(red: 0.25, green: 0.15, blue: 0.45), Color(red: 0.15, green: 0.08, blue: 0.30)]
        case 3: return [Color(red: 0.10, green: 0.30, blue: 0.32), Color(red: 0.06, green: 0.18, blue: 0.22)]
        case 4: return [Color(red: 0.35, green: 0.22, blue: 0.10), Color(red: 0.20, green: 0.12, blue: 0.06)]
        default: return [Color(red: 0.08, green: 0.15, blue: 0.12), Color(red: 0.04, green: 0.08, blue: 0.08)]
        }
    }

    var body: some View {
        ZStack {
            LinearGradient(colors: gradientColors, startPoint: .topLeading, endPoint: .bottomTrailing)

            GeometryReader { geo in
                let w = geo.size.width
                Circle()
                    .fill(gradientColors[0].opacity(0.4))
                    .frame(width: w * 0.7)
                    .blur(radius: 80)
                    .offset(x: -w * 0.15, y: -60)

                Circle()
                    .fill(gradientColors[1].opacity(0.3))
                    .frame(width: w * 0.5)
                    .blur(radius: 60)
                    .offset(x: w * 0.3, y: geo.size.height * 0.6)
            }
        }
        .ignoresSafeArea()
        .animation(.easeInOut(duration: 0.8), value: step)
    }
}
