import SwiftUI



enum AppTheme: String, CaseIterable, Identifiable {
    case system, light, dark
    var id: String { rawValue }

    var label: String {
        switch self {
        case .system: return "System"
        case .light: return "Light"
        case .dark: return "Dark"
        }
    }

    var icon: String {
        switch self {
        case .system: return "circle.lefthalf.filled"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }

    var colorScheme: ColorScheme? {
        switch self {
        case .system: return nil
        case .light: return .light
        case .dark: return .dark
        }
    }
}



enum TTColors {
    static let brandGreen = Color(red: 0.2, green: 0.78, blue: 0.35)
    static let brandOrange = Color(red: 1.0, green: 0.58, blue: 0.0)

    static let cardBg = Color(uiColor: .secondarySystemGroupedBackground)
    static let subtle = Color(uiColor: .tertiarySystemGroupedBackground)
    static let pageBg = Color(uiColor: .systemGroupedBackground)

    static let accent = Color.blue
    static let success = Color.green
    static let warning = Color.orange
    static let danger = Color.red

    static let points = brandGreen
    static let mutedIconBg = Color(uiColor: .tertiarySystemFill)
}


struct CollegeLogo: View {
    let schoolName: String
    var size: CGFloat = 40

    var body: some View {
        Group {
            if let img = Self.loadImage(for: schoolName) {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ZStack {
                    Circle().fill(Color(uiColor: .tertiarySystemFill))
                    Text(initials)
                        .font(.system(size: size * 0.35, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
        .accessibilityLabel("\(schoolName) logo")
    }

    private var initials: String {
        let words = schoolName.split(separator: " ")
        if words.count >= 2 { return String(words[0].prefix(1)) + String(words[1].prefix(1)) }
        return String(schoolName.prefix(2)).uppercased()
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



struct OddsBadge: View {
    let odds: String
    let detail: String

    private var color: Color {
        switch odds {
        case "High Odds": return .green
        case "Medium Odds": return .orange
        case "Low Odds": return .red
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
            Text("\(odds) — \(detail)").font(.caption.weight(.medium))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 4)
        .background(color.opacity(0.1))
        .clipShape(Capsule())
    }
}



struct ViabilityRing: View {
    let score: Int
    let animated: CGFloat
    var size: CGFloat = 180

    var color: Color {
        if score >= 75 { return .green }
        else if score >= 50 { return .orange }
        else { return .red }
    }

    var body: some View {
        ZStack {
            Circle().stroke(Color(uiColor: .systemFill), lineWidth: size > 80 ? 8 : 4)
            Circle()
                .trim(from: 0, to: animated / 100)
                .stroke(color, style: StrokeStyle(lineWidth: size > 80 ? 8 : 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 1) {
                Text("\(Int(animated))")
                    .font(.system(size > 80 ? .title2 : .caption2, design: .rounded).weight(.bold))
                    .foregroundStyle(.primary)
                    .contentTransition(.numericText())
                if size > 60 {
                    Text("/100").font(.caption2).foregroundStyle(.secondary)
                }
            }
        }
        .frame(width: size, height: size)
        .accessibilityLabel("Viability Score: \(score) out of 100")
    }
}



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
                .background(iconColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))

            Text(title)
                .font(.caption2.weight(.bold))
                .textCase(.uppercase)
                .tracking(0.8)
                .foregroundStyle(.secondary)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            Text(value)
                .font(.callout.weight(.bold))
                .foregroundStyle(valueColor)
                .minimumScaleFactor(0.6)
                .lineLimit(1)

            if let sub = subtitle {
                Text(sub).font(.caption2).foregroundStyle(.secondary)
            }
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .padding(12)
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .cardBorder(colorScheme: colorScheme, radius: 14)
        .accessibilityElement(children: .combine)
    }
}
