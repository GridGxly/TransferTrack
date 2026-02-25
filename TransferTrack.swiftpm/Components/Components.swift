import SwiftUI




struct CountingDollarText: View, Animatable {
    var value: CGFloat
    var fontSize: CGFloat = 52

    nonisolated var animatableData: CGFloat {
        get { value }
        set { value = newValue }
    }

    private var displayValue: Int { Int(value) }
    private var isPositive: Bool { displayValue >= 0 }

    var body: some View {
        Text("\(isPositive ? "+$" : "-$")\(abs(displayValue).formatted())")
            .font(.system(size: fontSize, weight: .bold, design: .rounded))
            .monospacedDigit()
            .foregroundStyle(isPositive ? TTBrand.mint : TTBrand.coral)
            .minimumScaleFactor(0.5)
            .lineLimit(1)
            .shadow(
                color: (isPositive ? TTBrand.mint : TTBrand.coral).opacity(0.25),
                radius: 12, y: 2
            )
    }
}




struct CountingText: View, Animatable {
    var value: CGFloat

    nonisolated var animatableData: CGFloat {
        get { value }
        set { value = newValue }
    }

    var body: some View {
        Text("\(Int(value))")
            .monospacedDigit()
    }
}



struct CollegeLogo: View {
    let schoolName: String
    var size: CGFloat = 40
    @Environment(\.colorScheme) private var colorScheme

    private var schoolColors: (primary: Color, secondary: Color) {
        let hash = abs(schoolName.hashValue)
        let hue1 = Double(hash % 360) / 360.0
        let hue2 = Double((hash / 360) % 360) / 360.0

        let saturation: Double = colorScheme == .dark ? 0.55 : 0.60
        let brightness1: Double = colorScheme == .dark ? 0.45 : 0.55
        let brightness2: Double = colorScheme == .dark ? 0.35 : 0.45

        return (
            primary: Color(hue: hue1, saturation: saturation, brightness: brightness1),
            secondary: Color(hue: hue2, saturation: saturation, brightness: brightness2)
        )
    }

    private var initials: String {
        let words = schoolName.split(separator: " ")
        if words.count >= 2 {
            return String(words[0].prefix(1)) + String(words[1].prefix(1))
        }
        return String(schoolName.prefix(2)).uppercased()
    }

    private var borderColor: Color {
        colorScheme == .dark
            ? Color.white.opacity(0.12)
            : Color.black.opacity(0.08)
    }

    private var shadowColor: Color {
        colorScheme == .dark
            ? Color.black.opacity(0.4)
            : Color.black.opacity(0.10)
    }

    private var imageBackgroundColor: Color {
        colorScheme == .dark
            ? Color(white: 0.15)
            : Color.white
    }

    var body: some View {
        Group {
            if let img = Self.loadImage(for: schoolName) {
                ZStack {
                    Circle()
                        .fill(imageBackgroundColor)

                    Image(uiImage: img)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(size * 0.10)
                }
            } else {

                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [schoolColors.primary, schoolColors.secondary],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )

                    Text(initials)
                        .font(.system(size: size * 0.34, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .shadow(color: .black.opacity(0.2), radius: 1, y: 1)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .overlay(
            Circle()
                .stroke(borderColor, lineWidth: size > 40 ? 1.0 : 0.5)
        )
        .shadow(color: shadowColor, radius: size > 40 ? 4 : 2, y: size > 40 ? 2 : 1)
        .accessibilityLabel("\(schoolName) logo")
    }



    static func loadImage(for school: String) -> UIImage? {
        guard let assetName = SchoolDatabase.logoMap[school] else { return nil }

        if let img = UIImage(named: assetName) { return img }


        for ext in ["png", "jpg", "jpeg", "heic", "webp"] {
            if let path = Bundle.main.path(forResource: assetName, ofType: ext) {
                if let img = UIImage(contentsOfFile: path) { return img }
            }
        }


        let stateFolder = stateFor(school: school)
        for ext in ["png", "jpg", "jpeg"] {
            if let url = Bundle.main.url(forResource: assetName, withExtension: ext, subdirectory: "Collegelogos/\(stateFolder)") {
                if let img = UIImage(contentsOfFile: url.path) { return img }
            }
            if let url = Bundle.main.url(forResource: assetName, withExtension: ext, subdirectory: "Collegelogos") {
                if let img = UIImage(contentsOfFile: url.path) { return img }
            }
        }


        if let resourcePath = Bundle.main.resourcePath {
            let fm = FileManager.default
            if let enumerator = fm.enumerator(atPath: resourcePath) {
                while let file = enumerator.nextObject() as? String {
                    let lower = file.lowercased()
                    let target = assetName.lowercased()
                    if lower.contains(target) && (lower.hasSuffix(".png") || lower.hasSuffix(".jpg") || lower.hasSuffix(".jpeg")) {
                        let fullPath = (resourcePath as NSString).appendingPathComponent(file)
                        if let img = UIImage(contentsOfFile: fullPath) { return img }
                    }
                }
            }
        }

        return nil
    }

    private static func stateFor(school: String) -> String {
        for (state, data) in SchoolDatabase.stateData {
            if data.ccs.contains(school) || data.unis.contains(school) { return state }
        }
        return ""
    }
}




@available(iOS 17.0, *)
struct ViabilityRing: View, Animatable {
    let score: Int
    var animated: CGFloat
    var size: CGFloat = 180

    nonisolated var animatableData: CGFloat {
        get { animated }
        set { animated = newValue }
    }

    var gradient: [Color] { TTBrand.gradient(for: Int(animated)) }

    private var scoreLabel: String {
        let s = Int(animated)
        if s >= 75 { return "Strong" }
        else if s >= 50 { return "Moderate" }
        else { return "At Risk" }
    }

    var body: some View {
        ZStack {

            Circle()
                .stroke(Color(uiColor: .systemFill).opacity(0.5), lineWidth: size > 80 ? 8 : 4)


            Circle()
                .trim(from: 0, to: max(0.001, animated / 100))
                .stroke(
                    AngularGradient(
                        colors: gradient + [gradient.first ?? .green],
                        center: .center,
                        startAngle: .degrees(-90),
                        endAngle: .degrees(270)
                    ),
                    style: StrokeStyle(lineWidth: size > 80 ? 8 : 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))


            Circle()
                .trim(from: 0, to: max(0.001, animated / 100))
                .stroke(
                    gradient.first ?? .green,
                    style: StrokeStyle(lineWidth: size > 80 ? 12 : 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .blur(radius: 8)
                .opacity(0.4)


            VStack(spacing: 1) {
                Text("\(Int(animated))")
                    .font(.system(size > 80 ? .title2 : .caption2, design: .rounded).weight(.bold))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                if size > 60 {
                    Text("/100")
                        .font(.system(.caption2, design: .rounded))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Viability Score: \(score) out of 100, \(scoreLabel)")
    }
}



@available(iOS 17.0, *)
struct StatCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let valueColor: Color
    var subtitle: String? = nil
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundStyle(iconColor)
                .padding(6)
                .background(iconColor.opacity(colorScheme == .dark ? 0.20 : 0.12))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(title)
                .font(.system(.caption2, design: .rounded).weight(.bold))
                .textCase(.uppercase)
                .tracking(0.8)
                .foregroundStyle(.secondary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(value)
                .font(.system(.callout, design: .rounded).weight(.bold))
                .monospacedDigit()
                .foregroundStyle(valueColor)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            if let sub = subtitle {
                Text(sub)
                    .font(.caption2)
                    .monospacedDigit()
                    .foregroundStyle(.secondary)
            }

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .glassCard(radius: 16, padding: 12)
        .accessibilityElement(children: .combine)
    }
}




struct OddsBadge: View {
    let odds: String
    let detail: String
    @Environment(\.colorScheme) private var colorScheme

    private var color: Color {
        switch odds {
        case "High Odds": return TTBrand.mint
        case "Medium Odds": return TTBrand.amber
        case "Low Odds": return TTBrand.coral
        default: return .gray
        }
    }

    private var shapeIcon: String {
        switch odds {
        case "High Odds": return "checkmark.circle.fill"
        case "Medium Odds": return "minus.circle.fill"
        case "Low Odds": return "xmark.circle.fill"
        default: return "questionmark.circle.fill"
        }
    }

    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: shapeIcon).font(.caption2)
            Text("\(odds) — \(detail)")
                .font(.system(.caption, design: .rounded).weight(.medium))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(color.opacity(colorScheme == .dark ? 0.18 : 0.12))
        .clipShape(Capsule())
    }
}




struct ConfettiParticle: Identifiable {
    let id = UUID()
    var x: CGFloat
    var y: CGFloat
    var size: CGFloat
    var color: Color
    var opacity: Double
}
