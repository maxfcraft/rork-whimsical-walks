import SwiftUI
import RevenueCat

@main
struct WhimsicalWalksApp: App {
    @State private var showSplash: Bool = true
    @State private var showOnboarding: Bool = false
    @State private var store = StoreViewModel()
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    init() {
        FontRegistration.registerFonts()
        Self.configureRevenueCat()
    }

    private static func configureRevenueCat() {
        #if DEBUG
        Purchases.logLevel = .debug
        let apiKey = Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY
        #else
        Purchases.logLevel = .warn
        let apiKey = Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY
        #endif
        guard !apiKey.isEmpty else { return }
        Purchases.configure(withAPIKey: apiKey)
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showOnboarding && !hasCompletedOnboarding {
                    OnboardingView(store: store) {
                        withAnimation(.easeOut(duration: 0.5)) {
                            hasCompletedOnboarding = true
                            showOnboarding = false
                        }
                    }
                    .transition(.opacity)
                } else if !showSplash {
                    ContentView(store: store)
                        .transition(.opacity)
                }

                if showSplash {
                    SplashView {
                        withAnimation(.easeOut(duration: 0.3)) {
                            showSplash = false
                            if !hasCompletedOnboarding {
                                showOnboarding = true
                            }
                        }
                    }
                    .transition(.opacity)
                }
            }
            .preferredColorScheme(.light)
            .task {
                store.start()
                await store.checkStatus()
                if store.isPremium && !hasCompletedOnboarding {
                    hasCompletedOnboarding = true
                }
            }
        }
    }
}
