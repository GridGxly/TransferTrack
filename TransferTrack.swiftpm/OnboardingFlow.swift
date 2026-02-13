import SwiftUI

// MARK: - global keyboard dismiss

extension UIApplication {
    func dismissKeyboard() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

// MARK: - onboarding flow


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

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                if currentPage > 0 && currentPage < totalPages - 1 {
                    ProgressView(value: Double(currentPage), total: Double(totalPages - 1))
                        .tint(.blue)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                        .animation(.spring(response: 0.5), value: currentPage)
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
                        onNext: {
                            saveAllData()
                            advance()
                        }
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
                .animation(.easeInOut(duration: 0.45), value: currentPage)
                .disabled(isTransitioning)
            }
        }
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    UIApplication.shared.dismissKeyboard()
                }
            }
        }
    }

    private func advance() {
        guard !isTransitioning, currentPage < totalPages - 1 else { return }
        isTransitioning = true
        UIApplication.shared.dismissKeyboard()
        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        withAnimation(.easeInOut(duration: 0.45)) { currentPage += 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { isTransitioning = false }
    }

    private func saveAllData() {
        let d = UserDefaults.standard
        d.set(userName, forKey: "userName")
        d.set(selectedState, forKey: "selectedState")
        d.set(selectedCC, forKey: "selectedCC")
        d.set(selectedUni, forKey: "selectedUni")
        d.set(Double(gpaText) ?? 3.2, forKey: "userGPA")
        d.set(Double(creditsText) ?? 45, forKey: "userCredits")
        d.set(Double(savingsText) ?? 2500, forKey: "userSavings")
        d.set(Double(rentText) ?? 1200, forKey: "userRent")
        d.set(transferSemester, forKey: "transferSemester")
    }
}

// MARK: -  hero

@available(iOS 17.0, *)
struct OnboardingHero: View {
    var onNext: () -> Void
    @State private var appear = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "graduationcap.circle.fill")
                .font(.system(size: 80))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.blue)
                .symbolEffect(.pulse, options: .repeating)
                .scaleEffect(appear ? 1 : 0.5)
                .opacity(appear ? 1 : 0)

            Text("TransferTrack")
                .font(.largeTitle.weight(.black))
                .foregroundStyle(.white)
                .padding(.top, 24)
                .opacity(appear ? 1 : 0)

            Text("Navigate the 2+2 transfer path\nwithout losing credits or cash.")
                .font(.title3.weight(.medium))
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.horizontal, 32)
                .opacity(appear ? 1 : 0)

            Spacer()

            Button(action: onNext) {
                HStack(spacing: 8) {
                    Text("Start Your Journey").font(.headline)
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 50)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.65).delay(0.2)) { appear = true }
        }
    }
}

// MARK: - name

@available(iOS 17.0, *)
struct OnboardingName: View {
    @Binding var name: String
    var onNext: () -> Void
    @State private var appear = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "person.crop.circle")
                .font(.system(size: 56))
                .foregroundStyle(.cyan)
                .opacity(appear ? 1 : 0)

            Text("What should we\ncall you?")
                .font(.largeTitle.weight(.bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .opacity(appear ? 1 : 0)

            TextField("Your name", text: $name)
                .font(.title2)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(16)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .padding(.horizontal, 40)
                .padding(.top, 32)
                .submitLabel(.continue)
                .onSubmit { if !name.isEmpty { onNext() } }
                .autocorrectionDisabled()
                .opacity(appear ? 1 : 0)

            Spacer()

            Button(action: onNext) {
                Text("Continue")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(name.isEmpty ? Color.gray : Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .disabled(name.isEmpty)
            .padding(.horizontal, 24)
            .padding(.bottom, 50)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) { appear = true }
        }
    }
}

// MARK: -  transfer path

@available(iOS 17.0, *)
struct OnboardingPath: View {
    let name: String
    @Binding var selectedState: String
    @Binding var selectedCC: String
    @Binding var selectedUni: String
    var onNext: () -> Void

    @State private var appear = false

    private var ccs: [String] { SchoolDatabase.stateData[selectedState]?.ccs ?? [] }
    private var unis: [String] { SchoolDatabase.stateData[selectedState]?.unis ?? [] }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer().frame(height: 60)

                Image(systemName: "map.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.blue)
                    .opacity(appear ? 1 : 0)

                Text("Hey \(name), where\nare you transferring?")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
                    .opacity(appear ? 1 : 0)

                VStack(spacing: 16) {
                    OnboardingPickerRow(label: "Your State", icon: "mappin.and.ellipse", color: .purple) {
                        Picker("State", selection: $selectedState) {
                            ForEach(SchoolDatabase.states, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                        .tint(.white)
                    }

                    OnboardingPickerRow(label: "Transferring From", icon: "building.columns.fill", color: .blue) {
                        Picker("CC", selection: $selectedCC) {
                            ForEach(ccs, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                        .tint(.white)
                    }

                    OnboardingPickerRow(label: "Dream School", icon: "graduationcap.fill", color: .green) {
                        Picker("Uni", selection: $selectedUni) {
                            ForEach(unis, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                        .tint(.white)
                    }
                }
                .padding(.top, 32)
                .padding(.horizontal, 24)
                .opacity(appear ? 1 : 0)

                Spacer().frame(height: 60)

                Button(action: onNext) {
                    HStack(spacing: 8) {
                        Text("Next").font(.headline)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: selectedState) { _, _ in
            selectedCC = ccs.first ?? ""
            selectedUni = unis.first ?? ""
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) { appear = true }
        }
    }
}

// MARK: - academics

@available(iOS 17.0, *)
struct OnboardingAcademics: View {
    let name: String
    @Binding var gpaText: String
    @Binding var creditsText: String
    var onNext: () -> Void

    @State private var appear = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "book.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(.green)
                .opacity(appear ? 1 : 0)

            Text("Let's check your\nacademics, \(name).")
                .font(.title.weight(.bold))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.top, 16)
                .opacity(appear ? 1 : 0)

            VStack(spacing: 20) {
                OnboardingInputField(
                    label: "Current GPA",
                    placeholder: "3.20",
                    text: $gpaText,
                    icon: "chart.bar.fill",
                    color: .green,
                    keyboardType: .decimalPad
                )

                OnboardingInputField(
                    label: "Credits Earned",
                    placeholder: "45",
                    text: $creditsText,
                    icon: "book.closed.fill",
                    color: .green,
                    keyboardType: .numberPad
                )
            }
            .padding(.top, 32)
            .padding(.horizontal, 24)
            .opacity(appear ? 1 : 0)

            Spacer()

            Button(action: onNext) {
                HStack(spacing: 8) {
                    Text("Next").font(.headline)
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.blue)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 50)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) { appear = true }
        }
    }
}

// MARK: - finances

@available(iOS 17.0, *)
struct OnboardingFinances: View {
    let name: String
    @Binding var savingsText: String
    @Binding var rentText: String
    @Binding var transferSemester: String
    var onNext: () -> Void

    @State private var appear = false

    private let semesters = ["Fall 2026", "Spring 2027", "Fall 2027", "Spring 2028"]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer().frame(height: 60)

                Image(systemName: "dollarsign.circle.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.orange)
                    .opacity(appear ? 1 : 0)

                Text("Almost there, \(name).\nYour financial snapshot.")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
                    .opacity(appear ? 1 : 0)

                VStack(spacing: 20) {
                    OnboardingInputField(
                        label: "Current Savings",
                        placeholder: "2500",
                        text: $savingsText,
                        icon: "banknote.fill",
                        color: .orange,
                        keyboardType: .numberPad,
                        prefix: "$"
                    )

                    OnboardingInputField(
                        label: "Monthly Rent",
                        placeholder: "1200",
                        text: $rentText,
                        icon: "house.fill",
                        color: .orange,
                        keyboardType: .numberPad,
                        prefix: "$"
                    )

                    OnboardingPickerRow(label: "When do you plan to transfer?", icon: "calendar", color: .cyan) {
                        Picker("Semester", selection: $transferSemester) {
                            ForEach(semesters, id: \.self) { Text($0) }
                        }
                        .pickerStyle(.menu)
                        .tint(.white)
                    }
                }
                .padding(.top, 32)
                .padding(.horizontal, 24)
                .opacity(appear ? 1 : 0)

                Spacer().frame(height: 60)

                Button(action: onNext) {
                    HStack(spacing: 8) {
                        Text("Generate My Forecast").font(.headline)
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) { appear = true }
        }
    }
}

// MARK: -  loading screen

@available(iOS 17.0, *)
struct OnboardingLoading: View {
    let uniName: String
    var onComplete: () -> Void

    @State private var currentStep = 0
    @State private var progress: CGFloat = 0
    @State private var showButton = false
    @State private var iconPulse = 0

    private var steps: [(icon: String, text: String)] {
        [
            ("magnifyingglass", "Analyzing \(uniName) degree requirements..."),
            ("house.lodge.fill", "Calculating off-campus housing odds..."),
            ("dollarsign.arrow.circlepath", "Finding hidden scholarships..."),
            ("checkmark.shield.fill", "Building your Transfer Plan.")
        ]
    }

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: steps[min(currentStep, steps.count - 1)].icon)
                .font(.system(size: 48))
                .symbolRenderingMode(.hierarchical)
                .foregroundStyle(.blue)
                .symbolEffect(.variableColor.iterative, options: .repeating, value: iconPulse)
                .contentTransition(.symbolEffect(.replace))
                .animation(.easeInOut(duration: 0.4), value: currentStep)

            Text(steps[min(currentStep, steps.count - 1)].text)
                .font(.title3.weight(.medium))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)
                .contentTransition(.opacity)
                .animation(.easeInOut(duration: 0.3), value: currentStep)

            ProgressView(value: progress)
                .tint(.blue)
                .padding(.horizontal, 60)
                .animation(.easeInOut(duration: 0.3), value: progress)

            Spacer()

            if showButton {
                Button(action: onComplete) {
                    HStack(spacing: 8) {
                        Text("View Your Plan").font(.headline)
                        Image(systemName: "arrow.right")
                    }
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .onAppear { runLoadingSequence() }
    }

    private func runLoadingSequence() {
        let tick = UISelectionFeedbackGenerator()
        tick.prepare()

        for i in 0..<steps.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.2) {
                currentStep = i
                progress = CGFloat(i + 1) / CGFloat(steps.count)
                iconPulse += 1
                tick.selectionChanged()
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + Double(steps.count) * 1.2 + 0.5) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation(.spring(response: 0.5)) { showButton = true }
        }
    }
}

// MARK: - reusable onboarding components

@available(iOS 17.0, *)
struct OnboardingInputField: View {
    let label: String
    let placeholder: String
    @Binding var text: String
    let icon: String
    let color: Color
    var keyboardType: UIKeyboardType = .default
    var prefix: String? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon).foregroundStyle(color).font(.caption)
                Text(label).font(.subheadline.weight(.medium)).foregroundStyle(.gray)
            }

            HStack {
                if let p = prefix {
                    Text(p).font(.title3).foregroundStyle(.gray)
                }
                TextField(placeholder, text: $text)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .keyboardType(keyboardType)
            }
            .padding(16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}

struct OnboardingPickerRow<Content: View>: View {
    let label: String
    let icon: String
    let color: Color
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 6) {
                Image(systemName: icon).foregroundStyle(color).font(.caption)
                Text(label).font(.subheadline.weight(.medium)).foregroundStyle(.gray)
            }

            HStack {
                content
                Spacer()
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        }
    }
}
