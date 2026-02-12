import SwiftUI

@available(iOS 17.0, *)
struct DashboardView: View {
    @State private var selectedTab = 0
    @AppStorage("userName") private var userName: String = ""
    @AppStorage("selectedCC") private var selectedCC: String = "Valencia College"
    @AppStorage("selectedUni") private var selectedUni: String = "UCF"
    @AppStorage("userGPA") private var userGPA: Double = 3.2
    @AppStorage("userCredits") private var userCredits: Double = 45
    @AppStorage("userSavings") private var userSavings: Double = 2500
    @AppStorage("userRent") private var userRent: Double = 1200

    private let tabs: [(icon: String, label: String)] = [
        ("chart.bar.fill", "Forecast"),
        ("book.closed.fill", "Academics"),
        ("house.fill", "Housing"),
        ("lightbulb.fill", "Solutions"),
    ]


    // MARK: - computed scores

    private var viabilityScore: Int {
        var score = 50
        if userGPA >= 3.5 { score += 20 }
        else if userGPA >= 3.0 { score += 12 }
        else if userGPA >= 2.5 { score += 5 }
        if userCredits >= 60 { score += 15 }
        else if userCredits >= 45 { score += 10 }
        else if userCredits >= 30 { score += 5 }
        if userSavings >= 10000 { score += 15 }
        else if userSavings >= 5000 { score += 8 }
        else { score -= 5 }
        if userRent > 1500 { score -= 10 }
        else if userRent > 1000 { score -= 5 }
        return min(100, max(0, score))
    }

    private var monthlyGap: Int {
        let income = 1800.0
        let tuitionMonthly = Double(SchoolDatabase.uniTuition[selectedUni] ?? 7000) / 12.0
        let expenses = userRent + tuitionMonthly + 400
        return Int(income - expenses)
    }

    private var selectedState: String {
        UserDefaults.standard.string(forKey: "selectedState") ?? "Florida"
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            VStack(spacing: 0) {
                // MARK: fixed header
                VStack(alignment: .leading, spacing: 6) {
                    HStack(spacing: 8) {
                        Text(userName.isEmpty ? "Your Transfer Plan" : "\(userName)'s Transfer Plan")
                            .font(.title2.weight(.bold))
                        Spacer()
                    }

                    HStack(spacing: 8) {
                        CollegeLogo(schoolName: selectedCC, size: 24)
                        Text(selectedCC)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                        Image(systemName: "arrow.right")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        CollegeLogo(schoolName: selectedUni, size: 24)
                        Text(selectedUni)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 16)
                .padding(.bottom, 12)
                .background(.ultraThinMaterial) // optional: gives a subtle glass separation for the header

                // MARK: swipeable tab content
                TabView(selection: $selectedTab) {
                    ScrollView(showsIndicators: false) {
                        ForecastTab(
                            score: viabilityScore,
                            gap: monthlyGap,
                            savings: userSavings,
                            rent: userRent,
                            ccName: selectedCC,
                            uniName: selectedUni
                        )
                        .padding(.top, 10)
                        // add padding at the bottom to ensure content isn't covered by the floating tab bar
                        .padding(.bottom, 100)
                    }
                    .tag(0)

                    ScrollView(showsIndicators: false) {
                        AcademicsTab(
                            gpa: userGPA,
                            credits: Int(userCredits),
                            ccName: selectedCC,
                            uniName: selectedUni
                        )
                        .padding(.top, 10)
                        .padding(.bottom, 100)
                    }
                    .tag(1)

                    ScrollView(showsIndicators: false) {
                        HousingTab(
                            currentRent: userRent,
                            uniName: selectedUni
                        )
                        .padding(.top, 10)
                        .padding(.bottom, 100)
                    }
                    .tag(2)

                    ScrollView(showsIndicators: false) {
                        SolutionsTab(
                            score: viabilityScore,
                            uniName: selectedUni,
                            ccName: selectedCC,
                            state: selectedState
                        )
                        .padding(.top, 10)
                        .padding(.bottom, 100)
                    }
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }

            // MARK: liquid glass tab bar
            if #available(iOS 26.0, *) {
                LiquidTabBar(selectedTab: $selectedTab, tabs: tabs)
            } else {
                // fallback for older iOS versions
                HStack {
                    ForEach(0..<tabs.count, id: \.self) { index in
                        Spacer()
                        VStack(spacing: 4) {
                            Image(systemName: tabs[index].icon)
                                .font(.system(size: 24))
                            Text(tabs[index].label)
                                .font(.caption2)
                        }
                        .foregroundStyle(selectedTab == index ? Color.accentColor : Color.gray)
                        .onTapGesture {
                            selectedTab = index
                        }
                        Spacer()
                    }
                }
                .frame(height: 60)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(.horizontal, 24)
                .padding(.bottom, 10)
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
        .ignoresSafeArea(edges: .bottom)

    }
}

