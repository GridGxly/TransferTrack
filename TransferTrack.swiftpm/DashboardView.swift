import SwiftUI

// MARK: - dashboard view

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
            VStack(spacing: 0) {
                // MARK: tappable header (change path)
                Button {
                    showEditSheet = true
                } label: {
                    VStack(alignment: .leading, spacing: 6) {
                        HStack(spacing: 8) {
                            Text(vm.userName.isEmpty ? "Your Transfer Plan" : "\(vm.userName)'s Transfer Plan")
                                .font(.title2.weight(.bold))
                                .foregroundStyle(.primary)
                            Spacer()
                            Image(systemName: "pencil.circle.fill")
                                .font(.title3)
                                .foregroundStyle(.secondary)
                        }
                        HStack(spacing: 8) {
                            CollegeLogo(schoolName: vm.selectedCC, size: 24)
                            Text(vm.selectedCC)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                            Image(systemName: "arrow.right")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                            CollegeLogo(schoolName: vm.selectedUni, size: 24)
                            Text(vm.selectedUni)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    .padding(.bottom, 12)
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Transfer path: \(vm.selectedCC) to \(vm.selectedUni). Tap to edit.")
                .accessibilityHint("Opens editor to change schools, GPA, and financial info")

                // MARK: tab content. each in its own NavigationStack
                TabView(selection: $selectedTab) {
                    NavigationStack {
                        ScrollView(showsIndicators: false) {
                            ForecastTab(vm: vm)
                                .padding(.top, 10)
                                .padding(.bottom, 100)
                        }
                    }
                    .tag(0)

                    NavigationStack {
                        AcademicsTab(vm: vm)
                    }
                    .tag(1)

                    NavigationStack {
                        HousingTab(vm: vm)
                    }
                    .tag(2)

                    NavigationStack {
                        ScrollView(showsIndicators: false) {
                            SolutionsTab(vm: vm)
                                .padding(.top, 10)
                                .padding(.bottom, 100)
                        }
                    }
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }

            // MARK: tab bar
            if #available(iOS 26.0, *) {
                LiquidTabBar(selectedTab: $selectedTab, tabs: tabs)
            } else {
                FloatingTabBar(selectedTab: $selectedTab, tabs: tabs)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .ignoresSafeArea(edges: .bottom)
        .sheet(isPresented: $showEditSheet) {
            EditPathSheet(vm: vm, isOnboardingComplete: $isOnboardingComplete)
        }
    }
}

// MARK: - edit path sheet

@available(iOS 17.0, *)
struct EditPathSheet: View {
    @Bindable var vm: TransferViewModel
    @Binding var isOnboardingComplete: Bool
    @Environment(\.dismiss) private var dismiss

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

    var body: some View {
        NavigationStack {
            Form {
                Section("Transfer Path") {
                    Picker("State", selection: $localState) {
                        ForEach(SchoolDatabase.states, id: \.self) { Text($0) }
                    }
                    Picker("From", selection: $localCC) {
                        ForEach(ccs, id: \.self) { Text($0) }
                    }
                    Picker("To", selection: $localUni) {
                        ForEach(unis, id: \.self) { Text($0) }
                    }
                }

                Section("Academics") {
                    HStack {
                        Text("GPA")
                        Spacer()
                        TextField("3.20", text: $gpaText)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                    HStack {
                        Text("Credits Earned")
                        Spacer()
                        TextField("45", text: $creditsText)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 80)
                    }
                }

                Section("Finances") {
                    HStack {
                        Text("Savings")
                        Spacer()
                        HStack(spacing: 2) {
                            Text("$")
                            TextField("2500", text: $savingsText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        }
                    }
                    HStack {
                        Text("Monthly Rent")
                        Spacer()
                        HStack(spacing: 2) {
                            Text("$")
                            TextField("1200", text: $rentText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 80)
                        }
                    }
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
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .fontWeight(.semibold)
                }
            }
            .onChange(of: localState) { _, _ in
                localCC = ccs.first ?? ""
                localUni = unis.first ?? ""
            }
        }
    }

    private func save() {
        vm.selectedState = localState
        vm.selectedCC = localCC
        vm.selectedUni = localUni
        vm.userGPA = Double(gpaText) ?? vm.userGPA
        vm.userCredits = Double(creditsText) ?? vm.userCredits
        vm.userSavings = Double(savingsText) ?? vm.userSavings
        vm.userRent = Double(rentText) ?? vm.userRent
        UINotificationFeedbackGenerator().notificationOccurred(.success)
        dismiss()
    }
}
