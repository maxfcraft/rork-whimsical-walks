import SwiftUI
import StoreKit

struct OnboardingView: View {
    let store: StoreViewModel
    let onComplete: () -> Void
    @State private var currentPage: Int = 0
    @State private var onboardingPhoto: UIImage?
    @State private var onboardingPhotoPath: String?

    private let totalPages: Int = 8

    var body: some View {
        ZStack {
            OnboardingBackground(page: currentPage)

            Group {
                switch currentPage {
                case 0:
                    HookScreen(onContinue: { advance() })
                case 1:
                    IdentityShiftScreen(onContinue: { advance() })
                case 2:
                    FeaturePreviewScreen(onContinue: { advance() })
                case 3:
                    OnboardingPersonalizationScreen(onContinue: { advance() })
                case 4:
                    LiveQuestScreen(onPhotoTaken: { image in
                        onboardingPhoto = image
                        if let path = PhotoManager.savePhoto(image) {
                            onboardingPhotoPath = path
                        }
                        advance()
                    })
                case 5:
                    ReinforcementScreen(
                        capturedImage: onboardingPhoto,
                        onContinue: { advance() }
                    )
                case 6:
                    OnboardingReviewScreen(onContinue: { advance() })
                case 7:
                    OnboardingPaywallScreen(store: store, onComplete: onComplete)
                default:
                    EmptyView()
                }
            }
            .transition(.asymmetric(
                insertion: .move(edge: .trailing).combined(with: .opacity),
                removal: .move(edge: .leading).combined(with: .opacity)
            ))

            if currentPage < 7 && currentPage != 4 {
                VStack {
                    Spacer()
                    pageIndicator
                        .padding(.bottom, 24)
                }
            }
        }
        .ignoresSafeArea()
        .sensoryFeedback(.selection, trigger: currentPage)
    }

    private func advance() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.85)) {
            currentPage += 1
        }
    }

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<totalPages, id: \.self) { i in
                Capsule()
                    .fill(i == currentPage ? Color.white : Color.white.opacity(0.3))
                    .frame(width: i == currentPage ? 20 : 6, height: 6)
                    .animation(.spring(response: 0.35), value: currentPage)
            }
        }
    }
}

struct OnboardingBackground: View {
    let page: Int

    var body: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.5, 0.5], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1]
            ],
            colors: gradientColors
        )
        .ignoresSafeArea()
        .overlay {
            OnboardingSparkleOverlay()
        }
        .animation(.easeInOut(duration: 0.8), value: page)
    }

    private var gradientColors: [Color] {
        switch page {
        case 0:
            return [
                Color(red: 0.15, green: 0.10, blue: 0.22),
                Color(red: 0.22, green: 0.12, blue: 0.28),
                Color(red: 0.18, green: 0.10, blue: 0.25),
                Color(red: 0.25, green: 0.14, blue: 0.30),
                Color(red: 0.20, green: 0.12, blue: 0.26),
                Color(red: 0.22, green: 0.10, blue: 0.28),
                Color(red: 0.18, green: 0.08, blue: 0.24),
                Color(red: 0.24, green: 0.12, blue: 0.30),
                Color(red: 0.16, green: 0.10, blue: 0.22)
            ]
        case 1:
            return [
                Color(red: 0.20, green: 0.12, blue: 0.28),
                WhimsicalTheme.deepLavender.opacity(0.6),
                Color(red: 0.25, green: 0.15, blue: 0.32),
                WhimsicalTheme.deepRose.opacity(0.4),
                Color(red: 0.22, green: 0.14, blue: 0.30),
                WhimsicalTheme.deepLavender.opacity(0.5),
                Color(red: 0.18, green: 0.10, blue: 0.26),
                WhimsicalTheme.deepRose.opacity(0.35),
                Color(red: 0.24, green: 0.14, blue: 0.32)
            ]
        case 2:
            return [
                WhimsicalTheme.deepRose.opacity(0.85),
                WhimsicalTheme.deepLavender.opacity(0.75),
                WhimsicalTheme.deepRose.opacity(0.6),
                WhimsicalTheme.deepSage.opacity(0.5),
                WhimsicalTheme.deepRose.opacity(0.7),
                WhimsicalTheme.deepLavender.opacity(0.8),
                WhimsicalTheme.blushPink.opacity(0.7),
                WhimsicalTheme.deepRose.opacity(0.65),
                WhimsicalTheme.deepLavender.opacity(0.9)
            ]
        case 3:
            return [
                WhimsicalTheme.deepLavender.opacity(0.8),
                WhimsicalTheme.deepRose.opacity(0.6),
                WhimsicalTheme.lavender.opacity(0.9),
                WhimsicalTheme.deepRose.opacity(0.5),
                WhimsicalTheme.deepLavender.opacity(0.9),
                WhimsicalTheme.blushPink.opacity(0.7),
                WhimsicalTheme.deepRose.opacity(0.7),
                WhimsicalTheme.lavender.opacity(0.8),
                WhimsicalTheme.deepLavender.opacity(0.6)
            ]
        case 4:
            return [
                WhimsicalTheme.deepRose.opacity(0.9),
                WhimsicalTheme.deepLavender.opacity(0.7),
                WhimsicalTheme.deepRose.opacity(0.8),
                WhimsicalTheme.lavender.opacity(0.6),
                WhimsicalTheme.deepRose,
                WhimsicalTheme.deepLavender.opacity(0.8),
                WhimsicalTheme.blushPink.opacity(0.5),
                WhimsicalTheme.deepRose.opacity(0.85),
                WhimsicalTheme.deepLavender.opacity(0.7)
            ]
        case 5:
            return [
                WhimsicalTheme.deepSage.opacity(0.7),
                WhimsicalTheme.deepLavender.opacity(0.6),
                WhimsicalTheme.deepRose.opacity(0.5),
                WhimsicalTheme.deepSage.opacity(0.5),
                WhimsicalTheme.deepLavender.opacity(0.7),
                WhimsicalTheme.deepRose.opacity(0.6),
                WhimsicalTheme.sageGreen.opacity(0.5),
                WhimsicalTheme.deepSage.opacity(0.6),
                WhimsicalTheme.deepLavender.opacity(0.5)
            ]
        case 6:
            return [
                WhimsicalTheme.warmPeach.opacity(0.7),
                WhimsicalTheme.deepRose.opacity(0.8),
                WhimsicalTheme.deepLavender.opacity(0.6),
                WhimsicalTheme.deepRose.opacity(0.6),
                WhimsicalTheme.warmPeach.opacity(0.8),
                WhimsicalTheme.deepRose.opacity(0.7),
                WhimsicalTheme.deepLavender.opacity(0.7),
                WhimsicalTheme.blushPink.opacity(0.8),
                WhimsicalTheme.deepRose.opacity(0.6)
            ]
        default:
            return [
                WhimsicalTheme.deepRose.opacity(0.8),
                WhimsicalTheme.deepLavender.opacity(0.7),
                WhimsicalTheme.blushPink.opacity(0.5),
                WhimsicalTheme.lavender.opacity(0.6),
                WhimsicalTheme.deepRose.opacity(0.7),
                WhimsicalTheme.warmPeach.opacity(0.5),
                WhimsicalTheme.deepLavender.opacity(0.6),
                WhimsicalTheme.blushPink.opacity(0.8),
                WhimsicalTheme.deepRose.opacity(0.6)
            ]
        }
    }
}

struct OnboardingSparkleOverlay: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.04)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                for i in 0..<18 {
                    let seed = Double(i) * 137.508
                    let x = (sin(seed + time * 0.4) * 0.4 + 0.5) * size.width
                    let y = (cos(seed * 0.7 + time * 0.3) * 0.4 + 0.5) * size.height
                    let pulse = sin(time * 2.0 + seed) * 0.5 + 0.5
                    let sparkSize = 2.0 + pulse * 4.0
                    let rect = CGRect(x: x - sparkSize / 2, y: y - sparkSize / 2, width: sparkSize, height: sparkSize)
                    context.opacity = pulse * 0.5
                    context.fill(Path(ellipseIn: rect), with: .color(.white))
                    if pulse > 0.75 {
                        let crossSize = sparkSize * 1.2
                        var cross = Path()
                        cross.move(to: CGPoint(x: x - crossSize, y: y))
                        cross.addLine(to: CGPoint(x: x + crossSize, y: y))
                        cross.move(to: CGPoint(x: x, y: y - crossSize))
                        cross.addLine(to: CGPoint(x: x, y: y + crossSize))
                        context.opacity = (pulse - 0.75) * 3.0
                        context.stroke(cross, with: .color(.white.opacity(0.4)), lineWidth: 0.5)
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}
