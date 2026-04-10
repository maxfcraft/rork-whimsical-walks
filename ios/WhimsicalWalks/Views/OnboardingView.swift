import SwiftUI
import StoreKit

struct OnboardingView: View {
    let store: StoreViewModel
    let onComplete: () -> Void
    @State private var currentPage: Int = 0
    @State private var userName: String = ""
    @State private var selectedGoal: Int = 10000
    @State private var customGoalText: String = ""
    @State private var showCustomGoal: Bool = false
    @State private var reviewRequested: Bool = false
    @State private var autoAdvanceTask: Task<Void, Never>?

    private let totalPages: Int = 6

    var body: some View {
        ZStack {
            OnboardingBackground(page: currentPage)

            TabView(selection: $currentPage) {
                RememberScreen()
                    .tag(0)
                WalkingMedicineScreen()
                    .tag(1)
                FeaturesScreen()
                    .tag(2)
                PersonalizeScreen(
                    userName: $userName,
                    selectedGoal: $selectedGoal,
                    customGoalText: $customGoalText,
                    showCustomGoal: $showCustomGoal,
                    onNext: { advanceTo(4) }
                )
                    .tag(3)
                ReviewScreen(reviewRequested: $reviewRequested)
                    .tag(4)
                OnboardingPaywallScreen(store: store, onComplete: onComplete)
                    .tag(5)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.spring(response: 0.5, dampingFraction: 0.85), value: currentPage)

            if currentPage < 5 {
                VStack {
                    Spacer()
                    pageControls
                        .padding(.bottom, 40)
                }
            }
        }
        .ignoresSafeArea()
        .sensoryFeedback(.selection, trigger: currentPage)
        .onChange(of: currentPage) { oldValue, newValue in
            if newValue == 4 && !reviewRequested {
                requestReviewAndAdvance()
            }
            if newValue == 3 {
                savePersonalization()
            }
        }
    }

    private var pageControls: some View {
        HStack(spacing: 0) {
            if currentPage > 0 && currentPage < 5 {
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

            if currentPage < 3 {
                Button {
                    withAnimation { currentPage += 1 }
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

    private func advanceTo(_ page: Int) {
        savePersonalization()
        withAnimation { currentPage = page }
    }

    private func savePersonalization() {
        if !userName.trimmingCharacters(in: .whitespaces).isEmpty {
            UserDefaults.standard.set(userName.trimmingCharacters(in: .whitespaces), forKey: "whimsical_user_name")
        }
        let goal = showCustomGoal ? (Int(customGoalText) ?? 10000) : selectedGoal
        UserDefaults.standard.set(goal, forKey: "whimsical_step_goal")
    }

    private func requestReviewAndAdvance() {
        reviewRequested = true
        if let scene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene {
            AppStore.requestReview(in: scene)
        }
        autoAdvanceTask?.cancel()
        autoAdvanceTask = Task {
            try? await Task.sleep(for: .seconds(2.5))
            if !Task.isCancelled {
                withAnimation { currentPage = 5 }
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
        case 2:
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
        case 3:
            return [
                WhimsicalTheme.deepRose.opacity(0.8),
                WhimsicalTheme.deepLavender.opacity(0.7),
                WhimsicalTheme.lavender.opacity(0.6),
                WhimsicalTheme.deepRose.opacity(0.7),
                WhimsicalTheme.blushPink.opacity(0.7),
                WhimsicalTheme.deepLavender.opacity(0.8),
                WhimsicalTheme.deepRose.opacity(0.9),
                WhimsicalTheme.lavender.opacity(0.6),
                WhimsicalTheme.deepLavender.opacity(0.7)
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
