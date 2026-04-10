import SwiftUI

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

struct QuestDemoScreen: View {
    @State private var phase: DemoPhase = .intro
    @State private var bubbleVisible: Bool = false
    @State private var verifyButtonVisible: Bool = false
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

    private enum DemoPhase {
        case intro, quest, verifying, complete
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                if sparklesActive {
                    DemoSparkleOverlay()
                }

                VStack(spacing: 24) {
                    if phase == .intro {
                        introContent
                    }

                    if phase != .intro {
                        questBubble
                    }

                    if phase == .quest {
                        verifyButton
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

    private var questBubble: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
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

            Text("Snap the most whimsical\nobject in your room")
                .font(.system(.headline, design: .serif))
                .foregroundStyle(.white)

            Text("Look around you - what catches your eye? A quirky mug, a colorful plant, something magical?")
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

    private var verifyButton: some View {
        Button {
            startVerification()
        } label: {
            Label("Verify Quest", systemImage: "camera.viewfinder")
                .font(.system(.body, design: .serif, weight: .semibold))
                .foregroundStyle(WhimsicalTheme.deepRose)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(.white, in: .rect(cornerRadius: 14))
                .shadow(color: WhimsicalTheme.deepRose.opacity(0.3), radius: 10, x: 0, y: 4)
        }
        .opacity(verifyButtonVisible ? 1 : 0)
        .offset(y: verifyButtonVisible ? 0 : 16)
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
                verifyButtonVisible = true
            }
        }
    }

    private func startVerification() {
        withAnimation(.easeOut(duration: 0.3)) {
            verifyButtonVisible = false
        }

        Task {
            try? await Task.sleep(for: .seconds(0.3))
            phase = .verifying
            scannerActive = true

            withAnimation(.easeIn(duration: 0.3)) {
                scanLineOpacity = 1.0
                scanTextOpacity = 1.0
                sparklesActive = true
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
