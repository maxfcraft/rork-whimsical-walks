import SwiftUI

struct PetsView: View {
    let dataService: DataService
    @State private var appeared: Bool = false
    @State private var selectedPet: Pet?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection
                totalStepsDisplay
                activePetSection

                LazyVGrid(columns: [GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14), GridItem(.flexible(), spacing: 14)], spacing: 14) {
                    ForEach(Array(dataService.pets.enumerated()), id: \.element.id) { index, pet in
                        PetCard(pet: pet, totalSteps: dataService.stats.totalStepsAllTime, onTap: {
                            if pet.isOwned {
                                dataService.setActivePet(pet)
                            } else {
                                selectedPet = pet
                            }
                        })
                        .opacity(appeared ? 1 : 0)
                        .offset(y: appeared ? 0 : 20)
                        .animation(.spring(response: 0.4).delay(Double(index) * 0.05), value: appeared)
                    }
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .background { WhimsicalBackground(screen: .pets) }
        .onAppear { appeared = true }
        .sheet(item: $selectedPet) { pet in
            PetPurchaseSheet(pet: pet, dataService: dataService)
                .presentationDetents([.height(420)])
                .presentationDragIndicator(.visible)
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            WhimsicalTitle("Pets")
            WhimsicalSubtitle("unlock companions by walking")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var totalStepsDisplay: some View {
        HStack(spacing: 6) {
            Image(systemName: "figure.walk")
                .foregroundStyle(WhimsicalTheme.deepRose)
            Text("\(dataService.stats.totalStepsAllTime.formatted()) total steps")
                .font(.system(.headline, design: .serif))
                .foregroundStyle(.primary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(WhimsicalTheme.cardBackground, in: Capsule())
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var activePetSection: some View {
        if let pet = dataService.activePet,
           let position = PetSpritePosition(rawValue: pet.spriteIndex) {
            HStack(spacing: 12) {
                PetSpriteView(position: position, size: 50)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Active Companion")
                        .font(.system(.caption, design: .serif))
                        .foregroundStyle(.secondary)
                    Text(pet.name)
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(.primary)
                }
                Spacer()
                starRatingView(pet.starRating)
            }
            .padding(16)
            .background(WhimsicalTheme.cardBackground, in: .rect(cornerRadius: 20))
        }
    }

    private func starRatingView(_ rating: Int) -> some View {
        HStack(spacing: 2) {
            ForEach(0..<rating, id: \.self) { _ in
                Image(systemName: "star.fill")
                    .font(.caption2)
                    .foregroundStyle(.yellow)
            }
        }
    }
}

struct PetCard: View {
    let pet: Pet
    let totalSteps: Int
    let onTap: () -> Void

    private var unlockProgress: Double {
        guard pet.stepsToUnlock > 0 else { return 1.0 }
        return min(1.0, Double(totalSteps) / Double(pet.stepsToUnlock))
    }

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                if let position = PetSpritePosition(rawValue: pet.spriteIndex) {
                    PetSpriteView(position: position, size: 56)
                        .opacity(pet.isOwned ? 1.0 : 0.4)
                }

                Text(pet.name)
                    .font(.system(.caption, design: .serif, weight: .semibold))
                    .foregroundStyle(pet.isOwned ? .primary : .secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                HStack(spacing: 1) {
                    ForEach(0..<pet.starRating, id: \.self) { _ in
                        Image(systemName: "star.fill")
                            .font(.system(size: 8))
                            .foregroundStyle(.yellow)
                    }
                }

                if pet.isOwned {
                    if pet.isActive {
                        Text("Active")
                            .font(.system(.caption2, design: .serif, weight: .semibold))
                            .foregroundStyle(WhimsicalTheme.deepSage)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(WhimsicalTheme.sageGreen.opacity(0.4), in: Capsule())
                    } else {
                        Text("Owned")
                            .font(.system(.caption2, design: .serif))
                            .foregroundStyle(.secondary)
                    }
                } else {
                    VStack(spacing: 2) {
                        Text("\(pet.stepsToUnlock.formatted())")
                            .font(.system(.caption2, design: .serif, weight: .semibold))
                            .foregroundStyle(.primary)
                        Text("steps")
                            .font(.system(size: 9, design: .serif))
                            .foregroundStyle(.tertiary)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .padding(.horizontal, 4)
            .background(WhimsicalTheme.cardBackground, in: .rect(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
