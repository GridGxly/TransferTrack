import SwiftUI

@available(iOS 17.0, *)
struct SolutionsTab: View {
    @Bindable var vm: TransferViewModel

    @State private var showCelebration = false
    @State private var previouslyGreen: Bool

    init(vm: TransferViewModel) {
        self.vm = vm
        _previouslyGreen = State(initialValue: vm.viabilityScore >= 75)
    }

    private var solutions: [SchoolDatabase.Solution] {
        SchoolDatabase.solutions(for: vm.selectedUni, from: vm.selectedCC, state: vm.selectedState)
    }

    private var totalPoints: Int { solutions.reduce(0) { $0 + $1.points } }
    private var earnedPoints: Int {
        vm.completedSolutions.reduce(0) { t, i in i < solutions.count ? t + solutions[i].points : t }
    }

    private var activeSolutions: [(offset: Int, element: SchoolDatabase.Solution)] {
        Array(solutions.enumerated()).filter { !vm.completedSolutions.contains($0.offset) }
    }
    private var completedSolutionsList: [(offset: Int, element: SchoolDatabase.Solution)] {
        Array(solutions.enumerated()).filter { vm.completedSolutions.contains($0.offset) }
    }

    var body: some View {
        ZStack {
            VStack(spacing: 20) {
                VStack(spacing: 12) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Action Plan")
                                .font(.system(.title3, design: .rounded).weight(.semibold))
                            Text("Complete actions to boost your transfer readiness.")
                                .font(.system(.subheadline, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        Text("\(earnedPoints)/\(totalPoints)")
                            .font(.system(.title3, design: .rounded).weight(.bold))
                            .foregroundStyle(TTBrand.mint)
                            .contentTransition(.numericText())
                    }

                    GeometryReader { geo in
                        let progress = totalPoints > 0 ? CGFloat(earnedPoints) / CGFloat(totalPoints) : 0
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color(uiColor: .quaternarySystemFill)).frame(height: 6)
                            Capsule()
                                .fill(
                                    LinearGradient(
                                        colors: TTBrand.gradient(for: vm.viabilityScore),
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .frame(width: max(0, geo.size.width * progress), height: 6)
                                .animation(.spring(response: 0.4), value: earnedPoints)
                        }
                    }
                    .frame(height: 6)

                    if vm.solutionMonthlyBonus > 0 {
                        HStack(spacing: 6) {
                            Image(systemName: "chart.line.uptrend.xyaxis").foregroundStyle(TTBrand.mint)
                            Text("Saving +$\(vm.solutionMonthlyBonus)/mo from completed actions")
                                .font(.system(.caption, design: .rounded).weight(.medium))
                                .foregroundStyle(TTBrand.mint)
                        }
                        .padding(8).frame(maxWidth: .infinity)
                        .background(TTBrand.mint.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                        .transition(.move(edge: .top).combined(with: .opacity))
                    }
                }
                .glassCard(radius: 20, padding: 20)
                .padding(.horizontal, 20)

                if !activeSolutions.isEmpty {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Active")
                                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(activeSolutions.count) remaining")
                                .font(.caption).foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 8)

                        ForEach(Array(activeSolutions.enumerated()), id: \.element.offset) { listIndex, item in
                            SolutionRow(
                                solution: item.element,
                                isCompleted: false,
                                displaySavings: displaySavings(for: item.element),
                                onToggle: { toggleItem(item.offset) }
                            )
                            if listIndex < activeSolutions.count - 1 {
                                Divider().padding(.leading, 54)
                            }
                        }
                    }
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.horizontal, 20)
                }

                if !completedSolutionsList.isEmpty {
                    VStack(spacing: 0) {
                        HStack {
                            Text("Completed")
                                .font(.system(.subheadline, design: .rounded).weight(.semibold))
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text("\(completedSolutionsList.count) done")
                                .font(.caption).foregroundStyle(.tertiary)
                        }
                        .padding(.horizontal, 16).padding(.top, 14).padding(.bottom, 8)

                        ForEach(Array(completedSolutionsList.enumerated()), id: \.element.offset) { listIndex, item in
                            SolutionRow(
                                solution: item.element,
                                isCompleted: true,
                                displaySavings: displaySavings(for: item.element),
                                onToggle: { toggleItem(item.offset) }
                            )
                            if listIndex < completedSolutionsList.count - 1 {
                                Divider().padding(.leading, 54)
                            }
                        }
                    }
                    .background(.regularMaterial)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    .padding(.horizontal, 20)
                }
            }

            if showCelebration {
                CelebrationView()
                    .drawingGroup(opaque: false, colorMode: .linear)
                    .allowsHitTesting(false)
                    .transition(.opacity)
            }
        }
        .sensoryFeedback(.success, trigger: showCelebration)
        .animation(.spring(response: 0.4), value: vm.solutionMonthlyBonus)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: vm.completedSolutions)
    }

    private func displaySavings(for solution: SchoolDatabase.Solution) -> String? {
        if solution.title.contains("Roommate") {
            let split = Int(vm.userRent * 0.3)
            return split > 0 ? "Saves ~$\(split)/mo" : nil
        }
        if solution.monthlyImpact > 0 { return "Saves ~$\(solution.monthlyImpact)/mo" }
        return nil
    }

    private func toggleItem(_ index: Int) {
        UIImpactFeedbackGenerator(style: .light).impactOccurred()
        withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
            if vm.completedSolutions.contains(index) { vm.completedSolutions.remove(index) }
            else { vm.completedSolutions.insert(index) }
        }
        let newScore = vm.viabilityScore
        if newScore >= 75 && !previouslyGreen {
            previouslyGreen = true
            triggerCelebration()
        } else if newScore < 75 { previouslyGreen = false }
    }

    private func triggerCelebration() {
        withAnimation(.easeIn(duration: 0.2)) { showCelebration = true }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            withAnimation(.easeOut(duration: 0.5)) { showCelebration = false }
        }
    }
}

@available(iOS 17.0, *)
struct SolutionRow: View {
    let solution: SchoolDatabase.Solution
    let isCompleted: Bool
    var displaySavings: String? = nil
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 14) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isCompleted ? TTBrand.mint : Color(uiColor: .tertiarySystemFill))
                        .frame(width: 32, height: 32)
                    Image(systemName: isCompleted ? "checkmark" : solution.icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(isCompleted ? .white : .secondary)
                }
                VStack(alignment: .leading, spacing: 2) {
                    Text(solution.title)
                        .font(.system(.subheadline, design: .rounded).weight(.medium))
                        .strikethrough(isCompleted, color: .secondary)
                        .foregroundStyle(isCompleted ? .tertiary : .primary)
                    Text(solution.description)
                        .font(.caption)
                        .strikethrough(isCompleted, color: .secondary)
                        .foregroundStyle(isCompleted ? .tertiary : .secondary)
                        .lineLimit(2)
                    if let savings = displaySavings {
                        Text(savings)
                            .font(.system(.caption2, design: .rounded).weight(.medium))
                            .foregroundStyle(isCompleted ? .tertiary : .secondary)
                    }
                }
                Spacer()
                Text("+\(solution.points)")
                    .font(.system(.caption, design: .rounded).weight(.bold))
                    .foregroundStyle(isCompleted ? .secondary : TTBrand.mint)
            }
            .padding(.horizontal, 16).padding(.vertical, 12)
        }
        .buttonStyle(.plain)
    }
}

@available(iOS 17.0, *)
struct CelebrationView: View {
    @State private var particles: [ConfettiParticle] = []

    var body: some View {
        GeometryReader { geo in
            ZStack {
                VStack(spacing: 8) {
                    Image(systemName: "star.fill").font(.largeTitle).foregroundStyle(.yellow)
                    Text("Score is Green!")
                        .font(.system(.title2, design: .rounded).weight(.bold))
                        .foregroundStyle(.primary)
                    Text("You're on track for a smooth transfer")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                .padding(24)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))

                ForEach(particles) { p in
                    Circle().fill(p.color).frame(width: p.size, height: p.size)
                        .position(x: p.x, y: p.y).opacity(p.opacity)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onAppear { spawn(in: geo.size) }
        }
    }

    private func spawn(in size: CGSize) {
        let colors: [Color] = [TTBrand.mint, .yellow, TTBrand.skyBlue, TTBrand.amber, TTBrand.violet, .cyan]
        for i in 0..<30 {
            let p = ConfettiParticle(x: CGFloat.random(in: 0...size.width), y: -20,
                size: CGFloat.random(in: 4...10), color: colors[i % colors.count], opacity: 1.0)
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
