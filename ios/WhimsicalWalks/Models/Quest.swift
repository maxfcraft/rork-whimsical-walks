import Foundation

nonisolated enum QuestDifficulty: String, Codable, CaseIterable, Sendable {
    case easy
    case medium
    case adventurous

    var label: String {
        switch self {
        case .easy: "Easy"
        case .medium: "Medium"
        case .adventurous: "Adventurous"
        }
    }

    var coinReward: Int {
        switch self {
        case .easy: 10
        case .medium: 25
        case .adventurous: 50
        }
    }

    var emoji: String {
        switch self {
        case .easy: "easy"
        case .medium: "medium"
        case .adventurous: "adventurous"
        }
    }
}

nonisolated struct Quest: Identifiable, Codable, Sendable {
    let id: UUID
    let title: String
    let description: String
    let difficulty: QuestDifficulty
    var isCompleted: Bool
    var polaroidImagePath: String?
    let dateAssigned: Date

    init(id: UUID = UUID(), title: String, description: String, difficulty: QuestDifficulty, isCompleted: Bool = false, polaroidImagePath: String? = nil, dateAssigned: Date = .now) {
        self.id = id
        self.title = title
        self.description = description
        self.difficulty = difficulty
        self.isCompleted = isCompleted
        self.polaroidImagePath = polaroidImagePath
        self.dateAssigned = dateAssigned
    }
}
