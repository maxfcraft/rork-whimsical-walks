import SwiftUI

struct JourneyMilestone: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let type: MilestoneType
    let isReached: Bool
    let progress: Double
    let spriteIndex: Int?

    enum MilestoneType {
        case start
        case steps
        case pet
        case rank
        case current
    }
}

struct JourneyTimelineView: View {
    let dataService: DataService
    @State private var appeared: Bool = false
    @State private var selectedMilestone: JourneyMilestone?

    private var milestones: [JourneyMilestone] {
        var items: [JourneyMilestone] = []
        let totalSteps = dataService.stats.totalStepsAllTime

        items.append(JourneyMilestone(
            title: "Journey Begins",
            subtitle: dataService.stats.joinDate.formatted(.dateTime.month(.wide).day().year()),
            icon: "heart.fill",
            type: .start,
            isReached: true,
            progress: 1.0,
            spriteIndex: nil
        ))

        let stepMilestones: [(Int, String)] = [
            (5_000, "First Adventure"),
            (10_000, "Getting Warmer"),
            (25_000, "Trail Finder"),
            (50_000, "Path Pioneer"),
            (100_000, "Horizon Chaser"),
            (250_000, "Distance Dreamer"),
            (500_000, "World Walker"),
            (1_000_000, "Million Step Club"),
        ]

        var allEvents: [(steps: Int, milestone: JourneyMilestone)] = []

        for (steps, name) in stepMilestones {
            let reached = totalSteps >= steps
            let prog = reached ? 1.0 : min(1.0, Double(totalSteps) / Double(steps))
            allEvents.append((steps, JourneyMilestone(
                title: name,
                subtitle: "\(steps.formatted()) steps",
                icon: "shoeprints.fill",
                type: .steps,
                isReached: reached,
                progress: prog,
                spriteIndex: nil
            )))
        }

        for pet in dataService.pets where pet.stepsToUnlock > 0 {
            let reached = pet.isOwned
            let prog = reached ? 1.0 : min(1.0, Double(totalSteps) / Double(pet.stepsToUnlock))
            let unlockRecord = dataService.stats.petUnlockHistory.first { $0.petSpriteIndex == pet.spriteIndex }
            let dateStr = unlockRecord.map { $0.dateUnlocked.formatted(.dateTime.month(.abbreviated).day()) } ?? "\(pet.stepsToUnlock.formatted()) steps"
            allEvents.append((pet.stepsToUnlock, JourneyMilestone(
                title: pet.name,
                subtitle: reached ? "Unlocked \(dateStr)" : dateStr,
                icon: "pawprint.fill",
                type: .pet,
                isReached: reached,
                progress: prog,
                spriteIndex: pet.spriteIndex
            )))
        }

        for rank in WalkerRank.allCases where rank.stepsRequired > 0 {
            let reached = totalSteps >= rank.stepsRequired
            let prog = reached ? 1.0 : min(1.0, Double(totalSteps) / Double(rank.stepsRequired))
            allEvents.append((rank.stepsRequired, JourneyMilestone(
                title: rank.title,
                subtitle: "\(rank.stepsRequired.formatted()) steps",
                icon: rank.icon,
                type: .rank,
                isReached: reached,
                progress: prog,
                spriteIndex: nil
            )))
        }

        allEvents.sort { $0.steps < $1.steps }

        for event in allEvents {
            items.append(event.milestone)
        }

        return items
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Image(systemName: "map.fill")
                    .foregroundStyle(WhimsicalTheme.deepRose)
                Text("Your Journey")
                    .font(.custom(FontRegistration.keshia, size: 22))
            }
            .padding(.bottom, 16)

            GeometryReader { geo in
                let width = geo.size.width
                ScrollView(.vertical, showsIndicators: false) {
                    ZStack(alignment: .topLeading) {
                        JourneyWindingPath(
                            nodeCount: milestones.count,
                            width: width,
                            totalSteps: dataService.stats.totalStepsAllTime,
                            milestones: milestones
                        )

                        VStack(spacing: 0) {
                            ForEach(Array(milestones.enumerated()), id: \.element.id) { index, milestone in
                                let isLeft = index % 2 == 0
                                milestoneNode(milestone, index: index, isLeft: isLeft, width: width)
                                    .opacity(appeared ? 1 : 0)
                                    .offset(x: appeared ? 0 : (isLeft ? -20 : 20))
                                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.06), value: appeared)
                            }
                        }
                    }
                    .padding(.bottom, 40)
                }
            }
        }
        .onAppear { appeared = true }
    }

    private func milestoneNode(_ milestone: JourneyMilestone, index: Int, isLeft: Bool, width: CGFloat) -> some View {
        let nodeSize: CGFloat = 44
        let rowHeight: CGFloat = 80

        return HStack(spacing: 0) {
            if !isLeft { Spacer(minLength: 0) }

            if isLeft {
                milestoneContent(milestone)
                    .frame(width: width * 0.38, alignment: .trailing)
                Spacer(minLength: 8)
            }

            ZStack {
                if milestone.isReached {
                    Circle()
                        .fill(milestoneColor(milestone).opacity(0.2))
                        .frame(width: nodeSize + 8, height: nodeSize + 8)
                }

                Circle()
                    .fill(milestone.isReached ? milestoneColor(milestone) : Color(.systemGray5))
                    .frame(width: nodeSize, height: nodeSize)
                    .shadow(color: milestone.isReached ? milestoneColor(milestone).opacity(0.3) : .clear, radius: 6, y: 2)

                if milestone.type == .pet, let spriteIndex = milestone.spriteIndex,
                   let position = PetSpritePosition(rawValue: spriteIndex), milestone.isReached {
                    PetSpriteView(position: position, size: 32)
                } else {
                    Image(systemName: milestone.icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(milestone.isReached ? .white : Color(.systemGray3))
                }
            }
            .frame(width: nodeSize + 8)

            if !isLeft {
                Spacer(minLength: 8)
                milestoneContent(milestone)
                    .frame(width: width * 0.38, alignment: .leading)
            }

            if isLeft { Spacer(minLength: 0) }
        }
        .frame(height: rowHeight)
        .sensoryFeedback(.selection, trigger: selectedMilestone?.id)
        .onTapGesture {
            selectedMilestone = milestone
        }
    }

    private func milestoneContent(_ milestone: JourneyMilestone) -> some View {
        VStack(alignment: milestone.type == .start ? .center : .leading, spacing: 2) {
            Text(milestone.title)
                .font(.system(.caption, design: .serif, weight: .semibold))
                .foregroundStyle(milestone.isReached ? .primary : .tertiary)
                .lineLimit(1)
                .minimumScaleFactor(0.8)

            Text(milestone.subtitle)
                .font(.system(.caption2, design: .serif))
                .foregroundStyle(milestone.isReached ? .secondary : .quaternary)
                .lineLimit(1)
                .minimumScaleFactor(0.7)

            if !milestone.isReached && milestone.progress > 0 {
                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color(.systemGray5))
                        .frame(height: 3)
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(milestoneColor(milestone).opacity(0.5))
                                .frame(width: geo.size.width * milestone.progress, height: 3)
                        }
                }
                .frame(height: 3)
                .frame(maxWidth: 80)
            }
        }
    }

    private func milestoneColor(_ milestone: JourneyMilestone) -> Color {
        switch milestone.type {
        case .start: WhimsicalTheme.deepRose
        case .steps: WhimsicalTheme.deepSage
        case .pet: WhimsicalTheme.deepLavender
        case .rank: WhimsicalTheme.deepPeach
        case .current: WhimsicalTheme.deepRose
        }
    }
}

struct JourneyWindingPath: View {
    let nodeCount: Int
    let width: CGFloat
    let totalSteps: Int
    let milestones: [JourneyMilestone]

    var body: some View {
        Canvas { context, size in
            let rowHeight: CGFloat = 80
            let centerX = width / 2
            let swingAmount = width * 0.15

            guard nodeCount > 1 else { return }

            var pathPoints: [CGPoint] = []
            for i in 0..<nodeCount {
                let y = CGFloat(i) * rowHeight + rowHeight / 2
                let isLeft = i % 2 == 0
                let x = isLeft ? centerX - swingAmount * 0.1 : centerX + swingAmount * 0.1
                pathPoints.append(CGPoint(x: x, y: y))
            }

            let bgPath = Path { p in
                guard let first = pathPoints.first else { return }
                p.move(to: first)
                for i in 1..<pathPoints.count {
                    let prev = pathPoints[i - 1]
                    let curr = pathPoints[i]
                    let midY = (prev.y + curr.y) / 2
                    let ctrl1 = CGPoint(x: prev.x + (i % 2 == 0 ? swingAmount : -swingAmount), y: midY - 10)
                    let ctrl2 = CGPoint(x: curr.x + (i % 2 == 0 ? -swingAmount * 0.5 : swingAmount * 0.5), y: midY + 10)
                    p.addCurve(to: curr, control1: ctrl1, control2: ctrl2)
                }
            }

            context.stroke(
                bgPath,
                with: .color(WhimsicalTheme.blushPink.opacity(0.4)),
                style: StrokeStyle(lineWidth: 4, lineCap: .round, dash: [8, 6])
            )

            let lastReachedIndex = milestones.lastIndex(where: { $0.isReached }) ?? 0
            if lastReachedIndex > 0 {
                let progressPath = Path { p in
                    p.move(to: pathPoints[0])
                    for i in 1...min(lastReachedIndex, pathPoints.count - 1) {
                        let prev = pathPoints[i - 1]
                        let curr = pathPoints[i]
                        let midY = (prev.y + curr.y) / 2
                        let ctrl1 = CGPoint(x: prev.x + (i % 2 == 0 ? swingAmount : -swingAmount), y: midY - 10)
                        let ctrl2 = CGPoint(x: curr.x + (i % 2 == 0 ? -swingAmount * 0.5 : swingAmount * 0.5), y: midY + 10)
                        p.addCurve(to: curr, control1: ctrl1, control2: ctrl2)
                    }
                }

                context.stroke(
                    progressPath,
                    with: .linearGradient(
                        Gradient(colors: [WhimsicalTheme.deepRose, WhimsicalTheme.deepLavender]),
                        startPoint: pathPoints[0],
                        endPoint: pathPoints[min(lastReachedIndex, pathPoints.count - 1)]
                    ),
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
            }

            for i in stride(from: 0, to: nodeCount, by: 3) {
                let y = CGFloat(i) * rowHeight + rowHeight / 2
                let flowerX = i % 2 == 0 ? centerX + swingAmount * 1.5 : centerX - swingAmount * 1.5
                drawTinyFlower(context: context, at: CGPoint(x: flowerX, y: y + 10), size: 6)
            }
        }
        .frame(height: CGFloat(nodeCount) * 80)
        .allowsHitTesting(false)
    }

    private func drawTinyFlower(context: GraphicsContext, at point: CGPoint, size: CGFloat) {
        let petalCount = 5
        for i in 0..<petalCount {
            let angle = Double(i) * (2.0 * .pi / Double(petalCount)) - .pi / 2
            let petalX = point.x + cos(angle) * size
            let petalY = point.y + sin(angle) * size
            let petalRect = CGRect(x: petalX - 2, y: petalY - 2, width: 4, height: 4)
            context.fill(Ellipse().path(in: petalRect), with: .color(WhimsicalTheme.blushPink.opacity(0.3)))
        }
        let centerRect = CGRect(x: point.x - 1.5, y: point.y - 1.5, width: 3, height: 3)
        context.fill(Circle().path(in: centerRect), with: .color(WhimsicalTheme.deepRose.opacity(0.3)))
    }
}
