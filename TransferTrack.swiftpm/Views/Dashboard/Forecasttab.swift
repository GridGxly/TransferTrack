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
    @State private var showGapExplainer = false

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

    private let bentoColumns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]


    private func tintBg(_ color: Color) -> Color {
        color.opacity(colorScheme == .light ? 0.10 : 0.15)
    }

    private func tintBgStrong(_ color: Color) -> Color {
        color.opacity(colorScheme == .light ? 0.12 : 0.18)
    }

    var body: some View {
        VStack(spacing: 16) {
            pathHeader
            heroCard
            bentoGrid
            transportAdvisor
            tuitionChart
        }
        .id(colorScheme)
        .animation(.spring(response: 0.4), value: vm.solutionMonthlyBonus)
        .animation(.spring(response: 0.4), value: vm.transportMode)
        .sheet(isPresented: $showTransportSheet) {
            TransportComparisonSheet(vm: vm)
        }
        .sheet(isPresented: $showGapExplainer) {
            GapExplainerSheet(vm: vm)
        }
    }



    private var pathHeader: some View {
        Button { showEditSheet = true } label: {
            HStack(spacing: 10) {
                CollegeLogo(schoolName: vm.selectedCC, size: 32)
                    .id(vm.selectedCC)
                    .transition(.scale.combined(with: .opacity))
                Image(systemName: "arrow.right")
                    .font(.caption2.weight(.bold))
                    .foregroundStyle(.secondary)
                CollegeLogo(schoolName: vm.selectedUni, size: 32)
                    .id(vm.selectedUni)
                    .transition(.scale.combined(with: .opacity))
                VStack(alignment: .leading, spacing: 2) {
                    Text("\(vm.selectedCC) → \(vm.selectedUni)")
                        .font(.system(.subheadline, design: .rounded).weight(.semibold))
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
            .glassCard(radius: 16, padding: 14)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .accessibilityLabel("Edit transfer path from \(vm.selectedCC) to \(vm.selectedUni)")
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: vm.selectedCC)
        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: vm.selectedUni)
    }



    private var heroCard: some View {
        HStack(spacing: 14) {
            VStack(alignment: .leading, spacing: 6) {
                Text("MONTHLY GAP")
                    .font(.system(.caption2, design: .rounded).weight(.bold))
                    .textCase(.uppercase)
                    .tracking(1.2)
                    .foregroundStyle(.secondary)

                CountingDollarText(value: animatedGap, fontSize: 48)

                HStack(spacing: 6) {
                    Text("per month after transfer")
                        .font(.system(.caption, design: .rounded))
                        .foregroundStyle(.secondary)

                    Button {
                        showGapExplainer = true
                    } label: {
                        Image(systemName: "info.circle")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .accessibilityLabel("How is this calculated?")
                }

                HStack(spacing: 4) {
                    Image(systemName: vm.monthlyGap >= 0 ? "checkmark.circle.fill" : "exclamationmark.triangle.fill")
                        .font(.caption2)
                    Text(vm.monthlyGap >= 0 ? "Surplus" : "Deficit")
                        .font(.system(.caption2, design: .rounded).weight(.semibold))
                }
                .foregroundStyle(vm.monthlyGap >= 0 ? TTBrand.mint : TTBrand.coral)

                if vm.solutionMonthlyBonus > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.caption2)
                        Text("+$\(vm.solutionMonthlyBonus)/mo saved")
                            .font(.system(.caption2, design: .rounded).weight(.medium))
                    }
                    .foregroundStyle(TTBrand.mint)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(tintBgStrong(TTBrand.mint))
                    .clipShape(Capsule())
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }

            Spacer(minLength: 0)

            VStack(spacing: 4) {
                ViabilityRing(score: vm.viabilityScore, animated: animatedScore, size: 80)
                    .scaleEffect(ringBounce)
                Text(shortViabilityLabel)
                    .font(.system(.caption2, design: .rounded).weight(.medium))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
            }
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Viability Score")
            .accessibilityValue("\(vm.viabilityScore) out of 100, \(shortViabilityLabel)")
            .accessibilityAddTraits(.updatesFrequently)
        }
        .glassCard(radius: 24, padding: 20)
        .padding(.horizontal, 20)
        .staggerFade(delay: 0.1)
        .onAppear {
            withAnimation(.easeOut(duration: 1.4).delay(0.2)) {
                animatedGap = CGFloat(vm.monthlyGap)
            }
            withAnimation(.spring(response: 1.2, dampingFraction: 0.7).delay(0.3)) {
                animatedScore = CGFloat(vm.viabilityScore)
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.5)) {
                showCards = true
            }
        }
        .onChange(of: vm.monthlyGap) { _, newGap in
            withAnimation(.easeOut(duration: 0.8)) {
                animatedGap = CGFloat(newGap)
            }
        }
        .onChange(of: vm.viabilityScore) { _, newScore in
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                animatedScore = CGFloat(newScore)
            }
            withAnimation(.spring(response: 0.15, dampingFraction: 0.3)) { ringBounce = 1.12 }
            withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.15)) { ringBounce = 1.0 }
        }
        .onChange(of: vm.updateTrigger) { _, _ in
            withAnimation(.easeOut(duration: 0.8)) {
                animatedGap = CGFloat(vm.monthlyGap)
            }
            let newScore = CGFloat(vm.viabilityScore)
            if abs(animatedScore - newScore) > 0.5 {
                withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) { animatedScore = newScore }
                withAnimation(.spring(response: 0.15, dampingFraction: 0.3)) { ringBounce = 1.12 }
                withAnimation(.spring(response: 0.3, dampingFraction: 0.5).delay(0.15)) { ringBounce = 1.0 }
            }
        }
    }


    private var bentoGrid: some View {
        LazyVGrid(columns: bentoColumns, spacing: 12) {
            StatCard(
                icon: vm.monthlyGap >= 0 ? "checkmark.circle.fill" : "clock.fill",
                iconColor: vm.monthlyGap >= 0 ? TTBrand.mint : TTBrand.amber,
                title: "Runway",
                value: runwayText,
                valueColor: vm.monthlyGap >= 0 ? TTBrand.mint : TTBrand.amber,
                subtitle: "$\(Int(vm.userSavings).formatted()) saved"
            )

            StatCard(
                icon: "book.closed.fill",
                iconColor: vm.creditsAtRisk > 0 ? TTBrand.amber : TTBrand.mint,
                title: "Credits at Risk",
                value: "\(vm.creditsAtRisk) cr",
                valueColor: vm.creditsAtRisk > 0 ? TTBrand.amber : TTBrand.mint,
                subtitle: vm.creditsAtRisk > 0 ? "~$\(vm.creditsAtRiskCost.formatted())" : nil
            )
        }
        .padding(.horizontal, 20)
        .opacity(showCards ? 1 : 0)
        .offset(y: showCards ? 0 : 12)
        .redacted(reason: hasData ? [] : .placeholder)
        .staggerFade(delay: 0.2)
    }


    private var transportAdvisor: some View {
        Button { showTransportSheet = true } label: {
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Transport Advisor")
                        .font(.system(.headline, design: .rounded))
                        .foregroundStyle(.primary)
                    Spacer()
                    Text("+$\(vm.transportCost)/mo")
                        .font(.system(.subheadline, design: .rounded).weight(.bold))
                        .monospacedDigit()
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText())
                }

                HStack(spacing: 10) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(tintBg(TTBrand.skyBlue))
                            .frame(width: 40, height: 40)
                        Image(systemName: transportIcons[vm.transportMode])
                            .font(.system(size: 18))
                            .foregroundStyle(TTBrand.skyBlue)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(transportLabels[vm.transportMode])
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            .foregroundStyle(.primary)
                        Text(transportSubtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    HStack(spacing: 4) {
                        Text("Compare")
                            .font(.system(.caption, design: .rounded).weight(.medium))
                            .foregroundStyle(TTBrand.skyBlue)
                        Image(systemName: "chevron.right")
                            .font(.caption2.weight(.semibold))
                            .foregroundStyle(TTBrand.skyBlue)
                    }
                }

                HStack(spacing: 6) {
                    ForEach(0..<3, id: \.self) { mode in
                        let isActive = vm.transportMode == mode
                        HStack(spacing: 4) {
                            Image(systemName: transportIcons[mode]).font(.system(size: 10))
                            Text(shortTransportCost(mode))
                                .font(.system(.caption2, design: .rounded).weight(.medium))
                                .monospacedDigit()
                        }
                        .padding(.horizontal, 10).padding(.vertical, 6)
                        .background(
                            isActive
                                ? tintBg(TTBrand.skyBlue)
                                : Color(uiColor: colorScheme == .light
                                    ? .systemGray5
                                    : .tertiarySystemFill)
                        )
                        .foregroundStyle(isActive ? TTBrand.skyBlue : .secondary)
                        .clipShape(Capsule())
                    }
                    Spacer()
                }
            }
            .glassCard(radius: 20, padding: 16)
        }
        .buttonStyle(.plain)
        .padding(.horizontal, 20)
        .opacity(showCards ? 1 : 0)
        .offset(y: showCards ? 0 : 12)
        .staggerFade(delay: 0.3)
    }


    private var tuitionChart: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("TUITION IMPACT")
                .font(.system(.caption2, design: .rounded).weight(.bold))
                .textCase(.uppercase)
                .tracking(1.0)
                .foregroundStyle(.secondary)

            HStack {
                Text("Annual Tuition")
                    .font(.system(.headline, design: .rounded))
                    .foregroundStyle(.primary)
                Spacer()
                Text("\(vm.selectedUni) is +$\(vm.tuitionJump.formatted())/yr")
                    .font(.system(.caption, design: .rounded).weight(.semibold))
                    .monospacedDigit()
                    .foregroundStyle(TTBrand.coral)
                    .contentTransition(.numericText())
            }

            Chart([
                TuitionEntry(school: vm.selectedCC, amount: vm.ccTuition, isCC: true),
                TuitionEntry(school: vm.selectedUni, amount: vm.uniTuition, isCC: false)
            ]) { entry in
                BarMark(x: .value("Tuition", entry.amount), y: .value("School", entry.school))
                    .foregroundStyle(
                        entry.isCC
                        ? TTBrand.skyBlue.opacity(colorScheme == .light ? 0.40 : 0.45)
                        : TTBrand.skyBlue.opacity(colorScheme == .light ? 0.80 : 0.85)
                    )
                    .cornerRadius(6)
                    .annotation(position: .trailing, spacing: 6) {
                        Text("$\(entry.amount.formatted())")
                            .font(.system(.caption, design: .rounded).weight(.semibold))
                            .monospacedDigit()
                            .foregroundStyle(.primary)
                    }
            }
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .font(.system(.caption, design: .rounded))
                        .offset(x: -4)
                }
            }
            .chartYSelection(value: $selectedChartSchool)
            .frame(height: 100)
            .padding(.vertical, 4)
            .accessibilityElement(children: .combine)
            .accessibilityLabel("Tuition comparison chart. \(vm.selectedCC) costs $\(vm.ccTuition) per year. \(vm.selectedUni) costs $\(vm.uniTuition) per year.")

            if let school = selectedChartSchool {
                let amount = school == vm.selectedCC ? vm.ccTuition : vm.uniTuition
                Text("\(school): $\(amount.formatted())/year")
                    .font(.system(.caption, design: .rounded).weight(.medium))
                    .monospacedDigit()
                    .foregroundStyle(TTBrand.skyBlue)
                    .transition(.opacity)
            }
        }
        .glassCard(radius: 20, padding: 16)
        .padding(.horizontal, 20)
        .opacity(showCards ? 1 : 0)
        .staggerFade(delay: 0.4)
    }

    private var shortViabilityLabel: String {
        if vm.viabilityScore >= 75 { return "Strong" }
        else if vm.viabilityScore >= 50 { return "Moderate" }
        else { return "At Risk" }
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
}

struct TuitionEntry: Identifiable {
    let id = UUID()
    let school: String
    let amount: Int
    let isCC: Bool
}


@available(iOS 17.0, *)
struct GapExplainerSheet: View {
    let vm: TransferViewModel
    @Environment(\.dismiss) private var dismiss

    private var tuitionMonthly: Int { (SchoolDatabase.uniTuition[vm.selectedUni] ?? 7000) / 12 }
    private var income: Int { 1800 }
    private var living: Int { 400 }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text("Based on tuition + rent + transport + living expenses for \(vm.selectedUni), here's how your monthly budget breaks down.")
                        .font(.system(.subheadline, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Section("Income") {
                    HStack {
                        Label("Estimated Monthly Income", systemImage: "dollarsign.circle.fill")
                            .font(.system(.subheadline, design: .rounded))
                        Spacer()
                        Text("$\(income.formatted())")
                            .font(.system(.subheadline, design: .rounded).weight(.semibold))
                            .monospacedDigit()
                            .foregroundStyle(TTBrand.mint)
                    }
                }

                Section("Expenses") {
                    expenseRow("Tuition (monthly)", icon: "graduationcap.fill", amount: tuitionMonthly)
                    expenseRow("Rent", icon: "house.fill", amount: Int(vm.userRent))
                    expenseRow("Living Expenses", icon: "cart.fill", amount: living)
                    expenseRow("Transport", icon: "car.fill", amount: vm.transportCost)
                }

                Section {
                    HStack {
                        Text("Monthly Gap")
                            .font(.system(.headline, design: .rounded).weight(.bold))
                        Spacer()
                        Text("\(vm.monthlyGap >= 0 ? "+" : "")$\(vm.monthlyGap.formatted())")
                            .font(.system(.headline, design: .rounded).weight(.bold))
                            .monospacedDigit()
                            .foregroundStyle(vm.monthlyGap >= 0 ? TTBrand.mint : TTBrand.coral)
                    }

                    if vm.solutionMonthlyBonus > 0 {
                        HStack {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(TTBrand.mint)
                            Text("Includes +$\(vm.solutionMonthlyBonus)/mo from completed actions")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section {
                    Text("Complete actions in the Solutions tab to improve your monthly gap and viability score.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            .navigationTitle("How It's Calculated")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    private func expenseRow(_ label: String, icon: String, amount: Int) -> some View {
        HStack {
            Label(label, systemImage: icon)
                .font(.system(.subheadline, design: .rounded))
            Spacer()
            Text("-$\(amount.formatted())")
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .monospacedDigit()
                .foregroundStyle(TTBrand.coral)
        }
    }
}
