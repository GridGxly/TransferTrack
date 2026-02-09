import SwiftUI
import SwiftData

@available(iOS 17.0, *)
struct OnboardingFlowView: View {
    @Binding var isOnboardingComplete: Bool
    @State private var currentStep = 0
    
    // user choices
    @State private var selectedOrigin: University?
    @State private var selectedTarget: University?
    @State private var housingMode: Int = 0
    
    @Query(sort: \University.name) var universities: [University]
    
    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            
            //  page controller
            TabView(selection: $currentStep) {
                RouteSelectionView(
                    universities: universities,
                    selectedOrigin: $selectedOrigin,
                    selectedTarget: $selectedTarget,
                    onNext: { withAnimation { currentStep = 1 } }
                )
                .tag(0)
                

                LifestyleSelectionView(
                    housingMode: $housingMode,
                    onNext: { withAnimation { currentStep = 2 } }
                )
                .tag(1)

                ImpactRevealView(
                    origin: selectedOrigin,
                    target: selectedTarget,
                    housingMode: housingMode,
                    onFinish: {
                        // save choice for dashboard
                        UserDefaults.standard.set(Double(housingMode), forKey: "initialSliderValue")
                        withAnimation { isOnboardingComplete = true }
                    }
                )
                .tag(2)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}

@available(iOS 17.0, *)
struct RouteSelectionView: View {
    var universities: [University]
    @Binding var selectedOrigin: University?
    @Binding var selectedTarget: University?
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 30) {
            Spacer()
            
            Text("Where is your journey starting?")
                .font(.largeTitle)
                .bold()
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
            
            // origin card
            Menu {
                ForEach(universities) { uni in
                    Button(uni.name) { selectedOrigin = uni }
                }
            } label: {
                SelectCard(title: "Starting At", value: selectedOrigin?.name ?? "Select College", icon: "building.columns", isSelected: selectedOrigin != nil)
            }
            
            Image(systemName: "arrow.down")
                .font(.title)
                .foregroundStyle(.gray)
                .opacity(0.5)
            
            // target card
            Menu {
                ForEach(universities) { uni in
                    Button(uni.name) { selectedTarget = uni }
                }
            } label: {
                SelectCard(title: "Transferring To", value: selectedTarget?.name ?? "Select University", icon: "graduationcap.fill", isSelected: selectedTarget != nil)
            }
            
            Spacer()
            
            
            if selectedOrigin != nil && selectedTarget != nil {
                Button(action: onNext) {
                    Text("Next Step")
                        .font(.headline)
                        .foregroundStyle(.black)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .cornerRadius(25)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .padding(30)
    }
}


@available(iOS 17.0, *)
struct LifestyleSelectionView: View {
    @Binding var housingMode: Int
    var onNext: () -> Void
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            Text("How will you live?")
                .font(.largeTitle)
                .bold()
                .foregroundStyle(.white)
            
            HStack(spacing: 20) {
                Button(action: { housingMode = 0; onNext() }) {
                    LifestyleCard(title: "Commuter", icon: "car.fill", desc: "Living at home")
                }
                

                Button(action: { housingMode = 1; onNext() }) {
                    LifestyleCard(title: "Relocator", icon: "box.truck.fill", desc: "Moving near campus")
                }
            }
            Spacer()
        }
        .padding()
    }
}


@available(iOS 17.0, *)
struct ImpactRevealView: View {
    var origin: University?
    var target: University?
    var housingMode: Int
    var onFinish: () -> Void
    @State private var showContent = false
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            if showContent {
                Text("Estimated Transfer Shock")
                    .font(.headline)
                    .foregroundStyle(.gray)
                    .transition(.opacity)
                
                Text(housingMode == 1 ? "+$4,200 / term" : "+$950 / term")
                    .font(.system(size: 50, weight: .heavy))
                    .foregroundStyle(housingMode == 1 ? .red : .orange)
                    .transition(.scale.combined(with: .opacity))
                
                Text(housingMode == 1 ? "Mainly due to rent increases in Orlando." : "Mainly due to tuition hikes.")
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.white.opacity(0.8))
                    .padding(.horizontal)
            } else {
                ProgressView()
                    .tint(.white)
                    .scaleEffect(2)
            }
            
            Spacer()
            
            if showContent {
                Button(action: onFinish) {
                    Text("See the Breakdown")
                        .bold()
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundStyle(.white)
                        .cornerRadius(25)
                }
            }
        }
        .padding(30)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                withAnimation { showContent = true }
            }
        }
    }
}


struct SelectCard: View {
    let title: String
    let value: String
    let icon: String
    let isSelected: Bool
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(isSelected ? .white : .gray)
                .frame(width: 40)
            
            VStack(alignment: .leading) {
                Text(title).font(.caption).foregroundStyle(.gray)
                Text(value).font(.title3).bold().foregroundStyle(.white)
            }
            Spacer()
            Image(systemName: "chevron.up.chevron.down")
                .foregroundStyle(.gray)
        }
        .padding()
        .background(Color(white: 0.1))
        .cornerRadius(15)
        .overlay(
            RoundedRectangle(cornerRadius: 15)
                .stroke(isSelected ? Color.blue : Color.clear, lineWidth: 2)
        )
    }
}

struct LifestyleCard: View {
    let title: String
    let icon: String
    let desc: String
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: icon)
                .font(.system(size: 50))
                .foregroundStyle(.blue)
            Text(title).bold().foregroundStyle(.white)
            Text(desc).font(.caption).foregroundStyle(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: 200)
        .background(Color(white: 0.1))
        .cornerRadius(20)
    }
}
