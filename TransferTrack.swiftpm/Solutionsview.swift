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

    var body: some View {
        VStack(spacing: 20) {
            // MARK: header
            VStack(alignment: .leading, spacing: 8) {
                SectionHeader(
                    title: "Improve Your Score",
                    subtitle: "Check off actions to boost your Viability Score."
                )
            }
            .padding(.horizontal, 20)

            // MARK: solution items
            VStack(spacing: 0) {
                ForEach(Array(solutions.enumerated()), id: \.offset) { index, solution in
                    SolutionRow(
                        title: solution.title,
                        description: solution.description,
                        points: solution.points,
                        color: solution.color,
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
    let color: Color
    let isCompleted: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                // circle checkbox
                ZStack {
                    Circle()
                        .stroke(isCompleted ? color : Color.gray.opacity(0.3), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isCompleted {
                        Circle()
                            .fill(color)
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }

                // title + description
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

                // points badge
                Text("+\(points) pts")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isCompleted ? .green : color)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}
