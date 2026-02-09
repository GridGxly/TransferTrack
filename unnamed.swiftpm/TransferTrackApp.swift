import SwiftUI
import SwiftData

@main
@available(iOS 17.0, *)
struct TransferTrackApp: App {
    let container: ModelContainer
    
    // track if onboarding is done
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    init() {
        do {
            let schema = Schema([
                University.self,
                Course.self,
                SimulationState.self
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if hasCompletedOnboarding {
                    DashboardView()
                        .transition(.opacity)
                } else {
                    OnboardingFlowView(isOnboardingComplete: $hasCompletedOnboarding)
                }
            }
            .animation(.easeInOut, value: hasCompletedOnboarding)
            .onAppear {
                Seeder.seedIfNeeded(container.mainContext)
            }
        }
        .modelContainer(container)
    }
}
