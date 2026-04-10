import Foundation

nonisolated struct Pet: Identifiable, Codable, Sendable {
    let id: UUID
    let name: String
    let icon: String
    let spriteIndex: Int
    let stepsToUnlock: Int
    let description: String
    let starRating: Int
    var isOwned: Bool
    var isActive: Bool

    init(id: UUID = UUID(), name: String, icon: String, spriteIndex: Int, stepsToUnlock: Int, description: String, starRating: Int = 1, isOwned: Bool = false, isActive: Bool = false) {
        self.id = id
        self.name = name
        self.icon = icon
        self.spriteIndex = spriteIndex
        self.stepsToUnlock = stepsToUnlock
        self.description = description
        self.starRating = starRating
        self.isOwned = isOwned
        self.isActive = isActive
    }
}

extension Pet {
    static let allPets: [Pet] = [
        Pet(name: "Kiki", icon: "leaf.fill", spriteIndex: 0, stepsToUnlock: 0, description: "A cuddly koala who naps between walks", starRating: 1, isOwned: true, isActive: true),
        Pet(name: "Leo", icon: "sun.max.fill", spriteIndex: 1, stepsToUnlock: 30_000, description: "A brave little lion who leads the way", starRating: 2),
        Pet(name: "Freddie", icon: "drop.fill", spriteIndex: 2, stepsToUnlock: 75_000, description: "A jolly frog who loves puddle hopping", starRating: 2),
        Pet(name: "Poppy", icon: "heart.fill", spriteIndex: 3, stepsToUnlock: 150_000, description: "A rosy pig who sniffs out flowers", starRating: 3),
        Pet(name: "Clover", icon: "sparkle", spriteIndex: 4, stepsToUnlock: 250_000, description: "A curious cat who finds hidden paths", starRating: 3),
        Pet(name: "Rosie", icon: "carrot.fill", spriteIndex: 5, stepsToUnlock: 400_000, description: "A sweet bunny who carries tiny carrots", starRating: 4),
        Pet(name: "Bamboo", icon: "leaf.fill", spriteIndex: 6, stepsToUnlock: 600_000, description: "A gentle panda who munches bamboo on strolls", starRating: 4),
        Pet(name: "Pippin", icon: "snowflake", spriteIndex: 7, stepsToUnlock: 850_000, description: "A dapper penguin who waddles with style", starRating: 5),
        Pet(name: "Honey", icon: "star.fill", spriteIndex: 8, stepsToUnlock: 1_000_000, description: "A golden bear who finds the sweetest spots", starRating: 5),
    ]
}
