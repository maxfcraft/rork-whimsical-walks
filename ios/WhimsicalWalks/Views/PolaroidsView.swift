import SwiftUI
import UIKit
import PhotosUI

struct PolaroidsView: View {
    let dataService: DataService
    let healthService: HealthKitService
    @State private var appeared: Bool = false
    @State private var selectedPolaroid: Polaroid?
    @State private var revealingPolaroid: Polaroid?
    @State private var wallpaperItem: PhotosPickerItem?
    @State private var customWallpaper: UIImage? = WallpaperManager.load()
    @State private var showWallpaperOptions: Bool = false

    private let columns = [GridItem(.flexible(), spacing: 12), GridItem(.flexible(), spacing: 12)]

    private var goalMet: Bool {
        healthService.todaySteps >= dataService.stats.dailyStepGoal
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection

                if dataService.polaroids.isEmpty {
                    emptyState
                } else {
                    LazyVGrid(columns: columns, spacing: 16) {
                        ForEach(Array(dataService.polaroids.enumerated()), id: \.element.id) { index, polaroid in
                            VStack(spacing: 8) {
                                PolaroidCard(polaroid: polaroid)
                                    .onTapGesture {
                                        if polaroid.isRevealed {
                                            selectedPolaroid = polaroid
                                        }
                                    }

                                if !polaroid.isRevealed && goalMet {
                                    Button {
                                        revealingPolaroid = polaroid
                                    } label: {
                                        HStack(spacing: 5) {
                                            Image(systemName: "sparkles")
                                                .font(.caption2)
                                            Text("Unlock Polaroid")
                                                .font(.system(.caption, design: .serif, weight: .semibold))
                                        }
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 14)
                                        .padding(.vertical, 8)
                                        .frame(maxWidth: .infinity)
                                        .background(WhimsicalTheme.deepRose, in: Capsule())
                                    }
                                    .sensoryFeedback(.impact(flexibility: .soft), trigger: revealingPolaroid?.id)
                                }
                            }
                            .opacity(appeared ? 1 : 0)
                            .offset(y: appeared ? 0 : 20)
                            .animation(.spring(response: 0.4).delay(Double(index) * 0.06), value: appeared)
                        }
                    }
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .background { WhimsicalBackground(screen: .polaroids, customImage: customWallpaper) }
        .onAppear {
            appeared = true
        }
        .sheet(item: $selectedPolaroid) { polaroid in
            PolaroidDetailSheet(polaroid: polaroid)
        }
        .fullScreenCover(item: $revealingPolaroid) { polaroid in
            PolaroidRevealView(polaroid: polaroid) {
                dataService.revealPolaroid(polaroid)
                revealingPolaroid = nil
            }
        }
    }

    private var headerSection: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 4) {
                WhimsicalTitle("Polaroids")
                WhimsicalSubtitle("complete quests to add memories")
            }
            .frame(maxWidth: .infinity, alignment: .leading)

            wallpaperButton
                .padding(.top, 8)
        }
    }

    private var wallpaperButton: some View {
        Button {
            if customWallpaper != nil {
                showWallpaperOptions = true
            } else {
                showWallpaperOptions = true
            }
        } label: {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: [WhimsicalTheme.blushPink, WhimsicalTheme.deepRose.opacity(0.85)],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 44, height: 44)
                    .shadow(color: WhimsicalTheme.deepRose.opacity(0.35), radius: 8, x: 0, y: 3)

                Image(systemName: customWallpaper == nil ? "photo.badge.plus" : "photo.fill")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(.white)
            }
        }
        .photosPicker(isPresented: Binding(
            get: { showWallpaperOptions && customWallpaper == nil },
            set: { if !$0 { showWallpaperOptions = false } }
        ), selection: $wallpaperItem, matching: .images)
        .confirmationDialog("Wallpaper", isPresented: Binding(
            get: { showWallpaperOptions && customWallpaper != nil },
            set: { if !$0 { showWallpaperOptions = false } }
        )) {
            Button("Choose New Wallpaper") {
                showWallpaperOptions = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    customWallpaper = nil
                    showWallpaperOptions = true
                }
            }
            Button("Remove Wallpaper", role: .destructive) {
                WallpaperManager.clear()
                withAnimation(.spring(response: 0.4)) {
                    customWallpaper = nil
                }
            }
            Button("Cancel", role: .cancel) {}
        }
        .onChange(of: wallpaperItem) { _, newItem in
            guard let newItem else { return }
            Task {
                if let data = try? await newItem.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    WallpaperManager.save(image)
                    await MainActor.run {
                        withAnimation(.spring(response: 0.45)) {
                            customWallpaper = image
                        }
                        wallpaperItem = nil
                    }
                }
            }
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: customWallpaper != nil)
    }

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "camera.viewfinder")
                .font(.system(size: 48))
                .foregroundStyle(WhimsicalTheme.deepRose.opacity(0.5))
            Text("No Polaroids yet")
                .font(.system(.title3, design: .serif, weight: .semibold))
                .foregroundStyle(.secondary)
            Text("Complete a quest and take a photo\nto start your collection!")
                .font(.system(.subheadline, design: .serif))
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, 60)
    }
}

struct PolaroidCard: View {
    let polaroid: Polaroid

    private var borderColor: Color {
        WhimsicalTheme.difficultyAccent(polaroid.difficulty)
    }

    private var borderWidth: CGFloat {
        switch polaroid.difficulty {
        case .easy: 3
        case .medium: 4
        case .adventurous: 5
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            Color(WhimsicalTheme.difficultyColor(polaroid.difficulty)).opacity(0.3)
                .frame(height: 160)
                .overlay {
                    if let image = PhotoManager.loadPhoto(named: polaroid.imagePath) {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .blur(radius: polaroid.blurRadius)
                            .allowsHitTesting(false)
                    } else {
                        Image(systemName: "photo")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
                }
                .clipShape(.rect(cornerRadius: 4))
                .padding(.horizontal, 8)
                .padding(.top, 8)

            VStack(spacing: 4) {
                if !polaroid.questTitle.isEmpty {
                    Text(polaroid.questTitle)
                        .font(.system(.caption2, design: .serif, weight: .semibold))
                        .foregroundStyle(.primary)
                        .lineLimit(1)
                }

                if polaroid.isRevealed {
                    HStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.caption2)
                            .foregroundStyle(.yellow)
                        Text("Revealed")
                            .font(.system(.caption2, design: .serif, weight: .semibold))
                            .foregroundStyle(WhimsicalTheme.deepSage)
                    }
                } else {
                    HStack(spacing: 4) {
                        Image(systemName: "lock.fill")
                            .font(.caption2)
                            .foregroundStyle(.secondary)
                        Text("Hit your goal to unlock")
                            .font(.system(.caption2, design: .serif, weight: .medium))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(.vertical, 10)
            .padding(.horizontal, 8)
        }
        .background(.white, in: .rect(cornerRadius: 8))
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(borderColor.opacity(0.6), lineWidth: borderWidth)
        )
        .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
    }
}

struct PolaroidDetailSheet: View {
    let polaroid: Polaroid
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                if let image = PhotoManager.loadPhoto(named: polaroid.imagePath) {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .clipShape(.rect(cornerRadius: 16))
                        .padding()
                }

                if !polaroid.questTitle.isEmpty {
                    Text(polaroid.questTitle)
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(.primary)
                }

                HStack(spacing: 12) {
                    Label(polaroid.difficulty.label, systemImage: "circle.fill")
                        .font(.system(.caption, design: .serif))
                        .foregroundStyle(WhimsicalTheme.difficultyAccent(polaroid.difficulty))

                    Text(polaroid.dateTaken.formatted(date: .long, time: .shortened))
                        .font(.system(.subheadline, design: .serif))
                        .foregroundStyle(.secondary)
                }

                ShareLink(item: PhotoManager.photoURL(named: polaroid.imagePath)) {
                    Label("Share Polaroid", systemImage: "square.and.arrow.up")
                        .font(.system(.headline, design: .serif))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(WhimsicalTheme.deepRose, in: .rect(cornerRadius: 16))
                }
                .padding(.horizontal)

                Spacer()
            }
            .navigationTitle("Polaroid")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }
}
