import SwiftUI

struct ProfileView: View {
    let dataService: DataService
    let healthService: HealthKitService
    @State private var appeared: Bool = false
    @State private var showGoalPicker: Bool = false
    @State private var showRankSheet: Bool = false
    @State private var showJourney: Bool = false
    @State private var newGoal: Double = 10000
    @State private var floatPhase: Bool = false
    @State private var resetTapCount: Int = 0
    @State private var showResetConfirm: Bool = false
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerWithRank
                heroStepsCard
                journeyToggle
                if showJourney {
                    JourneyTimelineView(dataService: dataService)
                        .frame(height: 500)
                        .padding(.horizontal, -4)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
                darkModeToggle
                streakSection
                goalSection
                ProfileHighlightsView(dataService: dataService)
                flowerDivider
                FeedbackView()

                Button {
                    resetTapCount += 1
                    if resetTapCount >= 5 {
                        showResetConfirm = true
                        resetTapCount = 0
                    }
                } label: {
                    Text("v1.0.0")
                        .font(.system(size: 11, design: .serif))
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
                .padding(.top, 8)

                Spacer(minLength: 40)
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .background { WhimsicalBackground(screen: .profile) }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 0.5), value: appeared)
        .onAppear {
            appeared = true
            newGoal = Double(dataService.stats.dailyStepGoal)
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                floatPhase = true
            }
        }
        .sheet(isPresented: $showGoalPicker) {
            GoalPickerSheet(goal: $newGoal, onSave: {
                dataService.updateDailyGoal(Int(newGoal))
                showGoalPicker = false
            })
            .presentationDetents([.medium])
            .presentationDragIndicator(.visible)
        }
        .alert("Reset Onboarding?", isPresented: $showResetConfirm) {
            Button("Reset", role: .destructive) {
                hasCompletedOnboarding = false
            }
            Button("Cancel", role: .cancel) { }
        } message: {
            Text("The app will restart with the onboarding flow. Force quit and reopen after this.")
        }
        .sheet(isPresented: $showRankSheet) {
            RankBadgeSheet(currentRank: dataService.currentRank, totalSteps: dataService.stats.totalStepsAllTime)
                .presentationDetents([.large])
                .presentationDragIndicator(.visible)
        }
    }

    private var headerWithRank: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    WhimsicalTitle("Profile")
                    WhimsicalSubtitle("your whimsical journey")
                }
                Spacer()
                rankBadge
            }

            if let pet = dataService.activePet,
               let position = PetSpritePosition(rawValue: pet.spriteIndex) {
                HStack(spacing: 10) {
                    PetSpriteView(position: position, size: 36)
                        .offset(y: floatPhase ? -2 : 2)
                    Text("walking with \(pet.name)")
                        .font(.system(.caption, design: .serif))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var rankBadge: some View {
        Button {
            showRankSheet = true
        } label: {
            VStack(spacing: 3) {
                ZStack {
                    Circle()
                        .fill(rankColor.opacity(0.12))
                        .frame(width: 40, height: 40)
                    Image(systemName: dataService.currentRank.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(rankColor)
                }
                Text(dataService.currentRank.title)
                    .font(.system(size: 9, weight: .semibold, design: .serif))
                    .foregroundStyle(rankColor)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }
            .frame(width: 72)
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: showRankSheet)
    }

    private var rankColor: Color {
        switch dataService.currentRank {
        case .daydreamWalker: WhimsicalTheme.blushPink
        case .petalStroller: WhimsicalTheme.deepRose
        case .meadowWanderer: WhimsicalTheme.deepSage
        case .starlitExplorer: WhimsicalTheme.deepLavender
        case .moonlitRambler: WhimsicalTheme.lavender
        case .enchantedTrailblazer: WhimsicalTheme.deepPeach
        case .celestialVoyager: Color(red: 0.85, green: 0.65, blue: 0.2)
        }
    }

    private var heroStepsCard: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                NotecardTapeStrip()
                Spacer()
            }
            .offset(y: 6)
            .zIndex(1)

            VStack(spacing: 14) {
                HStack(spacing: 16) {
                    stepRingMini
                    VStack(alignment: .leading, spacing: 4) {
                        Text(dataService.stats.totalStepsAllTime.formatted())
                            .font(.system(.title, design: .serif, weight: .bold))
                            .foregroundStyle(.primary)
                        Text("total steps")
                            .font(.system(.caption, design: .serif))
                            .foregroundStyle(.secondary)

                        if let nextRank = dataService.nextRank {
                            let remaining = nextRank.stepsRequired - dataService.stats.totalStepsAllTime
                            Text("\(remaining.formatted()) to \(nextRank.title)")
                                .font(.system(size: 10, weight: .medium, design: .serif))
                                .foregroundStyle(WhimsicalTheme.deepRose)
                        }
                    }
                    Spacer()
                }

                NotecardDivider()

                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8),
                    GridItem(.flexible(), spacing: 8)
                ], spacing: 8) {
                    MiniStat(value: "\(dataService.stats.longestStreak)", label: "day streak", color: WhimsicalTheme.deepRose)
                    MiniStat(value: "\(dataService.stats.questsCompleted)", label: "adventures", color: WhimsicalTheme.deepLavender)
                    MiniStat(value: "\(dataService.polaroids.count)", label: "memories", color: WhimsicalTheme.deepPeach)
                    MiniStat(value: "\(dataService.pets.filter(\.isOwned).count)", label: "lil friends", color: WhimsicalTheme.deepSage)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 14)
            .padding(.bottom, 18)
            .background {
                NotecardBackground()
            }
        }
        .rotationEffect(.degrees(-1.2))
        .padding(.horizontal, 4)
    }

    private var stepRingMini: some View {
        let progress = dataService.stats.dailyStepGoal > 0
            ? min(1.0, Double(healthService.todaySteps) / Double(dataService.stats.dailyStepGoal))
            : 0.0

        return ZStack {
            Circle()
                .stroke(WhimsicalTheme.blushPink.opacity(0.3), lineWidth: 6)
                .frame(width: 64, height: 64)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(
                    LinearGradient(
                        colors: [WhimsicalTheme.ringPink, WhimsicalTheme.deepRose],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .frame(width: 64, height: 64)
                .rotationEffect(.degrees(-90))
            Image(systemName: "figure.walk")
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(WhimsicalTheme.deepRose)
        }
    }

    private var journeyToggle: some View {
        Button {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showJourney.toggle()
            }
        } label: {
            HStack {
                Image(systemName: "point.bottomleft.forward.to.point.topright.scurvepath.fill")
                    .foregroundStyle(WhimsicalTheme.deepLavender)
                Text("Journey Timeline")
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(.primary)
                Spacer()

                let ownedCount = dataService.pets.filter(\.isOwned).count
                if ownedCount > 0 {
                    HStack(spacing: -8) {
                        ForEach(Array(dataService.pets.filter(\.isOwned).prefix(3).enumerated()), id: \.element.id) { index, pet in
                            if let pos = PetSpritePosition(rawValue: pet.spriteIndex) {
                                PetSpriteView(position: pos, size: 24)
                                    .background(Circle().fill(.white).frame(width: 28, height: 28))
                                    .zIndex(Double(3 - index))
                            }
                        }
                    }
                }

                Image(systemName: showJourney ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(WhimsicalTheme.cardBackground, in: .rect(cornerRadius: 20))
        }
        .buttonStyle(.plain)
        .sensoryFeedback(.selection, trigger: showJourney)
    }

    @AppStorage("isDarkMode") private var isDarkMode: Bool = false

    private var darkModeToggle: some View {
        HStack {
            Image(systemName: isDarkMode ? "moon.stars.fill" : "sun.max.fill")
                .foregroundStyle(WhimsicalTheme.deepLavender)
                .contentTransition(.symbolEffect(.replace))
            Text("Dark Mode")
                .font(.system(.headline, design: .serif))
                .foregroundStyle(.primary)
            Spacer()
            WhimsicalDarkModeSwitch(isOn: $isDarkMode)
        }
        .padding(16)
        .background(WhimsicalTheme.cardBackground, in: .rect(cornerRadius: 20))
        .sensoryFeedback(.selection, trigger: isDarkMode)
    }

    private var streakSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "flame.fill")
                    .foregroundStyle(WhimsicalTheme.deepRose)
                Text("Streak Calendar")
                    .font(.system(.headline, design: .serif))
                Spacer()
                Text("\(dataService.stats.currentStreak) day streak")
                    .font(.system(.subheadline, design: .serif))
                    .foregroundStyle(WhimsicalTheme.deepRose)
            }

            ProfileStreakCalendar(streakDates: dataService.stats.streakDates)
        }
        .padding(16)
        .background(WhimsicalTheme.cardBackground, in: .rect(cornerRadius: 20))
    }

    private var goalSection: some View {
        Button {
            showGoalPicker = true
        } label: {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Daily Step Goal")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(.secondary)
                    Text("\(dataService.stats.dailyStepGoal.formatted()) steps")
                        .font(.system(.title3, design: .serif, weight: .bold))
                        .foregroundStyle(.primary)
                }
                Spacer()
                Image(systemName: "chevron.right")
                    .font(.subheadline)
                    .foregroundStyle(.tertiary)
            }
            .padding(16)
            .background(WhimsicalTheme.cardBackground, in: .rect(cornerRadius: 20))
        }
        .buttonStyle(.plain)
    }

    private var flowerDivider: some View {
        HStack(spacing: 8) {
            flowerLine
            DoodleFlowerIcon(size: 20, color: WhimsicalTheme.deepRose.opacity(0.35))
            DoodleFlowerIcon(size: 14, color: WhimsicalTheme.lavender.opacity(0.35))
            DoodleFlowerIcon(size: 20, color: WhimsicalTheme.deepRose.opacity(0.35))
            flowerLine
        }
        .padding(.vertical, 4)
    }

    private var flowerLine: some View {
        Rectangle()
            .fill(WhimsicalTheme.blushPink.opacity(0.3))
            .frame(height: 1)
    }
}

struct MiniStat: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.custom(FontRegistration.keshia, size: 26))
                .foregroundStyle(color)
                .shadow(color: color.opacity(0.35), radius: 0, x: 1, y: 1.5)
                .shadow(color: .black.opacity(0.06), radius: 3, x: 0, y: 2)
            Text(label)
                .font(.custom(FontRegistration.keshia, size: 11))
                .foregroundStyle(color.opacity(0.7))
                .shadow(color: color.opacity(0.15), radius: 0, x: 0.5, y: 0.5)
                .multilineTextAlignment(.center)
                .lineLimit(1)
                .minimumScaleFactor(0.8)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 6)
    }
}

struct NotecardBackground: View {
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(red: 0.99, green: 0.97, blue: 0.93))

            RoundedRectangle(cornerRadius: 4)
                .fill(
                    LinearGradient(
                        colors: [
                            Color.white.opacity(0.5),
                            Color.clear,
                            Color.brown.opacity(0.03)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )

            VStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { _ in
                    Spacer()
                    Rectangle()
                        .fill(WhimsicalTheme.blushPink.opacity(0.18))
                        .frame(height: 0.5)
                }
                Spacer()
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 12)

            Rectangle()
                .fill(WhimsicalTheme.deepRose.opacity(0.12))
                .frame(width: 0.8)
                .frame(maxHeight: .infinity)
                .padding(.leading, 38)
                .frame(maxWidth: .infinity, alignment: .leading)

            RoundedRectangle(cornerRadius: 4)
                .stroke(Color.brown.opacity(0.08), lineWidth: 1)
        }
        .shadow(color: .black.opacity(0.06), radius: 8, x: 2, y: 4)
        .shadow(color: .brown.opacity(0.04), radius: 2, x: 1, y: 1)
    }
}

struct NotecardTapeStrip: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(
                LinearGradient(
                    colors: [
                        WhimsicalTheme.blushPink.opacity(0.35),
                        WhimsicalTheme.blushPink.opacity(0.2)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 64, height: 14)
            .overlay {
                RoundedRectangle(cornerRadius: 2)
                    .stroke(WhimsicalTheme.blushPink.opacity(0.15), lineWidth: 0.5)
            }
            .rotationEffect(.degrees(2.5))
    }
}

struct NotecardDivider: View {
    var body: some View {
        HStack(spacing: 6) {
            ForEach(0..<30, id: \.self) { _ in
                Circle()
                    .fill(WhimsicalTheme.deepRose.opacity(0.15))
                    .frame(width: 2, height: 2)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

struct ProfileStreakCalendar: View {
    let streakDates: [Date]

    private let calendar = Calendar.current
    private let columns = Array(repeating: GridItem(.flexible(), spacing: 4), count: 7)

    private var last28Days: [Date] {
        (0..<28).compactMap { offset in
            calendar.date(byAdding: .day, value: -offset, to: Date())
        }.reversed()
    }

    var body: some View {
        LazyVGrid(columns: columns, spacing: 4) {
            ForEach(last28Days, id: \.self) { date in
                let isActive = streakDates.contains { calendar.isDate($0, inSameDayAs: date) }
                let isToday = calendar.isDateInToday(date)

                ZStack {
                    if isActive {
                        DoodleFlowerIcon(size: 24, color: WhimsicalTheme.deepRose)
                    } else {
                        Circle()
                            .fill(WhimsicalTheme.blushPink.opacity(0.2))
                            .frame(width: 24, height: 24)
                    }

                    if isToday {
                        Circle()
                            .stroke(WhimsicalTheme.deepRose, lineWidth: 2)
                            .frame(width: 28, height: 28)
                    }
                }
                .frame(width: 28, height: 28)
            }
        }
    }
}

struct GoalPickerSheet: View {
    @Binding var goal: Double
    let onSave: () -> Void

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Text("\(Int(goal).formatted())")
                    .font(.system(.largeTitle, design: .serif, weight: .bold))
                    .foregroundStyle(WhimsicalTheme.deepRose)

                Text("steps per day")
                    .font(.system(.subheadline, design: .serif))
                    .foregroundStyle(.secondary)

                Slider(value: $goal, in: 1000...30000, step: 500)
                    .tint(WhimsicalTheme.deepRose)
                    .padding(.horizontal)

                HStack {
                    Text("1,000")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                    Spacer()
                    Text("30,000")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal)

                Spacer()
            }
            .padding(.top, 32)
            .navigationTitle("Step Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { onSave() }
                        .fontWeight(.semibold)
                }
            }
        }
    }
}
