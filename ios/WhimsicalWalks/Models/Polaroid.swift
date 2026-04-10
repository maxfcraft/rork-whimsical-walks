import Foundation

nonisolated struct Polaroid: Identifiable, Codable, Sendable {
    let id: UUID
    let imagePath: String
    let dateTaken: Date
    let questTitle: String
    let stepsRequired: Int
    var stepsAtCapture: Int
    let difficulty: QuestDifficulty
    var isRevealed: Bool

    init(id: UUID = UUID(), imagePath: String, dateTaken: Date = .now, questTitle: String = "", stepsRequired: Int = 5000, stepsAtCapture: Int = 0, difficulty: QuestDifficulty = .easy, isRevealed: Bool = false) {
        self.id = id
        self.imagePath = imagePath
        self.dateTaken = dateTaken
        self.questTitle = questTitle
        self.stepsRequired = stepsRequired
        self.stepsAtCapture = stepsAtCapture
        self.difficulty = difficulty
        self.isRevealed = isRevealed
    }

    var blurRadius: CGFloat {
        isRevealed ? 0 : 20.0
    }
}
