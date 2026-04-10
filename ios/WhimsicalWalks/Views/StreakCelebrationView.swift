import SwiftUI

struct StreakCelebrationView: View {
    let streakCount: Int
    let onDismiss: () -> Void

    @State private var flameScale: CGFloat = 0.3
    @State private var flameOpacity: Double = 0
    @State private var glowPulse: Bool = false
    @State private var particlesActive: Bool = false
    @State private var textRevealed: Int = 0
    @State private var subtitleOpacity: Double = 0
    @State private var dismissOpacity: Double = 0
    @State private var bgOpacity: Double = 0

    private let fullText = "Streak continued"

    var body: some View {
        ZStack {
            Color.black.opacity(bgOpacity * 0.4)
                .ignoresSafeArea()
                .allowsHitTesting(true)

            if particlesActive {
                flameParticles
            }

            VStack(spacing: 20) {
                Spacer()

                ZStack {
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [
                                    WhimsicalTheme.deepRose.opacity(0.4),
                                    WhimsicalTheme.deepRose.opacity(0.1),
                                    .clear
                                ],
                                center: .center,
                                startRadius: 10,
                                endRadius: 80
                            )
                        )
                        .frame(width: 160, height: 160)
                        .scaleEffect(glowPulse ? 1.2 : 0.9)

                    Image(systemName: "flame.fill")
                        .font(.system(size: 72, weight: .bold))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.85, blue: 0.4),
                                    WhimsicalTheme.deepRose,
                                    Color(red: 0.85, green: 0.3, blue: 0.2)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(flameScale)
                        .opacity(flameOpacity)
                        .shadow(color: Color(red: 1.0, green: 0.6, blue: 0.2).opacity(0.6), radius: 20, x: 0, y: 4)
                        .shadow(color: WhimsicalTheme.deepRose.opacity(0.4), radius: 30, x: 0, y: 8)
                }

                HStack(spacing: 0) {
                    ForEach(Array(fullText.enumerated()), id: \.offset) { index, char in
                        Text(String(char))
                            .font(.custom(FontRegistration.keshia, size: 34))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [WhimsicalTheme.deepRose, Color(red: 1.0, green: 0.7, blue: 0.4)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .opacity(index < textRevealed ? 1 : 0)
                            .offset(y: index < textRevealed ? 0 : 8)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7).delay(Double(index) * 0.04), value: textRevealed)
                    }
                }
                .shadow(color: WhimsicalTheme.deepRose.opacity(0.3), radius: 8, x: 0, y: 4)

                Text("\(streakCount) day streak")
                    .font(.system(.title3, design: .serif, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .opacity(subtitleOpacity)

                Spacer()

                Text("tap to continue")
                    .font(.system(.caption, design: .serif))
                    .foregroundStyle(.white.opacity(0.5))
                    .opacity(dismissOpacity)
                    .padding(.bottom, 60)
            }
        }
        .onTapGesture {
            withAnimation(.easeOut(duration: 0.3)) {
                bgOpacity = 0
                flameOpacity = 0
                subtitleOpacity = 0
                dismissOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                onDismiss()
            }
        }
        .onAppear { runCelebration() }
    }

    private var flameParticles: some View {
        TimelineView(.animation(minimumInterval: 0.03)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                let centerX = size.width / 2
                let centerY = size.height * 0.42

                for i in 0..<20 {
                    let seed = Double(i) * 73.7
                    let age = (time + seed).truncatingRemainder(dividingBy: 3.0)
                    let progress = age / 3.0

                    let spreadX = sin(seed * 2.3 + time * 1.5) * 80 * progress
                    let riseY = -progress * size.height * 0.35
                    let driftX = sin(time * 0.8 + seed) * 20

                    let x = centerX + spreadX + driftX
                    let y = centerY + riseY

                    let fadeOut = max(0, 1.0 - progress * 1.2)
                    let particleSize = 3.0 + sin(seed) * 2.0

                    let rect = CGRect(
                        x: x - particleSize / 2,
                        y: y - particleSize / 2,
                        width: particleSize,
                        height: particleSize
                    )

                    let colors: [Color] = [
                        Color(red: 1.0, green: 0.85, blue: 0.4),
                        WhimsicalTheme.deepRose,
                        Color(red: 1.0, green: 0.6, blue: 0.3),
                        .white
                    ]
                    context.opacity = fadeOut * 0.7
                    context.fill(Circle().path(in: rect), with: .color(colors[i % colors.count]))
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func runCelebration() {
        withAnimation(.easeOut(duration: 0.4)) {
            bgOpacity = 1
        }

        withAnimation(.spring(response: 0.6, dampingFraction: 0.5).delay(0.2)) {
            flameScale = 1.0
            flameOpacity = 1
        }

        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.5)) {
            glowPulse = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeIn(duration: 0.3)) {
                particlesActive = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            textRevealed = fullText.count
        }

        withAnimation(.easeOut(duration: 0.5).delay(1.4)) {
            subtitleOpacity = 1
        }

        withAnimation(.easeOut(duration: 0.5).delay(2.2)) {
            dismissOpacity = 1
        }
    }
}
