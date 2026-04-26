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
    var customImage: UIImage? = nil

    var body: some View {
        Group {
            if let customImage {
                Image(uiImage: customImage)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
            } else {
                Image(screen.backgroundImageName)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .ignoresSafeArea()
                    .opacity(0.3)
                    .overlay {
                        WhimsicalTheme.pageOverlay
                            .ignoresSafeArea()
                    }
            }
        }
    }
}
