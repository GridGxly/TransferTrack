import SwiftUI

// MARK: - solutions tab

@available(iOS 17.0, *)
struct SolutionsTab: View {
    let score: Int
    let uniName: String
    let ccName: String
    let state: String

    @State private var completedItems: Set<Int> = []
    @State private var animatedScore: Int

    init(score: Int, uniName: String, ccName: String, state: String) {
        self.score = score
        self.uniName = uniName
        self.ccName = ccName
        self.state = state
        self._animatedScore = State(initialValue: score)
    }

    private var solutions: [SchoolDatabase.Solution] {
        SchoolDatabase.solutions(for: uniName, from: ccName, state: state)
    }

    private var totalPoints: Int {
        solutions.reduce(0) { $0 + $1.points }
    }

    private var earnedPoints: Int {
        completedItems.reduce(0) { total, idx in
            idx < solutions.count ? total + solutions[idx].points : total
        }
    }

    var body: some View {
        VStack(spacing: 20) {
            // MARK: header with progress
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(
                    title: "Improve Your Score",
                    subtitle: "Complete actions to boost your Viability Score."
                )

                HStack(spacing: 12) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.gray.opacity(0.15))
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(TTColors.points)
                                .frame(width: totalPoints > 0 ? geo.size.width * CGFloat(earnedPoints) / CGFloat(totalPoints) : 0, height: 8)
                                .animation(.spring(response: 0.4), value: earnedPoints)
                        }
                    }
                    .frame(height: 8)

                    Text("\(earnedPoints)/\(totalPoints) pts")
                        .font(.caption.weight(.bold))
                        .foregroundStyle(TTColors.points)
                        .frame(width: 70, alignment: .trailing)
                }
            }
            .padding(.horizontal, 20)

            // MARK: solution items
            VStack(spacing: 0) {
                ForEach(Array(solutions.enumerated()), id: \.offset) { index, solution in
                    SolutionRow(
                        title: solution.title,
                        description: solution.description,
                        points: solution.points,
                        icon: solution.icon,
                        isCompleted: completedItems.contains(index),
                        onToggle: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                                if completedItems.contains(index) {
                                    completedItems.remove(index)
                                } else {
                                    completedItems.insert(index)
                                    let impact = UIImpactFeedbackGenerator(style: .light)
                                    impact.impactOccurred()
                                }
                                let bonus = completedItems.reduce(0) { total, idx in
                                    idx < solutions.count ? total + solutions[idx].points : total
                                }
                                animatedScore = score + bonus
                            }
                        }
                    )

                    if index < solutions.count - 1 {
                        Divider()
                            .padding(.horizontal, 16)
                    }
                }
            }
            .padding(.vertical, 4)
            .background(TTColors.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, 20)
        }
    }
}

// MARK: - solution row

struct SolutionRow: View {
    let title: String
    let description: String
    let points: Int
    let icon: String
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(isCompleted ? TTColors.points : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isCompleted {
                        Circle()
                            .fill(TTColors.points)
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }

                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 20)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(isCompleted ? .secondary : .primary)
                        .strikethrough(isCompleted)
                    Text(description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(2)
                }

                Spacer()

                Text("+\(points) pts")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(TTColors.points)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}
