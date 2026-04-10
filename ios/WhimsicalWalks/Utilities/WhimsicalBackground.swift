import SwiftUI

enum WhimsicalScreen {
    case home
    case quests
    case polaroids
    case pets
    case profile

    var backgroundImageName: String {
        switch self {
        case .home: "bg_home_sparkles"
        case .quests: "bg_quests_spirals"
        case .polaroids: "bg_polaroids_bubbles"
        case .pets: "bg_pets_butterflies"
        case .profile: "bg_profile_mixed"
        }
    }
}

struct WhimsicalBackground: View {
    let screen: WhimsicalScreen

    var body: some View {
        Image(screen.backgroundImageName)
            .resizable()
            .aspectRatio(contentMode: .fill)
            .ignoresSafeArea()
            .opacity(0.3)
            .overlay {
                WhimsicalTheme.cream.opacity(0.55)
                    .ignoresSafeArea()
            }
    }
}
