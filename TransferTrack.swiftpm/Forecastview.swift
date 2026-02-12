import SwiftUI

// mark -- forecast tab


@available(iOS 17.0, *)
struct ForecastTab: View {
    let score: Int
    let gap: Int
    let savings: Double
    let rent: Double
    let ccName: String
    let uniName: String

    @State private var animatedScore: CGFloat = 0

    private var scoreColor: Color {
        if score >= 75 { return .green }
        else if score >= 50 { return .orange }
        else { return .red }
    }

    private var viabilityDescription: String {
        if score >= 75 {
            return "You are academically and financially on track for a smooth transfer."
        } else if score >= 50 {
            return "You are academically ready, but financially at risk."
        } else {
            return "Your transfer plan needs significant improvement. Review the Solutions tab."
        }
    }

    private var creditsAtRisk: Int {
        let courses = SchoolDatabase.courses(from: ccName, to: uniName)
        return courses.filter { !$0.transfers }.reduce(0) { $0 + $1.credits }
    }

    private var commuteCost: Int {
        // estimated additional commute cost if living off-campus
        return rent > 800 ? 60 : 120
    }

    private var ccTuition: Int { SchoolDatabase.ccTuition[ccName] ?? 3000 }
    private var uniTuition: Int { SchoolDatabase.uniTuition[uniName] ?? 8000 }
    private var tuitionJump: Int { uniTuition - ccTuition }

    var body: some View {
        VStack(spacing: 20) {
            // MARK: viability score ring
            VStack(spacing: 12) {
                ViabilityRing(score: score, animated: animatedScore, size: 160)

                Text(viabilityDescription)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
            }
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity)
            .background(TTColors.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, 20)
            .onAppear {
                withAnimation(.spring(response: 1.2, dampingFraction: 0.7).delay(0.3)) {
                    animatedScore = CGFloat(score)
                }
            }

            // MARK: Stat Cards
            HStack(spacing: 12) {
                StatCard(
                    icon: "dollarsign.circle.fill",
                    iconColor: gap >= 0 ? .green : .red,
                    title: "Projected Monthly Gap",
                    value: "\(gap >= 0 ? "+" : "")$\(gap)",
                    valueColor: gap >= 0 ? .green : .red
                )

                StatCard(
                    icon: "car.fill",
                    iconColor: .blue,
                    title: "Commute Cost",
                    value: "+$\(commuteCost)/mo",
                    valueColor: .blue
                )

                StatCard(
                    icon: "book.closed.fill",
                    iconColor: .orange,
                    title: "Credits at Risk",
                    value: "\(creditsAtRisk) credits",
                    valueColor: .orange
                )
            }
            .padding(.horizontal, 20)

            // MARK: Tuition Comparison (with college logos)
            VStack(alignment: .leading, spacing: 16) {
                Text("Tuition Comparison")
                    .font(.headline)

                HStack(spacing: 16) {
                    // CC
                    VStack(spacing: 8) {
                        CollegeLogo(schoolName: ccName, size: 44)
                        Text(ccName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text("$\(ccTuition.formatted())/yr")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.green)
                    }
                    .frame(maxWidth: .infinity)

            
                    VStack(spacing: 4) {
                        Image(systemName: "arrow.right")
                            .font(.title3)
                            .foregroundStyle(.secondary)
                        Text("+$\(tuitionJump.formatted())")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.red)
                    }

                    // Uni
                    VStack(spacing: 8) {
                        CollegeLogo(schoolName: uniName, size: 44)
                        Text(uniName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineLimit(1)
                            .minimumScaleFactor(0.7)
                        Text("$\(uniTuition.formatted())/yr")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(.red)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
            .padding(20)
            .background(TTColors.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            .padding(.horizontal, 20)

            // MARK: key metrics
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
                            .foregroundStyle(gap < 0 ? .red : .green)
                        Text("Runway")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Text(gap < 0 ? "\(max(0, Int(savings / Double(abs(gap)))))mo" : "Stable")
                        .font(.title3.weight(.bold))
                        .foregroundStyle(gap < 0 ? .red : .green)
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
