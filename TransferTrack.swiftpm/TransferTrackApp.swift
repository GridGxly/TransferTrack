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
        }
        .modelContainer(for: [UserCourse.self])
    }
}

@available(iOS 17.0, *)
struct RootView: View {
    @Binding var isOnboardingComplete: Bool

    var body: some View {
        ZStack {
            // fix light mode breaking the freaking app
            Color(uiColor: .systemBackground)
                .ignoresSafeArea()

            if isOnboardingComplete {
                DashboardView(isOnboardingComplete: $isOnboardingComplete)
                    .transition(.opacity)
            } else {
                OnboardingFlow(isOnboardingComplete: $isOnboardingComplete)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.4), value: isOnboardingComplete)
    }
}
