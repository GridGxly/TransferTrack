import SwiftUI
import SwiftData
import TipKit
import AppIntents

@main
@available(iOS 17.0, *)
struct TransferTrackApp: App {
    @State private var isOnboardingComplete: Bool =
        UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")

    init() {
        try? Tips.configure([
            .datastoreLocation(.applicationDefault)
        ])

        #if DEBUG
        try? Tips.resetDatastore()
        #endif

        TransferTrackShortcuts.updateAppShortcutParameters()
    }

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
