import SwiftUI
import SwiftData

@main
@available(iOS 17.0, *)
struct TransferTrackApp: App {
    @State private var isOnboardingComplete: Bool = false

    var body: some Scene {
        WindowGroup {
            RootView(isOnboardingComplete: $isOnboardingComplete)
        }
        .modelContainer(DataController.makeContainer())
    }
}

@available(iOS 17.0, *)
struct RootView: View {
    @Binding var isOnboardingComplete: Bool

    var body: some View {
        ZStack {
            if isOnboardingComplete {
                DashboardView()
            } else {
                OnboardingFlowView(isOnboardingComplete: $isOnboardingComplete)
            }
        }
        .preferredColorScheme(.dark)
    }
}


@available(iOS 17.0, *)
enum DataController {
    static func makeContainer() -> ModelContainer {
        let schema = Schema([
            University.self,
            Course.self,
            SimulationState.self
        ])
        let config = ModelConfiguration(isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Failed to create ModelContainer: \(error)")
        }
    }
}
