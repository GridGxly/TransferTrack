import SwiftUI
import SwiftData

enum USState: String, CaseIterable, Identifiable {
    case florida = "Florida"
    case california = "California"
    case texas = "Texas"
    case newYork = "New York"
    var id: Self { self }
}

struct TransferPipeline: Hashable {
    let origin: String
    let target: String
}


@available(iOS 17.0, *)
struct OnboardingFlowView: View {
    @Binding var isOnboardingComplete: Bool
    @Environment(\.modelContext) var context
    
    // logic State
    @State private var currentStep = 0
    

    @State private var selectedState: USState = .florida
    @State private var selectedPipeline: TransferPipeline?
    @State private var gpa: Double = 3.2
    @State private var credits: Double = 45
    @State private var housingSelection: HousingType?
    
    var body: some View {
        ZStack {
            LiquidBackground()
            
            VStack {
                // progress Bar
                HStack(spacing: 8) {
                    ForEach(0..<4) { index in
                        Capsule()
                            .fill(index <= currentStep ? Color.blue : Color.gray.opacity(0.1))
                            .frame(height: 6)
                            .animation(.spring(), value: currentStep)
                    }
                }
                .padding(.horizontal, 40)
                .padding(.top, 20)
                
                TabView(selection: $currentStep) {
                    // location & pipeline
                    StateAndSchoolStep(
                        selectedState: $selectedState,
                        selectedPipeline: $selectedPipeline,
                        onNext: nextStep
                    )
                    .tag(0)
                    
                    // academics
                    AcademicStatsStep(
                        gpa: $gpa,
                        credits: $credits,
                        onNext: nextStep
                    )
                    .tag(1)
                    
                    // housing
                    HousingSelectionStep(
                        selection: $housingSelection,
                        onNext: nextStep
                    )
                    .tag(2)
                    
                    // simulation
                    SimulationLoadingStep(
                        pipeline: selectedPipeline,
                        onFinish: finishOnboarding
                    )
                    .tag(3)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
            }
        }
    }
    
    func nextStep() {
        withAnimation { currentStep += 1 }
    }
    
    func finishOnboarding() {
        let isApt = housingSelection == .apartment
        let rent = isApt ? 1200.0 : 0.0
        

        try? context.delete(model: SimulationState.self)
        

        let state = SimulationState(
            userSavings: 2500,
            rentCost: rent,
            tuitionGap: 0
        )
        context.insert(state)
        
        withAnimation { isOnboardingComplete = true }
    }
}


@available(iOS 17.0, *)
struct StateAndSchoolStep: View {
    @Binding var selectedState: USState
    @Binding var selectedPipeline: TransferPipeline?
    var onNext: () -> Void
    

    var pipelines: [TransferPipeline] {
        switch selectedState {
        case .florida:
            return [
                TransferPipeline(origin: "Valencia College", target: "UCF"),
                TransferPipeline(origin: "Miami Dade College", target: "UF"),
                TransferPipeline(origin: "Seminole State", target: "FSU"),
                TransferPipeline(origin: "Santa Fe College", target: "UF")
            ]
        case .california:
            return [
                TransferPipeline(origin: "Santa Monica College", target: "UCLA"),
                TransferPipeline(origin: "De Anza College", target: "UC Berkeley"),
                TransferPipeline(origin: "Irvine Valley College", target: "UC Irvine"),
                TransferPipeline(origin: "Mt. San Antonio", target: "Cal Poly Pomona")
            ]
        case .texas:
            return [
                TransferPipeline(origin: "Austin Comm. College", target: "UT Austin"),
                TransferPipeline(origin: "Dallas College", target: "UT Dallas"),
                TransferPipeline(origin: "El Paso Comm. College", target: "Texas Tech")
            ]
        case .newYork:
            return [
                TransferPipeline(origin: "BMCC", target: "NYU"),
                TransferPipeline(origin: "Nassau Comm. College", target: "Stony Brook"),
                TransferPipeline(origin: "LaGuardia CC", target: "Columbia GS")
            ]
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Select Your Path")
                .font(.system(size: 34, weight: .bold, design: .rounded))
            
            // state picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(USState.allCases) { state in
                        Button {
                            withAnimation {
                                selectedState = state
                                selectedPipeline = nil // reset pipeline on state change
                            }
                        } label: {
                            Text(state.rawValue)
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(selectedState == state ? Color.black : Color.gray.opacity(0.1))
                                .foregroundStyle(selectedState == state ? .white : .black)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding(.horizontal)
            }
            .padding(.bottom, 10)
            
            // pipeline List
            ScrollView {
                VStack(spacing: 12) {
                    ForEach(pipelines, id: \.self) { pipeline in
                        Button {
                            selectedPipeline = pipeline
                        } label: {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(pipeline.origin)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                    Image(systemName: "arrow.down")
                                        .font(.caption2)
                                        .foregroundStyle(.gray.opacity(0.5))
                                        .padding(.vertical, 2)
                                    Text(pipeline.target)
                                        .font(.headline)
                                        .foregroundStyle(.primary)
                                }
                                Spacer()
                                if selectedPipeline == pipeline {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundStyle(Color.blue)
                                        .font(.title2)
                                } else {
                                    Image(systemName: "circle")
                                        .foregroundStyle(Color.gray.opacity(0.3))
                                        .font(.title2)
                                }
                            }
                            .padding()
                            .liquidGlass()
                        }
                        .buttonStyle(ScaleButtonStyle())
                    }
                }
                .padding(.horizontal)
            }
            
            Button("Continue") { onNext() }
                .buttonStyle(PrimaryActionStyle())
                .disabled(selectedPipeline == nil)
                .opacity(selectedPipeline != nil ? 1 : 0.5)
                .padding(.bottom, 20)
                .padding(.horizontal)
        }
    }
}


@available(iOS 17.0, *)
struct AcademicStatsStep: View {
    @Binding var gpa: Double
    @Binding var credits: Double
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            Text("The Academic Reality.")
                .font(.system(size: 34, weight: .bold, design: .rounded))
            
            VStack(spacing: 30) {
                VStack {
                    HStack {
                        Text("Current GPA")
                        Spacer()
                        Text(String(format: "%.2f", gpa))
                            .font(.title2.bold())
                            .foregroundStyle(.blue)
                    }
                    Slider(value: $gpa, in: 0.0...4.0, step: 0.01)
                }
                
                Divider()
                
                VStack {
                    HStack {
                        Text("Credits Earned")
                        Spacer()
                        Text("\(Int(credits))")
                            .font(.title2.bold())
                            .foregroundStyle(.blue)
                    }
                    Slider(value: $credits, in: 0...90, step: 1)
                    Text("60 Credits = AA Degree (Ready to Transfer)")
                        .font(.caption).foregroundStyle(.secondary)
                }
            }
            .padding(30)
            .liquidGlass()
            .padding(.horizontal)
            
            Spacer()
            Button("Continue") { onNext() }
                .buttonStyle(PrimaryActionStyle())
                .padding(.bottom, 40)
                .padding(.horizontal)
        }
    }
}

enum HousingType { case commuter, apartment }

@available(iOS 17.0, *)
struct HousingSelectionStep: View {
    @Binding var selection: HousingType?
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Text("The Financial Shock.")
                .font(.system(size: 34, weight: .bold, design: .rounded))
            Text("Housing is the #1 cost variable. Where will you sleep?")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .padding(.bottom)
            
            // commuter option
            Button { selection = .commuter } label: {
                HStack {
                    Image(systemName: "car.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.green)
                        .frame(width: 60)
                    VStack(alignment: .leading) {
                        Text("The Commuter")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text("Living at home. Paying gas money.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if selection == .commuter { Image(systemName: "checkmark.circle.fill").foregroundStyle(.green) }
                }
                .padding()
                .liquidGlass()
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(selection == .commuter ? Color.green : Color.clear, lineWidth: 2)
                )
            }
            .buttonStyle(ScaleButtonStyle())
            
            // relocator option
            Button { selection = .apartment } label: {
                HStack {
                    Image(systemName: "building.2.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.orange)
                        .frame(width: 60)
                    VStack(alignment: .leading) {
                        Text("The Relocator")
                            .font(.headline)
                            .foregroundStyle(.primary)
                        Text("Moving to campus. Paying rent.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if selection == .apartment { Image(systemName: "checkmark.circle.fill").foregroundStyle(.orange) }
                }
                .padding()
                .liquidGlass()
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(selection == .apartment ? Color.orange : Color.clear, lineWidth: 2)
                )
            }
            .buttonStyle(ScaleButtonStyle())
            
            Spacer()
            
            Button("Run Simulation") { onNext() }
                .buttonStyle(PrimaryActionStyle())
                .disabled(selection == nil)
                .opacity(selection != nil ? 1 : 0.5)
                .padding(.bottom, 40)
                .padding(.horizontal)
        }
        .padding(.horizontal)
    }
}


@available(iOS 17.0, *)
struct SimulationLoadingStep: View {
    var pipeline: TransferPipeline?
    var onFinish: () -> Void
    @State private var loadingText = "Connecting..."
    @State private var progress: CGFloat = 0.0
    
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                Circle()
                    .stroke(Color.gray.opacity(0.1), lineWidth: 10)
                    .frame(width: 120, height: 120)
                
                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(Color.blue, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
            }
            .padding(.bottom, 40)
            
            Text(loadingText)
                .font(.title3.bold())
                .multilineTextAlignment(.center)
                .contentTransition(.numericText())
                .padding(.horizontal)
            Spacer()
        }
        .onAppear {
            runSim()
        }
    }
    
    func runSim() {
        let target = pipeline?.target ?? "University"
        let origin = pipeline?.origin ?? "College"
        
        let phases = [
            (0.2, "Analyzing \(origin) transcripts..."),
            (0.5, "Checking \(target) transfer agreements..."),
            (0.7, "Calculating cost of living shock..."),
            (1.0, "Simulation Complete.")
        ]
        
        Task {
            for (p, text) in phases {
                try? await Task.sleep(nanoseconds: 800_000_000)
                withAnimation {
                    progress = p
                    loadingText = text
                }
            }
            try? await Task.sleep(nanoseconds: 500_000_000)
            onFinish()
        }
    }
}


struct PrimaryActionStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.blue)
            .clipShape(Capsule())
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .animation(.spring(), value: configuration.isPressed)
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.97 : 1)
            .animation(.spring(), value: configuration.isPressed)
    }
}
