import SwiftUI

struct ProfileHighlightsView: View {
    let dataService: DataService
    @State private var appeared: Bool = false

    private var highlights: [HighlightCard] {
        var cards: [HighlightCard] = []
        let stats = dataService.stats

        if stats.currentStreak > 1 {
            cards.append(HighlightCard(
                text: "You're on a \(stats.currentStreak)-day streak!",
                icon: "flame.fill",
                color: WhimsicalTheme.deepRose
            ))
        }

        if stats.longestStreak > 3 {
            cards.append(HighlightCard(
                text: "Longest streak: \(stats.longestStreak) days",
                icon: "trophy.fill",
                color: WhimsicalTheme.deepPeach
            ))
        }

        let ownedCount = dataService.pets.filter(\.isOwned).count
        if ownedCount > 1 {
            cards.append(HighlightCard(
                text: "\(ownedCount) companions by your side",
                icon: "pawprint.fill",
                color: WhimsicalTheme.deepLavender
            ))
        }

        if stats.questsCompleted > 0 {
            cards.append(HighlightCard(
                text: "\(stats.questsCompleted) quests completed",
                icon: "map.fill",
                color: WhimsicalTheme.deepSage
            ))
        }

        let polaroidCount = dataService.polaroids.filter(\.isRevealed).count
        if polaroidCount > 0 {
            cards.append(HighlightCard(
                text: "\(polaroidCount) polaroids revealed",
                icon: "camera.fill",
                color: WhimsicalTheme.deepRose
            ))
        }

        if dataService.daysWalking > 1 {
            cards.append(HighlightCard(
                text: "Walking for \(dataService.daysWalking) days",
                icon: "calendar.badge.clock",
                color: WhimsicalTheme.deepPeach
            ))
        }

        return cards
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 6) {
                DoodleFlowerIcon(size: 16, color: WhimsicalTheme.deepRose.opacity(0.6))
                Text("Highlights")
                    .font(.custom(FontRegistration.keshia, size: 22))
                Spacer()
                DoodleFlowerIcon(size: 16, color: WhimsicalTheme.deepRose.opacity(0.6))
            }

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(Array(highlights.enumerated()), id: \.element.id) { index, card in
                        highlightBubble(card, index: index)
                    }
                }
            }
            .contentMargins(.horizontal, 0)
        }
    }

    private func highlightBubble(_ card: HighlightCard, index: Int) -> some View {
        HStack(spacing: 10) {
            ZStack {
                Circle()
                    .fill(card.color.opacity(0.12))
                    .frame(width: 36, height: 36)
                Image(systemName: card.icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(card.color)
            }

            Text(card.text)
                .font(.system(.caption, design: .serif, weight: .medium))
                .foregroundStyle(.primary)
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .frame(width: 200)
        .background(WhimsicalTheme.cardBackground, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(card.color.opacity(0.1), lineWidth: 1)
        }
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 10)
        .animation(.spring(response: 0.4).delay(Double(index) * 0.08), value: appeared)
        .onAppear { appeared = true }
    }
}

struct HighlightCard: Identifiable {
    let id = UUID()
    let text: String
    let icon: String
    let color: Color
}

struct DoodleFlowerIcon: View {
    let size: CGFloat
    let color: Color

    var body: some View {
        Canvas { context, canvasSize in
            let center = CGPoint(x: canvasSize.width / 2, y: canvasSize.height / 2)
            let r = min(canvasSize.width, canvasSize.height) / 2 * 0.85

            for i in 0..<5 {
                let angle = Double(i) * (2.0 * .pi / 5.0) - .pi / 2
                let petalX = center.x + cos(angle) * r
                let petalY = center.y + sin(angle) * r
                let petalRect = CGRect(
                    x: petalX - r * 0.35,
                    y: petalY - r * 0.35,
                    width: r * 0.7,
                    height: r * 0.7
                )
                context.fill(Ellipse().path(in: petalRect), with: .color(color.opacity(0.5)))
            }

            let centerSize = r * 0.4
            let centerRect = CGRect(
                x: center.x - centerSize,
                y: center.y - centerSize,
                width: centerSize * 2,
                height: centerSize * 2
            )
            context.fill(Circle().path(in: centerRect), with: .color(color))
        }
        .frame(width: size, height: size)
    }
}
