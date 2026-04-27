import SwiftUI
import Foundation

struct PetPlatformView: View {
    let ownedPets: [Pet]
    @Environment(\.colorScheme) private var colorScheme
    @State private var appeared: Bool = false
    @State private var floatPhase: Bool = false

    private var displayPets: [Pet] {
        Array(ownedPets.prefix(5))
    }

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            let h = geo.size.height

            ZStack(alignment: .bottom) {
                grassHills(width: w, height: h)

                petRow(width: w, height: h)

                doodleAccents(width: w, height: h)
            }
        }
        .frame(height: 200)
        .onAppear {
            appeared = true
            withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
                floatPhase = true
            }
        }
    }

    private var backHillColors: [Color] {
        if colorScheme == .dark {
            return [
                Color(red: 0.28, green: 0.18, blue: 0.42).opacity(0.55),
                Color(red: 0.18, green: 0.10, blue: 0.30).opacity(0.30)
            ]
        }
        return [
            WhimsicalTheme.sageGreen.opacity(0.18),
            WhimsicalTheme.sageGreen.opacity(0.08)
        ]
    }

    private var midHillColors: [Color] {
        if colorScheme == .dark {
            return [
                Color(red: 0.36, green: 0.22, blue: 0.50).opacity(0.65),
                Color(red: 0.24, green: 0.14, blue: 0.36).opacity(0.45)
            ]
        }
        return [
            WhimsicalTheme.blushPink.opacity(0.25),
            WhimsicalTheme.warmPeach.opacity(0.12)
        ]
    }

    private var frontHillColors: [Color] {
        if colorScheme == .dark {
            return [
                Color(red: 0.46, green: 0.28, blue: 0.62),
                Color(red: 0.22, green: 0.12, blue: 0.34)
            ]
        }
        return [
            WhimsicalTheme.groundCream,
            WhimsicalTheme.blushPink.opacity(0.2)
        ]
    }

    private var frontHillStroke: Color {
        colorScheme == .dark
            ? Color(red: 0.70, green: 0.55, blue: 0.90).opacity(0.35)
            : WhimsicalTheme.deepRose.opacity(0.12)
    }

    private var frontHillShadow: Color {
        colorScheme == .dark
            ? Color(red: 0.55, green: 0.35, blue: 0.85).opacity(0.35)
            : WhimsicalTheme.deepRose.opacity(0.08)
    }

    private func grassHills(width w: CGFloat, height h: CGFloat) -> some View {
        ZStack {
            WhimsicalHillShape(variant: .back)
                .fill(
                    LinearGradient(
                        colors: backHillColors,
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .frame(height: h * 0.85)
                .offset(y: h * 0.15)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.8).delay(0.1), value: appeared)

            WhimsicalHillShape(variant: .mid)
                .fill(
                    LinearGradient(
                        colors: midHillColors,
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .frame(height: h * 0.7)
                .offset(y: h * 0.3)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.8).delay(0.2), value: appeared)

            WhimsicalHillShape(variant: .front)
                .fill(
                    LinearGradient(
                        colors: frontHillColors,
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .shadow(color: frontHillShadow, radius: 12, x: 0, y: -6)
                .frame(height: h * 0.55)
                .offset(y: h * 0.45)
                .opacity(appeared ? 1 : 0)
                .animation(.easeOut(duration: 0.8).delay(0.3), value: appeared)

            WhimsicalHillShape(variant: .front)
                .stroke(
                    frontHillStroke,
                    style: StrokeStyle(lineWidth: 1.5, lineCap: .round, dash: [6, 4])
                )
                .frame(height: h * 0.55)
                .offset(y: h * 0.45)
                .opacity(appeared ? 0.8 : 0)
                .animation(.easeOut(duration: 1.0).delay(0.5), value: appeared)
        }
    }

    private func petRow(width w: CGFloat, height h: CGFloat) -> some View {
        HStack(spacing: -18) {
            ForEach(Array(displayPets.enumerated()), id: \.element.id) { index, pet in
                petFigure(pet: pet, index: index)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .offset(y: -h * 0.18)
    }

    private func petFigure(pet: Pet, index: Int) -> some View {
        VStack(spacing: 4) {
            if let position = PetSpritePosition(rawValue: pet.spriteIndex) {
                PetSpriteView(position: position, size: 91)
                    .padding(4)
                    .shadow(color: .black.opacity(0.1), radius: 6, x: 0, y: 4)
                    .shadow(color: WhimsicalTheme.deepRose.opacity(0.15), radius: 10, x: 0, y: 3)
                    .offset(y: floatPhase ? -3 : 3)
                    .animation(
                        .easeInOut(duration: 2.0 + Double(index) * 0.3)
                        .repeatForever(autoreverses: true)
                        .delay(Double(index) * 0.2),
                        value: floatPhase
                    )
            }

            Ellipse()
                .fill(
                    RadialGradient(
                        colors: [
                            .black.opacity(0.08),
                            .black.opacity(0.0)
                        ],
                        center: .center,
                        startRadius: 0,
                        endRadius: 18
                    )
                )
                .frame(width: 63, height: 14)
                .scaleEffect(x: floatPhase ? 0.85 : 1.1)
                .animation(
                    .easeInOut(duration: 2.0 + Double(index) * 0.3)
                    .repeatForever(autoreverses: true)
                    .delay(Double(index) * 0.2),
                    value: floatPhase
                )

            if pet.isActive {
                Text(pet.name.components(separatedBy: " ").first ?? "")
                    .font(.system(.caption2, design: .serif, weight: .medium))
                    .foregroundStyle(WhimsicalTheme.deepRose)
            }
        }
        .opacity(appeared ? 1 : 0)
        .scaleEffect(appeared ? 1 : 0.6)
        .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.4 + Double(index) * 0.1), value: appeared)
    }

    private func doodleAccents(width w: CGFloat, height h: CGFloat) -> some View {
        ZStack {
            tinyFlower(at: CGPoint(x: w * 0.08, y: h * 0.65), rotation: -15)
            tinyFlower(at: CGPoint(x: w * 0.92, y: h * 0.7), rotation: 10)
            tinyFlower(at: CGPoint(x: w * 0.5, y: h * 0.78), rotation: 5)

            sparkle(at: CGPoint(x: w * 0.2, y: h * 0.35))
            sparkle(at: CGPoint(x: w * 0.78, y: h * 0.28))
            sparkle(at: CGPoint(x: w * 0.55, y: h * 0.22))
        }
        .opacity(appeared ? 1 : 0)
        .animation(.easeOut(duration: 1.2).delay(0.6), value: appeared)
    }

    private func tinyFlower(at point: CGPoint, rotation: Double) -> some View {
        TinyDoodleFlower()
            .stroke(WhimsicalTheme.deepRose.opacity(0.2), lineWidth: 1)
            .frame(width: 14, height: 14)
            .rotationEffect(.degrees(rotation))
            .position(point)
    }

    private func sparkle(at point: CGPoint) -> some View {
        Image(systemName: "sparkle")
            .font(.system(size: 8, weight: .light))
            .foregroundStyle(WhimsicalTheme.deepRose.opacity(0.2))
            .position(point)
            .opacity(floatPhase ? 0.4 : 0.15)
    }
}

struct WhimsicalHillShape: Shape {
    let variant: Variant

    enum Variant {
        case front, mid, back
    }

    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height

        switch variant {
        case .front:
            path.move(to: CGPoint(x: 0, y: h * 0.45))
            path.addCurve(
                to: CGPoint(x: w * 0.3, y: h * 0.2),
                control1: CGPoint(x: w * 0.08, y: h * 0.35),
                control2: CGPoint(x: w * 0.18, y: h * 0.15)
            )
            path.addCurve(
                to: CGPoint(x: w * 0.65, y: h * 0.3),
                control1: CGPoint(x: w * 0.42, y: h * 0.25),
                control2: CGPoint(x: w * 0.52, y: h * 0.35)
            )
            path.addCurve(
                to: CGPoint(x: w, y: h * 0.15),
                control1: CGPoint(x: w * 0.78, y: h * 0.25),
                control2: CGPoint(x: w * 0.9, y: h * 0.1)
            )
            path.addLine(to: CGPoint(x: w, y: h))
            path.addLine(to: CGPoint(x: 0, y: h))
            path.closeSubpath()

        case .mid:
            path.move(to: CGPoint(x: 0, y: h * 0.35))
            path.addCurve(
                to: CGPoint(x: w * 0.25, y: h * 0.15),
                control1: CGPoint(x: w * 0.05, y: h * 0.22),
                control2: CGPoint(x: w * 0.15, y: h * 0.1)
            )
            path.addCurve(
                to: CGPoint(x: w * 0.55, y: h * 0.28),
                control1: CGPoint(x: w * 0.35, y: h * 0.2),
                control2: CGPoint(x: w * 0.45, y: h * 0.32)
            )
            path.addCurve(
                to: CGPoint(x: w * 0.8, y: h * 0.12),
                control1: CGPoint(x: w * 0.65, y: h * 0.24),
                control2: CGPoint(x: w * 0.72, y: h * 0.08)
            )
            path.addCurve(
                to: CGPoint(x: w, y: h * 0.25),
                control1: CGPoint(x: w * 0.88, y: h * 0.16),
                control2: CGPoint(x: w * 0.95, y: h * 0.22)
            )
            path.addLine(to: CGPoint(x: w, y: h))
            path.addLine(to: CGPoint(x: 0, y: h))
            path.closeSubpath()

        case .back:
            path.move(to: CGPoint(x: 0, y: h * 0.3))
            path.addCurve(
                to: CGPoint(x: w * 0.35, y: h * 0.1),
                control1: CGPoint(x: w * 0.1, y: h * 0.18),
                control2: CGPoint(x: w * 0.22, y: h * 0.05)
            )
            path.addCurve(
                to: CGPoint(x: w * 0.7, y: h * 0.22),
                control1: CGPoint(x: w * 0.48, y: h * 0.15),
                control2: CGPoint(x: w * 0.6, y: h * 0.28)
            )
            path.addCurve(
                to: CGPoint(x: w, y: h * 0.08),
                control1: CGPoint(x: w * 0.82, y: h * 0.16),
                control2: CGPoint(x: w * 0.92, y: h * 0.05)
            )
            path.addLine(to: CGPoint(x: w, y: h))
            path.addLine(to: CGPoint(x: 0, y: h))
            path.closeSubpath()
        }

        return path
    }
}

struct TinyDoodleFlower: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let center = CGPoint(x: rect.midX, y: rect.midY)
        let r = min(rect.width, rect.height) / 2

        for i in 0..<5 {
            let angle: CGFloat = CGFloat(i) * (2 * .pi / 5) - .pi / 2
            let cosA: CGFloat = CoreGraphics.cos(angle)
            let sinA: CGFloat = CoreGraphics.sin(angle)
            let petalEnd = CGPoint(
                x: center.x + cosA * r,
                y: center.y + sinA * r
            )
            let ctrl1Angle: CGFloat = angle - 0.4
            let ctrl2Angle: CGFloat = angle + 0.4
            let ctrl1 = CGPoint(
                x: center.x + CoreGraphics.cos(ctrl1Angle) * r * 0.7,
                y: center.y + CoreGraphics.sin(ctrl1Angle) * r * 0.7
            )
            let ctrl2 = CGPoint(
                x: center.x + CoreGraphics.cos(ctrl2Angle) * r * 0.7,
                y: center.y + CoreGraphics.sin(ctrl2Angle) * r * 0.7
            )
            path.move(to: center)
            path.addCurve(to: petalEnd, control1: ctrl1, control2: CGPoint(x: petalEnd.x, y: petalEnd.y))
            path.addCurve(to: center, control1: CGPoint(x: petalEnd.x, y: petalEnd.y), control2: ctrl2)
        }

        path.addEllipse(in: CGRect(x: center.x - r * 0.2, y: center.y - r * 0.2, width: r * 0.4, height: r * 0.4))

        return path
    }
}
