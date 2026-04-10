import Foundation

nonisolated struct PetUnlockRecord: Codable, Sendable, Identifiable {
    var id: UUID
    let petName: String
    let petSpriteIndex: Int
    let dateUnlocked: Date
    let stepsAtUnlock: Int

    init(id: UUID = UUID(), petName: String, petSpriteIndex: Int, dateUnlocked: Date = .now, stepsAtUnlock: Int = 0) {
        self.id = id
        self.petName = petName
        self.petSpriteIndex = petSpriteIndex
        self.dateUnlocked = dateUnlocked
        self.stepsAtUnlock = stepsAtUnlock
    }
}

nonisolated struct UserStats: Codable, Sendable {
    var totalStepsAllTime: Int
    var longestStreak: Int
    var currentStreak: Int
    var questsCompleted: Int
    var coins: Int
    var dailyStepGoal: Int
    var lastActiveDate: Date?
    var streakDates: [Date]
    var lastRecordedDailySteps: Int
    var lastRecordedDate: Date?
    var petUnlockHistory: [PetUnlockRecord]
    var joinDate: Date

    init(totalStepsAllTime: Int = 0, longestStreak: Int = 0, currentStreak: Int = 0, questsCompleted: Int = 0, coins: Int = 25, dailyStepGoal: Int = 10000, lastActiveDate: Date? = nil, streakDates: [Date] = [], lastRecordedDailySteps: Int = 0, lastRecordedDate: Date? = nil, petUnlockHistory: [PetUnlockRecord] = [], joinDate: Date = .now) {
        self.totalStepsAllTime = totalStepsAllTime
        self.longestStreak = longestStreak
        self.currentStreak = currentStreak
        self.questsCompleted = questsCompleted
        self.coins = coins
        self.dailyStepGoal = dailyStepGoal
        self.lastActiveDate = lastActiveDate
        self.streakDates = streakDates
        self.lastRecordedDailySteps = lastRecordedDailySteps
        self.lastRecordedDate = lastRecordedDate
        self.petUnlockHistory = petUnlockHistory
        self.joinDate = joinDate
    }
}
