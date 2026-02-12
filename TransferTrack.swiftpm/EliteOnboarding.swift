import SwiftUI
import SwiftData


@available(iOS 17.0, *)
struct EliteOnboardingFlow: View {
    @Binding var isOnboardingComplete: Bool
    @Environment(\.modelContext) var context
    
    @State private var currentPage = 0
    
    // user selections
    @State private var selectedState: String = "Florida"
    @State private var selectedCC: String = "Valencia College"
    @State private var selectedUni: String = "UCF"
    @State private var currentSavings: Double = 2500
    @State private var expectedRent: Double = 1200
    @State private var gpa: Double = 3.2
    @State private var credits: Int = 45
    
    var body: some View {
        ZStack {
            // dynamic background color based on page
            pageBackgroundColor
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // progress indicator
                if currentPage > 0 && currentPage < 8 {
                    ProgressView(value: Double(currentPage), total: 8)
                        .tint(pageAccentColor)
                        .padding(.horizontal, 40)
                        .padding(.top, 20)
                }
                
                TabView(selection: $currentPage) {
                    // Page 0: Hero with custom logo
                    HeroPageElite(onNext: { withAnimation { currentPage = 1 } })
                        .tag(0)
                    
                    // Page 1: the problem on a national scope
                    ProblemPageElite(onNext: { withAnimation { currentPage = 2 } })
                        .tag(1)
                    
                    // Page 2: Meet 3 Students
                    ThreeStudentsPage(onNext: { withAnimation { currentPage = 3 } })
                        .tag(2)
                    
                    // Page 3: feature - see your future (BLUE)
                    FeaturePage(
                        backgroundColor: Color.blue,
                        icon: "chart.xyaxis.line",
                        title: "See Your Future",
                        subtitle: "Crystal-clear financial forecast",
                        description: "Visualize exactly how your savings, income, and costs will change month-by-month after transfer. No surprises.",
                        onNext: { withAnimation { currentPage = 4 } }
                    )
                    .tag(3)
                    
                    // Page 4: feature - reality slider (ORANGE)
                    FeaturePage(
                        backgroundColor: Color.orange,
                        icon: "slider.horizontal.3",
                        title: "Reality Slider",
                        subtitle: "Instant housing impact",
                        description: "See in real-time how living at home vs. moving out affects your finances. Slide to compare—results update instantly.",
                        onNext: { withAnimation { currentPage = 5 } }
                    )
                    .tag(4)
                    
                    // Page 5: feature - track credits (GREEN)
                    FeaturePage(
                        backgroundColor: Color.green,
                        icon: "graduationcap.fill",
                        title: "Track Credits",
                        subtitle: "Know what transfers",
                        description: "See which of your classes count toward your degree and which are 'wasted.' Plan smarter, save money and time.",
                        onNext: { withAnimation { currentPage = 6 } }
                    )
                    .tag(5)
                    
                    // Page 6: feature - smart solutions (PURPLE)
                    FeaturePage(
                        backgroundColor: Color.purple,
                        icon: "lightbulb.fill",
                        title: "Smart Solutions",
                        subtitle: "Actionable steps to improve",
                        description: "Get personalized recommendations: scholarships you qualify for, roommate tips, appeal strategies—all based on your situation.",
                        onNext: { withAnimation { currentPage = 7 } }
                    )
                    .tag(6)
                    
                    // Page 7: personalization with logos
                    PersonalizationWithLogos(
                        state: $selectedState,
                        cc: $selectedCC,
                        uni: $selectedUni,
                        savings: $currentSavings,
                        rent: $expectedRent,
                        gpa: $gpa,
                        credits: $credits,
                        onNext: finishOnboarding
                    )
                    .tag(7)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
    }
    
    var pageBackgroundColor: Color {
        switch currentPage {
        case 0, 1, 2, 7: return Color(uiColor: .systemGroupedBackground)
        case 3: return Color.blue
        case 4: return Color.orange
        case 5: return Color.green
        case 6: return Color.purple
        default: return Color(uiColor: .systemGroupedBackground)
        }
    }
    
    var pageAccentColor: Color {
        switch currentPage {
        case 3: return .blue
        case 4: return .orange
        case 5: return .green
        case 6: return .purple
        default: return .blue
        }
    }
    
    func finishOnboarding() {
        // save to SwiftData
        try? context.delete(model: SimulationState.self)
        let state = SimulationState(
            userSavings: currentSavings,
            rentCost: expectedRent,
            tuitionGap: 0
        )
        context.insert(state)
        
        // mark as complete
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
            isOnboardingComplete = true
        }
    }
}

// mark1: HERO WITH CUSTOM LOGO

@available(iOS 17.0, *)
struct HeroPageElite: View {
    let onNext: () -> Void
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
                .ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // custom app logo
                ZStack {
                    RoundedRectangle(cornerRadius: 28, style: .continuous)
                        .fill(
                            LinearGradient(
                                colors: [Color(red: 0.82, green: 0.95, blue: 0.18), Color(red: 0.85, green: 0.97, blue: 0.22)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 130, height: 130)
                        .shadow(color: Color(red: 0.82, green: 0.95, blue: 0.18).opacity(0.5), radius: 25, x: 0, y: 15)
                    
 
                    ZStack {
                        // first stroke (left)
                        Path { path in
                            path.move(to: CGPoint(x: 38, y: 78))
                            path.addLine(to: CGPoint(x: 68, y: 48))
                        }
                        .stroke(Color.black, style: StrokeStyle(lineWidth: 11, lineCap: .round))
                        
                        // second stroke (right)
                        Path { path in
                            path.move(to: CGPoint(x: 58, y: 78))
                            path.addLine(to: CGPoint(x: 88, y: 48))
                        }
                        .stroke(Color.black, style: StrokeStyle(lineWidth: 11, lineCap: .round))
                    }
                    .frame(width: 130, height: 130)
                }
                .scaleEffect(showContent ? 1 : 0.7)
                .opacity(showContent ? 1 : 0)
                
                VStack(spacing: 16) {
                    Text("TransferTrack")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.primary)
                    
                    Text("Your financial GPS for the 2+2 journey")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Text("Navigate transfer costs with confidence—from community college to your dream university.")
                        .font(.body)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 50)
                        .padding(.top, 8)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                Spacer()
                
                Button(action: onNext) {
                    HStack(spacing: 10) {
                        Text("Start Your Journey")
                            .font(.headline)
                        Image(systemName: "arrow.right.circle.fill")
                            .font(.title3)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.8, green: 0.9, blue: 0.2), Color(red: 0.9, green: 1.0, blue: 0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
        }
    }
}

// mark2: the problem

@available(iOS 17.0, *)
struct ProblemPageElite: View {
    let onNext: () -> Void
    @State private var showContent = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer().frame(height: 40)
                
                VStack(spacing: 12) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(.red)
                        .symbolEffect(.bounce, value: showContent)
                    
                    Text("Transfer Shock")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    
                    Text("The hidden crisis affecting millions")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                }
                .opacity(showContent ? 1 : 0)
                
                VStack(alignment: .leading, spacing: 20) {
                    Text("Every year, 2.4 million students transfer from community college to a 4-year university. They're told it's the 'smart, cheap path.'")
                        .font(.body)
                        .foregroundStyle(.primary)
                    
                    Text("But thousands get blindsided:")
                        .font(.headline)
                        .padding(.top, 8)
                    
                    VStack(spacing: 16) {
                        ShockStatRow(
                            icon: "dollarsign.circle.fill",
                            color: .red,
                            title: "Tuition doubles or triples",
                            detail: "CC: $2-4k/year → University: $8-14k+/year"
                        )
                        
                        ShockStatRow(
                            icon: "house.fill",
                            color: .orange,
                            title: "Housing costs explode",
                            detail: "Living at home → $800-1,800/month rent"
                        )
                        
                        ShockStatRow(
                            icon: "exclamationmark.triangle.fill",
                            color: .yellow,
                            title: "Credits get rejected",
                            detail: "Lose months of work and $1,000s in wasted tuition"
                        )
                        
                        ShockStatRow(
                            icon: "creditcard.fill",
                            color: .purple,
                            title: "Financial aid changes",
                            detail: "Grants/scholarships don't always transfer"
                        )
                    }
                    
                    Text("The result? Students drop out, take on massive debt, or delay graduation by years.")
                        .font(.body)
                        .foregroundStyle(.red)
                        .fontWeight(.semibold)
                        .padding(.top, 12)
                }
                .padding(24)
                .background {
                    RoundedRectangle(cornerRadius: 24, style: .continuous)
                        .fill(Color(uiColor: .secondarySystemGroupedBackground))
                        .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                }
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)
                
                Spacer().frame(height: 20)
                
                Button(action: onNext) {
                    HStack {
                        Text("These Are Real Stories")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.red)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
        }
    }
}

struct ShockStatRow: View {
    let icon: String
    let color: Color
    let title: String
    let detail: String
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .frame(width: 30)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                Text(detail)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }
}

// mark3: the students

@available(iOS 17.0, *)
struct ThreeStudentsPage: View {
    let onNext: () -> Void
    @State private var selectedStudent = 0
    @State private var showContent = false
    
    let students = [
        StudentStory(
            name: "Sarah",
            state: "Florida",
            from: "Valencia College",
            to: "UCF",
            color: .green,
            increase: "$17,413/year",
            problem: "Thought 2+2 would save her $10K. Rent + tuition jump ate her savings in 2 months. Had to take $15K in loans.",
            icon: "person.crop.circle.fill"
        ),
        StudentStory(
            name: "Marcus",
            state: "Texas",
            from: "Austin Community College",
            to: "UT Austin",
            color: .orange,
            increase: "$21,200/year",
            problem: "Austin rent crisis hit hard. $0 at home → $1,500/month near campus. Lost financial aid in transfer. Working 30hrs/week just to stay enrolled.",
            icon: "person.crop.circle.fill"
        ),
        StudentStory(
            name: "Priya",
            state: "California",
            from: "Santa Monica College",
            to: "UCLA",
            color: .blue,
            increase: "$24,000/year",
            problem: "UC tuition tripled. LA rent doubled. 3 'elective' classes didn't transfer—wasted $1,800 and a whole semester. Almost gave up on her CS degree.",
            icon: "person.crop.circle.fill"
        )
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer().frame(height: 40)
                
                Text("These Are Real Stories")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .opacity(showContent ? 1 : 0)
                
                // student carousel
                TabView(selection: $selectedStudent) {
                    ForEach(0..<students.count, id: \.self) { index in
                        StudentCard(student: students[index])
                            .tag(index)
                    }
                }
                .frame(height: 500)
                .tabViewStyle(.page)
                .opacity(showContent ? 1 : 0)
                
                Text("Swipe to see more →")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .opacity(showContent ? 1 : 0)
                
                Spacer().frame(height: 20)
                
                Button(action: onNext) {
                    HStack {
                        Text("There's a Better Way")
                        Image(systemName: "arrow.right")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
        }
    }
}

struct StudentStory {
    let name: String
    let state: String
    let from: String
    let to: String
    let color: Color
    let increase: String
    let problem: String
    let icon: String
}

struct StudentCard: View {
    let student: StudentStory
    
    var body: some View {
        VStack(spacing: 24) {
            // student avatar
            ZStack {
                Circle()
                    .fill(student.color.opacity(0.15))
                    .frame(width: 100, height: 100)
                
                Image(systemName: student.icon)
                    .font(.system(size: 50))
                    .foregroundStyle(student.color)
            }
            
            VStack(spacing: 8) {
                Text(student.name)
                    .font(.title.bold())
                
                Text("\(student.state)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            
            // transfer path
            HStack(spacing: 16) {
                VStack(spacing: 4) {
                    Image(systemName: "building.columns.fill")
                        .font(.title2)
                        .foregroundStyle(student.color)
                    Text(student.from)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                
                Image(systemName: "arrow.right")
                    .foregroundStyle(.secondary)
                
                VStack(spacing: 4) {
                    Image(systemName: "star.fill")
                        .font(.title2)
                        .foregroundStyle(student.color)
                    Text(student.to)
                        .font(.caption)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 20)
            .background(student.color.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
            
            // cost increase
            Text(student.increase)
                .font(.system(size: 28, weight: .bold, design: .rounded))
                .foregroundStyle(.red)
            
            Text("cost increase")
                .font(.caption)
                .foregroundStyle(.secondary)
                .offset(y: -8)
            
            // problem description
            Text(student.problem)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 20)
        }
        .padding(24)
        .background {
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .fill(Color(uiColor: .secondarySystemGroupedBackground))
                .shadow(color: .black.opacity(0.08), radius: 15, x: 0, y: 8)
        }
        .padding(.horizontal, 24)
    }
}

// mark4: features pages

@available(iOS 17.0, *)
struct FeaturePage: View {
    let backgroundColor: Color
    let icon: String
    let title: String
    let subtitle: String
    let description: String
    let onNext: () -> Void
    
    @State private var showContent = false
    
    var body: some View {
        ZStack {
            backgroundColor.ignoresSafeArea()
            
            VStack(spacing: 40) {
                Spacer()
                
                // feature icon
                ZStack {
                    Circle()
                        .fill(.white.opacity(0.25))
                        .frame(width: 140, height: 140)
                    
                    Circle()
                        .fill(.white.opacity(0.15))
                        .frame(width: 110, height: 110)
                    
                    Image(systemName: icon)
                        .font(.system(size: 50, weight: .semibold))
                        .foregroundStyle(.white)
                }
                .scaleEffect(showContent ? 1 : 0.8)
                .opacity(showContent ? 1 : 0)
                
                VStack(spacing: 16) {
                    Text(title)
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(.title2.bold())
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    Text(description)
                        .font(.body)
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 50)
                        .padding(.top, 8)
                }
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 20)
                
                Spacer()
                
                Button(action: onNext) {
                    HStack {
                        Text("Next")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.white)
                    .foregroundStyle(backgroundColor)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
        }
    }
}

// mark5: personalization with logos

@available(iOS 17.0, *)
struct PersonalizationWithLogos: View {
    @Binding var state: String
    @Binding var cc: String
    @Binding var uni: String
    @Binding var savings: Double
    @Binding var rent: Double
    @Binding var gpa: Double
    @Binding var credits: Int
    
    let onNext: () -> Void
    
    @State private var showContent = false
    
    // state options
    let states = ["Florida", "California", "Texas", "Virginia", "Washington", "North Carolina", "New Jersey"]
    
    // CC options per state
    func ccOptions(for state: String) -> [String] {
        switch state {
        case "Florida": return ["Valencia College", "Miami Dade College", "Seminole State", "Polk State", "Santa Fe College"]
        case "California": return ["Santa Monica College", "De Anza College", "Pasadena City College", "Diablo Valley College", "Orange Coast College"]
        case "Texas": return ["Austin Community College", "Houston Community College", "Lone Star College", "Dallas College", "Alamo Colleges"]
        case "Virginia": return ["Northern Virginia CC", "Tidewater CC", "Virginia Western CC", "J. Sargeant Reynolds CC"]
        case "Washington": return ["Seattle Central College", "Bellevue College", "Spokane CC", "Green River College"]
        case "North Carolina": return ["Central Piedmont CC", "Wake Tech CC", "Guilford Tech CC", "Cape Fear CC"]
        case "New Jersey": return ["Bergen Community College", "Middlesex County College", "Camden County College", "Union County College"]
        default: return ["Valencia College"]
        }
    }
    
    // university options per state
    func uniOptions(for state: String) -> [String] {
        switch state {
        case "Florida": return ["UCF", "University of Florida", "Florida State", "USF", "FIU"]
        case "California": return ["UCLA", "UC Berkeley", "UC Davis", "Cal State LA", "San Jose State"]
        case "Texas": return ["UT Austin", "Texas A&M", "University of Houston", "UT San Antonio", "Texas State"]
        case "Virginia": return ["UVA", "Virginia Tech", "James Madison", "George Mason", "VCU"]
        case "Washington": return ["UW Seattle", "Washington State", "Central Washington", "Eastern Washington"]
        case "North Carolina": return ["UNC Chapel Hill", "NC State", "Appalachian State", "ECU", "UNC Charlotte"]
        case "New Jersey": return ["Rutgers", "Rowan University", "Montclair State", "NJIT", "Stockton University"]
        default: return ["UCF"]
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                Spacer().frame(height: 40)
                
                VStack(spacing: 12) {
                    Image(systemName: "person.fill.questionmark")
                        .font(.system(size: 50))
                        .foregroundStyle(.blue)
                    
                    Text("Your Turn")
                        .font(.system(size: 36, weight: .bold, design: .rounded))
                    
                    Text("Build your personalized transfer plan")
                        .font(.title3)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .opacity(showContent ? 1 : 0)
                
                VStack(spacing: 20) {
                    // State Selector
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Your State", systemImage: "mappin.and.ellipse")
                            .font(.headline)
                            .foregroundStyle(.blue)
                        
                        Menu {
                            ForEach(states, id: \.self) { s in
                                Button(s) {
                                    state = s
                                    // reset CC and Uni when state changes
                                    cc = ccOptions(for: s).first ?? ""
                                    uni = uniOptions(for: s).first ?? ""
                                }
                            }
                        } label: {
                            HStack {
                                Image(systemName: "map.fill")
                                Text(state)
                                    .fontWeight(.medium)
                                Spacer()
                                Image(systemName: "chevron.up.chevron.down")
                                    .font(.caption)
                            }
                            .padding()
                            .background(Color.blue.opacity(0.1))
                            .foregroundStyle(.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(20)
                    .background {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color(uiColor: .secondarySystemGroupedBackground))
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    }
                    
                    // transfer Path
                    VStack(alignment: .leading, spacing: 12) {
                        Label("Your Transfer Path", systemImage: "arrow.triangle.2.circlepath")
                            .font(.headline)
                            .foregroundStyle(.purple)
                        
                        HStack(spacing: 16) {
                            VStack(spacing: 8) {
                                Text("From")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Menu {
                                    ForEach(ccOptions(for: state), id: \.self) { college in
                                        Button(college) { cc = college }
                                    }
                                } label: {
                                    VStack(spacing: 6) {
                                        Image(systemName: "building.columns.fill")
                                            .font(.title2)
                                            .foregroundStyle(.blue)
                                        
                                        Text(cc)
                                            .font(.caption)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                            
                            Image(systemName: "arrow.right")
                                .foregroundStyle(.secondary)
                            

                            VStack(spacing: 8) {
                                Text("To")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Menu {
                                    ForEach(uniOptions(for: state), id: \.self) { university in
                                        Button(university) { uni = university }
                                    }
                                } label: {
                                    VStack(spacing: 6) {
                                        // university logo placeholder
                                        Image(systemName: "star.fill")
                                            .font(.title2)
                                            .foregroundStyle(.purple)
                                        
                                        Text(uni)
                                            .font(.caption)
                                            .lineLimit(2)
                                            .multilineTextAlignment(.center)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.purple.opacity(0.1))
                                    .clipShape(RoundedRectangle(cornerRadius: 12))
                                }
                            }
                        }
                    }
                    .padding(20)
                    .background {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color(uiColor: .secondarySystemGroupedBackground))
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    }
                    
                    // Academics (compact)
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Academic Status", systemImage: "book.fill")
                            .font(.headline)
                            .foregroundStyle(.green)
                        
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("GPA")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(String(format: "%.2f", gpa))
                                    .font(.title3.bold())
                                    .foregroundStyle(.green)
                            }
                            
                            Slider(value: $gpa, in: 0.0...4.0, step: 0.01)
                                .tint(.green)
                        }
                        
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Credits")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("\(credits)")
                                    .font(.title3.bold())
                                    .foregroundStyle(.green)
                            }
                            
                            Slider(value: Binding(
                                get: { Double(credits) },
                                set: { credits = Int($0) }
                            ), in: 0...90, step: 1)
                            .tint(.green)
                        }
                    }
                    .padding(20)
                    .background {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color(uiColor: .secondarySystemGroupedBackground))
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    }
                    
                    // finances (compact)
                    VStack(alignment: .leading, spacing: 16) {
                        Label("Financial Snapshot", systemImage: "dollarsign.circle.fill")
                            .font(.headline)
                            .foregroundStyle(.orange)
                        
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Savings")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("$\(Int(savings))")
                                    .font(.title3.bold())
                                    .foregroundStyle(.orange)
                            }
                            
                            Slider(value: $savings, in: 0...10000, step: 100)
                                .tint(.orange)
                        }
                        
                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Rent")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text("$\(Int(rent))")
                                    .font(.title3.bold())
                                    .foregroundStyle(.orange)
                            }
                            
                            Slider(value: $rent, in: 0...2000, step: 50)
                                .tint(.orange)
                        }
                    }
                    .padding(20)
                    .background {
                        RoundedRectangle(cornerRadius: 20, style: .continuous)
                            .fill(Color(uiColor: .secondarySystemGroupedBackground))
                            .shadow(color: .black.opacity(0.05), radius: 10, x: 0, y: 5)
                    }
                }
                .padding(.horizontal, 24)
                .opacity(showContent ? 1 : 0)
                .offset(y: showContent ? 0 : 30)
                
                Spacer().frame(height: 20)
                
                Button(action: onNext) {
                    HStack {
                        Text("Generate My Forecast")
                        Image(systemName: "arrow.right.circle.fill")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.8, green: 0.9, blue: 0.2), Color(red: 0.9, green: 1.0, blue: 0.3)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .foregroundStyle(.black)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 40)
                .opacity(showContent ? 1 : 0)
            }
        }
        .onAppear {
            // Initialize based on state
            if ccOptions(for: state).isEmpty == false && cc.isEmpty {
                cc = ccOptions(for: state).first ?? ""
            }
            if uniOptions(for: state).isEmpty == false && uni.isEmpty {
                uni = uniOptions(for: state).first ?? ""
            }
            
            withAnimation(.spring(response: 0.8, dampingFraction: 0.7).delay(0.2)) {
                showContent = true
            }
        }
    }
}
