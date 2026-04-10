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
        #else
        Purchases.logLevel = .info
        #endif

        let prodKey = Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY
        let testKey = Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY
        let apiKey = !prodKey.isEmpty ? prodKey : testKey

        guard !apiKey.isEmpty else {
            NSLog("[RevenueCat] No API key found in Config. Paywall will not load.")
            return
        }

        if prodKey.isEmpty {
            NSLog("[RevenueCat] IOS key empty — using TEST key fallback.")
        }

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
