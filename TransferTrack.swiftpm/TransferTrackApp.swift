import SwiftUI
import SwiftData

@main
@available(iOS 17.0, *)
struct TransferTrackApp: App {
    @State private var isOnboardingComplete: Bool = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    
    // Support both light and dark mode
    @AppStorage("userColorScheme") private var userColorScheme: String = "system"

    var body: some Scene {
        WindowGroup {
            RootView(isOnboardingComplete: $isOnboardingComplete)
                .preferredColorScheme(colorScheme)
        }
        .modelContainer(DataController.makeContainer())
    }
    
    var colorScheme: ColorScheme? {
        switch userColorScheme {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
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
                EliteOnboardingFlow(isOnboardingComplete: $isOnboardingComplete)
            }
        }
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











