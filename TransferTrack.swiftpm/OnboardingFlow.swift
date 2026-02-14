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

    var body: some View {
        ZStack {
            Color(uiColor: .systemBackground).ignoresSafeArea()

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
                    OnboardingPath(name: userName, selectedState: $selectedState, selectedCC: $selectedCC, selectedUni: $selectedUni, onNext: advance).tag(2)
                    OnboardingAcademics(name: userName, gpaText: $gpaText, creditsText: $creditsText, onNext: advance).tag(3)
                    OnboardingFinances(name: userName, savingsText: $savingsText, rentText: $rentText, transferSemester: $transferSemester, onNext: { saveAllData(); advance() }).tag(4)
                    OnboardingLoading(uniName: selectedUni, onComplete: {
                        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
                        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) { isOnboardingComplete = true }
                    }).tag(5)
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
                    let _ = UIApplication.shared.sendAction(
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

        let _ = UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil, from: nil, for: nil
        )

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





struct FramerFadeModifier: ViewModifier {
    @State private var isVisible = false
    var delay: Double
    var yOffset: CGFloat

    func body(content: Content) -> some View {
        content
            .opacity(isVisible ? 1 : 0)
            .offset(y: isVisible ? 0 : yOffset)
            .onAppear {
                withAnimation(.easeOut(duration: 0.55).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

extension View {
    func framerFade(delay: Double = 0, yOffset: CGFloat = 18) -> some View {
        self.modifier(FramerFadeModifier(delay: delay, yOffset: yOffset))
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
       let img = UIImage(named: lastName) {
        return img
    }

    if let iconName = Bundle.main.infoDictionary?["CFBundleIconName"] as? String,
       let img = UIImage(named: iconName) {
        return img
    }

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



@available(iOS 17.0, *)
struct OnboardingHero: View {
    var onNext: () -> Void

    var body: some View {
        ZStack {
            RadialGradient(colors: [Color.blue.opacity(0.15), Color.clear], center: .center, startRadius: 20, endRadius: 300)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Group {
                    if let appIcon = loadAppIcon() {
                        Image(uiImage: appIcon)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 100, height: 100)
                            .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
                            .shadow(color: .blue.opacity(0.3), radius: 16, y: 6)
                    } else {
                        ZStack {
                            RoundedRectangle(cornerRadius: 22, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.08, green: 0.10, blue: 0.14), Color(red: 0.05, green: 0.06, blue: 0.09)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                            Text("TT")
                                .font(.system(size: 44, weight: .black, design: .rounded))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(red: 0.7, green: 1.0, blue: 0.0), Color(red: 0.4, green: 0.9, blue: 0.1)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                        .frame(width: 100, height: 100)
                        .shadow(color: Color(red: 0.5, green: 0.9, blue: 0.1).opacity(0.3), radius: 16, y: 6)
                    }
                }
                .framerFade(delay: 0.15, yOffset: 24)

                Text("TransferTrack")
                    .font(.largeTitle.weight(.black))
                    .foregroundStyle(.primary)
                    .padding(.top, 24)
                    .framerFade(delay: 0.30)

                Text("Navigate the 2+2 transfer path\nwithout losing credits or cash.")
                    .font(.title3.weight(.medium))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
                    .padding(.horizontal, 32)
                    .framerFade(delay: 0.45)

                Spacer()
                Spacer()

                OnboardingButton(title: "Start Your Journey", icon: "arrow.right", action: onNext)
                    .framerFade(delay: 0.60, yOffset: 24)
            }
        }
    }
}



@available(iOS 17.0, *)
struct OnboardingName: View {
    @Binding var name: String
    var onNext: () -> Void
    @FocusState private var nameFocused: Bool

    var body: some View {
        ZStack {
            RadialGradient(colors: [Color.cyan.opacity(0.12), Color.clear], center: .top, startRadius: 20, endRadius: 350)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Image(systemName: "person.crop.circle")
                    .font(.system(size: 56)).foregroundStyle(.cyan)
                    .framerFade(delay: 0.10)

                Text("What should we\ncall you?")
                    .font(.largeTitle.weight(.bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
                    .framerFade(delay: 0.20)

                TextField("Your name", text: $name)
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 20)
                    .submitLabel(.continue)
                    .onSubmit { if !name.isEmpty { onNext() } }
                    .autocorrectionDisabled()
                    .focused($nameFocused)
                    .framerFade(delay: 0.35)

                Spacer()
                Spacer()

                OnboardingButton(title: "Continue", action: onNext)
                    .disabled(name.isEmpty)
                    .opacity(name.isEmpty ? 0.5 : 1.0)
                    .framerFade(delay: 0.50)
            }
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

    var body: some View {
        ZStack {
            RadialGradient(colors: [Color.blue.opacity(0.12), Color.clear], center: .center, startRadius: 20, endRadius: 350)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 40)

                        Image(systemName: "map.fill")
                            .font(.system(size: 48)).foregroundStyle(.blue)
                            .framerFade(delay: 0.10)

                        Text("Hey \(name), where\nare you transferring?")
                            .font(.title.weight(.bold))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 16)
                            .framerFade(delay: 0.20)

                        VStack(spacing: 20) {
                            PathPickerRow(label: "Your State", icon: "mappin.and.ellipse", color: .purple) {
                                Picker("State", selection: $selectedState) {
                                    ForEach(SchoolDatabase.states, id: \.self) { Text($0) }
                                }.pickerStyle(.menu).tint(.primary)
                            }
                            .framerFade(delay: 0.30)

                            PathPickerWithLogo(label: "Transferring From", icon: "building.columns.fill", color: .blue, schoolName: selectedCC) {
                                Picker("CC", selection: $selectedCC) {
                                    ForEach(ccs, id: \.self) { Text($0) }
                                }.pickerStyle(.menu).tint(.primary)
                            }
                            .framerFade(delay: 0.40)

                            PathPickerWithLogo(label: "Dream School", icon: "graduationcap.fill", color: TTColors.brandGreen, schoolName: selectedUni) {
                                Picker("Uni", selection: $selectedUni) {
                                    ForEach(unis, id: \.self) { Text($0) }
                                }.pickerStyle(.menu).tint(.primary)
                            }
                            .framerFade(delay: 0.50)
                        }
                        .padding(.top, 32).padding(.horizontal, 24)

                        Spacer().frame(height: 100)
                    }
                }
                .scrollDismissesKeyboard(.interactively)

                OnboardingButton(title: "Next", icon: "arrow.right", action: onNext)
                    .framerFade(delay: 0.60)
            }
        }
        .onChange(of: selectedState) { _, _ in selectedCC = ccs.first ?? ""; selectedUni = unis.first ?? "" }
    }
}


@available(iOS 17.0, *)
struct OnboardingAcademics: View {
    let name: String
    @Binding var gpaText: String
    @Binding var creditsText: String
    var onNext: () -> Void
    @FocusState private var gpaFocused: Bool

    private var isValid: Bool { !gpaText.isEmpty && !creditsText.isEmpty }

    var body: some View {
        ZStack {
            RadialGradient(colors: [TTColors.brandGreen.opacity(0.12), Color.clear], center: .center, startRadius: 40, endRadius: 400)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                Spacer()

                Image(systemName: "book.circle.fill")
                    .font(.system(size: 48)).foregroundStyle(TTColors.brandGreen)
                    .framerFade(delay: 0.10)

                Text("Let's check your\nacademics, \(name).")
                    .font(.title.weight(.bold))
                    .foregroundStyle(.primary)
                    .multilineTextAlignment(.center)
                    .padding(.top, 16)
                    .framerFade(delay: 0.20)

                VStack(spacing: 40) {
                    BigNumberInput(label: "Current GPA", placeholder: "3.20", text: $gpaText, color: TTColors.brandGreen, keyboardType: .decimalPad)
                        .framerFade(delay: 0.35)
                    BigNumberInput(label: "Credits Earned", placeholder: "45", text: $creditsText, color: TTColors.brandGreen, keyboardType: .numberPad)
                        .framerFade(delay: 0.45)
                }
                .padding(.top, 40).padding(.horizontal, 24)

                Spacer()
                Spacer()

                OnboardingButton(title: "Next", icon: "arrow.right", action: onNext)
                    .disabled(!isValid)
                    .opacity(isValid ? 1.0 : 0.5)
                    .framerFade(delay: 0.55)
            }
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) { gpaFocused = true }
        }
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
        ZStack {
            RadialGradient(colors: [TTColors.brandOrange.opacity(0.12), Color.clear], center: .center, startRadius: 40, endRadius: 400)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        Spacer().frame(height: 40)

                        Image(systemName: "dollarsign.circle.fill")
                            .font(.system(size: 48)).foregroundStyle(TTColors.brandOrange)
                            .framerFade(delay: 0.10)

                        Text("Almost there, \(name).\nYour financial snapshot.")
                            .font(.title.weight(.bold))
                            .foregroundStyle(.primary)
                            .multilineTextAlignment(.center)
                            .padding(.top, 16)
                            .framerFade(delay: 0.20)

                        VStack(spacing: 40) {
                            BigNumberInput(label: "Current Savings", placeholder: "2500", text: $savingsText, color: TTColors.brandOrange, keyboardType: .numberPad, prefix: "$")
                                .framerFade(delay: 0.35)
                            BigNumberInput(label: "Monthly Rent", placeholder: "1200", text: $rentText, color: TTColors.brandOrange, keyboardType: .numberPad, prefix: "$")
                                .framerFade(delay: 0.45)

                            PathPickerRow(label: "When do you plan to transfer?", icon: "calendar", color: .cyan) {
                                Picker("Semester", selection: $transferSemester) {
                                    ForEach(semesters, id: \.self) { Text($0) }
                                }.pickerStyle(.menu).tint(.primary)
                            }
                            .framerFade(delay: 0.55)
                        }
                        .padding(.top, 40).padding(.horizontal, 24)

                        Spacer().frame(height: 100)
                    }
                }
                .scrollDismissesKeyboard(.interactively)


                OnboardingButton(title: "Generate My Forecast", icon: "arrow.right.circle.fill", action: onNext)
                    .disabled(!isValid)
                    .opacity(isValid ? 1.0 : 0.5)
                    .framerFade(delay: 0.65)
            }
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
            ("checkmark.shield.fill", "Building your Transfer Plan")
        ]
    }

    var body: some View {
        ZStack {
            RadialGradient(colors: [Color.blue.opacity(0.08 + glowPhase * 0.12), Color.clear], center: .center, startRadius: 20, endRadius: 300)
                .ignoresSafeArea()
                .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: glowPhase)

            VStack(spacing: 32) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(Color.blue.opacity(0.08 + glowPhase * 0.06))
                        .frame(width: 120, height: 120)
                        .scaleEffect(1.0 + glowPhase * 0.1)

                    Circle()
                        .fill(Color.blue.opacity(0.15))
                        .frame(width: 80, height: 80)

                    Image(systemName: steps[min(activeStep, steps.count - 1)].icon)
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(.blue)
                        .contentTransition(.symbolEffect(.replace))
                        .animation(.easeInOut(duration: 0.4), value: activeStep)
                }

                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(steps.enumerated()), id: \.offset) { index, step in
                        HStack(spacing: 14) {
                            ZStack {
                                Circle()
                                    .fill(completedSteps.contains(index) ? Color.green : (activeStep == index ? Color.blue.opacity(0.15) : Color(uiColor: .tertiarySystemFill)))
                                    .frame(width: 28, height: 28)

                                if completedSteps.contains(index) {
                                    Image(systemName: "checkmark")
                                        .font(.caption.weight(.bold))
                                        .foregroundStyle(.white)
                                        .transition(.scale.combined(with: .opacity))
                                        .symbolEffect(.bounce, value: completedSteps.count)
                                } else if activeStep == index {
                                    ProgressView()
                                        .scaleEffect(0.6)
                                        .tint(.blue)
                                }
                            }

                            Text(step.text)
                                .font(.subheadline.weight(activeStep == index ? .semibold : .regular))
                                .foregroundStyle(completedSteps.contains(index) ? .secondary : (activeStep == index ? .primary : .tertiary))
                        }
                        .animation(.spring(response: 0.3), value: completedSteps)
                    }
                }
                .padding(.horizontal, 40)

                Spacer()

                if showButton {
                    OnboardingButton(title: "View Your Plan", icon: "arrow.right", action: onComplete)
                        .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
        }
        .onAppear { runLoadingSequence() }
    }

    private func runLoadingSequence() {
        glowPhase = 1.0

        for i in 0..<steps.count {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.3) {
                withAnimation(.spring(response: 0.3)) { activeStep = i }
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(i) * 1.3 + 0.9) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    _ = completedSteps.insert(i)
                }
                UIImpactFeedbackGenerator(style: .rigid).impactOccurred(intensity: 0.7)
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + Double(steps.count) * 1.3 + 0.5) {
            UINotificationFeedbackGenerator().notificationOccurred(.success)
            withAnimation(.spring(response: 0.5)) { showButton = true }
        }
    }
}



struct OnboardingButton: View {
    let title: String
    var icon: String? = nil
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 8) {
                Text(title).font(.headline)
                if let icon {
                    Image(systemName: icon)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 56)
            .background(Color.blue)
            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 32)
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
            Text(label)
                .font(.subheadline.weight(.medium))
                .foregroundStyle(color)

            HStack(spacing: 4) {
                if let p = prefix {
                    Text(p)
                        .font(.system(size: 56, weight: .bold, design: .rounded))
                        .foregroundStyle(text.isEmpty ? color.opacity(0.3) : color)
                }
                TextField(placeholder, text: $text)
                    .font(.system(size: 56, weight: .bold, design: .rounded))
                    .foregroundStyle(.primary)
                    .keyboardType(keyboardType)
                    .multilineTextAlignment(.center)
                    .minimumScaleFactor(0.5)
            }
            .frame(maxWidth: .infinity)

            Rectangle()
                .fill(color.opacity(0.3))
                .frame(height: 2)
                .padding(.horizontal, 40)
        }
    }
}

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
