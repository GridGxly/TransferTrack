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

    private let options: [VehicleOption] = [
        VehicleOption(
            name: "Keep Current Car",
            subtitle: "2007 Infiniti FX35",
            icon: "car.fill",
            iconColor: .orange,
            mileage: "14 MPG city · 19 hwy",
            costs: [
                CostLine(label: "Gas (800 mi/mo)", amount: 180, icon: "fuelpump.fill"),
                CostLine(label: "Insurance (full coverage)", amount: 145, icon: "shield.fill"),
                CostLine(label: "Maintenance (high mileage)", amount: 95, icon: "wrench.fill"),
                CostLine(label: "UCF Parking Permit", amount: 53, icon: "parkingsign.circle.fill"),
            ],
            pros: ["No car payment", "Freedom to drive anywhere", "Move furniture yourself"],
            cons: ["$180/mo in gas alone (V6 eats)", "17 years old — breakdowns add up", "Insurance is brutal on SUVs under 25"],
            tag: nil
        ),
        VehicleOption(
            name: "Swap to Used Car",
            subtitle: "2019 Honda Civic (example)",
            icon: "car.side.front.open.fill",
            iconColor: .blue,
            mileage: "30 MPG city · 38 hwy",
            costs: [
                CostLine(label: "Gas (800 mi/mo)", amount: 85, icon: "fuelpump.fill"),
                CostLine(label: "Insurance (liability)", amount: 90, icon: "shield.fill"),
                CostLine(label: "Maintenance", amount: 25, icon: "wrench.fill"),
                CostLine(label: "UCF Parking Permit", amount: 53, icon: "parkingsign.circle.fill"),
            ],
            pros: ["Half the gas cost", "Way cheaper insurance", "Sell the FX35 for ~$4–6K cash injection"],
            cons: ["Car payment ~$280/mo if financed", "Depreciation on the new purchase", "Time spent selling + buying"],
            tag: nil
        ),
        VehicleOption(
            name: "UCF Shuttle + Transit",
            subtitle: "Free with tuition fees",
            icon: "bus.fill",
            iconColor: .green,
            mileage: "SunRail · Lynx · UCF Shuttle",
            costs: [
                CostLine(label: "UCF Shuttle", amount: 0, icon: "bus.fill"),
                CostLine(label: "Lynx Bus Pass", amount: 0, icon: "tram.fill"),
                CostLine(label: "SunRail (occasional)", amount: 0, icon: "tram.circle.fill"),
                CostLine(label: "Lyft/Uber (emergencies)", amount: 40, icon: "car.circle.fill"),
            ],
            pros: ["$0/mo base cost", "Sell the car → $4–6K in savings", "No parking, insurance, or gas stress"],
            cons: ["Limited late-night routes", "Grocery trips need planning", "64-mile commute home is harder"],
            tag: "BEST VALUE"
        ),
    ]

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
                        Text("Compare your real monthly costs")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
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
                                    Text(option.name.components(separatedBy: " ").first ?? "")
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
