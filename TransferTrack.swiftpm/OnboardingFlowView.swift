import SwiftUI
import SwiftData
import MapKit

@available(iOS 17.0, *)
struct OnboardingFlowView: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentStep = 0
    
    // user choices
    @State private var selectedOrigin: University?
    @State private var selectedTarget: University?
    @State private var currentSavings: Double = 2000
    @State private var housingMode: Int = 0
    
    // data access
    @Query(sort: \University.name) var universities: [University]
    @Environment(\.modelContext) var context
    
    // map state
    @State private var cameraPosition: MapCameraPosition = .region(MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 28.5383, longitude: -81.3792),
        span: MKCoordinateSpan(latitudeDelta: 1.0, longitudeDelta: 1.0)
    ))
    
    var body: some View {
        ZStack {
            Map(position: $cameraPosition) {
                if let origin = selectedOrigin {
                    Marker("Start", systemImage: "figure.walk", coordinate: origin.location)
                        .tint(.green)
                }
                if let target = selectedTarget {
                    Marker("Goal", systemImage: "flag.checkered", coordinate: target.location)
                        .tint(.yellow)
                }
                if let origin = selectedOrigin, let target = selectedTarget {
                    MapPolyline(coordinates: [origin.location, target.location])
                        .stroke(.blue, lineWidth: 3)
                }
            }
            .mapStyle(.imagery(elevation: .realistic))
            .overlay(Color.black.opacity(0.7))
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 2.0), value: cameraPosition)
            .allowsHitTesting(false)
            TabView(selection: $currentStep) {
                
                RouteSelectionView(
                    universities: universities,
                    selectedOrigin: $selectedOrigin,
                    selectedTarget: $selectedTarget,
                    onNext: {
                        if let o = selectedOrigin, let t = selectedTarget {
                            let midLat = (o.location.latitude + t.location.latitude) / 2
                            let midLon = (o.location.longitude + t.location.longitude) / 2
                            withAnimation {
                                cameraPosition = .region(MKCoordinateRegion(
                                    center: CLLocationCoordinate2D(latitude: midLat, longitude: midLon),
                                    span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
                                ))
                                currentStep = 1
                            }
                        }
                    }
                )
                .tag(0)
                

                FinancialBaselineView(
                    savings: $currentSavings,
                    onNext: { withAnimation { currentStep = 2 } }
                )
                .tag(1)


                LifestyleSelectionView(
                    housingMode: $housingMode,
                    onNext: { withAnimation { currentStep = 3 } }
                )
                .tag(2)


                ImpactRevealView(
                    origin: selectedOrigin,
                    target: selectedTarget,
                    housingMode: housingMode,
                    savings: currentSavings,
                    onFinish: {
                        finishOnboarding()
                    }
                )
                .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .onAppear {
            if universities.isEmpty {
                seedData()
            }
        }
    }
    
    func finishOnboarding() {
        UserDefaults.standard.set(Double(housingMode), forKey: "initialSliderValue")
        
        do {
            // ensure state exists
            if let state = try context.fetch(FetchDescriptor<SimulationState>()).first {
                state.userSavings = currentSavings
                state.rentCost = housingMode == 1 ? 1200 : 0
            } else {
                let state = SimulationState(userSavings: currentSavings, rentCost: housingMode == 1 ? 1200 : 0, tuitionGap: 0)
                context.insert(state)
            }
            try context.save()
            withAnimation { isOnboardingComplete = true }
        } catch {
            print("Failed to save simulation state: \(error)")
        }
    }
    
    
    func seedData() {
        let list = [
            University(name: "Valencia College", tuitionRate: 103.0, colorHex: "#8C2131"),
            University(name: "UCF", tuitionRate: 212.0, colorHex: "#FFC904"),
            University(name: "Univ. of Florida", tuitionRate: 212.0, colorHex: "#FA4616"),
            University(name: "FIU", tuitionRate: 205.0, colorHex: "#081E3F"),
            University(name: "Miami Dade College", tuitionRate: 118.0, colorHex: "#00578A"),
            University(name: "UCLA", tuitionRate: 450.0, colorHex: "#2D68C4")
        ]
        
        for uni in list {
            context.insert(uni)
        }
        
        let state = SimulationState(userSavings: 2000, rentCost: 0, tuitionGap: 0)
        context.insert(state)
        
        try? context.save()
    }
}



@available(iOS 17.0, *)
struct RouteSelectionView: View {
    var universities: [University]
    @Binding var selectedOrigin: University?
    @Binding var selectedTarget: University?
    var onNext: () -> Void
    
    // sheet state
    @State private var showOriginSheet = false
    @State private var showTargetSheet = false
    
    var body: some View {
        VStack(spacing: 25) {
            Spacer()
            
            Text("Design Your Path")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .shadow(color: .blue.opacity(0.8), radius: 20)
            
            VStack(spacing: 15) {
                Button(action: { showOriginSheet = true }) {
                    GlassCard(title: "Current College", value: selectedOrigin?.name ?? "Tap to Select", icon: "building.columns.fill", isSet: selectedOrigin != nil)
                }
                .sheet(isPresented: $showOriginSheet) {
                    UniversityPickerSheet(title: "Select Origin", universities: universities, selection: $selectedOrigin)
                }

                Image(systemName: "arrow.down")
                    .font(.title2)
                    .foregroundStyle(.white.opacity(0.5))

                Button(action: { showTargetSheet = true }) {
                    GlassCard(title: "Target University", value: selectedTarget?.name ?? "Tap to Select", icon: "graduationcap.fill", isSet: selectedTarget != nil)
                }
                .sheet(isPresented: $showTargetSheet) {
                    UniversityPickerSheet(title: "Select Target", universities: universities, selection: $selectedTarget)
                }
            }
            .padding(.horizontal)
            
            Spacer()
            
            if selectedOrigin != nil && selectedTarget != nil {
                ContinueButton(title: "Calculate Route", action: onNext)
            }
        }
        .padding(.bottom, 50)
    }
}

// helper sheet for selection
@available(iOS 17.0, *)
struct UniversityPickerSheet: View {
    let title: String
    let universities: [University]
    @Binding var selection: University?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            List(universities) { uni in
                Button {
                    selection = uni
                    dismiss()
                } label: {
                    HStack {
                        Text(uni.name)
                            .foregroundStyle(.primary)
                        Spacer()
                        if selection?.name == uni.name {
                            Image(systemName: "checkmark").foregroundStyle(.blue)
                        }
                    }
                }
            }
            .navigationTitle(title)
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
    }
}

@available(iOS 17.0, *)
struct FinancialBaselineView: View {
    @Binding var savings: Double
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Day 1 Funding")
                .font(.largeTitle).bold()
                .foregroundStyle(.white)
            
            Text("How much cash will you have on the day you transfer?")
                .multilineTextAlignment(.center)
                .foregroundStyle(.gray)
                .padding(.horizontal)
            
            VStack {
                Text(savings, format: .currency(code: "USD"))
                    .font(.system(size: 56, weight: .black, design: .rounded))
                    .foregroundStyle(.green)
                    .contentTransition(.numericText())
                
                Slider(value: $savings, in: 0...10000, step: 100)
                    .tint(.green)
                    .padding()
            }
            .padding()
            .background(.ultraThinMaterial)
            .cornerRadius(20)
            .padding()
            
            Spacer()
            
            ContinueButton(title: "Lock it in", action: onNext)
        }
        .padding(.bottom, 50)
    }
}

@available(iOS 17.0, *)
struct LifestyleSelectionView: View {
    @Binding var housingMode: Int
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            Text("Fall 2026 Lifestyle")
                .font(.largeTitle).bold()
                .foregroundStyle(.white)
            
            HStack(spacing: 15) {
                Button(action: { housingMode = 0; onNext() }) {
                    LifestyleOption(
                        title: "The Commuter",
                        icon: "house.fill",
                        desc: "Living at home.\nLow cost, high traffic.",
                        color: .green
                    )
                }
                
                Button(action: { housingMode = 1; onNext() }) {
                    LifestyleOption(
                        title: "The Relocator",
                        icon: "building.2.fill",
                        desc: "Apartment life.\nIndependence, but expensive.",
                        color: .orange
                    )
                }
            }
            .padding(.horizontal)
            
            Spacer()
        }
        .padding(.bottom, 50)
    }
}

@available(iOS 17.0, *)
struct ImpactRevealView: View {
    var origin: University?
    var target: University?
    var housingMode: Int
    var savings: Double
    var onFinish: () -> Void
    
    @State private var animatedCost: Double = 0
    @State private var showButton = false
    
    var projectedCost: Double {
        return housingMode == 1 ? 4200 : 950
    }
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            Text("Projected Transfer Shock")
                .font(.headline)
                .foregroundStyle(.gray)
                .textCase(.uppercase)
                .tracking(2)
            
            HStack(alignment: .firstTextBaseline, spacing: 5) {
                Text("-")
                    .font(.system(size: 60, weight: .black))
                    .foregroundStyle(.red)
                Text(animatedCost, format: .currency(code: "USD"))
                    .font(.system(size: 60, weight: .black, design: .rounded))
                    .foregroundStyle(.red)
                    .contentTransition(.numericText())
            }
            
            Text("Per Semester Deficit")
                .font(.caption)
                .foregroundStyle(.red.opacity(0.8))
            
            if showButton {
                Text(housingMode == 1 ? "Rent in Orlando is the killer." : "Tuition hikes will eat your savings.")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white)
                    .padding(.top, 20)
                    .padding(.horizontal)
                    .transition(.opacity)
            }
            
            Spacer()
            
            if showButton {
                Button(action: onFinish) {
                    Text("Enter Simulation")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(30)
                        .shadow(radius: 10)
                }
                .padding(.horizontal, 30)
                .transition(.move(edge: .bottom))
            }
        }
        .padding(.bottom, 50)
        .task {
            await startCounting()
        }
    }
    
    func startCounting() async {
        let duration = 1.5
        let steps = 50
        let stepDuration = UInt64(duration / Double(steps) * 1_000_000_000)
        let increment = projectedCost / Double(steps)
        
        for _ in 0..<steps {
            try? await Task.sleep(nanoseconds: stepDuration)
            
            if animatedCost < projectedCost {
                withAnimation(.linear(duration: 0.05)) {
                    animatedCost += increment
                }
                let generator = UIImpactFeedbackGenerator(style: .light)
                generator.impactOccurred()
            }
        }
        
        animatedCost = projectedCost
        withAnimation { showButton = true }
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
}


struct GlassCard: View {
    let title: String
    let value: String
    let icon: String
    let isSet: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(isSet ? .white : .gray)
                .frame(width: 40)
            
            VStack(alignment: .leading) {
                Text(title).font(.caption).foregroundStyle(.gray)
                Text(value).font(.title3).bold().foregroundStyle(.white)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.gray.opacity(0.5))
        }
        .padding()
        .background(.ultraThinMaterial)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(isSet ? 0.5 : 0.1), lineWidth: 1)
        )
        // ensures the tap hits the entire card
        .contentShape(Rectangle())
    }
}

struct LifestyleOption: View {
    let title: String
    let icon: String
    let desc: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Image(systemName: icon)
                .font(.system(size: 40))
                .foregroundStyle(color)
            
            Text(title)
                .font(.headline)
                .foregroundStyle(.white)
            
            Text(desc)
                .font(.caption)
                .foregroundStyle(.gray)
                .multilineTextAlignment(.leading)
            
            Spacer()
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 220)
        .background(.ultraThinMaterial)
        .cornerRadius(20)
    }
}

struct ContinueButton: View {
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundStyle(.black)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white)
                .cornerRadius(30)
        }
        .padding(.horizontal, 30)
    }
}
