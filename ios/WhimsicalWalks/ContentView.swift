import SwiftUI

struct ContentView: View {
    let store: StoreViewModel
    @State private var selectedTab: Int = 0
    @State private var dataService = DataService()
    @State private var healthService = HealthKitService()
    @State private var showPaywall: Bool = false
    @State private var showStreakCelebration: Bool = false
    @State private var soundService = WhimsicalSoundService()

    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Home", systemImage: "house.fill", value: 0) {
                HomeView(healthService: healthService, dataService: dataService, selectedTab: $selectedTab)
            }
            Tab("Quests", systemImage: "map.fill", value: 1) {
                QuestsView(dataService: dataService, healthService: healthService)
            }
            Tab("Polaroids", systemImage: "camera.fill", value: 2) {
                PolaroidsView(dataService: dataService, healthService: healthService)
            }
            Tab("Pets", systemImage: "pawprint.fill", value: 3) {
                PetsView(dataService: dataService)
            }
            Tab("Profile", systemImage: "person.crop.circle.fill", value: 4) {
                ProfileView(dataService: dataService, healthService: healthService)
            }
        }
        .tint(WhimsicalTheme.deepRose)
        .task {
            await healthService.requestAuthorization()
            applyOnboardingGoal()
            await dataService.updateStreak(using: healthService)
        }
        .sensoryFeedback(.selection, trigger: selectedTab)
        .onChange(of: store.isPremium) { _, isPremium in
            if !isPremium {
                showPaywall = true
            }
        }
        .fullScreenCover(isPresented: $showPaywall) {
            SettingsPaywallView(store: store)
        }
        .overlay {
            if showStreakCelebration {
                StreakCelebrationView(streakCount: dataService.stats.currentStreak) {
                    showStreakCelebration = false
                }
                .transition(.opacity)
            }
        }
        .onAppear {
            checkStreakCelebration()
            soundService.playOpenChime()
        }
    }

    private func applyOnboardingGoal() {
        let savedGoal = UserDefaults.standard.integer(forKey: "whimsical_step_goal")
        if savedGoal > 0 && dataService.stats.dailyStepGoal == 10000 {
            dataService.updateDailyGoal(savedGoal)
        }
    }

    private func checkStreakCelebration() {
        let key = "whimsical_last_celebration_date"
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastDate = UserDefaults.standard.object(forKey: key) as? Date,
           calendar.isDate(lastDate, inSameDayAs: today) {
            return
        }

        guard dataService.stats.currentStreak > 1 else { return }

        Task {
            await healthService.fetchTodaySteps()
            if healthService.todaySteps >= 10000 {
                UserDefaults.standard.set(today, forKey: key)
                withAnimation(.easeOut(duration: 0.3)) {
                    showStreakCelebration = true
                }
            }
        }
    }

}
