import SwiftUI

enum WhimsicalTheme {
    static let blushPink = Color(red: 0.96, green: 0.80, blue: 0.82)
    static let deepRose = Color(red: 0.88, green: 0.56, blue: 0.62)
    static let lavender = Color(red: 0.82, green: 0.76, blue: 0.92)
    static let deepLavender = Color(red: 0.65, green: 0.55, blue: 0.85)
    static let sageGreen = Color(red: 0.76, green: 0.87, blue: 0.78)
    static let deepSage = Color(red: 0.55, green: 0.75, blue: 0.58)
    static let warmPeach = Color(red: 0.98, green: 0.87, blue: 0.75)
    static let deepPeach = Color(red: 0.92, green: 0.72, blue: 0.55)
    static let cream = Color(red: 0.99, green: 0.97, blue: 0.94)
    static let softWhite = Color(red: 1.0, green: 0.99, blue: 0.97)

    static let cardBackground = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.18, green: 0.14, blue: 0.18, alpha: 0.85)
            : UIColor(white: 1.0, alpha: 0.7)
    })

    static let cardBackgroundSolid = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.20, green: 0.16, blue: 0.20, alpha: 1.0)
            : UIColor(red: 0.99, green: 0.97, blue: 0.94, alpha: 1.0)
    })

    static let pageOverlay = Color(uiColor: UIColor { trait in
        trait.userInterfaceStyle == .dark
            ? UIColor(red: 0.10, green: 0.07, blue: 0.11, alpha: 0.78)
            : UIColor(red: 0.99, green: 0.97, blue: 0.94, alpha: 0.55)
    })

    static let ringPink = Color(red: 0.92, green: 0.50, blue: 0.58)
    static let ringPinkLight = Color(red: 0.96, green: 0.78, blue: 0.82)

    static let softPink = Color(red: 0.98, green: 0.88, blue: 0.90)
    static let midPink = Color(red: 0.96, green: 0.78, blue: 0.82)
    static let richPink = Color(red: 0.93, green: 0.68, blue: 0.74)

    static let accentSoftPink = Color(red: 0.90, green: 0.62, blue: 0.68)
    static let accentMidPink = Color(red: 0.85, green: 0.50, blue: 0.58)
    static let accentRichPink = Color(red: 0.78, green: 0.38, blue: 0.48)

    static func difficultyColor(_ difficulty: QuestDifficulty) -> Color {
        switch difficulty {
        case .easy: softPink
        case .medium: midPink
        case .adventurous: richPink
        }
    }

    static func difficultyAccent(_ difficulty: QuestDifficulty) -> Color {
        switch difficulty {
        case .easy: accentSoftPink
        case .medium: accentMidPink
        case .adventurous: accentRichPink
        }
    }
}
