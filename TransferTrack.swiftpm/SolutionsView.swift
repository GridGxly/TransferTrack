import SwiftUI

// MARK: - solutions tab (connected to forecast via ViewModel)

@available(iOS 17.0, *)
struct SolutionsTab: View {
    @Bindable var vm: TransferViewModel

    @State private var animatedScore: Int
    @State private var showCelebration = false
    @State private var previouslyGreen: Bool

    init(vm: TransferViewModel) {
        self.vm = vm
        _animatedScore = State(initialValue: vm.viabilityScore)
        _previouslyGreen = State(initialValue: vm.viabilityScore >= 75)
    }

    private var solutions: [SchoolDatabase.Solution] {
        SchoolDatabase.solutions(for: vm.selectedUni, from: vm.selectedCC, state: vm.selectedState)
    }

    private var totalPoints: Int {
        solutions.reduce(0) { $0 + $1.points }
    }

    private var earnedPoints: Int {
        vm.completedSolutions.reduce(0) { total, idx in
            idx < solutions.count ? total + solutions[idx].points : total
        }
    }

    private var projectedScore: Int {
        min(100, vm.viabilityScore + earnedPoints)
    }

    private var scoreColor: Color {
        if projectedScore >= 75 { return .green }
        else if projectedScore >= 50 { return .orange }
        else { return .red }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                // MARK: projected score card
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Improve Your Score")
                                .font(.title3.weight(.semibold))
                            Text("Complete actions to boost your Viability Score.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()

                        // mini viability ring
                        ZStack {
                            Circle()
                                .stroke(Color.gray.opacity(0.15), lineWidth: 4)
                                .frame(width: 50, height: 50)
                            Circle()
                                .trim(from: 0, to: CGFloat(projectedScore) / 100)
                                .stroke(scoreColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                                .frame(width: 50, height: 50)
                                .rotationEffect(.degrees(-90))
                            Text("\(projectedScore)")
                                .font(.system(.caption, design: .rounded).weight(.bold))
                                .foregroundStyle(scoreColor)
                                .contentTransition(.numericText())
                        }
                    }

                    // progress bar
                    HStack(spacing: 12) {
                        ProgressView(value: Double(earnedPoints), total: Double(max(1, totalPoints)))
                            .tint(TTColors.points)

                        Text("\(earnedPoints)/\(totalPoints) pts")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(TTColors.points)
                            .frame(width: 70, alignment: .trailing)
                            .contentTransition(.numericText())
                    }

                    // monthly impact banner
                    if vm.solutionMonthlyBonus > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "chart.line.uptrend.xyaxis")
                                .foregroundStyle(.green)
                            Text("Saving +$\(vm.solutionMonthlyBonus)/mo from completed actions")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.green)
                        }
                        .padding(8)
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .padding(20)
                .background(TTColors.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, 20)

                // MARK: solution items
                VStack(spacing: 0) {
                    ForEach(Array(solutions.enumerated()), id: \.element.id) { index, solution in
                        SolutionRow(
                            title: solution.title,
                            description: solution.description,
                            points: solution.points,
                            icon: solution.icon,
                            color: solution.color,
                            monthlyImpact: solution.monthlyImpact,
                            isCompleted: vm.completedSolutions.contains(index),
                            onToggle: { toggleItem(index) }
                        )

                        if index < solutions.count - 1 {
                            Divider().padding(.horizontal, 16)
                        }
                    }
                }
                .padding(.vertical, 4)
                .background(TTColors.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                .padding(.horizontal, 20)
            }

            // MARK: celebration overlay (GPU-rendered)
            if showCelebration {
                CelebrationView()
                    .drawingGroup(opaque: false, colorMode: .linear) // Metal GPU rendering
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
        .sensoryFeedback(.success, trigger: showCelebration)
        .animation(.spring(response: 0.4), value: vm.solutionMonthlyBonus)
    }

    // MARK: - toggle

    private func toggleItem(_ index: Int) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            if vm.completedSolutions.contains(index) {
                vm.completedSolutions.remove(index)
            } else {
                vm.completedSolutions.insert(index)
            }
            animatedScore = projectedScore
        }

        let newScore = projectedScore
        if newScore >= 75 && !previouslyGreen {
            previouslyGreen = true
            triggerCelebration()
        } else if newScore < 75 {
            previouslyGreen = false
        }
    }

    private func triggerCelebration() {
        withAnimation(.easeIn(duration: 0.2)) { showCelebration = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.5)) { showCelebration = false }
        }
    }
}

// MARK: - solution row

@available(iOS 17.0, *)
struct SolutionRow: View {
    let title: String
    let description: String
    let points: Int
    let icon: String
    let color: Color
    let monthlyImpact: Int
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
                        Circle().fill(TTColors.points).frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }

                Image(systemName: icon)
                    .font(.caption)
                    .foregroundStyle(color)
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
                    if monthlyImpact > 0 {
                        Text("Saves ~$\(monthlyImpact)/mo")
                            .font(.caption2.weight(.medium))
                            .foregroundStyle(.green)
                    }
                }

                Spacer()

                Text("+\(points) pts")
                    .font(.caption.weight(.bold))
                    .foregroundStyle(isCompleted ? .secondary : TTColors.points)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.impact(weight: .light), trigger: isCompleted)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(points) points. \(isCompleted ? "Completed" : "Not completed")")
        .accessibilityHint("Double tap to \(isCompleted ? "unmark" : "mark as completed")")
    }
}

// MARK: - optimized celebration view

@available(iOS 17.0, *)
struct CelebrationView: View {
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 8) {
                    if #available(iOS 18.0, *) {
                        Image(systemName: "star.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.yellow)
                            .symbolEffect(.bounce)
                    } else {
                        // Fallback for iOS 17: simple scaling effect
                        Image(systemName: "star.fill")
                            .font(.largeTitle)
                            .foregroundStyle(.yellow)
                            .scaleEffect(1.1)
                            .animation(
                                .easeInOut(duration: 0.6)
                                    .repeatForever(autoreverses: true),
                                value: particles.count // ties animation to something that changes once
                            )
                    }

                    Text("Score is Green!")
                        .font(.title2.weight(.bold))
                        .foregroundStyle(.white)
                    Text("You're on track for a smooth transfer")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.8))
                }
                .padding(24)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                ForEach(particles) { p in
                    Circle()
                        .fill(p.color)
                        .frame(width: p.size, height: p.size)
                        .position(x: p.x, y: p.y)
                        .opacity(p.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear { spawnParticles(in: geo.size) }
        }
    }

    private func spawnParticles(in size: CGSize) {
        let colors: [Color] = [.green, .yellow, .blue, .orange, .purple, .cyan]
        for i in 0..<30 {
            let p = ConfettiParticle(
                x: CGFloat.random(in: 0...size.width), y: -20,
                size: CGFloat.random(in: 4...10),
                color: colors[i % colors.count], opacity: 1.0
            )
            particles.append(p)
            withAnimation(.easeIn(duration: Double.random(in: 1.0...2.0)).delay(Double(i) * 0.03)) {
                if let idx = particles.firstIndex(where: { $0.id == p.id }) {
                    particles[idx].y = size.height + 20
                    particles[idx].x += CGFloat.random(in: -50...50)
                    particles[idx].opacity = 0
                }
            }
        }
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
