import SwiftUI

struct RankBadgeSheet: View {
    let currentRank: WalkerRank
    let totalSteps: Int
    @State private var appeared: Bool = false

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 8) {
                    Text("Walker Ranks")
                        .font(.custom(FontRegistration.keshia, size: 28))
                    Text("keep walking to unlock new titles")
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(.secondary)
                }
                .padding(.top, 8)

                ForEach(Array(WalkerRank.allCases.enumerated()), id: \.element) { index, rank in
                    let isUnlocked = totalSteps >= rank.stepsRequired
                    let isCurrent = rank == currentRank

                    HStack(spacing: 14) {
                        ZStack {
                            Circle()
                                .fill(isUnlocked ? rankColor(rank).opacity(0.15) : Color(.systemGray6))
                                .frame(width: 52, height: 52)

                            if isCurrent {
                                Circle()
                                    .stroke(rankColor(rank), lineWidth: 2)
                                    .frame(width: 56, height: 56)
                            }

                            Image(systemName: rank.icon)
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundStyle(isUnlocked ? rankColor(rank) : Color(.systemGray4))
                        }

                        VStack(alignment: .leading, spacing: 3) {
                            HStack(spacing: 6) {
                                Text(rank.title)
                                    .font(.system(.headline, design: .serif))
                                    .foregroundStyle(isUnlocked ? .primary : .tertiary)

                                if isCurrent {
                                    Text("current")
                                        .font(.system(.caption2, design: .serif, weight: .semibold))
                                        .foregroundStyle(rankColor(rank))
                                        .padding(.horizontal, 6)
                                        .padding(.vertical, 2)
                                        .background(rankColor(rank).opacity(0.12), in: Capsule())
                                }
                            }

                            if rank.stepsRequired > 0 {
                                Text("\(rank.stepsRequired.formatted()) steps")
                                    .font(.system(.caption, design: .serif))
                                    .foregroundStyle(isUnlocked ? .secondary : .quaternary)
                            } else {
                                Text("Starting rank")
                                    .font(.system(.caption, design: .serif))
                                    .foregroundStyle(.secondary)
                            }

                            if !isUnlocked {
                                let remaining = rank.stepsRequired - totalSteps
                                let progress = min(1.0, Double(totalSteps) / Double(max(1, rank.stepsRequired)))
                                VStack(alignment: .leading, spacing: 2) {
                                    GeometryReader { geo in
                                        RoundedRectangle(cornerRadius: 2)
                                            .fill(Color(.systemGray5))
                                            .frame(height: 4)
                                            .overlay(alignment: .leading) {
                                                RoundedRectangle(cornerRadius: 2)
                                                    .fill(rankColor(rank).opacity(0.4))
                                                    .frame(width: geo.size.width * progress, height: 4)
                                            }
                                    }
                                    .frame(height: 4)

                                    Text("\(remaining.formatted()) steps to go")
                                        .font(.system(size: 10, design: .serif))
                                        .foregroundStyle(.quaternary)
                                }
                            }
                        }

                        Spacer()

                        if isUnlocked {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.title3)
                                .foregroundStyle(rankColor(rank))
                        }
                    }
                    .padding(14)
                    .background(
                        isCurrent ? rankColor(rank).opacity(0.06) : Color.clear,
                        in: .rect(cornerRadius: 16)
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(isCurrent ? rankColor(rank).opacity(0.2) : .clear, lineWidth: 1)
                    )
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 12)
                    .animation(.spring(response: 0.4).delay(Double(index) * 0.05), value: appeared)
                }

                Spacer(minLength: 20)
            }
            .padding(.horizontal)
        }
        .onAppear { appeared = true }
    }

    private func rankColor(_ rank: WalkerRank) -> Color {
        switch rank {
        case .daydreamWalker: WhimsicalTheme.blushPink
        case .petalStroller: WhimsicalTheme.deepRose
        case .meadowWanderer: WhimsicalTheme.deepSage
        case .starlitExplorer: WhimsicalTheme.deepLavender
        case .moonlitRambler: WhimsicalTheme.lavender
        case .enchantedTrailblazer: WhimsicalTheme.deepPeach
        case .celestialVoyager: Color(red: 0.85, green: 0.65, blue: 0.2)
        }
    }
}
