import SwiftUI
import UIKit

struct QuestsView: View {
    let dataService: DataService
    let healthService: HealthKitService
    @State private var appeared: Bool = false
    @State private var completedQuestID: UUID?
    @State private var questForPhoto: Quest?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                headerSection

                ForEach(Array(dataService.quests.enumerated()), id: \.element.id) { index, quest in
                    QuestCard(quest: quest, onTakePhoto: {
                        questForPhoto = quest
                    })
                    .opacity(appeared ? 1 : 0)
                    .offset(y: appeared ? 0 : 20)
                    .animation(.spring(response: 0.4).delay(Double(index) * 0.08), value: appeared)
                }

                Spacer(minLength: 40)
            }
            .padding(.horizontal)
            .padding(.top, 8)
        }
        .background { WhimsicalBackground(screen: .quests) }
        .sensoryFeedback(.success, trigger: completedQuestID)
        .onAppear { appeared = true }
        .sheet(item: $questForPhoto) { quest in
            QuestCameraView { image in
                if let image {
                    handleQuestPhoto(image, quest: quest)
                }
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 4) {
            WhimsicalTitle("Today's Quests")
            WhimsicalSubtitle("complete quests & snap a photo")
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func handleQuestPhoto(_ image: UIImage, quest: Quest) {
        if let path = PhotoManager.savePhoto(image) {
            completedQuestID = quest.id
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                dataService.completeQuestWithPhoto(quest, imagePath: path, currentSteps: healthService.todaySteps)
            }
        }
    }
}

struct QuestCard: View {
    let quest: Quest
    let onTakePhoto: () -> Void
    @State private var bounceCount: Int = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Circle()
                    .fill(WhimsicalTheme.difficultyColor(quest.difficulty))
                    .frame(width: 10, height: 10)
                Text(quest.difficulty.label)
                    .font(.system(.caption, design: .serif, weight: .semibold))
                    .foregroundStyle(WhimsicalTheme.difficultyAccent(quest.difficulty))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(WhimsicalTheme.difficultyColor(quest.difficulty).opacity(0.4), in: Capsule())
                Spacer()
                Image(systemName: "camera.fill")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Text(quest.title)
                .font(.system(.headline, design: .serif))
                .foregroundStyle(.primary)

            Text(quest.description)
                .font(.system(.subheadline, design: .serif))
                .foregroundStyle(.secondary)
                .fixedSize(horizontal: false, vertical: true)

            if quest.isCompleted {
                HStack(spacing: 6) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(WhimsicalTheme.deepSage)
                        .symbolEffect(.bounce, value: bounceCount)
                    Text("Photo taken!")
                        .font(.system(.subheadline, design: .serif, weight: .semibold))
                        .foregroundStyle(WhimsicalTheme.deepSage)
                    Spacer()
                    Image(systemName: "photo.fill")
                        .font(.caption)
                        .foregroundStyle(WhimsicalTheme.deepSage.opacity(0.6))
                    Text("In Polaroids")
                        .font(.system(.caption, design: .serif))
                        .foregroundStyle(WhimsicalTheme.deepSage.opacity(0.6))
                }
                .onAppear { bounceCount += 1 }
            } else {
                Button {
                    onTakePhoto()
                } label: {
                    Label("Take Photo", systemImage: "camera.fill")
                        .font(.system(.subheadline, design: .serif, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(WhimsicalTheme.difficultyAccent(quest.difficulty), in: .rect(cornerRadius: 12))
                }
            }
        }
        .padding(16)
        .background(WhimsicalTheme.cardBackground, in: .rect(cornerRadius: 20))
    }
}

struct QuestCameraView: UIViewControllerRepresentable {
    let onImagePicked: (UIImage?) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        #if targetEnvironment(simulator)
        picker.sourceType = .photoLibrary
        #else
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        #endif
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator { Coordinator(onImagePicked: onImagePicked) }

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onImagePicked: (UIImage?) -> Void
        init(onImagePicked: @escaping (UIImage?) -> Void) { self.onImagePicked = onImagePicked }

        nonisolated func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            let image = info[.originalImage] as? UIImage
            Task { @MainActor in
                onImagePicked(image)
                picker.dismiss(animated: true)
            }
        }

        nonisolated func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            Task { @MainActor in
                onImagePicked(nil)
                picker.dismiss(animated: true)
            }
        }
    }
}
