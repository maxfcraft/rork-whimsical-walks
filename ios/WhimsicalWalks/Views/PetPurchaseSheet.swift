import SwiftUI

struct PetPurchaseSheet: View {
    let pet: Pet
    let dataService: DataService
    @Environment(\.dismiss) private var dismiss
    @State private var purchaseSuccess: Bool = false

    private var totalSteps: Int { dataService.stats.totalStepsAllTime }
    private var canUnlock: Bool { totalSteps >= pet.stepsToUnlock }
    private var progress: Double {
        guard pet.stepsToUnlock > 0 else { return 1.0 }
        return min(1.0, Double(totalSteps) / Double(pet.stepsToUnlock))
    }
    private var stepsRemaining: Int { max(0, pet.stepsToUnlock - totalSteps) }

    var body: some View {
        VStack(spacing: 20) {
            if let position = PetSpritePosition(rawValue: pet.spriteIndex) {
                PetSpriteView(position: position, size: 80)
                    .padding(.top, 8)
            }

            VStack(spacing: 4) {
                Text(pet.name)
                    .font(.system(.title3, design: .serif, weight: .bold))
                Text(pet.description)
                    .font(.system(.subheadline, design: .serif))
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }

            HStack(spacing: 1) {
                ForEach(0..<pet.starRating, id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.caption)
                        .foregroundStyle(.yellow)
                }
            }

            VStack(spacing: 8) {
                HStack {
                    Text("\(totalSteps.formatted()) steps")
                        .font(.system(.caption, design: .serif, weight: .medium))
                        .foregroundStyle(.secondary)
                    Spacer()
                    Text("\(pet.stepsToUnlock.formatted()) needed")
                        .font(.system(.caption, design: .serif, weight: .medium))
                        .foregroundStyle(.secondary)
                }

                GeometryReader { geo in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(WhimsicalTheme.blushPink.opacity(0.3))
                        .frame(height: 8)
                        .overlay(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 6)
                                .fill(
                                    LinearGradient(
                                        colors: [WhimsicalTheme.deepRose, WhimsicalTheme.ringPink],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * progress, height: 8)
                        }
                }
                .frame(height: 8)

                if !canUnlock {
                    Text("\(stepsRemaining.formatted()) steps to go!")
                        .font(.system(.callout, design: .serif, weight: .medium))
                        .foregroundStyle(WhimsicalTheme.deepRose.opacity(0.8))
                }
            }
            .padding(.horizontal, 4)

            VStack(spacing: 10) {
                if canUnlock {
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            dataService.checkAndUnlockPets()
                            purchaseSuccess = true
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                            dismiss()
                        }
                    } label: {
                        HStack(spacing: 6) {
                            Image(systemName: "lock.open.fill")
                                .font(.caption)
                            Text("Unlock \(pet.name)!")
                                .font(.system(.body, design: .serif, weight: .semibold))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(WhimsicalTheme.sageGreen.opacity(0.5), in: .rect(cornerRadius: 14))
                        .foregroundStyle(.primary)
                    }
                } else {
                    HStack(spacing: 6) {
                        Image(systemName: "lock.fill")
                            .font(.caption)
                        Text("Keep walking to unlock!")
                            .font(.system(.body, design: .serif, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color.gray.opacity(0.15), in: .rect(cornerRadius: 14))
                    .foregroundStyle(.secondary)
                }

                Button {
                    withAnimation(.spring(response: 0.3)) {
                        dataService.unlockPetInstantly(pet)
                        purchaseSuccess = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
                        dismiss()
                    }
                } label: {
                    HStack(spacing: 6) {
                        Image(systemName: "dollarsign.circle.fill")
                            .font(.callout)
                        Text("Unlock for $1.99")
                            .font(.system(.body, design: .serif, weight: .semibold))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(WhimsicalTheme.blushPink.opacity(0.5), in: .rect(cornerRadius: 14))
                    .foregroundStyle(.primary)
                }
            }
            .padding(.horizontal, 4)

            if purchaseSuccess {
                HStack(spacing: 4) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(WhimsicalTheme.deepSage)
                    Text("Unlocked!")
                        .font(.system(.subheadline, design: .serif, weight: .semibold))
                        .foregroundStyle(WhimsicalTheme.deepSage)
                }
                .transition(.scale.combined(with: .opacity))
            }
        }
        .padding(20)
        .animation(.spring(response: 0.3), value: purchaseSuccess)
    }
}
