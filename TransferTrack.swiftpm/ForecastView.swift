import SwiftUI
import Charts

// MARK: - forecast tab

@available(iOS 17.0, *)
struct ForecastTab: View {
    let score: Int
    let gap: Int
    let savings: Double
    let rent: Double
    let ccName: String
    let uniName: String

    @State private var animatedScore: CGFloat = 0
    @State private var showCards = false

    private var viabilityDescription: String {
        if score >= 75 {
            return "You're academically and financially on track for a smooth transfer."
        } else if score >= 50 {
            return "Academically ready, but financially at risk. Check Solutions."
        } else {
            return "Your transfer plan needs work. Review Solutions immediately."
        }
    }

    private var creditsAtRisk: Int {
        let courses = SchoolDatabase.courses(from: ccName, to: uniName)
        return courses.filter { !$0.transfers }.reduce(0) { $0 + $1.credits }
    }

    private var creditsAtRiskCost: Int {
        let courses = SchoolDatabase.courses(from: ccName, to: uniName)
        return courses.filter { !$0.transfers }.reduce(0) { $0 + $1.costIfWasted }
    }

    private var commuteCost: Int {
        return rent > 800 ? 60 : 120
    }

    private var ccTuition: Int { SchoolDatabase.ccTuition[ccName] ?? 3000 }
    private var uniTuition: Int { SchoolDatabase.uniTuition[uniName] ?? 8000 }
    private var tuitionJump: Int { uniTuition - ccTuition }
    private var tuitionJumpMonthly: Int { tuitionJump / 12 }

    private var runwayMonths: Int {
        if gap >= 0 { return -1 } // stable
        return max(0, Int(savings / Double(abs(gap))))
    }

    private var runwayText: String {
        if runwayMonths == -1 { return "Stable" }
        return runwayMonths == 0 ? "0 mo" : "\(runwayMonths) mo"
    }

    private var runwayIsStable: Bool { gap >= 0 }

    // MARK: - swift charts data model
    private var tuitionChartData: [TuitionEntry] {
        [
            TuitionEntry(school: ccName, amount: ccTuition, color: "green"),
            TuitionEntry(school: uniName, amount: uniTuition, color: "orange")
        ]
    }

    var body: some View {
        VStack(spacing: 16) {
            // MARK: Viability Score
            VStack(spacing: 12) {
                ViabilityRing(score: score, animated: animatedScore, size: 150)

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
                    animatedScore = CGFloat(score)
                }
                withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
                    showCards = true
                }
            }

            // MARK: stat cards
            HStack(spacing: 12) {
                StatCard(
                    icon: "dollarsign.circle.fill",
                    iconColor: gap >= 0 ? .green : .red,
                    title: "Monthly Gap",
                    value: "\(gap >= 0 ? "+" : "")$\(gap)/mo",
                    valueColor: gap >= 0 ? .green : .red
                )

                StatCard(
                    icon: "car.fill",
                    iconColor: .blue,
                    title: "Commute",
                    value: "+$\(commuteCost)/mo",
                    valueColor: .primary
                )

                StatCard(
                    icon: "book.closed.fill",
                    iconColor: creditsAtRisk > 0 ? .orange : .green,
                    title: "Credits at Risk",
                    value: "\(creditsAtRisk) cr",
                    valueColor: creditsAtRisk > 0 ? .orange : .green,
                    subtitle: creditsAtRisk > 0 ? "~$\(creditsAtRiskCost.formatted()) loss" : nil
                )
            }
            .padding(.horizontal, 20)
            .opacity(showCards ? 1 : 0)
            .offset(y: showCards ? 0 : 12)

            // MARK: tuition comparison using swiift charts
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Tuition Jump")
                        .font(.headline)
                    Spacer()
                    Text("+$\(tuitionJumpMonthly)/mo")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                }

                Chart(tuitionChartData) { entry in
                    BarMark(
                        x: .value("Tuition", entry.amount),
                        y: .value("School", entry.school)
                    )
                    .foregroundStyle(entry.school == ccName ? Color.green.opacity(0.7) : Color.orange.opacity(0.8))
                    .cornerRadius(6)
                    .annotation(position: .trailing, spacing: 6) {
                        Text("$\(entry.amount.formatted())")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.primary)
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks { value in
                        AxisValueLabel()
                            .font(.caption)
                    }
                }
                .frame(height: 80)
                .accessibilityLabel("Tuition comparison chart. \(ccName): $\(ccTuition). \(uniName): $\(uniTuition). Jump of $\(tuitionJump) per year.")

                Text("\(ccName) → \(uniName) · per year")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(TTColors.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 20)
            .opacity(showCards ? 1 : 0)

            // MARK: savings plus runway
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "banknote.fill")
                            .foregroundStyle(.blue)
                        Text("Savings")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text("$\(Int(savings).formatted())")
                        .font(.title3.weight(.bold))
                        .contentTransition(.numericText())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(TTColors.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Savings: $\(Int(savings).formatted())")

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: runwayIsStable ? "checkmark.circle.fill" : "clock.fill")
                            .foregroundStyle(runwayIsStable ? .green : (savings <= 0 ? .red : .orange))
                        Text("Runway")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(runwayText)
                        .font(.title3.weight(.bold))
                        .foregroundStyle(
                            runwayIsStable ? .green :
                            (savings <= 0 ? .red : .orange)
                        )
                        .contentTransition(.numericText())
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(TTColors.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .accessibilityElement(children: .combine)
                .accessibilityLabel("Runway: \(runwayText)\(runwayIsStable ? ". Financially stable." : ". You have \(runwayMonths) months before savings run out.")")
            }
            .padding(.horizontal, 20)
            .opacity(showCards ? 1 : 0)
        }
    }
}

// MARK: - chart data model

struct TuitionEntry: Identifiable {
    let id = UUID()
    let school: String
    let amount: Int
    let color: String
}
