import SwiftUI



@available(iOS 17.0, *)
struct TransportComparisonSheet: View {
    @Bindable var vm: TransferViewModel
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var selectedOption: Int

    init(vm: TransferViewModel) {
        self.vm = vm
        _selectedOption = State(initialValue: vm.transportMode)
    }



    private struct UniTransit {
        let parkingCost: Int
        let shuttleName: String
        let busName: String
        let railName: String
        let systemsSummary: String
    }

    private var transit: UniTransit {
        switch vm.selectedUni {
        case "UCF":
            return UniTransit(parkingCost: 53, shuttleName: "UCF Shuttle", busName: "Lynx Bus Pass", railName: "SunRail", systemsSummary: "SunRail · Lynx · UCF Shuttle")
        case "Univ. of Florida":
            return UniTransit(parkingCost: 48, shuttleName: "Gator Aider Shuttle", busName: "RTS Bus Pass", railName: "Regional Transit", systemsSummary: "RTS · Gator Aider · Later Gator")
        case "FSU":
            return UniTransit(parkingCost: 45, shuttleName: "Seminole Express", busName: "StarMetro Pass", railName: "Regional Transit", systemsSummary: "StarMetro · Seminole Express")
        case "USF":
            return UniTransit(parkingCost: 50, shuttleName: "Bull Runner", busName: "HART Bus Pass", railName: "TECO Streetcar", systemsSummary: "HART · Bull Runner · TECO")
        case "FIU":
            return UniTransit(parkingCost: 55, shuttleName: "FIU Shuttle", busName: "Miami-Dade Transit", railName: "Metrorail", systemsSummary: "Metrorail · MDT Bus · FIU Shuttle")
        case "UCLA":
            return UniTransit(parkingCost: 110, shuttleName: "BruinBus", busName: "Big Blue Bus", railName: "Metro Rail", systemsSummary: "Metro · Big Blue Bus · BruinBus")
        case "UC Berkeley":
            return UniTransit(parkingCost: 95, shuttleName: "Bear Transit", busName: "AC Transit Pass", railName: "BART", systemsSummary: "BART · AC Transit · Bear Transit")
        case "UC Davis":
            return UniTransit(parkingCost: 65, shuttleName: "Unitrans", busName: "Yolobus Pass", railName: "Amtrak Capitol Corridor", systemsSummary: "Unitrans · Yolobus · Amtrak")
        case "CSU LA":
            return UniTransit(parkingCost: 55, shuttleName: "CSULA Shuttle", busName: "Metro Bus Pass", railName: "Metro Gold Line", systemsSummary: "Metro Gold Line · Metro Bus · Shuttle")
        case "San Jose State":
            return UniTransit(parkingCost: 60, shuttleName: "SJSU Shuttle", busName: "VTA Bus Pass", railName: "VTA Light Rail", systemsSummary: "VTA Light Rail · VTA Bus · Shuttle")
        case "UT Austin":
            return UniTransit(parkingCost: 65, shuttleName: "UT Shuttle", busName: "CapMetro Pass", railName: "MetroRail", systemsSummary: "CapMetro · MetroRail · UT Shuttle")
        case "Texas A&M":
            return UniTransit(parkingCost: 45, shuttleName: "Aggie Spirit", busName: "Brazos Transit", railName: "Regional Transit", systemsSummary: "Brazos Transit · Aggie Spirit")
        case "Univ. of Houston":
            return UniTransit(parkingCost: 55, shuttleName: "Cougar Line", busName: "METRO Bus Pass", railName: "METRORail", systemsSummary: "METRORail · METRO Bus · Cougar Line")
        case "UTSA":
            return UniTransit(parkingCost: 40, shuttleName: "Runner Shuttle", busName: "VIA Transit Pass", railName: "VIA Transit", systemsSummary: "VIA Transit · Runner Shuttle")
        case "Texas State":
            return UniTransit(parkingCost: 42, shuttleName: "Bobcat Shuttle", busName: "CARTS Transit", railName: "Regional Transit", systemsSummary: "CARTS · Bobcat Shuttle")
        case "UVA":
            return UniTransit(parkingCost: 55, shuttleName: "UTS Shuttle", busName: "Charlottesville Transit", railName: "Amtrak", systemsSummary: "CTS · UTS Shuttle · Amtrak")
        case "Virginia Tech":
            return UniTransit(parkingCost: 48, shuttleName: "BT Shuttle", busName: "Blacksburg Transit", railName: "Regional Transit", systemsSummary: "Blacksburg Transit · BT Shuttle")
        case "George Mason":
            return UniTransit(parkingCost: 60, shuttleName: "Mason Shuttle", busName: "Fairfax Connector", railName: "Metro Orange Line", systemsSummary: "Metro · Fairfax Connector · Mason Shuttle")
        case "Univ. of Washington":
            return UniTransit(parkingCost: 80, shuttleName: "UW Shuttle", busName: "King County Metro", railName: "Link Light Rail", systemsSummary: "Link Rail · Metro · UW Shuttle")
        case "WSU":
            return UniTransit(parkingCost: 38, shuttleName: "Cougar Shuttle", busName: "Pullman Transit", railName: "Regional Transit", systemsSummary: "Pullman Transit · Cougar Shuttle")
        case "UNC Chapel Hill":
            return UniTransit(parkingCost: 55, shuttleName: "P2P Shuttle", busName: "Chapel Hill Transit", railName: "GoTriangle", systemsSummary: "CHT · P2P · GoTriangle")
        case "NC State":
            return UniTransit(parkingCost: 50, shuttleName: "Wolfline", busName: "GoRaleigh Pass", railName: "GoTriangle", systemsSummary: "GoRaleigh · Wolfline · GoTriangle")
        case "Rutgers":
            return UniTransit(parkingCost: 65, shuttleName: "Rutgers Shuttle", busName: "NJ Transit Bus", railName: "NJ Transit Rail", systemsSummary: "NJ Transit · Rutgers Shuttle")
        case "NJIT":
            return UniTransit(parkingCost: 70, shuttleName: "NJIT Shuttle", busName: "NJ Transit Bus", railName: "Newark Light Rail", systemsSummary: "Light Rail · NJ Transit · Shuttle")
        case "Rowan Univ.":
            return UniTransit(parkingCost: 45, shuttleName: "Rowan Shuttle", busName: "NJ Transit Bus", railName: "PATCO", systemsSummary: "NJ Transit · PATCO · Shuttle")
        default:
            return UniTransit(parkingCost: 50, shuttleName: "\(vm.selectedUni) Shuttle", busName: "Local Bus Pass", railName: "Regional Rail", systemsSummary: "Campus Shuttle · Local Transit")
        }
    }



    private var options: [VehicleOption] {
        [
            VehicleOption(
                name: "Keep Current Car",
                subtitle: "Your current vehicle",
                icon: "car.fill",
                iconColor: .orange,
                mileage: "Your current MPG",
                costs: [
                    CostLine(label: "Gas (estimated)", amount: 180, icon: "fuelpump.fill"),
                    CostLine(label: "Insurance (full coverage)", amount: 145, icon: "shield.fill"),
                    CostLine(label: "Maintenance", amount: 95, icon: "wrench.fill"),
                    CostLine(label: "\(vm.selectedUni) Parking Permit", amount: transit.parkingCost, icon: "parkingsign.circle.fill"),
                ],
                pros: ["No car payment", "Freedom to drive anywhere", "Move furniture yourself"],
                cons: ["Gas adds up fast on a long commute", "Older cars mean unpredictable repairs", "Insurance is higher for drivers under 25"],
                tag: nil
            ),
            VehicleOption(
                name: "Swap to Used Car",
                subtitle: "Fuel-efficient alternative",
                icon: "car.side.front.open.fill",
                iconColor: .blue,
                mileage: "30+ MPG city · 38+ hwy",
                costs: [
                    CostLine(label: "Gas (estimated)", amount: 85, icon: "fuelpump.fill"),
                    CostLine(label: "Insurance (liability)", amount: 90, icon: "shield.fill"),
                    CostLine(label: "Maintenance", amount: 25, icon: "wrench.fill"),
                    CostLine(label: "\(vm.selectedUni) Parking Permit", amount: transit.parkingCost, icon: "parkingsign.circle.fill"),
                ],
                pros: ["Half the gas cost", "Way cheaper insurance", "Sell current car for cash injection"],
                cons: ["Car payment if financed (~$280/mo)", "Depreciation on the new purchase", "Time spent selling + buying"],
                tag: nil
            ),
            VehicleOption(
                name: "\(vm.selectedUni) Transit",
                subtitle: "Free with tuition fees",
                icon: "bus.fill",
                iconColor: .green,
                mileage: transit.systemsSummary,
                costs: [
                    CostLine(label: transit.shuttleName, amount: 0, icon: "bus.fill"),
                    CostLine(label: transit.busName, amount: 0, icon: "tram.fill"),
                    CostLine(label: transit.railName, amount: 0, icon: "tram.circle.fill"),
                    CostLine(label: "Lyft/Uber (emergencies)", amount: 40, icon: "car.circle.fill"),
                ],
                pros: ["$0/mo base cost", "Sell your car for savings", "No parking, insurance, or gas stress"],
                cons: ["Limited late-night routes", "Grocery trips need planning", "Long-distance commute home is harder"],
                tag: "BEST VALUE"
            ),
        ]
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {

            
                    VStack(spacing: 6) {
                        Image(systemName: "car.2.fill")
                            .font(.system(size: 36))
                            .foregroundStyle(.blue)
                        Text("Transport Advisor")
                            .font(.title2.weight(.bold))
                        Text("Compare your real monthly costs at \(vm.selectedUni)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, 8)

                    ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                        TransportOptionCard(
                            option: option,
                            isSelected: selectedOption == index,
                            colorScheme: colorScheme
                        ) {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                selectedOption = index
                            }
                            UIImpactFeedbackGenerator(style: .light).impactOccurred()
                        }
                    }
                    VStack(spacing: 12) {
                        Text("MONTHLY TOTAL COMPARISON")
                            .font(.caption2.weight(.bold))
                            .tracking(1.2)
                            .foregroundStyle(.secondary)

                        HStack(spacing: 0) {
                            ForEach(Array(options.enumerated()), id: \.offset) { index, option in
                                let total = option.totalCost
                                let isSelected = selectedOption == index
                                VStack(spacing: 6) {
                                    Image(systemName: option.icon)
                                        .font(.system(size: 16))
                                        .foregroundStyle(isSelected ? .white : option.iconColor)
                                    Text(total == 0 ? "Free" : "$\(total)")
                                        .font(.system(.headline, design: .rounded).weight(.bold))
                                        .foregroundStyle(isSelected ? .white : .primary)
                                    Text(index == 2 ? "Transit" : option.name.components(separatedBy: " ").first ?? "")
                                        .font(.caption2)
                                        .foregroundStyle(isSelected ? .white.opacity(0.8) : .secondary)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(isSelected ? option.iconColor : Color(uiColor: .tertiarySystemFill))
                                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                                .scaleEffect(isSelected ? 1.05 : 1.0)
                                .animation(.spring(response: 0.25), value: selectedOption)
                                .onTapGesture {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedOption = index
                                    }
                                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                                }
                                if index < options.count - 1 {
                                    Spacer().frame(width: 8)
                                }
                            }
                        }
                    }
                    .padding(16)
                    .background(Color(uiColor: .secondarySystemGroupedBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                    .cardBorder(colorScheme: colorScheme)
                    .padding(.horizontal, 20)


                    if selectedOption == 2 {
                        HStack(spacing: 8) {
                            Image(systemName: "sparkles").foregroundStyle(.yellow)
                            Text("You'd save ~$\(options[0].totalCost)/mo switching to transit")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.green)
                        }
                        .padding(14)
                        .frame(maxWidth: .infinity)
                        .background(Color.green.opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                        .padding(.horizontal, 20)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                    }

                    Spacer(minLength: 40)
                }
                .padding(.bottom, 100)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Transport Advisor")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Apply") {
                        vm.transportMode = selectedOption
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .safeAreaInset(edge: .bottom) {
                Button {
                    vm.transportMode = selectedOption
                    UINotificationFeedbackGenerator().notificationOccurred(.success)
                    dismiss()
                } label: {
                    HStack(spacing: 8) {
                        Text("Apply \(options[selectedOption].name)")
                            .font(.headline)
                        Image(systemName: "checkmark.circle.fill")
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(options[selectedOption].iconColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 8)
                .background(.regularMaterial)
            }
        }
        .presentationDetents([.large])
    }
}




struct VehicleOption {
    let name: String
    let subtitle: String
    let icon: String
    let iconColor: Color
    let mileage: String
    let costs: [CostLine]
    let pros: [String]
    let cons: [String]
    let tag: String?

    var totalCost: Int { costs.reduce(0) { $0 + $1.amount } }
}

struct CostLine {
    let label: String
    let amount: Int
    let icon: String
}




@available(iOS 17.0, *)
struct TransportOptionCard: View {
    let option: VehicleOption
    let isSelected: Bool
    let colorScheme: ColorScheme
    let onTap: () -> Void

    @State private var showDetails = false

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 12) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 10)
                            .fill(option.iconColor.opacity(isSelected ? 0.2 : 0.1))
                            .frame(width: 44, height: 44)
                        Image(systemName: option.icon)
                            .font(.system(size: 20))
                            .foregroundStyle(option.iconColor)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        HStack(spacing: 6) {
                            Text(option.name)
                                .font(.subheadline.weight(.semibold))
                                .foregroundStyle(.primary)
                                .lineLimit(1)
                            if let tag = option.tag {
                                Text(tag)
                                    .font(.system(size: 9, weight: .bold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 6)
                                    .padding(.vertical, 2)
                                    .background(Color.green)
                                    .clipShape(Capsule())
                            }
                        }
                        Text(option.subtitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(option.mileage)
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                            .lineLimit(1)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 2) {
                        Text(option.totalCost == 0 ? "Free" : "$\(option.totalCost)")
                            .font(.title3.weight(.bold))
                            .foregroundStyle(option.totalCost == 0 ? .green : .primary)
                        Text("/mo")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(16)
            }
            .buttonStyle(.plain)


            if isSelected {
                VStack(alignment: .leading, spacing: 14) {
                    Divider()


                    ForEach(Array(option.costs.enumerated()), id: \.offset) { _, cost in
                        HStack(spacing: 10) {
                            Image(systemName: cost.icon)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .frame(width: 20)
                            Text(cost.label)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            Spacer()
                            Text(cost.amount == 0 ? "Free" : "$\(cost.amount)")
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(cost.amount == 0 ? .green : .primary)
                        }
                    }

                    Divider()


                    VStack(alignment: .leading, spacing: 6) {
                        Text("WHY THIS WORKS")
                            .font(.caption2.weight(.bold))
                            .tracking(0.8)
                            .foregroundStyle(.green)
                        ForEach(option.pros, id: \.self) { pro in
                            HStack(spacing: 6) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.green)
                                Text(pro)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }


                    VStack(alignment: .leading, spacing: 6) {
                        Text("WATCH OUT FOR")
                            .font(.caption2.weight(.bold))
                            .tracking(0.8)
                            .foregroundStyle(.orange)
                        ForEach(option.cons, id: \.self) { con in
                            HStack(spacing: 6) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .font(.caption2)
                                    .foregroundStyle(.orange)
                                Text(con)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color(uiColor: .secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(
            isSelected
                ? RoundedRectangle(cornerRadius: 16, style: .continuous)
                    .stroke(option.iconColor, lineWidth: 2)
                : nil
        )
        .cardBorder(colorScheme: isSelected ? .dark : colorScheme)
        .padding(.horizontal, 20)
        .animation(.spring(response: 0.35, dampingFraction: 0.8), value: isSelected)
    }
}
