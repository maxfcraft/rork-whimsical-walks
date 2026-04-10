import SwiftUI

struct PolaroidRevealView: View {
    let polaroid: Polaroid
    let onComplete: () -> Void

    @State private var phase: RevealPhase = .idle
    @State private var bgShift: Bool = false
    @State private var sparklesActive: Bool = false
    @State private var scanLineY: CGFloat = 0
    @State private var scanActive: Bool = false
    @State private var photoRotation: Double = 0
    @State private var photoScale: CGFloat = 0.6
    @State private var photoBlur: CGFloat = 20
    @State private var photoOpacity: Double = 0
    @State private var scanText: String = "Initializing..."
    @State private var scanTextOpacity: Double = 0
    @State private var checkmarkScale: CGFloat = 0
    @State private var checkmarkOpacity: Double = 0
    @State private var overlayOpacity: Double = 1.0
    @State private var scanLineOpacity: Double = 0

    private enum RevealPhase {
        case idle, scanning, revealing, complete
    }

    var body: some View {
        ZStack {
            meshBackground

            if sparklesActive {
                sparkleOverlay
            }

            VStack(spacing: 24) {
                Spacer()

                ZStack {
                    polaroidFrame
                        .scaleEffect(photoScale)
                        .rotation3DEffect(.degrees(photoRotation), axis: (x: 0, y: 1, z: 0))
                        .opacity(photoOpacity)

                    if scanActive {
                        scannerOverlay
                    }

                    if phase == .complete {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.white)
                            .shadow(color: WhimsicalTheme.deepRose.opacity(0.6), radius: 12)
                            .scaleEffect(checkmarkScale)
                            .opacity(checkmarkOpacity)
                    }
                }

                Text(scanText)
                    .font(.system(.subheadline, design: .serif, weight: .medium))
                    .foregroundStyle(.white.opacity(0.9))
                    .opacity(scanTextOpacity)
                    .contentTransition(.opacity)

                Spacer()
            }
        }
        .ignoresSafeArea()
        .onAppear { runRevealSequence() }
    }

    private var meshBackground: some View {
        MeshGradient(
            width: 3, height: 3,
            points: [
                [0, 0], [0.5, 0], [1, 0],
                [0, 0.5], [0.5, 0.5], [1, 0.5],
                [0, 1], [0.5, 1], [1, 1]
            ],
            colors: bgShift ? [
                WhimsicalTheme.deepRose.opacity(0.7),
                WhimsicalTheme.deepLavender.opacity(0.8),
                WhimsicalTheme.blushPink.opacity(0.6),
                WhimsicalTheme.lavender.opacity(0.7),
                WhimsicalTheme.deepRose.opacity(0.9),
                WhimsicalTheme.deepLavender.opacity(0.6),
                WhimsicalTheme.blushPink.opacity(0.5),
                WhimsicalTheme.deepRose.opacity(0.7),
                WhimsicalTheme.lavender.opacity(0.8)
            ] : [
                WhimsicalTheme.blushPink.opacity(0.3),
                WhimsicalTheme.lavender.opacity(0.2),
                WhimsicalTheme.cream.opacity(0.5),
                WhimsicalTheme.deepRose.opacity(0.2),
                WhimsicalTheme.blushPink.opacity(0.4),
                WhimsicalTheme.lavender.opacity(0.3),
                WhimsicalTheme.cream.opacity(0.4),
                WhimsicalTheme.blushPink.opacity(0.3),
                WhimsicalTheme.deepRose.opacity(0.2)
            ]
        )
    }

    private var polaroidFrame: some View {
        VStack(spacing: 0) {
            Color(WhimsicalTheme.difficultyColor(polaroid.difficulty)).opacity(0.3)
                .frame(width: 240, height: 280)
                .overlay {
                    if let image = PhotoManager.loadPhoto(named: polaroid.imagePath) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: photoBlur)
                            .allowsHitTesting(false)
                    } else {
                        Image(systemName: "photo")
                            .font(.system(size: 48))
                            .foregroundStyle(.white.opacity(0.5))
                    }
                }
                .clipShape(.rect(cornerRadius: 4))
                .padding(.horizontal, 12)
                .padding(.top, 12)

            VStack(spacing: 4) {
                if !polaroid.questTitle.isEmpty {
                    Text(polaroid.questTitle)
                        .font(.system(.caption, design: .serif, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }
                Text(polaroid.dateTaken.formatted(date: .abbreviated, time: .omitted))
                    .font(.system(.caption2, design: .serif))
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 12)
        }
        .background(.white, in: .rect(cornerRadius: 8))
        .shadow(color: .black.opacity(0.2), radius: 20, y: 10)
    }

    private var scannerOverlay: some View {
        GeometryReader { geo in
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(WhimsicalTheme.deepRose.opacity(0.6), lineWidth: 2)
                    .frame(width: 264, height: 340)
                    .position(x: geo.size.width / 2, y: geo.size.height / 2)

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
                    .frame(width: 260, height: 4)
                    .opacity(scanLineOpacity)
                    .position(x: geo.size.width / 2, y: scanLineY)
            }
        }
    }

    private var sparkleOverlay: some View {
        TimelineView(.animation(minimumInterval: 0.04)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                for i in 0..<20 {
                    let seed = Double(i) * 137.508
                    let baseX = (sin(seed + time * 0.8) * 0.4 + 0.5) * size.width
                    let baseY = (cos(seed * 0.7 + time * 0.5) * 0.4 + 0.5) * size.height
                    let pulse = sin(time * 3.0 + seed) * 0.5 + 0.5
                    let sparkSize = 2.0 + pulse * 6.0
                    let rect = CGRect(x: baseX - sparkSize / 2, y: baseY - sparkSize / 2, width: sparkSize, height: sparkSize)
                    context.opacity = pulse * 0.8
                    let colors: [Color] = [.white, WhimsicalTheme.blushPink, WhimsicalTheme.lavender, .white, WhimsicalTheme.warmPeach]
                    context.fill(Path(ellipseIn: rect), with: .color(colors[i % colors.count]))

                    if pulse > 0.7 {
                        let crossSize = sparkSize * 1.5
                        var cross = Path()
                        cross.move(to: CGPoint(x: baseX - crossSize, y: baseY))
                        cross.addLine(to: CGPoint(x: baseX + crossSize, y: baseY))
                        cross.move(to: CGPoint(x: baseX, y: baseY - crossSize))
                        cross.addLine(to: CGPoint(x: baseX, y: baseY + crossSize))
                        context.opacity = (pulse - 0.7) * 2.5
                        context.stroke(cross, with: .color(.white.opacity(0.8)), lineWidth: 0.5)
                    }
                }
            }
        }
        .allowsHitTesting(false)
    }

    private func runRevealSequence() {
        withAnimation(.easeInOut(duration: 1.5)) {
            bgShift = true
        }

        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.2)) {
            photoOpacity = 1.0
            photoScale = 1.0
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeIn(duration: 0.3)) {
                sparklesActive = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            phase = .scanning
            scanActive = true
            withAnimation(.easeIn(duration: 0.3)) {
                scanTextOpacity = 1.0
                scanLineOpacity = 1.0
            }
            animateScanLine()
            cycleScanTexts()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.2) {
            phase = .revealing
            withAnimation(.easeOut(duration: 0.3)) {
                scanActive = false
                scanLineOpacity = 0
            }

            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                photoRotation = 360
            }

            withAnimation(.easeOut(duration: 1.0)) {
                photoBlur = 0
            }

            withAnimation(.easeInOut(duration: 0.3)) {
                scanText = "Memory unlocked"
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 4.2) {
            phase = .complete
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                checkmarkScale = 1.0
                checkmarkOpacity = 1.0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
            withAnimation(.easeOut(duration: 0.4)) {
                overlayOpacity = 0
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 5.4) {
            onComplete()
        }
    }

    private func animateScanLine() {
        let screenHeight = UIScreen.main.bounds.height
        let centerY = screenHeight / 2
        let startY = centerY - 170
        let endY = centerY + 170

        scanLineY = startY

        func sweep() {
            guard scanActive else { return }
            withAnimation(.easeInOut(duration: 0.8)) {
                scanLineY = endY
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                guard scanActive else { return }
                withAnimation(.easeInOut(duration: 0.8)) {
                    scanLineY = startY
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                    sweep()
                }
            }
        }

        sweep()
    }

    private func cycleScanTexts() {
        let texts = [
            "Sprinkling fairy dust...",
            "Adding fantasy filter...",
            "Weaving in the whimsy...",
            "Making it dreamy..."
        ]
        var index = 0

        func next() {
            guard phase == .scanning else { return }
            withAnimation(.easeInOut(duration: 0.2)) {
                scanText = texts[index % texts.count]
            }
            index += 1
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                next()
            }
        }

        next()
    }
}
