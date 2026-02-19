import SwiftUI
import SwiftData
import TipKit
import AppIntents
import UIKit

extension View {
    @ViewBuilder
    func syncSystemTheme(theme: AppTheme) -> some View {
        if #available(iOS 17.0, *) {
            self.onChange(of: theme, initial: true) { _, newTheme in
                if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                    for window in windowScene.windows {
                        switch newTheme {
                        case .system:
                            window.overrideUserInterfaceStyle = .unspecified
                        case .light:
                            window.overrideUserInterfaceStyle = .light
                        case .dark:
                            window.overrideUserInterfaceStyle = .dark
                        }
                    }
                }
            }
        } else {
            // Fallback on earlier versions: no-op, return the original view
            self
        }
    }
}

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
                .roundedDesign()
                .syncSystemTheme(theme: selectedTheme)
        }
        .modelContainer(for: [UserCourse.self])
    }
}

@available(iOS 17.0, *)
struct RootView: View {
    @Binding var isOnboardingComplete: Bool

    var body: some View {
        ZStack {
            if isOnboardingComplete {
                DashboardView(isOnboardingComplete: $isOnboardingComplete)
                    .transition(.opacity.combined(with: .scale(scale: 0.96)))
            } else {
                OnboardingFlow(isOnboardingComplete: $isOnboardingComplete)
                    .transition(.opacity)
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.85), value: isOnboardingComplete)
    }
}
