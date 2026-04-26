import SwiftUI

struct HomeView: View {
    let healthService: HealthKitService
    let dataService: DataService
    @Binding var selectedTab: Int
    @State private var appeared: Bool = false
    @State private var ringAnimated: Bool = false
    @State private var displayedSteps: Int = 0
    @State private var stepCountTimer: Timer?
    @State private var animationStartTime: Date?
    @AppStorage("walkingFactIndex") private var walkingFactIndex: Int = 0

    private var ownedPets: [Pet] {
        dataService.pets.filter { $0.isOwned }
    }

    private var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        let name = UserDefaults.standard.string(forKey: "whimsical_user_name") ?? ""
        let timeGreeting: String
        if hour < 12 { timeGreeting = "Good morning" }
        else if hour < 17 { timeGreeting = "Good afternoon" }
        else { timeGreeting = "Good evening" }
        return name.isEmpty ? timeGreeting : "\(timeGreeting), \(name)"
    }

    private var stepProgress: Double {
        guard dataService.stats.dailyStepGoal > 0 else { return 0 }
        return min(1.0, Double(healthService.todaySteps) / Double(dataService.stats.dailyStepGoal))
    }

    private var todayQuest: Quest? {
        dataService.quests.first(where: { !$0.isCompleted })
    }

    private var unrevealedPolaroid: Polaroid? {
        dataService.polaroids.first(where: { !$0.isRevealed })
    }

    private var nextPet: Pet? {
        dataService.nextPetToUnlock
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                stepRingSection
                if let polaroid = unrevealedPolaroid {
                    polaroidPreviewCard(polaroid)
                }
                if let quest = todayQuest {
                    questPreviewCard(quest)
                }
                if let pet = nextPet {
                    nextPetCard(pet)
                }

                if !ownedPets.isEmpty {
                    VStack(spacing: 0) {
                        Text("Your Companions")
                            .font(.system(.caption, design: .serif))
                            .foregroundStyle(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        PetPlatformView(ownedPets: ownedPets)
                    }
                }

                Spacer(minLength: 20)

                walkingFactsCarousel
                    .padding(.top, 8)
                    .padding(.bottom, 32)
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .background { WhimsicalBackground(screen: .home) }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.easeOut(duration: 0.6), value: appeared)
        .onAppear {
            appeared = true
            walkingFactIndex = (walkingFactIndex + 1) % walkingFacts.count
            Task { await loadSteps() }
        }
        .onChange(of: healthService.isAuthorized) { _, isAuthorized in
            if isAuthorized {
                Task { await loadSteps() }
            }
        }
    }

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                WhimsicalTitle(greeting)
                WhimsicalSubtitle("today's quests")
            }
            Spacer()
            streakBadge
        }
    }

    private var streakBadge: some View {
        HStack(spacing: 4) {
            Image(systemName: "flame.fill")
                .font(.callout)
                .foregroundStyle(WhimsicalTheme.deepRose)
                .symbolEffect(.pulse, options: .repeating)
            Text("\(dataService.stats.currentStreak)")
                .font(.system(.headline, design: .serif, weight: .bold))
                .foregroundStyle(WhimsicalTheme.deepRose)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(WhimsicalTheme.blushPink.opacity(0.6), in: Capsule())
    }

    private var stepRingSection: some View {
        VStack(spacing: 16) {
            ZStack {
                Circle()
                    .stroke(WhimsicalTheme.ringPinkLight.opacity(0.3), lineWidth: 16)
                    .frame(width: 180, height: 180)

                Circle()
                    .trim(from: 0, to: ringAnimated ? stepProgress : 0)
                    .stroke(
                        LinearGradient(
                            colors: [WhimsicalTheme.ringPink, WhimsicalTheme.deepRose],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 16, lineCap: .round)
                    )
                    .frame(width: 180, height: 180)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Text("\(displayedSteps)")
                        .font(.system(.largeTitle, design: .serif, weight: .bold))
                        .foregroundStyle(.primary)
                        .contentTransition(.numericText(countsDown: false))
                    Text("of \(dataService.stats.dailyStepGoal.formatted()) steps")
                        .font(.system(.caption, design: .serif))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding(.vertical, 8)
    }

    private func polaroidPreviewCard(_ polaroid: Polaroid) -> some View {
        let goalMet = healthService.todaySteps >= dataService.stats.dailyStepGoal
        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: goalMet ? "sparkles" : "camera.fill")
                    .foregroundStyle(WhimsicalTheme.deepRose)
                Text(goalMet ? "Ready to unlock" : "Developing...")
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(.primary)
                Spacer()
                if !goalMet {
                    Text("Hit your step goal to reveal")
                        .font(.system(.caption, design: .serif))
                        .foregroundStyle(.secondary)
                }
            }

            if goalMet {
                Button {
                    selectedTab = 2
                } label: {
                    HStack(spacing: 5) {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                        Text("Go Unlock")
                            .font(.system(.caption, design: .serif, weight: .semibold))
                    }
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .frame(maxWidth: .infinity)
                    .background(WhimsicalTheme.deepRose, in: Capsule())
                }
            } else {
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 8)
                        .fill(WhimsicalTheme.blushPink.opacity(0.3))
                        .frame(height: 6)
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(WhimsicalTheme.deepRose)
                                .frame(width: geo.size.width * stepProgress, height: 6)
                        }
                }
                .frame(height: 6)
            }
        }
        .padding(16)
        .background(WhimsicalTheme.cardBackground, in: .rect(cornerRadius: 16))
    }

    private func questPreviewCard(_ quest: Quest) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Circle()
                    .fill(WhimsicalTheme.difficultyColor(quest.difficulty))
                    .frame(width: 8, height: 8)
                Text("Today's Quest")
                    .font(.system(.subheadline, design: .serif, weight: .semibold))
                Spacer()
            }

            Text(quest.title)
                .font(.system(.subheadline, design: .serif, weight: .semibold))
                .foregroundStyle(.primary)

            Text(quest.description)
                .font(.system(.caption, design: .serif))
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    selectedTab = 1
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "camera.fill")
                        .font(.caption2)
                    Text("Take Photo")
                        .font(.system(.caption, design: .serif, weight: .semibold))
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .frame(maxWidth: .infinity)
                .background(WhimsicalTheme.deepRose, in: Capsule())
            }
            .sensoryFeedback(.impact(flexibility: .soft), trigger: selectedTab)
        }
        .padding(12)
        .background(WhimsicalTheme.cardBackground, in: .rect(cornerRadius: 14))
    }

    private func loadSteps() async {
        await healthService.fetchTodaySteps()
        dataService.updateTotalSteps(healthService.todaySteps)
        if healthService.todaySteps >= dataService.stats.dailyStepGoal {
            dataService.markTodayGoalMet()
        }
        withAnimation(.easeInOut(duration: 1.2).delay(0.3)) {
            ringAnimated = true
        }
        animateStepCount(to: healthService.todaySteps)
    }

    private func animateStepCount(to target: Int) {
        stepCountTimer?.invalidate()
        guard target > 0 else {
            displayedSteps = 0
            return
        }
        let duration: Double = 1.4
        let startDelay: Double = 0.3
        let frameRate: Double = 60
        let totalFrames = Int(duration * frameRate)
        var frame = 0

        DispatchQueue.main.asyncAfter(deadline: .now() + startDelay) {
            stepCountTimer = Timer.scheduledTimer(withTimeInterval: 1.0 / frameRate, repeats: true) { timer in
                frame += 1
                let progress = min(1.0, Double(frame) / Double(totalFrames))
                let eased = 1 - pow(1 - progress, 3)
                withAnimation(.linear(duration: 1.0 / frameRate)) {
                    displayedSteps = Int(Double(target) * eased)
                }
                if frame >= totalFrames {
                    timer.invalidate()
                    stepCountTimer = nil
                    withAnimation(.linear(duration: 0.05)) {
                        displayedSteps = target
                    }
                }
            }
        }
    }

    private let walkingFacts: [String] = [
        "A Stanford study found that walking boosts creative thinking by up to 60%. Your best ideas are just a stroll away.",
        "Harvard researchers found that as few as 4,400 steps a day significantly lowers mortality risk in women. Every step is self care.",
        "A JAMA meta-analysis found that higher daily step counts are linked to fewer symptoms of depression. Walking is basically therapy with better views.",
        "Forest walking has been shown to reduce the stress hormone cortisol. Nature walks are the original spa day."
    ]

    private var walkingFactsCarousel: some View {
        Text(walkingFacts[walkingFactIndex % walkingFacts.count])
            .font(.system(size: 17, weight: .regular, design: .serif))
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: 300)
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity)
    }

    private func nextPetCard(_ pet: Pet) -> some View {
        let progress = pet.stepsToUnlock > 0 ? min(1.0, Double(dataService.stats.totalStepsAllTime) / Double(pet.stepsToUnlock)) : 1.0
        let remaining = max(0, pet.stepsToUnlock - dataService.stats.totalStepsAllTime)

        return VStack(alignment: .leading, spacing: 6) {
            HStack {
                Image(systemName: "pawprint.fill")
                    .font(.caption)
                    .foregroundStyle(WhimsicalTheme.deepSage)
                Text("Next Pet")
                    .font(.system(.subheadline, design: .serif, weight: .semibold))
                Spacer()
                Text(pet.name)
                    .font(.system(.caption, design: .serif, weight: .semibold))
                    .foregroundStyle(WhimsicalTheme.deepSage)
            }

            HStack {
                Text("\(dataService.stats.totalStepsAllTime.formatted())")
                    .font(.system(.caption2, design: .serif, weight: .medium))
                    .foregroundStyle(.secondary)
                Spacer()
                Text("\(pet.stepsToUnlock.formatted()) steps")
                    .font(.system(.caption2, design: .serif, weight: .medium))
                    .foregroundStyle(.secondary)
            }

            GeometryReader { geo in
                RoundedRectangle(cornerRadius: 8)
                    .fill(WhimsicalTheme.sageGreen.opacity(0.3))
                    .frame(height: 4)
                    .overlay(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(WhimsicalTheme.deepSage)
                            .frame(width: geo.size.width * progress, height: 4)
                    }
            }
            .frame(height: 4)

            Text("\(remaining.formatted()) steps to unlock")
                .font(.system(.caption2, design: .serif))
                .foregroundStyle(.tertiary)
        }
        .padding(10)
        .background(WhimsicalTheme.cardBackground, in: .rect(cornerRadius: 14))
    }
}
