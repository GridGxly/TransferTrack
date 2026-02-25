import SwiftUI
import SwiftData

@available(iOS 17.0, *)
struct DashboardView: View {
    @State private var vm = TransferViewModel()
    @State private var selectedTab: Int = 0
    @State private var showEditSheet: Bool = false
    @Binding var isOnboardingComplete: Bool


    private let tabs: [(icon: String, label: String)] = [
        ("chart.line.uptrend.xyaxis", "Forecast"),
        ("book.closed.fill", "Academics"),
        ("house.fill", "Housing"),
        ("lightbulb.fill", "Solutions"),
        ("calendar", "Timeline")
    ]

    var body: some View {
        ZStack(alignment: .bottom) {
            ScoreAwareBackground(score: vm.viabilityScore)


            GeometryReader { geo in
                ZStack {
                    NavigationStack {
                        ScrollView(showsIndicators: false) {
                            ForecastTab(vm: vm, showEditSheet: $showEditSheet)
                            Spacer(minLength: 120)
                        }
                        .background(Color.clear)
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
                    .frame(width: geo.size.width, height: geo.size.height)
                    .offset(x: slideOffset(for: 0, in: geo.size.width))
                    .opacity(tabOpacity(for: 0))
                    .allowsHitTesting(selectedTab == 0)


                    NavigationStack {
                        AcademicsTab(vm: vm)
                            .navigationTitle("Academics")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .offset(x: slideOffset(for: 1, in: geo.size.width))
                    .opacity(tabOpacity(for: 1))
                    .allowsHitTesting(selectedTab == 1)


                    NavigationStack {
                        HousingTab(vm: vm)
                            .navigationTitle("Housing")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .offset(x: slideOffset(for: 2, in: geo.size.width))
                    .opacity(tabOpacity(for: 2))
                    .allowsHitTesting(selectedTab == 2)

                    NavigationStack {
                        ScrollView(showsIndicators: false) {
                            SolutionsTab(vm: vm)
                            Spacer(minLength: 120)
                        }
                        .background(Color.clear)
                        .navigationTitle("Solutions")
                        .navigationBarTitleDisplayMode(.inline)
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .offset(x: slideOffset(for: 3, in: geo.size.width))
                    .opacity(tabOpacity(for: 3))
                    .allowsHitTesting(selectedTab == 3)

                    NavigationStack {
                        TimelineTab(vm: vm)
                            .navigationTitle("Timeline")
                            .navigationBarTitleDisplayMode(.inline)
                    }
                    .frame(width: geo.size.width, height: geo.size.height)
                    .offset(x: slideOffset(for: 4, in: geo.size.width))
                    .opacity(tabOpacity(for: 4))
                    .allowsHitTesting(selectedTab == 4)
                }
                .clipped()
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.85), value: selectedTab)
            .ignoresSafeArea(.keyboard)

            tabBarView
        }
        .sheet(isPresented: $showEditSheet) {
            EditPathSheet(vm: vm, isOnboardingComplete: $isOnboardingComplete)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: selectedTab)
        .onAppear {
            vm.cacheForSiri()
        }
    }

    private func slideOffset(for tabIndex: Int, in width: CGFloat) -> CGFloat {
        CGFloat(tabIndex - selectedTab) * width
    }

    private func tabOpacity(for tabIndex: Int) -> Double {
        abs(tabIndex - selectedTab) <= 1 ? 1.0 : 0.0
    }

    @ViewBuilder
    private var tabBarView: some View {
        if #available(iOS 26.0, *) {
            LiquidTabBar(selectedTab: $selectedTab, tabs: tabs)
        } else {
            FloatingTabBar(selectedTab: $selectedTab, tabs: tabs)
        }
    }
}



@available(iOS 17.0, *)
struct EditPathSheet: View {
    @Bindable var vm: TransferViewModel
    @Binding var isOnboardingComplete: Bool
    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    @State private var editState: String
    @State private var editCC: String
    @State private var editUni: String
    @State private var editGPA: String
    @State private var editCredits: String
    @State private var editSavings: String
    @State private var editRent: String
    @State private var editSemester: String
    @State private var editTheme: AppTheme

    @State private var showRestartConfirmation = false

    @AppStorage("appTheme") private var appTheme: String = AppTheme.system.rawValue

    private var ccs: [String] { SchoolDatabase.stateData[editState]?.ccs ?? [] }
    private var unis: [String] { SchoolDatabase.stateData[editState]?.unis ?? [] }


    private var hasChanges: Bool {
        editState != vm.selectedState ||
        editCC != vm.selectedCC ||
        editUni != vm.selectedUni ||
        editGPA != String(format: "%.2f", vm.userGPA) ||
        editCredits != "\(Int(vm.userCredits))" ||
        editSavings != "\(Int(vm.userSavings))" ||
        editRent != "\(Int(vm.userRent))" ||
        editSemester != vm.transferSemester ||
        editTheme.rawValue != appTheme
    }


    private let semesters = ["Fall 2026", "Spring 2027", "Fall 2027", "Spring 2028"]

    private var semesterTerm: String {
        editSemester.components(separatedBy: " ").first ?? "Fall"
    }
    private var semesterYear: String {
        editSemester.components(separatedBy: " ").last ?? "2026"
    }

    init(vm: TransferViewModel, isOnboardingComplete: Binding<Bool>) {
        self.vm = vm
        self._isOnboardingComplete = isOnboardingComplete
        _editState = State(initialValue: vm.selectedState)
        _editCC = State(initialValue: vm.selectedCC)
        _editUni = State(initialValue: vm.selectedUni)
        _editGPA = State(initialValue: String(format: "%.2f", vm.userGPA))
        _editCredits = State(initialValue: "\(Int(vm.userCredits))")
        _editSavings = State(initialValue: "\(Int(vm.userSavings))")
        _editRent = State(initialValue: "\(Int(vm.userRent))")
        _editSemester = State(initialValue: vm.transferSemester)

        let current = AppTheme(rawValue: UserDefaults.standard.string(forKey: "appTheme") ?? "system") ?? .system
        _editTheme = State(initialValue: current)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    Picker("State", selection: $editState) {
                        ForEach(SchoolDatabase.states, id: \.self) { state in
                            Text(state).tag(state)
                        }
                    }

                    HStack(spacing: 12) {
                        CollegeLogo(schoolName: editCC, size: 32)
                            .id(editCC)
                            .transition(.scale.combined(with: .opacity))
                        Picker("Community College", selection: $editCC) {
                            ForEach(ccs, id: \.self) { cc in
                                Text(cc).tag(cc)
                            }
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: editCC)
                    }

                    HStack(spacing: 12) {
                        CollegeLogo(schoolName: editUni, size: 32)
                            .id(editUni)
                            .transition(.scale.combined(with: .opacity))
                        Picker("University", selection: $editUni) {
                            ForEach(unis, id: \.self) { uni in
                                Text(uni).tag(uni)
                            }
                        }
                        .animation(.spring(response: 0.4, dampingFraction: 0.7), value: editUni)
                    }
                } header: {
                    Text("Transfer Path")
                }

                Section {
                    HStack {
                        Text("GPA")
                        Spacer()
                        TextField("3.20", text: $editGPA)
                            .keyboardType(.decimalPad)
                            .multilineTextAlignment(.trailing)
                            .monospacedDigit()
                            .frame(width: 80)
                            .foregroundStyle(.primary)
                            .onChange(of: editGPA) { _, newVal in
                                editGPA = clampGPAInput(newVal)
                            }
                    }
                    HStack {
                        Text("Credits Earned")
                        Spacer()
                        TextField("45", text: $editCredits)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .monospacedDigit()
                            .frame(width: 80)
                            .foregroundStyle(.primary)
                            .onChange(of: editCredits) { _, newVal in
                                editCredits = clampCreditsInput(newVal)
                            }
                    }
                } header: {
                    Text("Academics")
                }

                Section {
                    HStack {
                        Text("Current Savings")
                        Spacer()
                        Text("$")
                            .foregroundStyle(.secondary)
                        TextField("2,500", text: $editSavings)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .monospacedDigit()
                            .frame(width: 80)
                            .foregroundStyle(.primary)
                    }
                    HStack {
                        Text("Monthly Rent")
                        Spacer()
                        Text("$")
                            .foregroundStyle(.secondary)
                        TextField("1,200", text: $editRent)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .monospacedDigit()
                            .frame(width: 80)
                            .foregroundStyle(.primary)
                    }

                    Picker("Transfer Semester", selection: $editSemester) {
                        ForEach(semesters, id: \.self) { semester in
                            Text(semester).tag(semester)
                        }
                    }
                } header: {
                    Text("Finances")
                } footer: {
                    Text("Used to calculate your monthly forecast and financial runway.")
                        .font(.caption)
                }

                Section {
                    VStack(alignment: .leading, spacing: 10) {
                        Text("Theme")
                            .font(.subheadline)
                        Picker("Theme", selection: $editTheme) {
                            ForEach(AppTheme.allCases) { theme in
                                Label(theme.label, systemImage: theme.icon)
                                    .tag(theme)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.vertical, 4)
                } header: {
                    Text("Appearance")
                }

                Section {
                    Button(role: .destructive) {
                        showRestartConfirmation = true
                    } label: {
                        HStack {
                            Image(systemName: "arrow.counterclockwise")
                            Text("Restart Onboarding")
                        }
                    }
                } header: {
                    Text("Reset")
                } footer: {
                    Text("This will clear your current setup and start the onboarding process over. Your saved course data will not be deleted.")
                        .font(.caption)
                }
            }
            .navigationTitle("Edit Transfer Path")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        applyChanges()
                        UINotificationFeedbackGenerator().notificationOccurred(.success)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                    .disabled(!hasChanges)
                }
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("Done") {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil, from: nil, for: nil
                        )
                    }
                }
            }
            .onChange(of: editState) { _, _ in
                editCC = ccs.first ?? ""
                editUni = unis.first ?? ""
            }
            .confirmationDialog(
                "Restart Onboarding?",
                isPresented: $showRestartConfirmation,
                titleVisibility: .visible
            ) {
                Button("Restart", role: .destructive) {
                    UserDefaults.standard.set(false, forKey: "hasCompletedOnboarding")
                    isOnboardingComplete = false
                    dismiss()
                }
                Button("Cancel", role: .cancel) { }
            } message: {
                Text("This will reset your transfer path setup. You'll need to re-enter your information. Your added courses will be kept.")
            }
        }
    }

    private func applyChanges() {
        vm.selectedState = editState
        vm.selectedCC = editCC
        vm.selectedUni = editUni
        vm.userGPA = clampGPA(Double(editGPA) ?? vm.userGPA)
        vm.userCredits = Double(editCredits) ?? vm.userCredits
        vm.userSavings = Double(editSavings) ?? vm.userSavings
        vm.userRent = Double(editRent) ?? vm.userRent
        vm.transferSemester = editSemester

        appTheme = editTheme.rawValue

        vm.forceRecalculate()
    }
}
