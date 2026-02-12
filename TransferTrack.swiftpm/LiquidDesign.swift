import SwiftUI

// MARK: - design tokens

enum TTColors {
    static let background = Color(uiColor: .systemBackground)
    static let cardBg = Color(uiColor: .secondarySystemGroupedBackground)
    static let subtle = Color(uiColor: .tertiarySystemGroupedBackground)
    static let label = Color(uiColor: .label)
    static let secondaryLabel = Color(uiColor: .secondaryLabel)
    static let separator = Color(uiColor: .separator)

    static let accent = Color.blue
    static let success = Color.green
    static let warning = Color.orange
    static let danger = Color.red
    static let purple = Color.purple

    // points currency — one consistent color for Solutions tab
    static let points = Color(red: 0.2, green: 0.7, blue: 0.3)
}

// MARK: - college logo

struct CollegeLogo: View {
    let schoolName: String
    var size: CGFloat = 40

    private var assetName: String? {
        SchoolDatabase.logoMap[schoolName]
    }

    var body: some View {
        Group {
            if let name = assetName, UIImage(named: name) != nil {
                Image(name)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
            } else {
                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.12))
                    Text(initials)
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.blue)
                }
            }
        }
        .frame(width: size, height: size)
        .clipShape(Circle())
    }

    private var initials: String {
        let words = schoolName.split(separator: " ")
        if words.count >= 2 {
            return String(words[0].prefix(1)) + String(words[1].prefix(1))
        }
        return String(schoolName.prefix(2)).uppercased()
    }
}

// MARK: - odds badge

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

    var body: some View {
        Text("\(odds) — \(detail)")
            .font(.caption.weight(.medium))
            .foregroundStyle(color)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(color.opacity(0.1))
            .clipShape(Capsule())
    }
}

// MARK: - viability score ring

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
            Circle()
                .stroke(Color.gray.opacity(0.15), lineWidth: 14)

            Circle()
                .trim(from: 0, to: animated / 100)
                .stroke(color, style: StrokeStyle(lineWidth: 14, lineCap: .round))
                .rotationEffect(.degrees(-90))

            VStack(spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text("\(Int(animated))")
                        .font(.system(.largeTitle, design: .rounded).weight(.bold))
                        .contentTransition(.numericText())
                    Text("/100")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.secondary)
                }
                Text("Viability Score")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - stat card

struct StatCard: View {
    let icon: String
    let iconColor: Color
    let title: String
    let value: String
    let valueColor: Color
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(iconColor)
                .padding(8)
                .background(iconColor.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)

            Text(value)
                .font(.title2.weight(.bold))
                .foregroundStyle(valueColor)
                .minimumScaleFactor(0.7)
                .lineLimit(1)

            if let sub = subtitle {
                Text(sub)
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(TTColors.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
    }
}

// MARK: - section header

struct SectionHeader: View {
    let title: String
    var subtitle: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title3.weight(.semibold))
            if let sub = subtitle {
                Text(sub)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

// MARK: - floating capsule tab bar

@available(iOS 17.0, *)
struct FloatingTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [(icon: String, label: String)]
    @Namespace private var tabNamespace

    var body: some View {
        HStack(spacing: 4) {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                Button {
                    withAnimation(.spring(response: 0.35, dampingFraction: 0.75)) {
                        selectedTab = index
                    }
                    let impact = UIImpactFeedbackGenerator(style: .light)
                    impact.impactOccurred()
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: tab.icon)
                            .font(.subheadline)
                            .symbolVariant(selectedTab == index ? .fill : .none)

                        if selectedTab == index {
                            Text(tab.label)
                                .font(.caption.weight(.semibold))
                                .lineLimit(1)
                        }
                    }
                    .foregroundStyle(selectedTab == index ? .white : .secondary)
                    .padding(.horizontal, selectedTab == index ? 16 : 14)
                    .padding(.vertical, 10)
                    .background {
                        if selectedTab == index {
                            Capsule()
                                .fill(TTColors.accent)
                                .matchedGeometryEffect(id: "activeTab", in: tabNamespace)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(6)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.white.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.15), radius: 10, y: 5)
    }
}
