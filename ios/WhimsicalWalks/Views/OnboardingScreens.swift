import SwiftUI

struct RememberScreen: View {
    @State private var titleVisible: Bool = false
    @State private var subtitleVisible: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 16) {
                Text("Remember when\nthe world felt magical?")
                    .font(.system(size: 32, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 4)
                    .opacity(titleVisible ? 1 : 0)
                    .offset(y: titleVisible ? 0 : 20)

                Text("When every puddle was an ocean\nand every walk was an adventure")
                    .font(.system(size: 18, weight: .medium, design: .serif))
                    .foregroundStyle(.white.opacity(0.9))
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 2)
                    .opacity(subtitleVisible ? 1 : 0)
                    .offset(y: subtitleVisible ? 0 : 12)
            }
            .padding(.horizontal, 32)

            Spacer()
            Spacer().frame(height: 80)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7).delay(0.3)) {
                titleVisible = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.9)) {
                subtitleVisible = true
            }
        }
    }
}

struct WalkingMedicineScreen: View {
    @State private var ringProgress: CGFloat = 0
    @State private var stat1Visible: Bool = false
    @State private var stat2Visible: Bool = false
    @State private var stat3Visible: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.white.opacity(0.15), lineWidth: 14)
                    .frame(width: 160, height: 160)

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
                    .frame(width: 160, height: 160)
                    .rotationEffect(.degrees(-90))

                VStack(spacing: 2) {
                    Image(systemName: "figure.walk")
                        .font(.system(size: 36, weight: .medium))
                        .foregroundStyle(.white)
                    Text("60%")
                        .font(.system(size: 28, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                }
            }

            Spacer().frame(height: 40)

            VStack(spacing: 20) {
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
            withAnimation(.easeInOut(duration: 1.5).delay(0.3)) {
                ringProgress = 0.6
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.6)) {
                stat1Visible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(1.0)) {
                stat2Visible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(1.4)) {
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

struct FeaturesScreen: View {
    @State private var feature1Visible: Bool = false
    @State private var feature2Visible: Bool = false
    @State private var feature3Visible: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Your Walks,\nReimagined")
                .font(.system(size: 30, weight: .bold, design: .serif))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)

            Spacer().frame(height: 36)

            VStack(spacing: 16) {
                FeatureCard(
                    icon: "camera.filters",
                    title: "Whimsical Polaroids",
                    description: "Turn your walks into magical memories with fantasy filters",
                    tint: WhimsicalTheme.deepRose
                )
                .opacity(feature1Visible ? 1 : 0)
                .offset(x: feature1Visible ? 0 : -40)

                FeatureCard(
                    icon: "map.fill",
                    title: "Daily Quests",
                    description: "Fun photo adventures that make every walk an expedition",
                    tint: WhimsicalTheme.deepLavender
                )
                .opacity(feature2Visible ? 1 : 0)
                .offset(x: feature2Visible ? 0 : 40)

                FeatureCard(
                    icon: "pawprint.fill",
                    title: "Collect Companions",
                    description: "Earn adorable pets as you explore the world around you",
                    tint: WhimsicalTheme.deepSage
                )
                .opacity(feature3Visible ? 1 : 0)
                .offset(x: feature3Visible ? 0 : -40)
            }
            .padding(.horizontal, 24)

            Spacer()
            Spacer().frame(height: 80)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3)) {
                feature1Visible = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.6)) {
                feature2Visible = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.9)) {
                feature3Visible = true
            }
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let tint: Color

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(tint.opacity(0.3))
                    .frame(width: 48, height: 48)
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundStyle(.white)
            }

            VStack(alignment: .leading, spacing: 3) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)
                Text(description)
                    .font(.system(size: 14, weight: .regular, design: .serif))
                    .foregroundStyle(.white.opacity(0.75))
                    .lineLimit(2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.white.opacity(0.12), in: .rect(cornerRadius: 18))
    }
}

struct PersonalizeScreen: View {
    @Binding var userName: String
    @Binding var selectedGoal: Int
    @Binding var customGoalText: String
    @Binding var showCustomGoal: Bool
    let onNext: () -> Void
    @State private var visible: Bool = false
    @FocusState private var nameFieldFocused: Bool

    private let goalOptions: [(label: String, value: Int)] = [
        ("3,000", 3000),
        ("5,000", 5000),
        ("7,500", 7500),
        ("10,000", 10000),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 8) {
                Text("Make It Yours")
                    .font(.system(size: 30, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                Text("We'll tailor your adventure just for you")
                    .font(.system(size: 16, weight: .regular, design: .serif))
                    .foregroundStyle(.white.opacity(0.75))
            }
            .opacity(visible ? 1 : 0)

            Spacer().frame(height: 32)

            VStack(spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("What should we call you?")
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .foregroundStyle(.white.opacity(0.85))
                    TextField("Your name", text: $userName)
                        .font(.system(size: 18, weight: .medium, design: .serif))
                        .foregroundStyle(.white)
                        .padding(14)
                        .background(.white.opacity(0.15), in: .rect(cornerRadius: 14))
                        .tint(.white)
                        .focused($nameFieldFocused)
                        .submitLabel(.done)
                        .onSubmit { nameFieldFocused = false }
                }

                VStack(alignment: .leading, spacing: 10) {
                    Text("Daily step goal")
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .foregroundStyle(.white.opacity(0.85))

                    HStack(spacing: 8) {
                        ForEach(goalOptions, id: \.value) { option in
                            Button {
                                showCustomGoal = false
                                selectedGoal = option.value
                            } label: {
                                Text(option.label)
                                    .font(.system(size: 14, weight: .semibold, design: .serif))
                                    .foregroundStyle(!showCustomGoal && selectedGoal == option.value ? WhimsicalTheme.deepRose : .white)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 10)
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        !showCustomGoal && selectedGoal == option.value
                                            ? .white.opacity(0.9)
                                            : .white.opacity(0.12),
                                        in: .rect(cornerRadius: 12)
                                    )
                            }
                        }
                    }

                    Button {
                        showCustomGoal.toggle()
                    } label: {
                        HStack {
                            Image(systemName: showCustomGoal ? "checkmark.circle.fill" : "circle")
                                .foregroundStyle(.white.opacity(0.7))
                            Text("Custom goal")
                                .font(.system(size: 14, weight: .medium, design: .serif))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }

                    if showCustomGoal {
                        TextField("e.g. 12000", text: $customGoalText)
                            .font(.system(size: 18, weight: .medium, design: .serif))
                            .foregroundStyle(.white)
                            .keyboardType(.numberPad)
                            .padding(14)
                            .background(.white.opacity(0.15), in: .rect(cornerRadius: 14))
                            .tint(.white)
                    }
                }
            }
            .padding(.horizontal, 28)
            .opacity(visible ? 1 : 0)

            Spacer().frame(height: 32)

            Button(action: onNext) {
                Text("Continue")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundStyle(WhimsicalTheme.deepRose)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(.white, in: Capsule())
                    .shadow(color: WhimsicalTheme.deepRose.opacity(0.3), radius: 12, x: 0, y: 6)
            }
            .padding(.horizontal, 28)
            .opacity(visible ? 1 : 0)

            Spacer()
            Spacer().frame(height: 80)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                visible = true
            }
        }
    }
}

struct ReviewScreen: View {
    @Binding var reviewRequested: Bool
    @State private var visible: Bool = false
    @State private var heartsActive: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                if heartsActive {
                    FloatingHeartsOverlay()
                }

                VStack(spacing: 20) {
                    Image(systemName: "sparkles")
                        .font(.system(size: 56))
                        .foregroundStyle(.white)
                        .symbolEffect(.pulse, options: .repeating)

                    Text("Enjoying the\nvibes so far?")
                        .font(.system(size: 30, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("A quick rating helps us bring\nmore magic to your walks")
                        .font(.system(size: 16, weight: .regular, design: .serif))
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                }
            }
            .opacity(visible ? 1 : 0)
            .scaleEffect(visible ? 1 : 0.9)

            Spacer()
            Spacer().frame(height: 80)
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                visible = true
            }
            withAnimation(.easeIn(duration: 0.3).delay(0.5)) {
                heartsActive = true
            }
        }
    }
}

struct FloatingHeartsOverlay: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.05)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                for i in 0..<12 {
                    let seed = Double(i) * 47.3
                    let x = (sin(seed * 0.3 + time * 0.5) * 0.35 + 0.5) * size.width
                    let baseY = size.height - (time * 30.0 + seed * 20.0).truncatingRemainder(dividingBy: size.height)
                    let pulse = sin(time * 1.5 + seed) * 0.5 + 0.5
                    let heartSize = 8.0 + pulse * 10.0
                    context.opacity = 0.15 + pulse * 0.2
                    let symbol = context.resolve(Image(systemName: "heart.fill"))
                    context.draw(symbol, in: CGRect(x: x - heartSize / 2, y: baseY - heartSize / 2, width: heartSize, height: heartSize))
                }
            }
        }
        .allowsHitTesting(false)
    }
}
