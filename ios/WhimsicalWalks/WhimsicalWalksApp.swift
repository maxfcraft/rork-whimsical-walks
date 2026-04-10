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

        // RevenueCat uses the SAME public SDK key for sandbox (simulator +
        // TestFlight) and production — there is no separate "test" key. The
        // previous code branched on #if DEBUG and picked a different key in
        // Release, which meant TestFlight builds loaded an empty/unset key
        // and silently bailed out of configure(), leaving Purchases never
        // initialized and the paywall stuck on "Subscription service not
        // available." Prefer the iOS key; fall back to the test slot if the
        // iOS slot happens to be blank so either is accepted.
        let prodKey = Config.EXPO_PUBLIC_REVENUECAT_IOS_API_KEY
        let testKey = Config.EXPO_PUBLIC_REVENUECAT_TEST_API_KEY
        let apiKey = !prodKey.isEmpty ? prodKey : testKey

        guard !apiKey.isEmpty else {
            NSLog("[RevenueCat] No API key found in Config. Paywall will not load. Populate EXPO_PUBLIC_REVENUECAT_IOS_API_KEY with your appl_… key.")
            return
        }

        if prodKey.isEmpty {
            NSLog("[RevenueCat] EXPO_PUBLIC_REVENUECAT_IOS_API_KEY was empty — using EXPO_PUBLIC_REVENUECAT_TEST_API_KEY as fallback.")
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
