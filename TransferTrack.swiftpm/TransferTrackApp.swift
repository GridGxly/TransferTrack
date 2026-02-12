import SwiftUI
import SwiftData

@main
@available(iOS 17.0, *)
struct TransferTrackApp: App {
    @State private var isOnboardingComplete: Bool =
        UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

    var body: some Scene {
        WindowGroup {
            RootView(isOnboardingComplete: $isOnboardingComplete)
                .preferredColorScheme(.light)
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
                    .transition(.opacity)
            } else {
                OnboardingFlow(isOnboardingComplete: $isOnboardingComplete)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: isOnboardingComplete)
    }
}

