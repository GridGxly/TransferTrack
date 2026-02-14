import SwiftUI
import SwiftData
import TipKit
import AppIntents

@main
@available(iOS 17.0, *)
struct TransferTrackApp: App {
    @State private var isOnboardingComplete: Bool =
        UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
    @AppStorage("appTheme") private var appTheme: String = AppTheme.system.rawValue

    init() {
        try? Tips.configure([
            .datastoreLocation(.applicationDefault)
        ])

        #if DEBUG
        try? Tips.resetDatastore()
        #endif

        TransferTrackShortcuts.updateAppShortcutParameters()
    }

    private var selectedTheme: AppTheme {
        AppTheme(rawValue: appTheme) ?? .system
    }
    var body: some Scene {
        WindowGroup {
            RootView(isOnboardingComplete: $isOnboardingComplete)
                .preferredColorScheme(selectedTheme.colorScheme)
        }
        .modelContainer(for: [UserCourse.self])
    }
}

@available(iOS 17.0, *)
struct RootView: View {
    @Binding var isOnboardingComplete: Bool

    var body: some View {
        ZStack {
            Color(uiColor: .systemGroupedBackground)
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
