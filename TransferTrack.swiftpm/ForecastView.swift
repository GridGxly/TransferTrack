import SwiftUI
import Charts

@available(iOS 17.0, *)
struct ForecastTab: View {
    @Bindable var vm: TransferViewModel

    @State private var animatedScore: CGFloat = 0
    @State private var showCards = false
    @State private var selectedChartSchool: String? = nil

    private var runwayMonths: Int {
        if vm.monthlyGap >= 0 { return -1 }
        return max(0, Int(vm.userSavings / Double(abs(vm.monthlyGap))))
    }

    private var runwayText: String {
        runwayMonths == -1 ? "Stable" : "\(runwayMonths) mo"
    }

    private var transportLabels: [String] { ["Keep Car", "Sell/Swap", "Transit"] }
    private var transportIcons: [String] { ["car.fill", "car.side.front.open.fill", "bus.fill"] }

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Monthly Gap")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                    Text("\(vm.monthlyGap >= 0 ? "+" : "")$\(vm.monthlyGap)")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(vm.monthlyGap >= 0 ? .green : Color(red: 1, green: 0.3, blue: 0.3))
                        .contentTransition(.numericText())
                        .minimumScaleFactor(0.5)
                        .lineLimit(1)
                    Text("per month after transfer")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                ViabilityRing(score: vm.viabilityScore, animated: animatedScore, size: 80)
            }
            .padding(20)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, 20)
            .onAppear {
                withAnimation(.spring(response: 1.2, dampingFraction: 0.7).delay(0.3)) {
                    animatedScore = CGFloat(vm.viabilityScore)
                }
                withAnimation(.easeOut(duration: 0.6).delay(0.5)) { showCards = true }
            }

            if vm.solutionMonthlyBonus > 0 {
                HStack(spacing: 8) {
                    Image(systemName: "arrow.up.circle.fill").foregroundStyle(.green)
                    Text("Solutions saving you +$\(vm.solutionMonthlyBonus)/mo")
                        .font(.caption.weight(.medium)).foregroundStyle(.green)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(Color.green.opacity(0.1))
                .clipShape(Capsule())
                .padding(.horizontal, 20)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }

            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    Image(systemName: transportIcons[vm.transportMode])
                        .font(.callout)
                        .foregroundStyle(.blue)
                        .padding(6)
                        .background(Color.blue.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    Text("Transport").font(.caption).foregroundStyle(.secondary)
                    Text("+$\(vm.transportCost)/mo")
                        .font(.callout.weight(.bold))
                        .contentTransition(.numericText())
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
                        }
                    }
                    .padding(2)
                    .background(Color.gray.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    Spacer(minLength: 0)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))

                StatCard(
                    icon: "book.closed.fill",
                    iconColor: vm.creditsAtRisk > 0 ? .orange : .green,
                    title: "Credits at Risk",
                    value: "\(vm.creditsAtRisk) cr",
                    valueColor: vm.creditsAtRisk > 0 ? .orange : .green,
                    subtitle: vm.creditsAtRisk > 0 ? "~$\(vm.creditsAtRiskCost.formatted())" : nil
                )

                StatCard(
                    icon: vm.monthlyGap >= 0 ? "checkmark.circle.fill" : "clock.fill",
                    iconColor: vm.monthlyGap >= 0 ? .green : .orange,
                    title: "Runway",
                    value: runwayText,
                    valueColor: vm.monthlyGap >= 0 ? .green : .orange,
                    subtitle: "$\(Int(vm.userSavings).formatted()) saved"
                )
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 20)
            .opacity(showCards ? 1 : 0)
            .offset(y: showCards ? 0 : 12)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Tuition Jump").font(.headline)
                    Spacer()
                    Text("+$\(vm.tuitionJump / 12)/mo")
                        .font(.subheadline.weight(.bold))
                        .contentTransition(.numericText())
                }
                Chart([
                    TuitionEntry(school: vm.selectedCC, amount: vm.ccTuition, isCC: true),
                    TuitionEntry(school: vm.selectedUni, amount: vm.uniTuition, isCC: false)
                ]) { entry in
                    BarMark(x: .value("Tuition", entry.amount), y: .value("School", entry.school))
                        .foregroundStyle(entry.isCC ? Color.green.opacity(0.7) : Color.orange.opacity(0.8))
                        .cornerRadius(6)
                        .annotation(position: .trailing, spacing: 6) {
                            Text("$\(entry.amount.formatted())")
                                .font(.caption.weight(.semibold))
                        }
                }
                .chartXAxis(.hidden)
                .chartYAxis { AxisMarks { _ in AxisValueLabel().font(.caption) } }
                .chartYSelection(value: $selectedChartSchool)
                .frame(height: 80)

                if let school = selectedChartSchool {
                    let amount = school == vm.selectedCC ? vm.ccTuition : vm.uniTuition
                    Text("\(school): $\(amount.formatted())/year")
                        .font(.caption.weight(.medium)).foregroundStyle(.blue)
                        .transition(.opacity)
                }

                Text("\(vm.selectedCC) → \(vm.selectedUni) · per year")
                    .font(.caption2).foregroundStyle(.secondary)
            }
            .padding(16)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 20)
            .opacity(showCards ? 1 : 0)

            VStack(alignment: .leading, spacing: 10) {
                Text("Score Breakdown").font(.headline)
                HStack(spacing: 16) {
                    ScoreFactorRow(label: "GPA", value: String(format: "%.2f", vm.userGPA), icon: "chart.bar.fill", good: vm.userGPA >= 3.0)
                    ScoreFactorRow(label: "Credits", value: "\(Int(vm.userCredits))", icon: "book.fill", good: vm.userCredits >= 45)
                    ScoreFactorRow(label: "Savings", value: "$\(Int(vm.userSavings).formatted())", icon: "banknote.fill", good: vm.userSavings >= 5000)
                }
            }
            .padding(16)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 20)
            .opacity(showCards ? 1 : 0)
        }
        .animation(.spring(response: 0.4), value: vm.solutionMonthlyBonus)
        .animation(.spring(response: 0.4), value: vm.transportMode)
    }
}

@available(iOS 17.0, *)
struct ScoreFactorRow: View {
    let label: String
    let value: String
    let icon: String
    let good: Bool

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(good ? .green : .orange)
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(.primary)
            Text(label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct TuitionEntry: Identifiable {
    let id = UUID()
    let school: String
    let amount: Int
    let isCC: Bool
}
