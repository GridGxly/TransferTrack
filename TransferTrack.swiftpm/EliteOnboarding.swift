import SwiftUI



@available(iOS 17.0, *)
struct OnboardingFlow: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentPage = 0
    @State private var isTransitioning = false

    private let totalPages = 4

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 0) {
                // progress bar (pages 1-3 only)
                if currentPage > 0 && currentPage < totalPages - 1 {
                    OnboardingProgressBar(current: currentPage, total: totalPages - 1)
                        .padding(.horizontal, 24)
                        .padding(.top, 8)
                }

                TabView(selection: $currentPage) {
                    HeroPage(onNext: advancePage)
                        .tag(0)

                    TransferShockPage(onNext: advancePage)
                        .tag(1)

                    InteractiveDemoPage(onNext: advancePage)
                        .tag(2)

                    PersonalizationPage(isOnboardingComplete: $isOnboardingComplete)
                        .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.45), value: currentPage)
                .disabled(isTransitioning)
            }
        }
    }

    private func advancePage() {
        guard !isTransitioning, currentPage < totalPages - 1 else { return }
        isTransitioning = true
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()
        withAnimation(.easeInOut(duration: 0.45)) { currentPage += 1 }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { isTransitioning = false }
    }
}

// mark -- progress bar
struct OnboardingProgressBar: View {
    let current: Int
    let total: Int

    var body: some View {
        GeometryReader { geo in
            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.white.opacity(0.15))
                    .frame(height: 4)
                RoundedRectangle(cornerRadius: 3)
                    .fill(Color.blue)
                    .frame(width: geo.size.width * CGFloat(current) / CGFloat(total), height: 4)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8), value: current)
            }
        }
        .frame(height: 4)
    }
}

// mark -- hero
@available(iOS 17.0, *)
struct HeroPage: View {
    var onNext: () -> Void
    @State private var logoScale: CGFloat = 0.5
    @State private var logoOpacity: CGFloat = 0
    @State private var textOpacity: CGFloat = 0
    @State private var glowOpacity: CGFloat = 0.3

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            // app Icon with glow
            ZStack {
                RoundedRectangle(cornerRadius: 28, style: .continuous)
                    .fill(Color(red: 0.85, green: 0.95, blue: 0.0))
                    .frame(width: 140, height: 140)
                    .blur(radius: 30)
                    .opacity(glowOpacity)

                if let icon = UIImage(named: "AppIcon") {
                    Image(uiImage: icon)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .clipShape(RoundedRectangle(cornerRadius: 26, style: .continuous))
                } else {
                    // fallback matching the neon green TT app icon
                    RoundedRectangle(cornerRadius: 26, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.85, green: 0.95, blue: 0.0), Color(red: 0.65, green: 0.85, blue: 0.0)],
                                startPoint: .topLeading, endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 120, height: 120)
                        .overlay(
                            Text("TT")
                                .font(.system(size: 48, weight: .black, design: .rounded))
                                .foregroundStyle(.black)
                        )
                }
            }
            .scaleEffect(logoScale)
            .opacity(logoOpacity)

            Text("TransferTrack")
                .font(.largeTitle.weight(.black))
                .foregroundStyle(.white)
                .padding(.top, 24)
                .opacity(textOpacity)

            Text("Don't get blindsided by the transfer cliff.")
                .font(.title3.weight(.medium))
                .foregroundStyle(.gray)
                .multilineTextAlignment(.center)
                .padding(.top, 8)
                .padding(.horizontal, 32)
                .opacity(textOpacity)

            Text("I built this because I realized 2+2 ≠ cheap.\nI didn't want to lose $15k. Neither should you.")
                .font(.callout)
                .foregroundStyle(.gray.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.top, 12)
                .padding(.horizontal, 40)
                .opacity(textOpacity)

            Spacer()

            Button(action: onNext) {
                HStack(spacing: 8) {
                    Text("Start Your Journey")
                        .font(.headline)
                    Image(systemName: "arrow.right")
                }
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color(red: 0.85, green: 0.95, blue: 0.0))
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 50)
            .opacity(textOpacity)
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.65).delay(0.2)) {
                logoScale = 1.0; logoOpacity = 1.0
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.5)) { textOpacity = 1.0 }
            withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) { glowOpacity = 0.7 }
        }
    }
}

// mark -- transfer shock
@available(iOS 17.0, *)
struct TransferShockPage: View {
    var onNext: () -> Void
    @State private var line1 = false
    @State private var line2 = false
    @State private var line3 = false
    @State private var showCTA = false

    private let horrors: [(text: String, color: Color)] = [
        ("Tuition triples overnight.", .red),
        ("Rent doubles. Savings vanish.", .orange),
        ("Credits rejected — thousands wasted.", .yellow),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.red)
                .symbolEffect(.pulse, options: .repeating)

            Text("Transfer Shock")
                .font(.largeTitle.weight(.black))
                .foregroundStyle(.white)
                .padding(.top, 16)

            // visceral one liners that slam in
            VStack(alignment: .leading, spacing: 20) {
                ShockLine(text: horrors[0].text, color: horrors[0].color, show: line1)
                ShockLine(text: horrors[1].text, color: horrors[1].color, show: line2)
                ShockLine(text: horrors[2].text, color: horrors[2].color, show: line3)
            }
            .padding(.horizontal, 32)
            .padding(.top, 32)

            Text("This happens to 2.4 million students every year.\nIt almost happened to me.")
                .font(.callout.weight(.medium))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
                .padding(.top, 24)
                .padding(.horizontal, 32)
                .opacity(showCTA ? 1 : 0)

            Spacer()

            Button(action: onNext) {
                HStack(spacing: 8) {
                    Text("See the Solution")
                    Image(systemName: "arrow.right")
                }
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 56)
                .background(Color.red)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
            .padding(.horizontal, 24)
            .padding(.bottom, 50)
            .opacity(showCTA ? 1 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.3)) { line1 = true }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.7)) { line2 = true }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(1.1)) { line3 = true }
            withAnimation(.easeOut(duration: 0.5).delay(1.6)) { showCTA = true }

            // haptics for each slam
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) { UIImpactFeedbackGenerator(style: .heavy).impactOccurred() }
        }
    }
}

struct ShockLine: View {
    let text: String
    let color: Color
    let show: Bool

    var body: some View {
        HStack(spacing: 12) {
            Circle()
                .fill(color)
                .frame(width: 8, height: 8)
            Text(text)
                .font(.title3.weight(.bold))
                .foregroundStyle(.white)
        }
        .opacity(show ? 1 : 0)
        .offset(x: show ? 0 : -30)
    }
}

// mark -- interactive demo
@available(iOS 17.0, *)
struct InteractiveDemoPage: View {
    var onNext: () -> Void
    @State private var livingCost: Double = 800
    @State private var isAnimating = false

    // simulated bar chart data
    private var barData: [(label: String, value: Double, isShock: Bool)] {
        [
            ("CC Tuition", 3000, false),
            ("CC Rent", 600, false),
            ("CC Total", 3600, false),
            ("Uni Tuition", 12000, true),
            ("Uni Rent", livingCost * 12, true),
            ("Uni Total", 12000 + livingCost * 12, true),
        ]
    }

    private var monthlyCost: Int { Int(livingCost + 1000) } // rent + tuition/mo estimate
    private var yearlyShock: Int { Int((livingCost * 12 + 12000) - 3600) }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 24) {
                Spacer().frame(height: 40)

                Text("Feel the Shock")
                    .font(.largeTitle.weight(.black))
                    .foregroundStyle(.white)

                Text("Drag the slider. Watch your costs explode.")
                    .font(.callout)
                    .foregroundStyle(.gray)

                // interactive cost chart
                VStack(spacing: 16) {
                    // mini bar visualization
                    HStack(alignment: .bottom, spacing: 6) {
                        // CC costs
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.green.opacity(0.6))
                                .frame(width: 36, height: 40)
                            Text("CC")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        // arrow
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundStyle(.gray)
                            .padding(.bottom, 16)

                        // uni tuition (fixed spike)
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.red.opacity(0.7))
                                .frame(width: 36, height: isAnimating ? 80 : 40)
                            Text("Tuition")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        // Uni rent
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.orange)
                                .frame(width: 36, height: max(20, CGFloat(livingCost) / 15))
                            Text("Rent")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }

                        // total shock bar
                        VStack(spacing: 4) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.red)
                                .frame(width: 36, height: max(30, CGFloat(livingCost) / 12 + 80))
                            Text("Total")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .frame(height: 140)
                    .padding(.top, 8)

                    // the shock number
                    VStack(spacing: 4) {
                        Text("+$\(yearlyShock.formatted())")
                            .font(.system(.title, design: .rounded).weight(.black))
                            .foregroundStyle(.red)
                            .contentTransition(.numericText())
                            .animation(.spring(response: 0.3), value: yearlyShock)
                        Text("yearly cost increase")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Divider().padding(.horizontal)

                    // interactive slider
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Text("Your Monthly Rent")
                                .font(.subheadline.weight(.medium))
                                .foregroundStyle(.white)
                            Spacer()
                            Text("$\(Int(livingCost))/mo")
                                .font(.subheadline.weight(.bold))
                                .foregroundStyle(.orange)
                        }

                        Slider(value: $livingCost, in: 400...2500, step: 50)
                            .tint(.orange)

                        HStack {
                            Text("$400")
                                .font(.caption2)
                                .foregroundStyle(.gray)
                            Spacer()
                            Text("$2,500")
                                .font(.caption2)
                                .foregroundStyle(.gray)
                        }
                    }
                    .padding(.horizontal, 4)
                }
                .padding(20)
                .background(.ultraThinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(.white.opacity(0.1), lineWidth: 1)
                )
                .padding(.horizontal, 24)

                Text("This is why TransferTrack exists.\nLet's make sure this doesn't happen to you.")
                    .font(.callout.weight(.medium))
                    .foregroundStyle(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)

                Spacer().frame(height: 20)

                Button(action: onNext) {
                    HStack(spacing: 8) {
                        Text("Build My Plan")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color.blue)
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 50)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(0.3)) {
                isAnimating = true
            }
        }
    }
}

// mark -- personalization
@available(iOS 17.0, *)
struct PersonalizationPage: View {
    @Binding var isOnboardingComplete: Bool

    @AppStorage("userName") private var userName: String = ""
    @State private var selectedState = "Florida"
    @State private var selectedCC = "Valencia College"
    @State private var selectedUni = "UCF"
    @State private var gpa: Double = 3.2
    @State private var credits: Double = 45
    @State private var savings: Double = 2500
    @State private var rent: Double = 1200

    @FocusState private var nameFieldFocused: Bool

    private var communityColleges: [String] { SchoolDatabase.stateData[selectedState]?.ccs ?? [] }
    private var universities: [String] { SchoolDatabase.stateData[selectedState]?.unis ?? [] }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Spacer().frame(height: 20)

                Image(systemName: "person.crop.circle.badge.plus")
                    .font(.system(size: 44))
                    .foregroundStyle(.blue)
                    .padding(.bottom, 4)

                Text("Your Turn")
                    .font(.largeTitle.weight(.black))
                    .foregroundStyle(.white)

                Text("Build your personalized transfer plan")
                    .font(.callout)
                    .foregroundStyle(.gray)

                // name
                OnboardingSection(icon: "person.fill", title: "Your Name", color: .cyan) {
                    TextField("What should we call you?", text: $userName)
                        .font(.body)
                        .foregroundStyle(.white)
                        .padding(14)
                        .background(Color.white.opacity(0.08))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                        .focused($nameFieldFocused)
                        .submitLabel(.done)
                        .autocorrectionDisabled()
                }

                // state
                OnboardingSection(icon: "map.fill", title: "Your State", color: .blue) {
                    Picker("State", selection: $selectedState) {
                        ForEach(SchoolDatabase.states, id: \.self) { Text($0).tag($0) }
                    }
                    .pickerStyle(.menu)
                    .tint(.blue)
                    .padding(10)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                }

                // transfer path
                OnboardingSection(icon: "arrow.triangle.swap", title: "Transfer Path", color: .purple) {
                    HStack(spacing: 0) {
                        VStack(spacing: 6) {
                            Text("From").font(.caption).foregroundStyle(.gray)
                            Picker("CC", selection: $selectedCC) {
                                ForEach(communityColleges, id: \.self) { Text($0).tag($0) }
                            }
                            .pickerStyle(.menu).tint(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.blue.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))

                        Image(systemName: "arrow.right")
                            .foregroundStyle(.gray)
                            .padding(.horizontal, 8)

                        VStack(spacing: 6) {
                            Text("To").font(.caption).foregroundStyle(.gray)
                            Picker("Uni", selection: $selectedUni) {
                                ForEach(universities, id: \.self) { Text($0).tag($0) }
                            }
                            .pickerStyle(.menu).tint(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(Color.purple.opacity(0.12))
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    }
                }

                // academics
                OnboardingSection(icon: "book.closed.fill", title: "Academics", color: .green) {
                    SliderRow(label: "GPA", value: $gpa, range: 0...4.0, step: 0.01, format: "%.2f", color: .green, width: 55)
                    SliderRow(label: "Credits", value: $credits, range: 0...120, step: 1, format: "%.0f", color: .green, width: 55)
                }

                // finances
                OnboardingSection(icon: "dollarsign.circle.fill", title: "Financial Snapshot", color: .orange) {
                    SliderRow(label: "Savings", value: $savings, range: 0...50000, step: 100, format: "$%.0f", color: .orange, width: 80, isDollar: true)
                    SliderRow(label: "Rent", value: $rent, range: 0...3000, step: 50, format: "$%.0f", color: .orange, width: 80, isDollar: true)
                }

                // generate button
                Button(action: generateForecast) {
                    HStack(spacing: 8) {
                        Text("Generate My Forecast")
                            .font(.headline)
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .foregroundStyle(.black)
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .background(Color(red: 0.85, green: 0.95, blue: 0.0))
                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 60)
            }
        }
        .scrollDismissesKeyboard(.interactively)
        .onChange(of: selectedState) { _, _ in
            selectedCC = communityColleges.first ?? ""
            selectedUni = universities.first ?? ""
        }
    }

    private func generateForecast() {
        UserDefaults.standard.set(selectedState, forKey: "selectedState")
        UserDefaults.standard.set(selectedCC, forKey: "selectedCC")
        UserDefaults.standard.set(selectedUni, forKey: "selectedUni")
        UserDefaults.standard.set(gpa, forKey: "userGPA")
        UserDefaults.standard.set(credits, forKey: "userCredits")
        UserDefaults.standard.set(savings, forKey: "userSavings")
        UserDefaults.standard.set(rent, forKey: "userRent")
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")

        let success = UINotificationFeedbackGenerator()
        success.notificationOccurred(.success)

        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            isOnboardingComplete = true
        }
    }
}

// mark -- onboarding 
struct OnboardingSection<Content: View>: View {
    let icon: String
    let title: String
    let color: Color
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: icon).foregroundStyle(color)
                Text(title).font(.headline).foregroundStyle(color)
            }
            content
        }
        .padding(20)
        .background(Color.white.opacity(0.06))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white.opacity(0.06), lineWidth: 1)
        )
        .padding(.horizontal, 24)
    }
}

// mark -- slider row
struct SliderRow: View {
    let label: String
    @Binding var value: Double
    let range: ClosedRange<Double>
    let step: Double
    let format: String
    let color: Color
    var width: CGFloat = 60
    var isDollar: Bool = false

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label).font(.caption).foregroundStyle(.gray)
            HStack {
                Text(String(format: format, value))
                    .font(.title3.weight(.bold))
                    .foregroundStyle(color)
                    .frame(width: width, alignment: .leading)
                Slider(value: $value, in: range, step: step)
                    .tint(color)
            }
        }
    }
}

