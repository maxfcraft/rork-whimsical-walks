import SwiftUI
import StoreKit

struct AdventureIntroScreen: View {
    @State private var titleVisible: Bool = false
    @State private var subtitleVisible: Bool = false
    @State private var iconVisible: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                Image(systemName: "sparkles")
                    .font(.system(size: 52))
                    .foregroundStyle(.white)
                    .symbolEffect(.pulse, options: .repeating)
                    .opacity(iconVisible ? 1 : 0)
                    .scaleEffect(iconVisible ? 1 : 0.5)

                VStack(spacing: 14) {
                    Text("Make Every Day\nan Adventure")
                        .font(.system(size: 34, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 4)
                        .opacity(titleVisible ? 1 : 0)
                        .offset(y: titleVisible ? 0 : 24)

                    Text("Rediscover the magic in\nevery step you take")
                        .font(.system(size: 18, weight: .medium, design: .serif))
                        .foregroundStyle(.white.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 2)
                        .opacity(subtitleVisible ? 1 : 0)
                        .offset(y: subtitleVisible ? 0 : 12)
                }
            }
            .padding(.horizontal, 32)

            Spacer()
            Spacer().frame(height: 80)
        }
        .onAppear {
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(0.2)) {
                iconVisible = true
            }
            withAnimation(.easeOut(duration: 0.7).delay(0.5)) {
                titleVisible = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(1.0)) {
                subtitleVisible = true
            }
        }
    }
}

// MARK: - Quest Demo Screen

struct QuestDemoScreen: View {
    @State private var phase: QuestDemoPhase = .intro
    @State private var bubbleVisible: Bool = false
    @State private var photoButtonVisible: Bool = false
    @State private var scannerActive: Bool = false
    @State private var scanLineY: CGFloat = 0
    @State private var scanLineOpacity: Double = 0
    @State private var scanText: String = ""
    @State private var scanTextOpacity: Double = 0
    @State private var checkmarkScale: CGFloat = 0
    @State private var checkmarkOpacity: Double = 0
    @State private var addedVisible: Bool = false
    @State private var sparklesActive: Bool = false
    @State private var introTextVisible: Bool = false
    @State private var photoThumbnailVisible: Bool = false

    private enum QuestDemoPhase {
        case intro, quest, photoTaken, verifying, complete
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                if sparklesActive {
                    DemoSparkleOverlay()
                }

                VStack(spacing: 20) {
                    if phase == .intro {
                        introContent
                    }

                    if phase != .intro {
                        questCard
                    }

                    if phase == .quest {
                        takePhotoButton
                    }

                    if phase == .photoTaken {
                        photoPreview
                    }

                    if phase == .verifying {
                        scannerSection
                    }

                    if phase == .complete {
                        completionSection
                    }
                }
                .padding(.horizontal, 28)
            }

            Spacer()
            Spacer().frame(height: 80)
        }
        .onAppear {
            startIntroSequence()
        }
    }

    private var introContent: some View {
        VStack(spacing: 12) {
            Text("Every walk is a quest")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)

            Text("Fun photo challenges that turn\nordinary walks into adventures")
                .font(.system(size: 16, weight: .medium, design: .serif))
                .foregroundStyle(.white.opacity(0.8))
                .multilineTextAlignment(.center)
        }
        .opacity(introTextVisible ? 1 : 0)
        .offset(y: introTextVisible ? 0 : 16)
    }

    private var questCard: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(WhimsicalTheme.softPink)
                    .frame(width: 10, height: 10)
                Text("Easy")
                    .font(.system(.caption, design: .serif, weight: .semibold))
                    .foregroundStyle(WhimsicalTheme.accentSoftPink)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(WhimsicalTheme.softPink.opacity(0.4), in: Capsule())
                Spacer()
                Image(systemName: "camera.fill")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Text("Find Something Pink")
                .font(.system(.headline, design: .serif))
                .foregroundStyle(.white)

            Text("Spot something pink on your walk and take a mental snapshot")
                .font(.system(.subheadline, design: .serif))
                .foregroundStyle(.white.opacity(0.7))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.15), in: .rect(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        )
        .opacity(bubbleVisible ? 1 : 0)
        .offset(y: bubbleVisible ? 0 : 40)
        .scaleEffect(bubbleVisible ? 1 : 0.9)
    }

    private var takePhotoButton: some View {
        Button {
            startPhotoFlow()
        } label: {
            Label("Take Photo", systemImage: "camera.fill")
                .font(.system(.body, design: .serif, weight: .semibold))
                .foregroundStyle(WhimsicalTheme.deepRose)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.white, in: .rect(cornerRadius: 14))
                .shadow(color: WhimsicalTheme.deepRose.opacity(0.3), radius: 10, x: 0, y: 4)
        }
        .opacity(photoButtonVisible ? 1 : 0)
        .offset(y: photoButtonVisible ? 0 : 16)
    }

    private var photoPreview: some View {
        VStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.white.opacity(0.12))
                    .frame(height: 100)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )

                HStack(spacing: 14) {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(
                            LinearGradient(
                                colors: [WhimsicalTheme.blushPink, WhimsicalTheme.deepRose.opacity(0.6)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 64, height: 64)
                        .overlay {
                            Image(systemName: "photo.fill")
                                .font(.title2)
                                .foregroundStyle(.white.opacity(0.8))
                        }

                    VStack(alignment: .leading, spacing: 4) {
                        Text("Photo captured!")
                            .font(.system(.subheadline, design: .serif, weight: .semibold))
                            .foregroundStyle(.white)
                        Text("Ready to verify your quest")
                            .font(.system(.caption, design: .serif))
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    Spacer()
                }
                .padding(.horizontal, 16)
            }

            Button {
                startVerification()
            } label: {
                Label("Verify Quest", systemImage: "camera.viewfinder")
                    .font(.system(.body, design: .serif, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(WhimsicalTheme.deepRose, in: .rect(cornerRadius: 14))
                    .shadow(color: WhimsicalTheme.deepRose.opacity(0.5), radius: 10, x: 0, y: 4)
            }
        }
        .opacity(photoThumbnailVisible ? 1 : 0)
        .offset(y: photoThumbnailVisible ? 0 : 20)
    }

    private var scannerSection: some View {
        VStack(spacing: 16) {
            ZStack {
                RoundedRectangle(cornerRadius: 14)
                    .fill(.white.opacity(0.08))
                    .frame(height: 120)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(WhimsicalTheme.deepRose.opacity(0.5), lineWidth: 1.5)
                    )

                GeometryReader { geo in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    WhimsicalTheme.deepRose.opacity(0),
                                    WhimsicalTheme.deepRose.opacity(0.8),
                                    WhimsicalTheme.deepRose.opacity(0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 3)
                        .opacity(scanLineOpacity)
                        .position(x: geo.size.width / 2, y: scanLineY)
                }
                .frame(height: 120)
                .clipShape(.rect(cornerRadius: 14))

                if phase == .complete {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white)
                        .shadow(color: WhimsicalTheme.deepRose.opacity(0.6), radius: 10)
                        .scaleEffect(checkmarkScale)
                        .opacity(checkmarkOpacity)
                }
            }

            Text(scanText)
                .font(.system(.subheadline, design: .serif, weight: .medium))
                .foregroundStyle(.white.opacity(0.9))
                .opacity(scanTextOpacity)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.2), value: scanText)
        }
    }

    private var completionSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 10) {
                Image(systemName: "photo.fill.on.rectangle.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                Text("Added to your Polaroid library!")
                    .font(.system(.body, design: .serif, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(WhimsicalTheme.deepSage.opacity(0.5), in: .rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(WhimsicalTheme.deepSage.opacity(0.3), lineWidth: 1)
            )
        }
        .opacity(addedVisible ? 1 : 0)
        .offset(y: addedVisible ? 0 : 20)
        .scaleEffect(addedVisible ? 1 : 0.9)
    }

    private func startIntroSequence() {
        withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
            introTextVisible = true
        }

        Task {
            try? await Task.sleep(for: .seconds(1.8))
            withAnimation(.easeOut(duration: 0.4)) {
                introTextVisible = false
            }

            try? await Task.sleep(for: .seconds(0.5))
            phase = .quest
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.1)) {
                bubbleVisible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.6)) {
                photoButtonVisible = true
            }
        }
    }

    private func startPhotoFlow() {
        withAnimation(.easeOut(duration: 0.3)) {
            photoButtonVisible = false
        }

        Task {
            try? await Task.sleep(for: .seconds(0.4))
            phase = .photoTaken
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                photoThumbnailVisible = true
            }
        }
    }

    private func startVerification() {
        withAnimation(.easeOut(duration: 0.3)) {
            photoThumbnailVisible = false
        }

        Task {
            try? await Task.sleep(for: .seconds(0.3))
            phase = .verifying
            scannerActive = true
            sparklesActive = true

            withAnimation(.easeIn(duration: 0.3)) {
                scanLineOpacity = 1.0
                scanTextOpacity = 1.0
            }

            scanText = "Analyzing photo..."
            animateScanLine()

            try? await Task.sleep(for: .seconds(0.8))
            scanText = "Sprinkling fairy dust..."

            try? await Task.sleep(for: .seconds(0.7))
            scanText = "Adding whimsy filter..."

            try? await Task.sleep(for: .seconds(0.7))
            scanText = "Weaving in the magic..."

            try? await Task.sleep(for: .seconds(0.6))

            withAnimation(.easeOut(duration: 0.3)) {
                scanLineOpacity = 0
            }

            scanText = "Quest complete!"

            phase = .complete
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                checkmarkScale = 1.0
                checkmarkOpacity = 1.0
            }

            try? await Task.sleep(for: .seconds(0.8))

            withAnimation(.easeOut(duration: 0.3)) {
                scanTextOpacity = 0
                checkmarkOpacity = 0
                scannerActive = false
            }

            try? await Task.sleep(for: .seconds(0.3))
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                addedVisible = true
            }
        }
    }

    private func animateScanLine() {
        scanLineY = 10

        func sweep() {
            guard scannerActive else { return }
            withAnimation(.easeInOut(duration: 0.7)) {
                scanLineY = 110
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                guard scannerActive else { return }
                withAnimation(.easeInOut(duration: 0.7)) {
                    scanLineY = 10
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    sweep()
                }
            }
        }

        sweep()
    }
}

struct DemoSparkleOverlay: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.04)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                for i in 0..<14 {
                    let seed = Double(i) * 137.508
                    let x = (sin(seed + time * 0.6) * 0.4 + 0.5) * size.width
                    let y = (cos(seed * 0.7 + time * 0.4) * 0.4 + 0.5) * size.height
                    let pulse = sin(time * 2.5 + seed) * 0.5 + 0.5
                    let sparkSize = 2.0 + pulse * 5.0
                    let rect = CGRect(x: x - sparkSize / 2, y: y - sparkSize / 2, width: sparkSize, height: sparkSize)
                    context.opacity = pulse * 0.6
                    let colors: [Color] = [.white, WhimsicalTheme.blushPink, WhimsicalTheme.lavender, .white]
                    context.fill(Path(ellipseIn: rect), with: .color(colors[i % colors.count]))
                    if pulse > 0.75 {
                        let crossSize = sparkSize * 1.3
                        var cross = Path()
                        cross.move(to: CGPoint(x: x - crossSize, y: y))
                        cross.addLine(to: CGPoint(x: x + crossSize, y: y))
                        cross.move(to: CGPoint(x: x, y: y - crossSize))
                        cross.addLine(to: CGPoint(x: x, y: y + crossSize))
                        context.opacity = (pulse - 0.75) * 3.0
                        context.stroke(cross, with: .color(.white.opacity(0.5)), lineWidth: 0.5)
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

// MARK: - Feature Showcase Screen

struct FeatureShowcaseScreen: View {
    @State private var headerVisible: Bool = false
    @State private var card1Visible: Bool = false
    @State private var card2Visible: Bool = false
    @State private var card3Visible: Bool = false
    @State private var polaroidTilt: Double = 0
    @State private var questFlip: Bool = false
    @State private var petBounce: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Your Walks,\nReimagined")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                .opacity(headerVisible ? 1 : 0)
                .offset(y: headerVisible ? 0 : 16)

            Spacer().frame(height: 28)

            VStack(spacing: 16) {
                featureCard(
                    icon: "camera.filters",
                    iconColor: WhimsicalTheme.deepRose,
                    title: "Whimsical Polaroids",
                    subtitle: "Turn walks into magical memories\nwith fantasy filters",
                    miniView: AnyView(
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [WhimsicalTheme.blushPink, WhimsicalTheme.deepRose.opacity(0.5)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 44, height: 44)
                            Image(systemName: "sparkle")
                                .font(.system(size: 18))
                                .foregroundStyle(.white)
                        }
                        .rotationEffect(.degrees(polaroidTilt))
                    )
                )
                .opacity(card1Visible ? 1 : 0)
                .offset(x: card1Visible ? 0 : -60)

                featureCard(
                    icon: "map.fill",
                    iconColor: WhimsicalTheme.deepLavender,
                    title: "Daily Quests",
                    subtitle: "Fun photo adventures that make\nevery walk an expedition",
                    miniView: AnyView(
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(WhimsicalTheme.deepLavender.opacity(0.3))
                                .frame(width: 44, height: 44)
                            Image(systemName: "map.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(WhimsicalTheme.deepLavender)
                                .scaleEffect(questFlip ? 1.15 : 1.0)
                        }
                    )
                )
                .opacity(card2Visible ? 1 : 0)
                .offset(x: card2Visible ? 0 : 60)

                featureCard(
                    icon: "pawprint.fill",
                    iconColor: WhimsicalTheme.deepSage,
                    title: "Collect Companions",
                    subtitle: "Earn adorable pets as you explore\nthe world around you",
                    miniView: AnyView(
                        ZStack {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(WhimsicalTheme.deepSage.opacity(0.3))
                                .frame(width: 44, height: 44)
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 18))
                                .foregroundStyle(WhimsicalTheme.deepSage)
                                .offset(y: petBounce)
                        }
                    )
                )
                .opacity(card3Visible ? 1 : 0)
                .offset(x: card3Visible ? 0 : -60)
            }
            .padding(.horizontal, 28)

            Spacer()
            Spacer().frame(height: 80)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                headerVisible = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5)) {
                card1Visible = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.8)) {
                card2Visible = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.1)) {
                card3Visible = true
            }
            startMiniAnimations()
        }
    }

    private func featureCard(icon: String, iconColor: Color, title: String, subtitle: String, miniView: AnyView) -> some View {
        HStack(spacing: 14) {
            miniView

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .foregroundStyle(.white.opacity(0.7))
                    .lineSpacing(2)
            }

            Spacer()
        }
        .padding(16)
        .background(.white.opacity(0.15), in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white.opacity(0.15), lineWidth: 1)
        )
    }

    private func startMiniAnimations() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.6)) {
            polaroidTilt = 8
        }
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(1.0)) {
            questFlip = true
        }
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(1.3)) {
            petBounce = -6
        }
    }
}

// MARK: - Walking Stats Screen

struct WalkingStatsScreen: View {
    @State private var ringProgress: CGFloat = 0
    @State private var stat1Visible: Bool = false
    @State private var stat2Visible: Bool = false
    @State private var stat3Visible: Bool = false
    @State private var headerVisible: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Walking Is\nYour Superpower")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                .opacity(headerVisible ? 1 : 0)
                .offset(y: headerVisible ? 0 : 16)

            Spacer().frame(height: 28)

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 14)
                    .frame(width: 140, height: 140)

                Circle()
                    .trim(from: 0, to: ringProgress)
                    .stroke(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.7)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        ),
                        style: StrokeStyle(lineWidth: 14, lineCap: .round)
                    )
                    .frame(width: 140, height: 140)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 32, weight: .medium))
                        .foregroundStyle(.white)
                    Text("60%")
                        .font(.system(size: 24, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                }
            }

            Spacer().frame(height: 32)

            VStack(spacing: 14) {
                StatBubble(
                    icon: "brain.head.profile",
                    text: "Walking boosts creative thinking by up to 60%",
                    source: "Stanford University"
                )
                .opacity(stat1Visible ? 1 : 0)
                .offset(y: stat1Visible ? 0 : 16)

                StatBubble(
                    icon: "heart.fill",
                    text: "Just 4,400 steps/day significantly lowers mortality risk",
                    source: "Harvard Medical School"
                )
                .opacity(stat2Visible ? 1 : 0)
                .offset(y: stat2Visible ? 0 : 16)

                StatBubble(
                    icon: "sun.max.fill",
                    text: "Higher daily steps = fewer symptoms of depression",
                    source: "JAMA Network"
                )
                .opacity(stat3Visible ? 1 : 0)
                .offset(y: stat3Visible ? 0 : 16)
            }
            .padding(.horizontal, 28)

            Spacer()
            Spacer().frame(height: 80)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                headerVisible = true
            }
            withAnimation(.easeInOut(duration: 1.5).delay(0.4)) {
                ringProgress = 0.6
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.7)) {
                stat1Visible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(1.1)) {
                stat2Visible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(1.5)) {
                stat3Visible = true
            }
        }
    }
}

struct StatBubble: View {
    let icon: String
    let text: String
    let source: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(.white)
                .frame(width: 36)

            VStack(alignment: .leading, spacing: 2) {
                Text(text)
                    .font(.system(size: 15, weight: .medium, design: .serif))
                    .foregroundStyle(.white)
                Text(source)
                    .font(.system(size: 11, weight: .regular, design: .serif))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
        .padding(14)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.12), in: .rect(cornerRadius: 16))
    }
}

// MARK: - Personalization Screen

struct PersonalizationScreen: View {
    @State private var headerVisible: Bool = false
    @State private var nameFieldVisible: Bool = false
    @State private var goalPickerVisible: Bool = false
    @State private var userName: String = ""
    @State private var selectedGoal: Int = 7500
    @FocusState private var nameFieldFocused: Bool

    private let goalOptions: [(label: String, value: Int, emoji: String)] = [
        ("3,000", 3000, "🌱"),
        ("5,000", 5000, "🌿"),
        ("7,500", 7500, "🌳"),
        ("10,000", 10000, "🏔️"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 8) {
                Text("Make It Yours")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)

                Text("We'll tailor your adventure just for you")
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundStyle(.white.opacity(0.8))
            }
            .opacity(headerVisible ? 1 : 0)
            .offset(y: headerVisible ? 0 : 16)

            Spacer().frame(height: 32)

            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 10) {
                    Text("What should we call you?")
                        .font(.system(size: 15, weight: .semibold, design: .serif))
                        .foregroundStyle(.white.opacity(0.9))

                    TextField("Your name", text: $userName)
                        .font(.system(size: 18, weight: .medium, design: .serif))
                        .foregroundStyle(.white)
                        .padding(16)
                        .background(.white.opacity(0.15), in: .rect(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(.white.opacity(0.25), lineWidth: 1)
                        )
                        .focused($nameFieldFocused)
                        .tint(.white)
                        .autocorrectionDisabled()
                }
                .opacity(nameFieldVisible ? 1 : 0)
                .offset(y: nameFieldVisible ? 0 : 20)

                VStack(alignment: .leading, spacing: 12) {
                    Text("Daily step goal")
                        .font(.system(size: 15, weight: .semibold, design: .serif))
                        .foregroundStyle(.white.opacity(0.9))

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
                        ForEach(goalOptions, id: \.value) { option in
                            Button {
                                selectedGoal = option.value
                            } label: {
                                HStack(spacing: 8) {
                                    Text(option.emoji)
                                        .font(.title3)
                                    Text(option.label)
                                        .font(.system(size: 16, weight: .semibold, design: .serif))
                                        .foregroundStyle(.white)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(
                                    selectedGoal == option.value
                                        ? Color.white.opacity(0.25)
                                        : Color.white.opacity(0.1),
                                    in: .rect(cornerRadius: 14)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 14)
                                        .stroke(
                                            selectedGoal == option.value
                                                ? Color.white.opacity(0.5)
                                                : Color.clear,
                                            lineWidth: 1.5
                                        )
                                )
                            }
                            .sensoryFeedback(.selection, trigger: selectedGoal)
                        }
                    }
                }
                .opacity(goalPickerVisible ? 1 : 0)
                .offset(y: goalPickerVisible ? 0 : 20)
            }
            .padding(.horizontal, 28)

            Spacer()
            Spacer().frame(height: 80)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                headerVisible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.5)) {
                nameFieldVisible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.8)) {
                goalPickerVisible = true
            }
        }
        .onDisappear {
            savePersonalization()
        }
        .onChange(of: nameFieldFocused) { _, _ in }
    }

    private func savePersonalization() {
        let trimmed = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            UserDefaults.standard.set(trimmed, forKey: "whimsical_user_name")
        }
        UserDefaults.standard.set(selectedGoal, forKey: "whimsical_step_goal")
    }
}

// MARK: - Review Screen

struct ReviewScreen: View {
    let onContinue: () -> Void
    @State private var headerVisible: Bool = false
    @State private var starsVisible: Bool = false
    @State private var testimonialsVisible: Bool = false
    @State private var ctaVisible: Bool = false
    @State private var starScale: [CGFloat] = [0, 0, 0, 0, 0]
    @State private var hasRequestedReview: Bool = false
    @Environment(\.requestReview) private var requestReview

    private let testimonials: [(text: String, author: String)] = [
        ("This app made walking fun again! I actually look forward to my daily walk now.", "Sarah K."),
        ("My kids love doing the quests with me. We've discovered so many hidden gems in our neighborhood.", "Mike T."),
        ("The polaroid filters are gorgeous. My camera roll is full of whimsical memories!", "Emma L."),
    ]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer().frame(height: 80)

                VStack(spacing: 12) {
                    Text("Enjoying the\nVibes So Far?")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)

                    Text("You're about to unlock something special")
                        .font(.system(size: 16, weight: .medium, design: .serif))
                        .foregroundStyle(.white.opacity(0.8))
                }
                .opacity(headerVisible ? 1 : 0)
                .offset(y: headerVisible ? 0 : 16)

                Spacer().frame(height: 24)

                HStack(spacing: 8) {
                    ForEach(0..<5, id: \.self) { i in
                        Image(systemName: "star.fill")
                            .font(.system(size: 28))
                            .foregroundStyle(.yellow)
                            .shadow(color: .yellow.opacity(0.4), radius: 6)
                            .scaleEffect(starScale[i])
                    }
                }
                .opacity(starsVisible ? 1 : 0)

                Spacer().frame(height: 28)

                VStack(spacing: 12) {
                    ForEach(Array(testimonials.enumerated()), id: \.offset) { index, testimonial in
                        TestimonialBubble(text: testimonial.text, author: testimonial.author)
                            .opacity(testimonialsVisible ? 1 : 0)
                            .offset(y: testimonialsVisible ? 0 : 20)
                            .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.2), value: testimonialsVisible)
                    }
                }
                .padding(.horizontal, 28)

                Spacer().frame(height: 28)

                VStack(spacing: 14) {
                    Button {
                        if !hasRequestedReview {
                            requestReview()
                            hasRequestedReview = true
                        }
                        Task {
                            try? await Task.sleep(for: .seconds(0.5))
                            onContinue()
                        }
                    } label: {
                        HStack(spacing: 8) {
                            Image(systemName: "heart.fill")
                                .font(.body)
                            Text("Rate & Continue")
                                .font(.system(size: 18, weight: .bold, design: .serif))
                        }
                        .foregroundStyle(WhimsicalTheme.deepRose)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 17)
                        .background(.white, in: Capsule())
                        .shadow(color: WhimsicalTheme.deepRose.opacity(0.3), radius: 12, x: 0, y: 4)
                    }

                    Button {
                        onContinue()
                    } label: {
                        Text("Maybe later")
                            .font(.system(size: 15, weight: .medium, design: .serif))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }
                .padding(.horizontal, 28)
                .opacity(ctaVisible ? 1 : 0)
                .offset(y: ctaVisible ? 0 : 16)

                Spacer().frame(height: 60)
            }
        }
        .scrollDismissesKeyboard(.immediately)
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                headerVisible = true
            }
            withAnimation(.easeOut(duration: 0.3).delay(0.5)) {
                starsVisible = true
            }
            animateStars()
            withAnimation(.easeOut(duration: 0.5).delay(1.0)) {
                testimonialsVisible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(1.8)) {
                ctaVisible = true
            }
        }
    }

    private func animateStars() {
        for i in 0..<5 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.5).delay(0.6 + Double(i) * 0.1)) {
                starScale[i] = 1.0
            }
        }
    }
}

struct TestimonialBubble: View {
    let text: String
    let author: String

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 4) {
                ForEach(0..<5, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundStyle(.yellow.opacity(0.9))
                }
            }

            Text("\"\(text)\"")
                .font(.system(size: 14, weight: .medium, design: .serif))
                .foregroundStyle(.white.opacity(0.9))
                .italic()

            Text("— \(author)")
                .font(.system(size: 12, weight: .regular, design: .serif))
                .foregroundStyle(.white.opacity(0.6))
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.12), in: .rect(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }
}
