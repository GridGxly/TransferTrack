import SwiftUI
import Charts

// MARK: - forecast tab

@available(iOS 17.0, *)
struct ForecastTab: View {
    @Bindable var vm: TransferViewModel

    @State private var animatedScore: CGFloat = 0
    @State private var showCards = false
    @State private var selectedChartSchool: String? = nil

    private var viabilityDescription: String {
        if vm.viabilityScore >= 75 {
            return "You're academically and financially on track for a smooth transfer."
        } else if vm.viabilityScore >= 50 {
            return "Academically ready, but financially at risk. Check Solutions."
        } else {
            return "Your transfer plan needs work. Review Solutions immediately."
        }
    }

    private var tuitionJumpMonthly: Int { vm.tuitionJump / 12 }

    private var runwayMonths: Int {
        if vm.monthlyGap >= 0 { return -1 }
        return max(0, Int(vm.userSavings / Double(abs(vm.monthlyGap))))
    }

    private var runwayText: String {
        if runwayMonths == -1 { return "Stable" }
        return runwayMonths == 0 ? "0 mo" : "\(runwayMonths) mo"
    }

    private var transportLabels: [String] { ["Keep Car", "Sell/Swap", "Transit"] }
    private var transportIcons: [String] { ["car.fill", "car.side.front.open.fill", "bus.fill"] }

    private var tuitionChartData: [TuitionEntry] {
        [
            TuitionEntry(school: vm.selectedCC, amount: vm.ccTuition, isCC: true),
            TuitionEntry(school: vm.selectedUni, amount: vm.uniTuition, isCC: false)
        ]
    }

    var body: some View {
        VStack(spacing: 16) {
            // MARK: viability score
            VStack(spacing: 12) {
                ViabilityRing(score: vm.viabilityScore, animated: animatedScore, size: 150)

                Text(viabilityDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(TTColors.subtle)
                    .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(TTColors.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, 20)
            .onAppear {
                withAnimation(.spring(response: 1.2, dampingFraction: 0.7).delay(0.3)) {
                    animatedScore = CGFloat(vm.viabilityScore)
                }
                withAnimation(.easeOut(duration: 0.6).delay(0.5)) { showCards = true }
            }

            // MARK: stat cards
            HStack(spacing: 12) {
                StatCard(
                    icon: "dollarsign.circle.fill",
                    iconColor: vm.monthlyGap >= 0 ? .green : .red,
                    title: "Monthly Gap",
                    value: "\(vm.monthlyGap >= 0 ? "+" : "")$\(vm.monthlyGap)/mo",
                    valueColor: vm.monthlyGap >= 0 ? .green : Color(red: 1, green: 0.3, blue: 0.3)
                )

                // MARK: transport mode card
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: transportIcons[vm.transportMode])
                        .font(.title3)
                        .foregroundStyle(.blue)
                        .padding(8)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8, style: .continuous))
                    Text("Transport")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("+$\(vm.transportCost)/mo")
                        .font(.title3.weight(.bold))
                        .contentTransition(.numericText())
                        .animation(.spring(response: 0.3), value: vm.transportCost)

                    // segmented control
                    HStack(spacing: 2) {
                        ForEach(0..<3, id: \.self) { mode in
                            Button {
                                withAnimation(.spring(response: 0.3)) { vm.transportMode = mode }
                                UIImpactFeedbackGenerator(style: .light).impactOccurred()
                            } label: {
                                Image(systemName: transportIcons[mode])
                                    .font(.caption2)
                                    .foregroundStyle(vm.transportMode == mode ? .white : .secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 4)
                                    .background(vm.transportMode == mode ? Color.blue : Color.clear)
                                    .clipShape(RoundedRectangle(cornerRadius: 4))
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel(transportLabels[mode])
                            .accessibilityAddTraits(vm.transportMode == mode ? .isSelected : [])
                        }
                    }
                    .padding(2)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(TTColors.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                StatCard(
                    icon: "book.closed.fill",
                    iconColor: vm.creditsAtRisk > 0 ? .orange : .green,
                    title: "Credits at Risk",
                    value: "\(vm.creditsAtRisk) cr",
                    valueColor: vm.creditsAtRisk > 0 ? .orange : .green,
                    subtitle: vm.creditsAtRisk > 0 ? "~$\(vm.creditsAtRiskCost.formatted()) loss" : nil
                )
            }
            .padding(.horizontal, 20)
            .opacity(showCards ? 1 : 0)
            .offset(y: showCards ? 0 : 12)

            // MARK: tuition chart
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Tuition Jump")
                        .font(.headline)
                    Spacer()
                    Text("+$\(tuitionJumpMonthly)/mo")
                        .font(.subheadline.weight(.bold))
                        .contentTransition(.numericText())
                }

                Chart(tuitionChartData) { entry in
                    BarMark(
                        x: .value("Tuition", entry.amount),
                        y: .value("School", entry.school)
                    )
                    .foregroundStyle(entry.isCC ? Color.green.opacity(0.7) : Color.orange.opacity(0.8))
                    .cornerRadius(6)
                    .annotation(position: .trailing, spacing: 6) {
                        Text("$\(entry.amount.formatted())")
                            .font(.caption.weight(.semibold))
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks { _ in AxisValueLabel().font(.caption) }
                }
                .chartYSelection(value: $selectedChartSchool)
                .frame(height: 80)
                .accessibilityLabel("Tuition comparison. \(vm.selectedCC): $\(vm.ccTuition). \(vm.selectedUni): $\(vm.uniTuition).")

                // chart selection detail
                if let school = selectedChartSchool {
                    let amount = school == vm.selectedCC ? vm.ccTuition : vm.uniTuition
                    Text("\(school): $\(amount.formatted())/year")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.blue)
                        .transition(.opacity)
                }

                Text("\(vm.selectedCC) → \(vm.selectedUni) · per year")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(TTColors.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 20)
            .opacity(showCards ? 1 : 0)

            // MARK: savings and runway
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "banknote.fill").foregroundStyle(.blue)
                        Text("Savings").font(.caption).foregroundStyle(.secondary)
                    }
                    Text("$\(Int(vm.userSavings).formatted())")
                        .font(.title3.weight(.bold))
                        .contentTransition(.numericText())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(TTColors.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: vm.monthlyGap >= 0 ? "checkmark.circle.fill" : "clock.fill")
                            .foregroundStyle(vm.monthlyGap >= 0 ? .green : .orange)
                        Text("Runway").font(.caption).foregroundStyle(.secondary)
                    }
                    Text(runwayText)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(vm.monthlyGap >= 0 ? .green : .orange)
                        .contentTransition(.numericText())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(TTColors.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(.horizontal, 20)
            .opacity(showCards ? 1 : 0)

            // MARK: solutions impact toast
            if vm.solutionMonthlyBonus > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.circle.fill")
                        .foregroundStyle(.green)
                    Text("Solutions saving you +$\(vm.solutionMonthlyBonus)/mo")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.green)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.green.opacity(0.1))
                .clipShape(Capsule())
                .padding(.horizontal, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.4), value: vm.solutionMonthlyBonus)
        .animation(.spring(response: 0.4), value: vm.transportMode)
    }
}

struct TuitionEntry: Identifiable {
    let id = UUID()
    let school: String
    let amount: Int
    let isCC: Bool
}
