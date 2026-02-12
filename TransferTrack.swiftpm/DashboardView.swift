import SwiftUI
import SwiftData
import Charts

// mark - chart data
struct MonthlyBalance: Identifiable, Hashable {
    let id = UUID()
    let month: String
    let amount: Double
}

// mark - view model
@available(iOS 17.0, *)
@Observable
class DashboardViewModel {
    var sliderValue: Double = 0.0
    var chartData: [MonthlyBalance] = []
    

    var viabilityScore: Int = 72
    var monthlyGap: Int = -450
    var commuteCost: Int = 60
    var atRiskCredits: Int = 6
    
    init() {
        // initialize with default data
        calculateProjection()
    }
    
    func calculateProjection() {
        // placeholder for future logic
    }
}

// mark - main dashboard view
@available(iOS 17.0, *)
struct DashboardView: View {
    @State private var selectedTab: Int = 0
    @Environment(\.modelContext) var context
    
    // viewmodel is now defined above so this will work now
    @State private var viewModel = DashboardViewModel()
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ForecastView(viewModel: viewModel)
                .tabItem {
                    Label("Forecast", systemImage: "chart.bar.xaxis")
                }
                .tag(0)
            
            AcademicsView()
                .tabItem {
                    Label("Academics", systemImage: "book.fill")
                }
                .tag(1)
            
            HousingView()
                .tabItem {
                    Label("Housing", systemImage: "house.fill")
                }
                .tag(2)
            
            SolutionsView()
                .tabItem {
                    Label("Solutions", systemImage: "lightbulb.fill")
                }
                .tag(3)
        }
        .tint(.blue)
    }
}

// mark1 - forecast tab
@available(iOS 17.0, *)
struct ForecastView: View {
    var viewModel: DashboardViewModel
    @State private var scoreAnimation: Double = 0.0
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    
    
                    VStack(spacing: 8) {
                        Text("TRANSFERTRACK")
                            .font(.caption)
                            .fontWeight(.bold)
                            .foregroundStyle(.secondary)
                            .padding(.top, 20)
                        
                        Text("Ralph's Transfer Plan")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundStyle(.primary)
                    }
                    
                    // viability score ring
                    ZStack {
                        Circle()
                            .stroke(Color.gray.opacity(0.15), lineWidth: 20)
                            .frame(width: 220, height: 220)
                        
                        Circle()
                            .trim(from: 0, to: scoreAnimation / 100)
                            .stroke(
                                LinearGradient(colors: [.orange, .yellow], startPoint: .topLeading, endPoint: .bottomTrailing),
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .frame(width: 220, height: 220)
                            .rotationEffect(.degrees(-90))
                            .animation(.spring(duration: 1.5, bounce: 0.3), value: scoreAnimation)
                        
                        VStack(spacing: 4) {
                            Text("\(Int(scoreAnimation))")
                                .font(.system(size: 64, weight: .bold, design: .rounded))
                                .contentTransition(.numericText())
                            
                            Text("Viability Score")
                                .font(.subheadline)
                                .fontWeight(.medium)
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.vertical, 10)
                    
                    Text("You are academically ready, but financially at risk.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                    
                    // metric cards
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 16) {
                            MetricCard(
                                icon: "dollarsign.circle.fill",
                                color: .red,
                                label: "Projected Monthly Gap",
                                value: "-$450",
                                valueColor: .red
                            )
                            
                            MetricCard(
                                icon: "fuelpump.fill",
                                color: .orange,
                                label: "Commute Cost",
                                value: "+$60/mo",
                                valueColor: .orange
                            )
                            
                            MetricCard(
                                icon: "book.closed.fill",
                                color: .blue,
                                label: "Credits at Risk",
                                value: "6 credits",
                                valueColor: .blue
                            )
                        }
                        .padding(.horizontal, 20)
                    }
                    
                    Spacer(minLength: 50)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .onAppear {
                scoreAnimation = Double(viewModel.viabilityScore)
            }
        }
    }
}

// mark2 - academics tab
@available(iOS 17.0, *)
struct AcademicsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    
                    // degree applicable
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Degree Applicable")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        Text("These credits transfer directly to your major.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                            .padding(.top, -10)
                        
                        VStack(spacing: 12) {
                            CourseRow(name: "Intro to Programming", code: "COP 2000", credits: 3, grade: "A", status: .success)
                            CourseRow(name: "Calculus I", code: "MAC 2311", credits: 4, grade: "B+", status: .success)
                            CourseRow(name: "English Composition I", code: "ENC 1101", credits: 3, grade: "A-", status: .success)
                            CourseRow(name: "General Psychology", code: "PSY 2012", credits: 3, grade: "B", status: .success)
                            CourseRow(name: "Physics I", code: "PHY 2048", credits: 4, grade: "B", status: .success)
                            CourseRow(name: "Data Structures", code: "COP 3530", credits: 3, grade: "A-", status: .success)
                        }
                        .padding(.horizontal)
                    }
                    
                    // wasted credits
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Elective Only — \"Wasted\" Credits")
                            .font(.headline)
                            .padding(.horizontal)
                            .padding(.top, 10)
                        
                        Text("These won't count toward your CS degree at UCF.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .padding(.horizontal)
                            .padding(.top, -10)
                        
                        VStack(spacing: 12) {
                            CourseRow(name: "Art Appreciation", code: "ARH 1000", credits: 3, grade: "A", status: .warning, costNote: "Cost: $600 / 4mo Lost")
                            CourseRow(name: "Music of the World", code: "MUH 2012", credits: 3, grade: "B+", status: .warning, costNote: "Cost: $600 / 4mo Lost")
                            CourseRow(name: "Humanities Elective", code: "HUM 2230", credits: 3, grade: "B", status: .warning, costNote: "Cost: $600 / 4mo Lost")
                        }
                        .padding(.horizontal)
                    }
                    
                    Spacer(minLength: 40)
                }
                .padding(.vertical)
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Academics")
        }
    }
}

// mark3 - housing tab
@available(iOS 17.0, *)
struct HousingView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Housing Near UCF")
                            .font(.title3.bold())
                        Text("Rent +$400/mo vs. current · Gas savings -$50/mo")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    VStack(spacing: 16) {
                        ApartmentCard(
                            name: "Knights Landing",
                            distance: "0.5 mi",
                            price: 1200,
                            beds: 2, baths: 2,
                            tag: "High Odds — Student-Friendly",
                            tagColor: .green
                        )
                        
                        ApartmentCard(
                            name: "University House",
                            distance: "1.2 mi",
                            price: 950,
                            beds: 1, baths: 1,
                            tag: "Medium Odds — Co-signer Recommended",
                            tagColor: .orange
                        )
                        
                        ApartmentCard(
                            name: "The Pointe at Central",
                            distance: "0.8 mi",
                            price: 1450,
                            beds: 2, baths: 2,
                            tag: "Low Odds — Guarantor Required",
                            tagColor: .red
                        )
                        
                        ApartmentCard(
                            name: "Tivoli Apartments",
                            distance: "2.1 mi",
                            price: 800,
                            beds: 1, baths: 1,
                            tag: "High Odds — No Credit Check",
                            tagColor: .green
                        )
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Housing")
        }
    }
}

// mark4 - solutions tab
@available(iOS 17.0, *)
struct SolutionsView: View {
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Improve Your Score")
                            .font(.title3.bold())
                        Text("Check off actions to boost your Viability Score.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.horizontal)
                    .padding(.top)
                    
                    // boost banner
                    HStack {
                        Image(systemName: "chart.line.uptrend.xyaxis")
                        Text("+8 potential score boost")
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding()
                    .background(Color.green.opacity(0.1))
                    .foregroundStyle(.green)
                    .cornerRadius(12)
                    .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        SolutionRow(title: "Apply for UCF DirectConnect", desc: "Guaranteed admission pathway from Valencia to UCF", points: 8)
                        SolutionRow(title: "Appeal Credit Transfer Decision", desc: "Contest 6 at-risk credits with course syllabus", points: 5)
                        SolutionRow(title: "Find a Roommate", desc: "Split rent costs to reduce monthly housing gap", points: 6)
                        SolutionRow(title: "Apply for Bright Futures Scholarship", desc: "State scholarship covering up to 100% tuition", points: 7)
                        SolutionRow(title: "Set Up Emergency Fund", desc: "Save 3 months of projected gap ($1,350) before transfer", points: 3)
                        SolutionRow(title: "Get a Campus Job", desc: "UCF Federal Work-Study covers ~$200/mo", points: 4)
                    }
                    .padding(.horizontal)
                    
                    Spacer(minLength: 40)
                }
            }
            .background(Color(uiColor: .systemGroupedBackground))
            .navigationTitle("Solutions")
        }
    }
}


// MARK - reuseable componenets

@available(iOS 17.0, *)
struct MetricCard: View {
    let icon: String
    let color: Color
    let label: String
    let value: String
    let valueColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(color)
                .padding(10)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 10))
            
            VStack(alignment: .leading, spacing: 4) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                
                Text(value)
                    .font(.title3.bold())
                    .foregroundStyle(valueColor)
            }
        }
        .padding(16)
        .frame(width: 160, alignment: .leading)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

enum CourseStatus {
    case success, warning
}

@available(iOS 17.0, *)
struct CourseRow: View {
    let name: String
    let code: String
    let credits: Int
    let grade: String
    let status: CourseStatus
    var costNote: String? = nil
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            Image(systemName: status == .success ? "checkmark.circle.fill" : "exclamationmark.triangle")
                .font(.title2)
                .foregroundStyle(status == .success ? .green : .orange)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.subheadline.bold())
                    .foregroundStyle(.primary)
                
                HStack(spacing: 4) {
                    Text(code)
                    Text("•")
                    Text("\(credits) cr")
                    Text("•")
                    Text(grade)
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            if let cost = costNote {
                Text(cost)
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundStyle(.red)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
    }
}

@available(iOS 17.0, *)
struct ApartmentCard: View {
    let name: String
    let distance: String
    let price: Int
    let beds: Int
    let baths: Int
    let tag: String
    let tagColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(name)
                        .font(.headline)
                    
                    HStack(spacing: 4) {
                        Image(systemName: "mappin.and.ellipse")
                        Text("\(distance) from campus")
                    }
                    .font(.caption)
                    .foregroundStyle(.secondary)
                }
                Spacer()
                Text("$\(price)")
                    .font(.title3.bold())
                    + Text("/mo").font(.caption).foregroundStyle(.secondary)
            }
            
            HStack(spacing: 16) {
                HStack(spacing: 4) {
                    Image(systemName: "bed.double.fill")
                    Text("\(beds) bed")
                }
                HStack(spacing: 4) {
                    Image(systemName: "shower.fill")
                    Text("\(baths) bath")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            }
            
            Text(tag)
                .font(.caption.bold())
                .foregroundStyle(tagColor)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(tagColor.opacity(0.1))
                .clipShape(Capsule())
        }
        .padding()
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}

@available(iOS 17.0, *)
struct SolutionRow: View {
    let title: String
    let desc: String
    let points: Int
    @State private var isChecked = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring) {
                isChecked.toggle()
            }
        }) {
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: isChecked ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isChecked ? .blue : .secondary)
                    .contentTransition(.symbolEffect(.replace))
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.subheadline.bold())
                        .foregroundStyle(.primary)
                        .strikethrough(isChecked, color: .secondary)
                    
                    Text(desc)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                Text("+\(points) pts")
                    .font(.caption.bold())
                    .foregroundStyle(.blue)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(8)
                    .opacity(isChecked ? 0.5 : 1.0)
            }
            .padding()
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: .black.opacity(0.03), radius: 2, x: 0, y: 1)
        }
        .buttonStyle(.plain)
    }
}

