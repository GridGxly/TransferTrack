import SwiftUI
import Charts

@available(iOS 17.0, *)
struct ForecastTab: View {
    @Bindable var vm: TransferViewModel
    @Binding var showEditSheet: Bool
    @Environment(\.colorScheme) private var colorScheme

    @State private var animatedScore: CGFloat = 0
    @State private var animatedGap: CGFloat = 0
    @State private var showCards = false
    @State private var selectedChartSchool: String? = nil
    @State private var ringBounce: CGFloat = 1.0
    @State private var showTransportSheet = false

    private var runwayMonths: Int {
        if vm.monthlyGap >= 0 { return -1 }
        return max(0, Int(vm.userSavings / Double(abs(vm.monthlyGap))))
    }

    private var runwayText: String {
        runwayMonths == -1 ? "Stable" : "\(runwayMonths) mo"
    }

    private var transportLabels: [String] { ["Keep Car", "Sell/Swap", "Transit"] }
    private var transportIcons: [String] { ["car.fill", "car.side.front.open.fill", "bus.fill"] }

    private var hasData: Bool { vm.userCredits > 0 }

    var body: some View {
        VStack(spacing: 16) {

           
            Button { showEditSheet = true } label: {
                HStack(spacing: 10) {
                    CollegeLogo(schoolName: vm.selectedCC, size: 32)
                        .id(vm.selectedCC)
                        .transition(.scale.combined(with: .opacity))
                    VStack(spacing: 2) {
                        Image(systemName: "arrow.right")
                            .font(.caption2.weight(.bold))
                            .foregroundStyle(.secondary)
                    }
                    CollegeLogo(schoolName: vm.selectedUni, size: 32)
                        .id(vm.selectedUni)
                        .transition(.scale.combined(with: .opacity))
                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(vm.selectedCC) → \(vm.selectedUni)")
                            .font(.subheadline.weight(.semibold))
                            .foregroundStyle(.primary)
                            .lineLimit(1)
                        Text("Tap to edit path")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.tertiary)
                }
                .padding(14)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .cardBorder(colorScheme: colorScheme)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: vm.selectedCC)
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: vm.selectedUni)



            VStack(spacing: 4) {
                Text("MONTHLY GAP")
                    .font(.caption2.weight(.bold))
                    .textCase(.uppercase)
                    .tracking(1.2)
                    .foregroundStyle(.secondary)

                CountingDollarText(value: animatedGap, fontSize: 52)

                Text("per month after transfer")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 4)
            .onAppear {
                withAnimation(.easeOut(duration: 1.4).delay(0.2)) {
                    animatedGap = CGFloat(vm.monthlyGap)
                }
            }
            .onChange(of: vm.monthlyGap) { _, newGap in
                withAnimation(.easeOut(duration: 0.8)) {
                    animatedGap = CGFloat(newGap)
                }
            }
            .onChange(of: vm.updateTrigger) { _, _ in
                withAnimation(.easeOut(duration: 0.8)) {
                    animatedGap = CGFloat(vm.monthlyGap)
                }
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


            HStack(spacing: 14) {
                ViabilityRing(score: vm.viabilityScore, animated: animatedScore, size: 70)
                    .scaleEffect(ringBounce)
                VStack(alignment: .leading, spacing: 4) {
                    Text("Viability Score").font(.headline).foregroundStyle(.primary)
                    Text(viabilityMessage)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .fixedSize(horizontal: false, vertical: true)
                }
                Spacer()
            }
            .padding(16)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .cardBorder(colorScheme: colorScheme)
            .padding(.horizontal, 20)
            .onAppear {
                withAnimation(.spring(response: 1.2, dampingFraction: 0.7).delay(0.3)) {
                    animatedScore = CGFloat(vm.viabilityScore)
                }
                withAnimation(.easeOut(duration: 0.6).delay(0.5)) { showCards = true }
            }
            .onChange(of: vm.viabilityScore) { _, newScore in
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                    animatedScore = CGFloat(newScore)
                }
                withAnimation(.spring(response: 0.15, dampingFraction: 0.3)) {
                    ringBounce = 1.12
                }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.15)) {
                    ringBounce = 1.0
                }
            }
            .onChange(of: vm.updateTrigger) { _, _ in
                let newScore = CGFloat(vm.viabilityScore)
                if abs(animatedScore - newScore) > 0.5 {
                    withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                        animatedScore = newScore
                    }
                    withAnimation(.spring(response: 0.15, dampingFraction: 0.3)) {
                        ringBounce = 1.12
                    }
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.15)) {
                        ringBounce = 1.0
                    }
                }
            }


            Button { showTransportSheet = true } label: {
                VStack(alignment: .leading, spacing: 10) {
                    HStack {
                        Text("Transport Advisor").font(.headline).foregroundStyle(.primary)
                        Spacer()
                        Text("+$\(vm.transportCost)/mo")
                            .font(.subheadline.weight(.bold))
                            .foregroundStyle(.primary)
                            .contentTransition(.numericText())
                    }

                    HStack(spacing: 10) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 40, height: 40)
                            Image(systemName: transportIcons[vm.transportMode])
                                .font(.system(size: 18))
                                .foregroundStyle(.blue)
                        }

                        VStack(alignment: .leading, spacing: 2) {
                            Text(transportLabels[vm.transportMode])
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                            Text(transportSubtitle)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        HStack(spacing: 4) {
                            Text("Compare Options")
                                .font(.caption.weight(.medium))
                                .foregroundStyle(.blue)
                            Image(systemName: "chevron.right")
                                .font(.caption2.weight(.semibold))
                                .foregroundStyle(.blue)
                        }
                    }

                    HStack(spacing: 6) {
                        ForEach(0..<3, id: \.self) { mode in
                            let isActive = vm.transportMode == mode
                            HStack(spacing: 4) {
                                Image(systemName: transportIcons[mode])
                                    .font(.system(size: 10))
                                Text(shortTransportCost(mode))
                                    .font(.caption2.weight(.medium))
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(isActive ? Color.blue.opacity(0.15) : Color(uiColor: .tertiarySystemFill))
                            .foregroundStyle(isActive ? .blue : .secondary)
                            .clipShape(Capsule())
                        }
                        Spacer()
                    }
                }
                .padding(16)
                .background(Color(uiColor: .secondarySystemGroupedBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .cardBorder(colorScheme: colorScheme)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 20)
            .opacity(showCards ? 1 : 0)
            .offset(y: showCards ? 0 : 12)


            ViewThatFits(in: .horizontal) {
                HStack(spacing: 12) {
                    statCardAtRisk
                    statCardRunway
                }
                VStack(spacing: 12) {
                    statCardAtRisk
                    statCardRunway
                }
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal, 20)
            .opacity(showCards ? 1 : 0)
            .offset(y: showCards ? 0 : 12)
            .redacted(reason: hasData ? [] : .placeholder)



            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Text("Tuition Jump").font(.headline).foregroundStyle(.primary)
                    Spacer()
                    Text("+$\(vm.tuitionJump / 12)/mo")
                        .font(.subheadline.weight(.bold))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                }
                Chart([
                    TuitionEntry(school: vm.selectedCC, amount: vm.ccTuition, isCC: true),
                    TuitionEntry(school: vm.selectedUni, amount: vm.uniTuition, isCC: false)
                ]) { entry in
                    BarMark(x: .value("Tuition", entry.amount), y: .value("School", entry.school))
                        .foregroundStyle(entry.isCC
                            ? Color.blue.opacity(0.45)
                            : Color.blue.opacity(0.85))
                        .cornerRadius(6)
                        .annotation(position: .trailing, spacing: 6) {
                            Text("$\(entry.amount.formatted())")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.primary)
                        }
                }
                .chartXAxis(.hidden)
                .chartYAxis {
                    AxisMarks { _ in
                        AxisValueLabel()
                            .font(.caption)
                            .offset(x: -4)
                    }
                }
                .chartYSelection(value: $selectedChartSchool)
                .frame(height: 120)
                .padding(.vertical, 4)

                if let school = selectedChartSchool {
                    let amount = school == vm.selectedCC ? vm.ccTuition : vm.uniTuition
                    Text("\(school): $\(amount.formatted())/year")
                        .font(.caption.weight(.medium)).foregroundStyle(.blue)
                        .transition(.opacity)
                }

                Text("Annual tuition comparison")
                    .font(.caption2).foregroundStyle(.secondary)
            }
            .padding(16)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .cardBorder(colorScheme: colorScheme)
            .padding(.horizontal, 20)
            .opacity(showCards ? 1 : 0)
        }
        .animation(.spring(response: 0.4), value: vm.solutionMonthlyBonus)
        .animation(.spring(response: 0.4), value: vm.transportMode)
        .sheet(isPresented: $showTransportSheet) {
            TransportComparisonSheet(vm: vm)
        }
    }



    private var transportSubtitle: String {
        switch vm.transportMode {
        case 0: return "Gas + insurance + maintenance + parking"
        case 1: return "Lower gas & insurance, smaller payment"
        case 2: return "Free \(vm.selectedUni) shuttle pass with tuition"
        default: return ""
        }
    }

    private func shortTransportCost(_ mode: Int) -> String {
        let cost: Int
        switch mode {
        case 0: cost = vm.userRent > 800 ? 60 : 120
        case 1: cost = 40
        case 2: cost = 0
        default: cost = 60
        }
        return cost == 0 ? "Free" : "$\(cost)/mo"
    }

    private var statCardAtRisk: some View {
        StatCard(
            icon: "book.closed.fill",
            iconColor: vm.creditsAtRisk > 0 ? .orange : .green,
            title: "Credits at Risk",
            value: "\(vm.creditsAtRisk) cr",
            valueColor: vm.creditsAtRisk > 0 ? .orange : .green,
            subtitle: vm.creditsAtRisk > 0 ? "~$\(vm.creditsAtRiskCost.formatted())" : nil
        )
    }

    private var statCardRunway: some View {
        StatCard(
            icon: vm.monthlyGap >= 0 ? "checkmark.circle.fill" : "clock.fill",
            iconColor: vm.monthlyGap >= 0 ? .green : .orange,
            title: "Runway",
            value: runwayText,
            valueColor: vm.monthlyGap >= 0 ? .green : .orange,
            subtitle: "$\(Int(vm.userSavings).formatted()) saved"
        )
    }

    private var viabilityMessage: String {
        if vm.viabilityScore >= 75 {
            return "Strong position. Your GPA, credits, and finances support a smooth transfer."
        } else if vm.viabilityScore >= 50 {
            return "Moderate risk. Check Solutions tab for ways to improve."
        } else {
            return "High risk. Address financial gaps and credit transfers before moving forward."
        }
    }
}

struct TuitionEntry: Identifiable {
    let id = UUID()
    let school: String
    let amount: Int
    let isCC: Bool
}
