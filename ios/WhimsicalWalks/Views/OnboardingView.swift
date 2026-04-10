import SwiftUI
import StoreKit

struct OnboardingView: View {
    let store: StoreViewModel
    let onComplete: () -> Void
    @State private var currentPage: Int = 0

    private let totalPages: Int = 4

    var body: some View {
        ZStack {
            OnboardingBackground(page: currentPage)

            TabView(selection: $currentPage) {
                AdventureIntroScreen()
                    .tag(0)
                QuestDemoScreen()
                    .tag(1)
                WalkingStatsScreen()
                    .tag(2)
                OnboardingPaywallScreen(store: store, onComplete: onComplete)
                    .tag(3)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(response: 0.5, dampingFraction: 0.85), value: currentPage)

            if currentPage < 3 {
                VStack {
                    Spacer()
                    pageControls
                        .padding(.bottom, 40)
                }
            }
        }
        .ignoresSafeArea()
        .sensoryFeedback(.selection, trigger: currentPage)
    }

    private var pageControls: some View {
        HStack(spacing: 0) {
            if currentPage > 0 {
                Button {
                    withAnimation { currentPage -= 1 }
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.8))
                        .frame(width: 44, height: 44)
                }
            } else {
                Spacer().frame(width: 44)
            }

            Spacer()

            HStack(spacing: 8) {
                ForEach(0..<totalPages, id: \.self) { i in
                    Capsule()
                        .fill(i == currentPage ? Color.white : Color.white.opacity(0.35))
                        .frame(width: i == currentPage ? 24 : 8, height: 8)
                        .animation(.spring(response: 0.35), value: currentPage)
                }
            }

            Spacer()

            if currentPage < 2 {
                Button {
                    withAnimation { currentPage += 1 }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.8))
                        .frame(width: 44, height: 44)
                }
            } else if currentPage == 2 {
                Button {
                    withAnimation { currentPage = 3 }
                } label: {
                    Image(systemName: "chevron.right")
                        .font(.body.weight(.semibold))
                        .foregroundStyle(.white.opacity(0.8))
                        .frame(width: 44, height: 44)
                }
            } else {
                Spacer().frame(width: 44)
            }
        }
        .padding(.horizontal, 24)
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
                WhimsicalTheme.deepRose,
                WhimsicalTheme.deepLavender.opacity(0.9),
                WhimsicalTheme.deepRose.opacity(0.8),
                WhimsicalTheme.lavender.opacity(0.7),
                WhimsicalTheme.deepLavender,
                WhimsicalTheme.blushPink.opacity(0.6),
                WhimsicalTheme.deepRose.opacity(0.9),
                WhimsicalTheme.deepLavender.opacity(0.8),
                WhimsicalTheme.lavender.opacity(0.7)
            ]
        case 1:
            return [
                WhimsicalTheme.deepLavender.opacity(0.9),
                WhimsicalTheme.deepRose.opacity(0.8),
                WhimsicalTheme.lavender.opacity(0.7),
                WhimsicalTheme.deepRose.opacity(0.7),
                WhimsicalTheme.deepLavender,
                WhimsicalTheme.deepSage.opacity(0.7),
                WhimsicalTheme.deepRose.opacity(0.9),
                WhimsicalTheme.deepLavender.opacity(0.8),
                WhimsicalTheme.blushPink.opacity(0.6)
            ]
        case 2:
            return [
                WhimsicalTheme.deepSage.opacity(0.9),
                WhimsicalTheme.deepRose.opacity(0.7),
                WhimsicalTheme.deepLavender.opacity(0.8),
                WhimsicalTheme.lavender.opacity(0.6),
                WhimsicalTheme.deepSage,
                WhimsicalTheme.deepRose.opacity(0.8),
                WhimsicalTheme.blushPink.opacity(0.6),
                WhimsicalTheme.deepSage.opacity(0.8),
                WhimsicalTheme.deepRose.opacity(0.9)
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
