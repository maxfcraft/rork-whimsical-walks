import Foundation

@Observable
@MainActor
class DataService {
    var stats: UserStats
    var quests: [Quest]
    var polaroids: [Polaroid]
    var pets: [Pet]

    private let statsKey = "whimsical_stats"
    private let questsKey = "whimsical_quests"
    private let polaroidsKey = "whimsical_polaroids"
    private let petsKey = "whimsical_pets"
    private let lastQuestDateKey = "whimsical_last_quest_date"

    init() {
        stats = UserStats()
        quests = []
        polaroids = []
        pets = Pet.allPets
        loadAll()
        checkAndRefreshQuests()
    }

    private func loadAll() {
        if let data = UserDefaults.standard.data(forKey: statsKey),
           let decoded = try? JSONDecoder().decode(UserStats.self, from: data) {
            stats = decoded
        }
        if let data = UserDefaults.standard.data(forKey: questsKey),
           let decoded = try? JSONDecoder().decode([Quest].self, from: data) {
            quests = decoded
        }
        if let data = UserDefaults.standard.data(forKey: polaroidsKey),
           let decoded = try? JSONDecoder().decode([Polaroid].self, from: data) {
            polaroids = decoded
        }
        if let data = UserDefaults.standard.data(forKey: petsKey),
           let decoded = try? JSONDecoder().decode([Pet].self, from: data) {
            let canonical = Pet.allPets
            pets = canonical.map { defaultPet in
                if let saved = decoded.first(where: { $0.spriteIndex == defaultPet.spriteIndex }) {
                    var p = defaultPet
                    p.isOwned = saved.isOwned
                    p.isActive = saved.isActive
                    return p
                }
                return defaultPet
            }
        }
    }

    func save() {
        if let data = try? JSONEncoder().encode(stats) {
            UserDefaults.standard.set(data, forKey: statsKey)
        }
        if let data = try? JSONEncoder().encode(quests) {
            UserDefaults.standard.set(data, forKey: questsKey)
        }
        if let data = try? JSONEncoder().encode(polaroids) {
            UserDefaults.standard.set(data, forKey: polaroidsKey)
        }
        if let data = try? JSONEncoder().encode(pets) {
            UserDefaults.standard.set(data, forKey: petsKey)
        }
    }

    func updateStreak(using healthService: HealthKitService) async {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        guard let lastActive = stats.lastActiveDate else {
            stats.lastActiveDate = today
            save()
            return
        }

        let lastDay = calendar.startOfDay(for: lastActive)
        let dayDiff = calendar.dateComponents([.day], from: lastDay, to: today).day ?? 0

        guard dayDiff >= 1 else { return }

        if dayDiff == 1 {
            let yesterdaySteps = await healthService.fetchSteps(for: lastDay)
            if yesterdaySteps >= stats.dailyStepGoal {
                stats.currentStreak += 1
                if !stats.streakDates.contains(where: { calendar.isDate($0, inSameDayAs: lastDay) }) {
                    stats.streakDates.append(lastDay)
                }
            } else {
                stats.currentStreak = 0
            }
        } else {
            var missedGoal = false
            let daysToCheck = min(dayDiff, 30)
            for offset in 1...daysToCheck {
                guard let checkDate = calendar.date(byAdding: .day, value: -offset, to: today) else { continue }
                let stepsOnDay = await healthService.fetchSteps(for: checkDate)
                if stepsOnDay < stats.dailyStepGoal {
                    missedGoal = true
                    break
                } else {
                    if !stats.streakDates.contains(where: { calendar.isDate($0, inSameDayAs: checkDate) }) {
                        stats.streakDates.append(checkDate)
                    }
                }
            }
            if missedGoal {
                stats.currentStreak = 0
            } else {
                stats.currentStreak += daysToCheck
            }
        }

        stats.lastActiveDate = today
        if stats.currentStreak > stats.longestStreak {
            stats.longestStreak = stats.currentStreak
        }

        save()
    }

    func markTodayGoalMet() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        if stats.currentStreak == 0 {
            stats.currentStreak = 1
        }
        if !stats.streakDates.contains(where: { calendar.isDate($0, inSameDayAs: today) }) {
            stats.streakDates.append(today)
        }
        stats.lastActiveDate = today
        if stats.currentStreak > stats.longestStreak {
            stats.longestStreak = stats.currentStreak
        }
        save()
    }

    private func checkAndRefreshQuests() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastDateData = UserDefaults.standard.object(forKey: lastQuestDateKey) as? Date {
            let lastDate = calendar.startOfDay(for: lastDateData)
            if calendar.isDate(lastDate, inSameDayAs: today) {
                return
            }
        }

        quests = Self.generateDailyQuests()
        UserDefaults.standard.set(Date(), forKey: lastQuestDateKey)
        save()
    }

    func completeQuestWithPhoto(_ quest: Quest, imagePath: String, currentSteps: Int) {
        guard let index = quests.firstIndex(where: { $0.id == quest.id }) else { return }
        quests[index].isCompleted = true
        quests[index].polaroidImagePath = imagePath
        stats.questsCompleted += 1

        let stepsToReveal: Int
        switch quest.difficulty {
        case .easy: stepsToReveal = 3000
        case .medium: stepsToReveal = 5000
        case .adventurous: stepsToReveal = 8000
        }

        let polaroid = Polaroid(
            imagePath: imagePath,
            questTitle: quest.title,
            stepsRequired: currentSteps + stepsToReveal,
            stepsAtCapture: currentSteps,
            difficulty: quest.difficulty
        )
        polaroids.insert(polaroid, at: 0)
        save()
    }

    func revealPolaroid(_ polaroid: Polaroid) {
        guard let index = polaroids.firstIndex(where: { $0.id == polaroid.id }) else { return }
        polaroids[index].isRevealed = true
        save()
    }

    func addPolaroid(imagePath: String, difficulty: QuestDifficulty, currentSteps: Int) {
        let stepsRequired = currentSteps + (difficulty == .easy ? 3000 : difficulty == .medium ? 5000 : 8000)
        let polaroid = Polaroid(
            imagePath: imagePath,
            stepsRequired: stepsRequired,
            stepsAtCapture: currentSteps,
            difficulty: difficulty
        )
        polaroids.insert(polaroid, at: 0)
        save()
    }

    func checkAndUnlockPets() {
        let totalSteps = stats.totalStepsAllTime
        for i in pets.indices {
            if !pets[i].isOwned && totalSteps >= pets[i].stepsToUnlock {
                pets[i].isOwned = true
                let alreadyRecorded = stats.petUnlockHistory.contains { $0.petSpriteIndex == pets[i].spriteIndex }
                if !alreadyRecorded {
                    let record = PetUnlockRecord(
                        petName: pets[i].name,
                        petSpriteIndex: pets[i].spriteIndex,
                        dateUnlocked: .now,
                        stepsAtUnlock: totalSteps
                    )
                    stats.petUnlockHistory.append(record)
                }
            }
        }
        save()
    }

    func unlockPetInstantly(_ pet: Pet) {
        guard let index = pets.firstIndex(where: { $0.id == pet.id }) else { return }
        pets[index].isOwned = true
        let alreadyRecorded = stats.petUnlockHistory.contains { $0.petSpriteIndex == pet.spriteIndex }
        if !alreadyRecorded {
            let record = PetUnlockRecord(
                petName: pet.name,
                petSpriteIndex: pet.spriteIndex,
                dateUnlocked: .now,
                stepsAtUnlock: stats.totalStepsAllTime
            )
            stats.petUnlockHistory.append(record)
        }
        save()
    }

    func setActivePet(_ pet: Pet) {
        for i in pets.indices {
            pets[i].isActive = (pets[i].id == pet.id)
        }
        save()
    }

    var activePet: Pet? {
        pets.first(where: { $0.isActive })
    }

    func updateTotalSteps(_ todaySteps: Int) {
        guard todaySteps > 0 else { return }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())

        if let lastDate = stats.lastRecordedDate, !calendar.isDate(lastDate, inSameDayAs: today) {
            stats.lastRecordedDailySteps = 0
        }

        let delta = max(0, todaySteps - stats.lastRecordedDailySteps)
        stats.totalStepsAllTime += delta
        stats.lastRecordedDailySteps = todaySteps
        stats.lastRecordedDate = today
        checkAndUnlockPets()
        save()
    }

    func updateDailyGoal(_ goal: Int) {
        stats.dailyStepGoal = goal
        save()
    }

    var nextPetToUnlock: Pet? {
        pets.first(where: { !$0.isOwned })
    }

    var currentRank: WalkerRank {
        WalkerRank.rank(for: stats.totalStepsAllTime)
    }

    var nextRank: WalkerRank? {
        currentRank.next
    }

    var daysWalking: Int {
        max(1, Calendar.current.dateComponents([.day], from: stats.joinDate, to: .now).day ?? 1)
    }

    static func generateDailyQuests() -> [Quest] {
        let easyQuests = [
            ("Find Something Pink", "Spot something pink on your walk and take a mental snapshot"),
            ("Cloud Gazing", "Look up and find a cloud that looks like an animal"),
            ("Flower Finder", "Find and admire a flower you've never noticed before"),
            ("Puddle Mirror", "Find a puddle and look at your reflection"),
            ("Leaf Collection", "Pick up one beautiful fallen leaf"),
            ("Sunny Spot", "Find the sunniest spot on your route and pause there"),
        ]

        let mediumQuests = [
            ("New Path Explorer", "Take a street or path you've never walked before"),
            ("Photograph a Door", "Find the most interesting door on your walk and photograph it"),
            ("Nature Sound Bath", "Stop for 2 minutes and just listen to nature sounds"),
            ("Color Hunt", "Find something in every rainbow color on your walk"),
            ("Secret Garden", "Find a hidden garden, courtyard, or green space"),
            ("Window Shopping", "Find the most whimsical shop window display"),
        ]

        let adventurousQuests = [
            ("Sunrise/Sunset Chase", "Walk somewhere with a beautiful view of the sky"),
            ("1000 Extra Steps", "Walk 1,000 steps more than your usual route today"),
            ("Picnic Spot Scout", "Find the perfect picnic spot and mark it mentally"),
            ("Bridge Crossing", "Find and cross a bridge you haven't walked across"),
            ("Hilltop View", "Walk to the highest point near you for a panoramic view"),
            ("Wildlife Spotter", "Spot and identify 3 different types of birds or animals"),
        ]

        var dailyQuests: [Quest] = []

        if let q = easyQuests.randomElement() {
            dailyQuests.append(Quest(title: q.0, description: q.1, difficulty: .easy))
        }
        if let q = mediumQuests.randomElement() {
            dailyQuests.append(Quest(title: q.0, description: q.1, difficulty: .medium))
        }
        if let q = adventurousQuests.randomElement() {
            dailyQuests.append(Quest(title: q.0, description: q.1, difficulty: .adventurous))
        }

        return dailyQuests
    }
}
