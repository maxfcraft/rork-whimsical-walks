import Foundation

nonisolated enum WalkerRank: Int, Codable, CaseIterable, Sendable {
    case daydreamWalker = 0
    case petalStroller = 1
    case meadowWanderer = 2
    case starlitExplorer = 3
    case moonlitRambler = 4
    case enchantedTrailblazer = 5
    case celestialVoyager = 6

    var title: String {
        switch self {
        case .daydreamWalker: "Daydream Walker"
        case .petalStroller: "Petal Stroller"
        case .meadowWanderer: "Meadow Wanderer"
        case .starlitExplorer: "Starlit Explorer"
        case .moonlitRambler: "Moonlit Rambler"
        case .enchantedTrailblazer: "Enchanted Trailblazer"
        case .celestialVoyager: "Celestial Voyager"
        }
    }

    var icon: String {
        switch self {
        case .daydreamWalker: "cloud.fill"
        case .petalStroller: "leaf.fill"
        case .meadowWanderer: "wind"
        case .starlitExplorer: "star.fill"
        case .moonlitRambler: "moon.fill"
        case .enchantedTrailblazer: "sparkles"
        case .celestialVoyager: "sun.max.fill"
        }
    }

    var stepsRequired: Int {
        switch self {
        case .daydreamWalker: 0
        case .petalStroller: 10_000
        case .meadowWanderer: 50_000
        case .starlitExplorer: 150_000
        case .moonlitRambler: 400_000
        case .enchantedTrailblazer: 750_000
        case .celestialVoyager: 1_000_000
        }
    }

    var next: WalkerRank? {
        WalkerRank(rawValue: rawValue + 1)
    }

    static func rank(for totalSteps: Int) -> WalkerRank {
        var current: WalkerRank = .daydreamWalker
        for rank in WalkerRank.allCases {
            if totalSteps >= rank.stepsRequired {
                current = rank
            } else {
                break
            }
        }
        return current
    }
}
