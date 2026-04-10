import SwiftUI

struct SplashView: View {
    @State private var strokeProgress: CGFloat = 0
    @State private var textOpacity: Double = 0
    @State private var sparklesActive: Bool = false
    @State private var bgShift: Bool = false
    @State private var circleScale: CGFloat = 0.08
    @State private var circleOpacity: Double = 0.0
    @State private var envelopeActive: Bool = false
    @State private var contentOpacity: Double = 1.0
    @State private var decorativeLines: Bool = false

    let onFinished: () -> Void

    var body: some View {
        ZStack {
            backgroundGradient

            if decorativeLines {
                decorativeSwirls
                    .transition(.opacity)
            }

            if sparklesActive {
                sparkleOverlay
            }

            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            WhimsicalTheme.blushPink.opacity(0.6),
                            WhimsicalTheme.lavender.opacity(0.5),
                            WhimsicalTheme.cream
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 300
                    )
                )
                .scaleEffect(circleScale)
                .opacity(circleOpacity)

            VStack(spacing: 12) {
                Text("Whimsical Walks")
                    .font(.custom(FontRegistration.keshia, size: 38))
                    .foregroundStyle(.clear)
                    .overlay {
                        Text("Whimsical Walks")
                            .font(.custom(FontRegistration.keshia, size: 38))
                            .foregroundStyle(
                                LinearGradient(
                                    colors: [WhimsicalTheme.deepRose, WhimsicalTheme.deepLavender],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .mask(
                                GeometryReader { geo in
                                    Rectangle()
                                        .frame(width: geo.size.width * strokeProgress)
                                }
                            )
                    }
                    .shadow(color: WhimsicalTheme.deepRose.opacity(0.3), radius: 12, x: 0, y: 6)

                HandwrittenUnderline()
                    .trim(from: 0, to: strokeProgress)
                    .stroke(
                        LinearGradient(
                            colors: [WhimsicalTheme.deepRose.opacity(0.5), WhimsicalTheme.deepLavender.opacity(0.5)],
                            startPoint: .leading,
                            endPoint: .trailing
                        ),
                        style: StrokeStyle(lineWidth: 2, lineCap: .round)
                    )
                    .frame(width: 260, height: 12)
            }
            .opacity(contentOpacity)
        }
        .ignoresSafeArea()
        .onAppear { runSequence() }
    }

    private var backgroundGradient: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.5, 0.5], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1]
            ],
            colors: bgShift ? [
                WhimsicalTheme.blushPink.opacity(0.4),
                WhimsicalTheme.lavender.opacity(0.6),
                WhimsicalTheme.cream,
                WhimsicalTheme.warmPeach.opacity(0.5),
                WhimsicalTheme.blushPink.opacity(0.7),
                WhimsicalTheme.lavender.opacity(0.4),
                WhimsicalTheme.cream,
                WhimsicalTheme.blushPink.opacity(0.5),
                WhimsicalTheme.lavender.opacity(0.6)
            ] : [
                WhimsicalTheme.cream,
                WhimsicalTheme.blushPink.opacity(0.2),
                WhimsicalTheme.lavender.opacity(0.15),
                WhimsicalTheme.blushPink.opacity(0.15),
                WhimsicalTheme.cream,
                WhimsicalTheme.warmPeach.opacity(0.15),
                WhimsicalTheme.lavender.opacity(0.1),
                WhimsicalTheme.cream,
                WhimsicalTheme.blushPink.opacity(0.15)
            ]
        )
        .ignoresSafeArea()
    }

    private var decorativeSwirls: some View {
        TimelineView(.animation(minimumInterval: 0.03)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate

                for i in 0..<6 {
                    let seed = Double(i) * 60.0
                    let baseX = (sin(seed * 0.01 + time * 0.3) * 0.3 + 0.5) * size.width
                    let baseY = (cos(seed * 0.01 + time * 0.2) * 0.3 + 0.5) * size.height
                    let curlSize = 20.0 + sin(time + seed) * 8.0

                    var path = Path()
                    for j in stride(from: 0.0, to: Double.pi * 4, by: 0.2) {
                        let r = curlSize * j / (Double.pi * 4)
                        let x = baseX + cos(j) * r
                        let y = baseY + sin(j) * r
                        if j == 0 { path.move(to: CGPoint(x: x, y: y)) }
                        else { path.addLine(to: CGPoint(x: x, y: y)) }
                    }
                    context.opacity = 0.12
                    context.stroke(path, with: .color(WhimsicalTheme.deepRose), lineWidth: 1)
                }
            }
        }
        .allowsHitTesting(false)
    }

    private var sparkleOverlay: some View {
        TimelineView(.animation(minimumInterval: 0.04)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate

                for i in 0..<24 {
                    let seed = Double(i) * 137.508
                    let baseX = (sin(seed + time * 0.6) * 0.4 + 0.5) * size.width
                    let baseY = (cos(seed * 0.7 + time * 0.4) * 0.4 + 0.5) * size.height
                    let pulse = sin(time * 2.5 + seed) * 0.5 + 0.5
                    let sparkSize = 2.0 + pulse * 5.0

                    let rect = CGRect(
                        x: baseX - sparkSize / 2,
                        y: baseY - sparkSize / 2,
                        width: sparkSize,
                        height: sparkSize
                    )
                    context.opacity = pulse * 0.7
                    let colors: [Color] = [
                        WhimsicalTheme.deepRose, WhimsicalTheme.lavender,
                        WhimsicalTheme.warmPeach, .white,
                        WhimsicalTheme.deepLavender, WhimsicalTheme.blushPink
                    ]
                    context.fill(Path(ellipseIn: rect), with: .color(colors[i % colors.count]))

                    if pulse > 0.7 {
                        let crossSize = sparkSize * 1.5
                        var cross = Path()
                        cross.move(to: CGPoint(x: baseX - crossSize, y: baseY))
                        cross.addLine(to: CGPoint(x: baseX + crossSize, y: baseY))
                        cross.move(to: CGPoint(x: baseX, y: baseY - crossSize))
                        cross.addLine(to: CGPoint(x: baseX, y: baseY + crossSize))
                        context.opacity = (pulse - 0.7) * 2.0
                        context.stroke(cross, with: .color(.white.opacity(0.6)), lineWidth: 0.5)
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .transition(.opacity)
    }

    private func runSequence() {
        withAnimation(.easeInOut(duration: 2.5)) {
            bgShift = true
        }

        withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
            circleOpacity = 0.7
        }

        withAnimation(.easeInOut(duration: 1.8).delay(0.3)) {
            strokeProgress = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation(.easeIn(duration: 0.4)) {
                decorativeLines = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.4) {
            withAnimation(.easeIn(duration: 0.3)) {
                sparklesActive = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.4) {
            withAnimation(.easeIn(duration: 0.7)) {
                circleScale = 12.0
                circleOpacity = 1.0
                envelopeActive = true
            }
            withAnimation(.easeIn(duration: 0.5).delay(0.15)) {
                contentOpacity = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            onFinished()
        }
    }
}

struct HandwrittenUnderline: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let mid = h * 0.5

        path.move(to: CGPoint(x: 0, y: mid))
        path.addCurve(
            to: CGPoint(x: w * 0.25, y: mid - 3),
            control1: CGPoint(x: w * 0.08, y: mid + 4),
            control2: CGPoint(x: w * 0.18, y: mid - 5)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.55, y: mid + 2),
            control1: CGPoint(x: w * 0.35, y: mid),
            control2: CGPoint(x: w * 0.45, y: mid + 5)
        )
        path.addCurve(
            to: CGPoint(x: w * 0.8, y: mid - 2),
            control1: CGPoint(x: w * 0.65, y: mid - 1),
            control2: CGPoint(x: w * 0.72, y: mid - 4)
        )
        path.addCurve(
            to: CGPoint(x: w, y: mid + 1),
            control1: CGPoint(x: w * 0.88, y: mid),
            control2: CGPoint(x: w * 0.95, y: mid + 3)
        )
        return path
    }
}
