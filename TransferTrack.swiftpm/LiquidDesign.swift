import SwiftUI

enum TTColors {
    static let cardBg = Color(uiColor: .secondarySystemGroupedBackground)
    static let subtle = Color(uiColor: .tertiarySystemGroupedBackground)
    static let accent = Color.blue
    static let success = Color.green
    static let warning = Color.orange
    static let danger = Color.red
    static let points = Color(red: 0.2, green: 0.7, blue: 0.3)
}

struct CollegeLogo: View {
    let schoolName: String
    var size: CGFloat = 40

    var body: some View {
        Group {
            if let assetName = SchoolDatabase.logoMap[schoolName],
               let img = UIImage(named: assetName) {
                Image(uiImage: img)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ZStack {
                    Circle().fill(Color.blue.opacity(0.12))
                    Text(initials)
                        .font(.system(size: size * 0.35, weight: .bold, design: .rounded))
                        .foregroundStyle(.blue)
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
            Circle().stroke(Color.gray.opacity(0.15), lineWidth: size > 80 ? 8 : 4)
            Circle()
                .trim(from: 0, to: animated / 100)
                .stroke(color, style: StrokeStyle(lineWidth: size > 80 ? 8 : 4, lineCap: .round))
                .rotationEffect(.degrees(-90))
            VStack(spacing: 1) {
                Text("\(Int(animated))")
                    .font(.system(size > 80 ? .title2 : .caption2, design: .rounded).weight(.bold))
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

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Image(systemName: icon)
                .font(.callout)
                .foregroundStyle(iconColor)
                .padding(6)
                .background(iconColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 6))
            Text(title).font(.caption).foregroundStyle(.secondary)
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
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .accessibilityElement(children: .combine)
    }
}
