import SwiftUI

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

    private var runwayText: String {
        if gap >= 0 { return "Stable" }
        let months = max(0, Int(savings / Double(abs(gap))))
        return months == 0 ? "0 months" : "\(months) mo"
    }

    private var runwayIsStable: Bool { gap >= 0 }

    var body: some View {
        VStack(spacing: 16) {
            // MARK: viability score
            VStack(spacing: 12) {
                ViabilityRing(score: score, animated: animatedScore, size: 150)

                Text(viabilityDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 10)
                    .frame(maxWidth: .infinity)
                    .background(Color(uiColor: .tertiarySystemGroupedBackground))
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
            }

            // MARK: stat cards
            HStack(spacing: 12) {
                StatCard(
                    icon: "dollarsign.circle.fill",
                    iconColor: gap >= 0 ? .green : .red,
                    title: "Monthly Gap",
                    value: "$\(gap)/mo",
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

            // MARK: tuition comparison bar chart
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Tuition Jump")
                        .font(.headline)
                    Spacer()
                    Text("+$\(tuitionJumpMonthly)/mo")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                }

                GeometryReader { geo in
                    let maxVal = CGFloat(max(ccTuition, uniTuition))
                    let ccWidth = maxVal > 0 ? geo.size.width * CGFloat(ccTuition) / maxVal : 0
                    let uniWidth = maxVal > 0 ? geo.size.width * CGFloat(uniTuition) / maxVal : 0

                    VStack(spacing: 8) {
                        HStack(spacing: 8) {
                            CollegeLogo(schoolName: ccName, size: 20)
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color.green.opacity(0.6))
                                .frame(width: max(40, ccWidth - 80), height: 28)
                            Text("$\(ccTuition.formatted())")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.primary)
                        }

                        HStack(spacing: 8) {
                            CollegeLogo(schoolName: uniName, size: 20)
                            RoundedRectangle(cornerRadius: 6, style: .continuous)
                                .fill(Color.orange.opacity(0.7))
                                .frame(width: max(40, uniWidth - 80), height: 28)
                            Text("$\(uniTuition.formatted())")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.primary)
                        }
                    }
                }
                .frame(height: 68)

                Text("\(ccName) → \(uniName) · per year")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }
            .padding(16)
            .background(TTColors.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .padding(.horizontal, 20)

            // MARK: savings + runway
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
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(TTColors.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: "clock.fill")
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
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(16)
                .background(TTColors.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(.horizontal, 20)
        }
    }
}
