import SwiftUI

@available(iOS 17.0, *)
struct DashboardView: View {
    @Binding var isOnboardingComplete: Bool
    @State private var vm = TransferViewModel()
    @State private var selectedTab = 0
    @State private var showEditSheet = false

    private let tabs: [(icon: String, label: String)] = [
        ("chart.bar.fill", "Forecast"),
        ("book.closed.fill", "Academics"),
        ("house.fill", "Housing"),
        ("lightbulb.fill", "Solutions"),
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            TabView(selection: $selectedTab) {
                NavigationStack {
                    ScrollView(showsIndicators: false) {
                        ForecastTab(vm: vm, showEditSheet: $showEditSheet)
                        Spacer(minLength: 120)
                    }
                    .background(Color(uiColor: .systemGroupedBackground))
                    .navigationTitle("Forecast")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .primaryAction) {
                            Button { showEditSheet = true } label: {
                                Image(systemName: "slider.horizontal.3")
                                    .font(.body)
                                    .foregroundStyle(.primary)
                            }
                            .accessibilityLabel("Edit transfer path")
                        }
                    }
                }
                .tag(0)

                NavigationStack {
                    AcademicsTab(vm: vm)
                        .navigationTitle("Academics")
                }
                .tag(1)

                NavigationStack {
                    HousingTab(vm: vm)
                        .navigationTitle("Housing")
                        .navigationBarTitleDisplayMode(.inline)
                }
                .tag(2)

                NavigationStack {
                    ScrollView(showsIndicators: false) {
                        SolutionsTab(vm: vm)
                        Spacer(minLength: 120)
                    }
                    .background(Color(uiColor: .systemGroupedBackground))
                    .navigationTitle("Solutions")
                    .navigationBarTitleDisplayMode(.inline)
                }
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))

            if #available(iOS 26.0, *) {
                LiquidTabBar(selectedTab: $selectedTab, tabs: tabs)
            } else {
                FloatingTabBar(selectedTab: $selectedTab, tabs: tabs)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .ignoresSafeArea(edges: [])
        .sheet(isPresented: $showEditSheet) {
            EditPathSheet(vm: vm, isOnboardingComplete: $isOnboardingComplete)
        }
        .sensoryFeedback(.increase, trigger: vm.monthlyGap) { old, new in new > old }
        .sensoryFeedback(.decrease, trigger: vm.monthlyGap) { old, new in new < old }
        .onAppear { vm.cacheForSiri() }
        .onChange(of: vm.monthlyGap) { _, _ in vm.cacheForSiri() }
        .onChange(of: vm.updateTrigger) { _, _ in
            vm.cacheForSiri()
        }
    }
}




@available(iOS 17.0, *)
struct EditPathSheet: View {
    @Bindable var vm: TransferViewModel
    @Binding var isOnboardingComplete: Bool
    @Environment(\.dismiss) private var dismiss
    @AppStorage("appTheme") private var appTheme: String = AppTheme.system.rawValue

    @State private var localState: String
    @State private var localCC: String
    @State private var localUni: String
    @State private var gpaText: String
    @State private var creditsText: String
    @State private var savingsText: String
    @State private var rentText: String

    init(vm: TransferViewModel, isOnboardingComplete: Binding<Bool>) {
        self.vm = vm
        self._isOnboardingComplete = isOnboardingComplete
        _localState = State(initialValue: vm.selectedState)
        _localCC = State(initialValue: vm.selectedCC)
        _localUni = State(initialValue: vm.selectedUni)
        _gpaText = State(initialValue: String(format: "%.2f", vm.userGPA))
        _creditsText = State(initialValue: "\(Int(vm.userCredits))")
        _savingsText = State(initialValue: "\(Int(vm.userSavings))")
        _rentText = State(initialValue: "\(Int(vm.userRent))")
    }

    private var ccs: [String] { SchoolDatabase.stateData[localState]?.ccs ?? [] }
    private var unis: [String] { SchoolDatabase.stateData[localState]?.unis ?? [] }
    private var selectedTheme: AppTheme { AppTheme(rawValue: appTheme) ?? .system }

    var body: some View {
        NavigationStack {
            Form {
                Section("Transfer Path") {
                    Picker("State", selection: $localState) {
                        ForEach(SchoolDatabase.states, id: \.self) { Text($0) }
                    }
                    HStack {
                        CollegeLogo(schoolName: localCC, size: 28)
                        Picker("From", selection: $localCC) {
                            ForEach(ccs, id: \.self) { Text($0) }
                        }
                    }
                    HStack {
                        CollegeLogo(schoolName: localUni, size: 28)
                        Picker("To", selection: $localUni) {
                            ForEach(unis, id: \.self) { Text($0) }
                        }
                    }
                }

                Section("Academics") {
                    HStack {
                        Text("GPA"); Spacer()
                        TextField("3.20", text: $gpaText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    HStack {
                        Text("Credits Earned"); Spacer()
                        TextField("45", text: $creditsText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }

                Section("Finances") {
                    HStack {
                        Text("Savings"); Spacer()
                        HStack(spacing: 2) {
                            Text("$").foregroundStyle(.secondary)
                            TextField("2500", text: $savingsText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        }
                    }
                    HStack {
                        Text("Monthly Rent"); Spacer()
                        HStack(spacing: 2) {
                            Text("$").foregroundStyle(.secondary)
                            TextField("1200", text: $rentText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        }
                    }
                }

                Section("Appearance") {
                    Picker("Theme", selection: Binding(
                        get: { selectedTheme },
                        set: { appTheme = $0.rawValue }
                    )) {
                        ForEach(AppTheme.allCases) { theme in
                            Label(theme.label, systemImage: theme.icon).tag(theme)
                        }
                    }
                    .pickerStyle(.segmented)
                }

                Section {
                    Button("Reset Onboarding", role: .destructive) {
                        UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                        dismiss()
                        withAnimation { isOnboardingComplete = false }
                    }
                }
            }
            .navigationTitle("Edit Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }.fontWeight(.semibold)
                }
            }
            .onChange(of: localState) { _, _ in
                localCC = ccs.first ?? ""
                localUni = unis.first ?? ""
            }
        }
        .preferredColorScheme(selectedTheme.colorScheme)
    }

    private func save() {
        withAnimation(.spring(response: 0.4)) {
            vm.selectedState = localState
            vm.selectedCC = localCC
            vm.selectedUni = localUni
            vm.userGPA = Double(gpaText) ?? vm.userGPA
            vm.userCredits = Double(creditsText) ?? vm.userCredits
            vm.userSavings = Double(savingsText) ?? vm.userSavings
            vm.userRent = Double(rentText) ?? vm.userRent
        }

        vm.forceRecalculate()

        UINotificationFeedbackGenerator().notificationOccurred(.success)

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            dismiss()
        }
    }
}
