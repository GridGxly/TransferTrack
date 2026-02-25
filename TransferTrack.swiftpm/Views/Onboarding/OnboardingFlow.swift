import SwiftUI


@available(iOS 17.0, *)
struct OnboardingFlow: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentPage = 0
    @State private var isTransitioning = false

    @State private var userName = ""
    @State private var selectedState = "Florida"
    @State private var selectedCC = "Valencia College"
    @State private var selectedUni = "UCF"
    @State private var gpaText = ""
    @State private var creditsText = ""
    @State private var savingsText = ""
    @State private var rentText = ""
    @State private var transferSemester = "Fall 2026"

    private let totalPages = 6
    private var contentSteps: Int { totalPages - 2 }

    var body: some View {
        ZStack {
            OnboardingBackground(step: currentPage, totalSteps: totalPages)

            VStack(spacing: 0) {
                if currentPage > 0 && currentPage < totalPages - 1 {
                    VStack(spacing: 6) {
                        HStack(spacing: 4) {
                            ForEach(1..<totalPages - 1, id: \.self) { step in
                                Capsule()
                                    .fill(step <= currentPage ? Color.white : Color.white.opacity(0.2))
                                    .frame(height: 3)
                                    .animation(.spring(response: 0.4), value: currentPage)
                            }
                        }
                        .padding(.horizontal, 24)

                        Text("Step \(currentPage) of \(contentSteps)")
                            .font(.system(.caption2, design: .rounded).weight(.medium))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .padding(.top, 12)
                    .transition(.opacity)
                    .accessibilityLabel("Step \(currentPage) of \(contentSteps)")
                }

                TabView(selection: $currentPage) {
                    OnboardingHero(onNext: advance).tag(0)
                    OnboardingName(name: $userName, onNext: advance).tag(1)
                    OnboardingPath(
                        name: userName,
                        selectedState: $selectedState,
                        selectedCC: $selectedCC,
                        selectedUni: $selectedUni,
                        onNext: advance
                    ).tag(2)
                    OnboardingAcademics(
                        name: userName,
                        gpaText: $gpaText,
                        creditsText: $creditsText,
                        onNext: advance
                    ).tag(3)
                    OnboardingFinances(
                        name: userName,
                        savingsText: $savingsText,
                        rentText: $rentText,
                        transferSemester: $transferSemester,
                        onNext: { saveAllData(); advance() }
                    ).tag(4)
                    OnboardingLoading(
                        uniName: selectedUni,
                        onComplete: {
                            UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                                isOnboardingComplete = true
                            }
                        }
                    ).tag(5)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.spring(response: 0.5, dampingFraction: 0.82), value: currentPage)
                .disabled(isTransitioning)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.sendAction(
                        #selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil
                    )
                }
                .foregroundStyle(.blue)
            }
        }
    }

    private func advance() {
        guard !isTransitioning, currentPage < totalPages - 1 else { return }
        isTransitioning = true
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        UIImpactFeedbackGenerator(style: .soft).impactOccurred()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.82)) { currentPage += 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) { isTransitioning = false }
    }

    private func saveAllData() {
        let d = UserDefaults.standard
        d.set(userName, forKey: "userName")
        d.set(selectedState, forKey: "selectedState")
        d.set(selectedCC, forKey: "selectedCC")
        d.set(selectedUni, forKey: "selectedUni")
        d.set(clampGPA(Double(gpaText) ?? 3.2), forKey: "userGPA")
        d.set(Double(creditsText) ?? 45, forKey: "userCredits")
        d.set(Double(savingsText) ?? 2500, forKey: "userSavings")
        d.set(Double(rentText) ?? 1200, forKey: "userRent")
        d.set(transferSemester, forKey: "transferSemester")
    }
}

@available(iOS 17.0, *)
struct OnboardingHero: View {
    var onNext: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Group {
                if let appIcon = loadAppIcon() {
                    Image(uiImage: appIcon)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                        .shadow(color: TTBrand.skyBlue.opacity(0.4), radius: 20, y: 8)
                } else {
                    ZStack {
                        RoundedRectangle(cornerRadius: 22, style: .continuous)
                            .fill(
                                LinearGradient(
                                    colors: [Color(red: 0.08, green: 0.10, blue: 0.18), Color(red: 0.04, green: 0.06, blue: 0.12)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                        Text("TT")
                            .font(.system(size: 44, weight: .black, design: .rounded))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [TTBrand.mint, Color(red: 0.4, green: 0.9, blue: 0.3)],
                                    startPoint: .topLeading, endPoint: .bottomTrailing
                                )
                            )
                    }
                    .frame(width: 100, height: 100)
                    .shadow(color: TTBrand.mint.opacity(0.3), radius: 20, y: 8)
                }
            }
            .staggerFade(delay: 0.15, yOffset: 24)

            Text("TransferTrack")
                .font(.system(size: 36, weight: .black, design: .rounded))
                .foregroundStyle(.white)
                .padding(.top, 28)
                .staggerFade(delay: 0.30)

            Text("Navigate the 2+2 transfer path\nwithout losing credits or cash.")
                .font(.system(.title3, design: .rounded).weight(.medium))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.top, 10)
                .padding(.horizontal, 32)
                .staggerFade(delay: 0.45)

            Spacer()
            Spacer()

            OnboardingButton(title: "Get started", icon: "arrow.right", action: onNext)
                .staggerFade(delay: 0.60, yOffset: 24)
        }
    }
}

@available(iOS 17.0, *)
struct OnboardingName: View {
    @Binding var name: String
    var onNext: () -> Void
    @FocusState private var nameFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "person.crop.circle")
                .font(.system(size: 56))
                .foregroundStyle(.white.opacity(0.8))
                .staggerFade(delay: 0.10)

            Text("What should we\ncall you?")
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .staggerFade(delay: 0.20)

            VStack(spacing: 6) {
                Text("Name")
                    .font(.system(.caption, design: .rounded).weight(.medium))
                    .foregroundStyle(.white.opacity(0.5))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 50)

                HStack(spacing: 0) {
                    Text("Hi, I'm ")
                        .font(.system(size: 32, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                    TextField("", text: $name, prompt: Text("Ralph").foregroundStyle(.white.opacity(0.25)))
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .submitLabel(.next)
                        .onSubmit { if !name.isEmpty { onNext() } }
                        .autocorrectionDisabled()
                        .focused($nameFocused)
                        .frame(maxWidth: 200)
                    Text(".")
                        .font(.system(size: 32, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.5))
                }

                Rectangle()
                    .fill(name.isEmpty ? Color.white.opacity(0.2) : TTBrand.skyBlue)
                    .frame(height: 2)
                    .padding(.horizontal, 50)
                    .animation(.spring(response: 0.3), value: name.isEmpty)
            }
            .padding(.top, 32)
            .staggerFade(delay: 0.35)

            Spacer()
            Spacer()

            OnboardingButton(title: "Next", icon: "arrow.right", action: onNext)
                .disabled(name.isEmpty)
                .opacity(name.isEmpty ? 0.4 : 1.0)
                .staggerFade(delay: 0.50)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { nameFocused = true }
        }
    }
}

@available(iOS 17.0, *)
struct OnboardingPath: View {
    let name: String
    @Binding var selectedState: String
    @Binding var selectedCC: String
    @Binding var selectedUni: String
    var onNext: () -> Void

    private var ccs: [String] { SchoolDatabase.stateData[selectedState]?.ccs ?? [] }
    private var unis: [String] { SchoolDatabase.stateData[selectedState]?.unis ?? [] }

    @State private var connectionAnimated = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 40)

                    Image(systemName: "map.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.8))
                        .staggerFade(delay: 0.10)

                    Text("Where are you\ntransferring, \(name)?")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)
                        .staggerFade(delay: 0.20)

                    HStack(spacing: 0) {
                        VStack(spacing: 8) {
                            CollegeLogo(schoolName: selectedCC, size: 56)
                                .id(selectedCC)
                                .transition(.scale.combined(with: .opacity))
                                .environment(\.colorScheme, .dark)
                            Text("From")
                                .font(.system(.caption2, design: .rounded).weight(.bold))
                                .foregroundStyle(.white.opacity(0.5))
                                .textCase(.uppercase)
                            Text(selectedCC)
                                .font(.system(.caption, design: .rounded).weight(.medium))
                                .foregroundStyle(.white.opacity(0.8))
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .frame(width: 100)
                        }

                        ZStack {
                            Rectangle()
                                .fill(Color.white.opacity(0.15))
                                .frame(height: 2)
                            Rectangle()
                                .fill(
                                    LinearGradient(
                                        colors: [TTBrand.skyBlue, TTBrand.mint],
                                        startPoint: .leading, endPoint: .trailing
                                    )
                                )
                                .frame(width: connectionAnimated ? nil : 0, height: 2)
                                .frame(maxWidth: .infinity, alignment: .leading)

                            Image(systemName: "airplane")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.white)
                                .opacity(connectionAnimated ? 1 : 0)
                                .offset(x: connectionAnimated ? 20 : -20)
                        }
                        .frame(maxWidth: 80)
                        .padding(.bottom, 30)

                        VStack(spacing: 8) {
                            CollegeLogo(schoolName: selectedUni, size: 56)
                                .id(selectedUni)
                                .transition(.scale.combined(with: .opacity))
                                .environment(\.colorScheme, .dark)
                            Text("To")
                                .font(.system(.caption2, design: .rounded).weight(.bold))
                                .foregroundStyle(.white.opacity(0.5))
                                .textCase(.uppercase)
                            Text(selectedUni)
                                .font(.system(.caption, design: .rounded).weight(.medium))
                                .foregroundStyle(.white.opacity(0.8))
                                .lineLimit(2)
                                .multilineTextAlignment(.center)
                                .frame(width: 100)
                        }
                    }
                    .padding(.top, 32)
                    .staggerFade(delay: 0.30)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedCC)
                    .animation(.spring(response: 0.4, dampingFraction: 0.7), value: selectedUni)
                    .onAppear {
                        withAnimation(.spring(response: 0.6).delay(0.8)) { connectionAnimated = true }
                    }

                    VStack(spacing: 16) {
                        OnboardingPickerRow(label: "Your state", icon: "mappin.and.ellipse") {
                            Picker("State", selection: $selectedState) {
                                ForEach(SchoolDatabase.states, id: \.self) { Text($0) }
                            }.pickerStyle(.menu).tint(.white)
                        }
                        .staggerFade(delay: 0.40)

                        OnboardingPickerRow(label: "Community college", icon: "building.columns.fill") {
                            Picker("CC", selection: $selectedCC) {
                                ForEach(ccs, id: \.self) { Text($0) }
                            }.pickerStyle(.menu).tint(.white)
                        }
                        .staggerFade(delay: 0.50)

                        OnboardingPickerRow(label: "Dream school", icon: "graduationcap.fill") {
                            Picker("Uni", selection: $selectedUni) {
                                ForEach(unis, id: \.self) { Text($0) }
                            }.pickerStyle(.menu).tint(.white)
                        }
                        .staggerFade(delay: 0.60)
                    }
                    .padding(.top, 28)
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 100)
                }
            }
            .scrollDismissesKeyboard(.interactively)

            OnboardingButton(title: "Next", icon: "arrow.right", action: onNext)
                .staggerFade(delay: 0.70)
        }
        .onChange(of: selectedState) { _, _ in
            selectedCC = ccs.first ?? ""
            selectedUni = unis.first ?? ""
            connectionAnimated = false
            withAnimation(.spring(response: 0.5).delay(0.2)) { connectionAnimated = true }
            UIImpactFeedbackGenerator(style: .rigid).impactOccurred()
        }
    }
}

@available(iOS 17.0, *)
struct OnboardingAcademics: View {
    let name: String
    @Binding var gpaText: String
    @Binding var creditsText: String
    var onNext: () -> Void
    @FocusState private var gpaFocused: Bool

    private var gpaValue: Double { Double(gpaText) ?? 0 }
    private var creditsValue: Int { Int(creditsText) ?? 0 }
    private var isValid: Bool { !gpaText.isEmpty && !creditsText.isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 40)

                    Image(systemName: "book.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.8))
                        .staggerFade(delay: 0.10)

                    Text("Your academics,\n\(name).")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)
                        .staggerFade(delay: 0.20)

                    VStack(spacing: 36) {
                        VStack(spacing: 10) {
                            Text("Current GPA")
                                .font(.system(.subheadline, design: .rounded).weight(.medium))
                                .foregroundStyle(.white.opacity(0.6))

                            TextField("", text: $gpaText, prompt: Text("3.20").foregroundStyle(.white.opacity(0.3)))
                                .font(.system(size: 52, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(.white)
                                .keyboardType(.decimalPad)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.5)
                                .focused($gpaFocused)
                                .onChange(of: gpaText) { _, newVal in
                                    gpaText = clampGPAInput(newVal)
                                }

                            HStack(spacing: 0) {
                                ForEach([0.0, 1.0, 2.0, 3.0, 4.0], id: \.self) { mark in
                                    VStack(spacing: 4) {
                                        Rectangle()
                                            .fill(gpaValue >= mark ? TTBrand.mint : Color.white.opacity(0.2))
                                            .frame(width: 2, height: 8)
                                        if mark == 0 || mark == 2 || mark == 4 {
                                            Text(String(format: "%.0f", mark))
                                                .font(.system(size: 9, design: .rounded))
                                                .foregroundStyle(.white.opacity(0.4))
                                        }
                                    }
                                    if mark < 4 { Spacer() }
                                }
                            }
                            .frame(maxWidth: 220)

                            GeometryReader { geo in
                                let progress = min(1.0, gpaValue / 4.0)
                                ZStack(alignment: .leading) {
                                    Capsule().fill(Color.white.opacity(0.1)).frame(height: 4)
                                    Capsule()
                                        .fill(LinearGradient(colors: [TTBrand.coral, TTBrand.amber, TTBrand.mint], startPoint: .leading, endPoint: .trailing))
                                        .frame(width: max(0, geo.size.width * CGFloat(progress)), height: 4)
                                        .animation(.spring(response: 0.3), value: gpaValue)
                                }
                            }
                            .frame(maxWidth: 220, maxHeight: 4)

                            Text(gpaFeedback)
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.white.opacity(0.5))
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.3), value: gpaText)

                            Text("Used to estimate transfer readiness")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.white.opacity(0.35))
                        }
                        .staggerFade(delay: 0.35)

                        VStack(spacing: 10) {
                            Text("Credits Earned")
                                .font(.system(.subheadline, design: .rounded).weight(.medium))
                                .foregroundStyle(.white.opacity(0.6))

                            TextField("", text: $creditsText, prompt: Text("45").foregroundStyle(.white.opacity(0.3)))
                                .font(.system(size: 52, weight: .bold, design: .rounded))
                                .monospacedDigit()
                                .foregroundStyle(.white)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.center)
                                .minimumScaleFactor(0.5)
                                .onChange(of: creditsText) { _, newVal in
                                    creditsText = clampCreditsInput(newVal)
                                }

                            if creditsValue > 0 {
                                let progress = min(1.0, Double(creditsValue) / 60.0)
                                VStack(spacing: 4) {
                                    GeometryReader { geo in
                                        ZStack(alignment: .leading) {
                                            Capsule().fill(Color.white.opacity(0.1)).frame(height: 4)
                                            Capsule()
                                                .fill(creditsValue >= 60 ? TTBrand.mint : TTBrand.skyBlue)
                                                .frame(width: max(0, geo.size.width * CGFloat(progress)), height: 4)
                                                .animation(.spring(response: 0.3), value: creditsValue)
                                        }
                                    }
                                    .frame(maxWidth: 220, maxHeight: 4)

                                    Text(creditsValue >= 60 ? "AA/AS threshold reached!" : "\(creditsValue)/60 toward Associate's")
                                        .font(.system(.caption, design: .rounded))
                                        .foregroundStyle(creditsValue >= 60 ? TTBrand.mint : .white.opacity(0.5))
                                }
                                .transition(.opacity)
                            }

                            Text("Used to track degree progress")
                                .font(.system(.caption2, design: .rounded))
                                .foregroundStyle(.white.opacity(0.35))
                        }
                        .staggerFade(delay: 0.45)
                    }
                    .padding(.top, 40)
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 100)
                }
            }
            .scrollDismissesKeyboard(.interactively)

            OnboardingButton(title: "Next", icon: "arrow.right", action: onNext)
                .disabled(!isValid)
                .opacity(isValid ? 1.0 : 0.4)
                .staggerFade(delay: 0.55)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { gpaFocused = true }
        }
    }

    private var gpaFeedback: String {
        if gpaText.isEmpty { return "Enter your cumulative GPA (0.0–4.0)" }
        if gpaValue >= 3.5 { return "Excellent! Strong transfer candidate." }
        if gpaValue >= 3.0 { return "Solid GPA for most transfer programs." }
        if gpaValue >= 2.5 { return "Meets minimum for many schools." }
        if gpaValue >= 2.0 { return "Some schools may require higher." }
        return "Consider improving before transfer."
    }
}


@available(iOS 17.0, *)
struct OnboardingFinances: View {
    let name: String
    @Binding var savingsText: String
    @Binding var rentText: String
    @Binding var transferSemester: String
    var onNext: () -> Void
    @FocusState private var savingsFocused: Bool

    private let semesters = ["Fall 2026", "Spring 2027", "Fall 2027", "Spring 2028"]
    private var isValid: Bool { !savingsText.isEmpty && !rentText.isEmpty }

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    Spacer().frame(height: 40)

                    Image(systemName: "dollarsign.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white.opacity(0.8))
                        .staggerFade(delay: 0.10)

                    Text("Almost there, \(name).\nYour financial snapshot.")
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.top, 16)
                        .staggerFade(delay: 0.20)

                    VStack(spacing: 36) {
                        OnboardingMoneyInput(
                            label: "Current Savings",
                            placeholder: "2,500",
                            text: $savingsText,
                            hint: "Used to calculate your financial runway"
                        )
                        .staggerFade(delay: 0.35)

                        VStack(spacing: 10) {
                            Text("Monthly Rent")
                                .font(.system(.subheadline, design: .rounded).weight(.medium))
                                .foregroundStyle(.white.opacity(0.6))

                            HStack(spacing: 4) {
                                Text("$")
                                    .font(.system(size: 44, weight: .bold, design: .rounded))
                                    .foregroundStyle(rentText.isEmpty ? .white.opacity(0.2) : .white.opacity(0.6))
                                TextField("", text: $rentText, prompt: Text("1,200").foregroundStyle(.white.opacity(0.3)))
                                    .font(.system(size: 44, weight: .bold, design: .rounded))
                                    .monospacedDigit()
                                    .foregroundStyle(.white)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.center)
                                    .minimumScaleFactor(0.5)
                                Text("/mo")
                                    .font(.system(size: 20, weight: .medium, design: .rounded))
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                            .frame(maxWidth: .infinity)

                            Rectangle()
                                .fill(rentText.isEmpty ? Color.white.opacity(0.15) : TTBrand.amber.opacity(0.6))
                                .frame(height: 2)
                                .padding(.horizontal, 40)
                                .animation(.spring(response: 0.3), value: rentText.isEmpty)

                            Text("Used to calculate your monthly gap")
                                .font(.system(.caption, design: .rounded))
                                .foregroundStyle(.white.opacity(0.4))
                        }
                        .staggerFade(delay: 0.45)

                        OnboardingPickerRow(label: "When do you plan to transfer?", icon: "calendar") {
                            Picker("Semester", selection: $transferSemester) {
                                ForEach(semesters, id: \.self) { Text($0) }
                            }.pickerStyle(.menu).tint(.white)
                        }
                        .staggerFade(delay: 0.55)
                    }
                    .padding(.top, 36)
                    .padding(.horizontal, 24)

                    Spacer().frame(height: 100)
                }
            }
            .scrollDismissesKeyboard(.interactively)

            OnboardingButton(title: "Generate my forecast", icon: "arrow.right.circle.fill", action: onNext)
                .disabled(!isValid)
                .opacity(isValid ? 1.0 : 0.4)
                .staggerFade(delay: 0.65)
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { savingsFocused = true }
        }
    }
}


@available(iOS 17.0, *)
struct OnboardingLoading: View {
    let uniName: String
    var onComplete: () -> Void

    @State private var completedSteps: Set<Int> = []
    @State private var activeStep = 0
    @State private var showButton = false
    @State private var glowPhase: CGFloat = 0

    private var steps: [(icon: String, text: String)] {
        [
            ("magnifyingglass", "Analyzing \(uniName) degree requirements"),
            ("house.lodge.fill", "Calculating off-campus housing odds"),
            ("dollarsign.arrow.circlepath", "Finding hidden scholarships"),
            ("checkmark.shield.fill", "Building your transfer plan")
        ]
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .fill(TTBrand.skyBlue.opacity(0.06 + glowPhase * 0.08))
                    .frame(width: 130, height: 130)
                    .scaleEffect(1.0 + glowPhase * 0.12)

                Circle()
                    .fill(TTBrand.skyBlue.opacity(0.15))
                    .frame(width: 80, height: 80)

                Image(systemName: steps[min(activeStep, steps.count - 1)].icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundStyle(.white)
                    .contentTransition(.symbolEffect(.replace))
                    .animation(.easeInOut(duration: 0.4), value: activeStep)
            }

            VStack(alignment: .leading, spacing: 16) {
                ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(
                                    completedSteps.contains(index)
                                        ? TTBrand.mint
                                        : (activeStep == index ? TTBrand.skyBlue.opacity(0.2) : Color.white.opacity(0.08))
                                )
                                .frame(width: 28, height: 28)

                            if completedSteps.contains(index) {
                                Image(systemName: "checkmark")
                                    .font(.caption.weight(.bold))
                                    .foregroundStyle(.white)
                                    .transition(.scale.combined(with: .opacity))
                            } else if activeStep == index {
                                ProgressView().scaleEffect(0.6).tint(.white)
                            }
                        }

                        Text(step.text)
                            .font(.system(.subheadline, design: .rounded).weight(activeStep == index ? .semibold : .regular))
                            .foregroundStyle(
                                completedSteps.contains(index) ? .white.opacity(0.5) :
                                (activeStep == index ? .white : .white.opacity(0.3))
                            )
                    }
                    .animation(.spring(response: 0.3), value: completedSteps)
                }
            }
            .padding(.horizontal, 40)

            Spacer()

            if showButton {
                OnboardingButton(title: "View your plan", icon: "arrow.right", action: onComplete)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear { runLoadingSequence() }
    }

    private func runLoadingSequence() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) { glowPhase = 1.0 }

        for i in 0..<steps.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.3) {
                withAnimation(.spring(response: 0.3)) { activeStep = i }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.3 + 0.9) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) { _ = completedSteps.insert(i) }
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.7)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(steps.count) * 1.3 + 0.5) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation(.spring(response: 0.5)) { showButton = true }
        }
    }
}




@available(iOS 17.0, *)
struct OnboardingButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title)
                    .font(.system(.headline, design: .rounded))
                if let icon {
                    Image(systemName: icon)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(
                LinearGradient(
                    colors: [TTBrand.skyBlue, TTBrand.skyBlue.opacity(0.8)],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            .shadow(color: TTBrand.skyBlue.opacity(0.3), radius: 12, y: 4)
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
    }
}

@available(iOS 17.0, *)
struct OnboardingPickerRow<Content: View>: View {
    let label: String
    let icon: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon).foregroundStyle(.white.opacity(0.5)).font(.caption)
                Text(label)
                    .font(.system(.subheadline, design: .rounded).weight(.medium))
                    .foregroundStyle(.white.opacity(0.6))
            }
            HStack {
                content
                Spacer()
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .stroke(Color.white.opacity(0.1), lineWidth: 0.5)
            )
        }
    }
}

@available(iOS 17.0, *)
struct OnboardingMoneyInput: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    var hint: String = ""

    var body: some View {
        VStack(spacing: 10) {
            Text(label)
                .font(.system(.subheadline, design: .rounded).weight(.medium))
                .foregroundStyle(.white.opacity(0.6))

            HStack(spacing: 4) {
                Text("$")
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .foregroundStyle(text.isEmpty ? .white.opacity(0.2) : .white.opacity(0.6))
                TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(.white.opacity(0.3)))
                    .font(.system(size: 44, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.white)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity)

            Rectangle()
                .fill(text.isEmpty ? Color.white.opacity(0.15) : TTBrand.amber.opacity(0.6))
                .frame(height: 2)
                .padding(.horizontal, 40)
                .animation(.spring(response: 0.3), value: text.isEmpty)

            if !hint.isEmpty {
                Text(hint)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.white.opacity(0.4))
            }
        }
    }
}


@available(iOS 17.0, *)
struct PathPickerRow<Content: View>: View {
    let label: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon).foregroundStyle(color).font(.caption)
                Text(label).font(.subheadline.weight(.medium)).foregroundStyle(.secondary)
            }
            HStack {
                content
                Spacer()
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}

@available(iOS 17.0, *)
struct PathPickerWithLogo<Content: View>: View {
    let label: String
    let icon: String
    let color: Color
    let schoolName: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon).foregroundStyle(color).font(.caption)
                Text(label).font(.subheadline.weight(.medium)).foregroundStyle(.secondary)
            }
            HStack(spacing: 12) {
                CollegeLogo(schoolName: schoolName, size: 40)
                    .id(schoolName)
                    .transition(.scale.combined(with: .opacity))
                content
                Spacer()
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(uiColor: .secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .animation(.spring(response: 0.4, dampingFraction: 0.7), value: schoolName)
        }
    }
}

@available(iOS 17.0, *)
struct BigNumberInput: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let color: Color
    var keyboardType: UIKeyboardType = .default
    var prefix: String? = nil

    var body: some View {
        VStack(spacing: 8) {
            Text(label).font(.subheadline.weight(.medium)).foregroundStyle(color)
            HStack(spacing: 4) {
                if let p = prefix {
                    Text(p)
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(text.isEmpty ? color.opacity(0.3) : color)
                }
                TextField(placeholder, text: $text)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .monospacedDigit()
                    .foregroundStyle(.primary)
                    .keyboardType(keyboardType)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity)
            Rectangle().fill(color.opacity(0.3)).frame(height: 2).padding(.horizontal, 40)
        }
    }
}

func loadAppIcon() -> UIImage? {
    let names = ["AppIcon", "AppIcon60x60@3x", "AppIcon76x76@2x", "AppIcon-1024"]
    for name in names {
        if let img = UIImage(named: name) { return img }
    }
    if let icons = Bundle.main.infoDictionary?["CFBundleIcons"] as? [String: Any],
       let primary = icons["CFBundlePrimaryIcon"] as? [String: Any],
       let iconFiles = primary["CFBundleIconFiles"] as? [String],
       let lastName = iconFiles.last,
       let img = UIImage(named: lastName) { return img }
    if let iconName = Bundle.main.infoDictionary?["CFBundleIconName"] as? String,
       let img = UIImage(named: iconName) { return img }
    if let resourcePath = Bundle.main.resourcePath {
        let fm = FileManager.default
        if let enumerator = fm.enumerator(atPath: resourcePath) {
            while let file = enumerator.nextObject() as? String {
                let lower = file.lowercased()
                if lower.contains("appicon") && (lower.hasSuffix(".png") || lower.hasSuffix(".jpg")) {
                    let fullPath = (resourcePath as NSString).appendingPathComponent(file)
                    if let img = UIImage(contentsOfFile: fullPath) { return img }
                }
            }
        }
    }
    return nil
}
