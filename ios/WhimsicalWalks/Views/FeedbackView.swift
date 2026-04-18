import SwiftUI
import MessageUI
import UIKit

struct FeedbackView: View {
    @State private var rating: Int = 0
    @State private var feedbackText: String = ""
    @State private var submitted: Bool = false
    @State private var showMailSheet: Bool = false
    @State private var showMailError: Bool = false
    @State private var appeared: Bool = false

    private let recipient = "maxfayrweather@gmail.com"

    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundStyle(WhimsicalTheme.deepRose.opacity(0.6))
                Text("How did we do?")
                    .font(.custom(FontRegistration.keshia, size: 20))
                    .foregroundStyle(.primary)
                Image(systemName: "sparkles")
                    .font(.caption)
                    .foregroundStyle(WhimsicalTheme.deepRose.opacity(0.6))
            }

            Text("We'd love to hear from you")
                .font(.system(.caption, design: .serif))
                .foregroundStyle(.secondary)

            if submitted {
                submittedState
            } else {
                ratingStars
                feedbackField
                sendButton
            }
        }
        .padding(20)
        .background(.white.opacity(0.7), in: .rect(cornerRadius: 20))
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 12)
        .animation(.spring(response: 0.5).delay(0.1), value: appeared)
        .onAppear { appeared = true }
        .sheet(isPresented: $showMailSheet) {
            MailComposeView(
                recipient: recipient,
                subject: "Whimsical Walks Feedback — \(rating)/5",
                body: composedBody
            ) { result in
                showMailSheet = false
                if result == .sent || result == .saved {
                    markSubmitted()
                }
            }
        }
        .alert("Unable to Send", isPresented: $showMailError) {
            Button("Copy Email Address") {
                UIPasteboard.general.string = recipient
                markSubmitted()
            }
            Button("OK", role: .cancel) {}
        } message: {
            Text("No mail account is set up on this device. Please email us at \(recipient)")
        }
    }

    private var ratingStars: some View {
        HStack(spacing: 8) {
            ForEach(1...5, id: \.self) { star in
                Button {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        rating = star
                    }
                } label: {
                    Image(systemName: star <= rating ? "heart.fill" : "heart")
                        .font(.title3)
                        .foregroundStyle(star <= rating ? WhimsicalTheme.deepRose : WhimsicalTheme.blushPink)
                        .scaleEffect(star <= rating ? 1.15 : 1.0)
                }
                .buttonStyle(.plain)
                .sensoryFeedback(.selection, trigger: rating)
            }
        }
        .padding(.vertical, 4)
    }

    private var feedbackField: some View {
        TextField("Tell us what you think...", text: $feedbackText, axis: .vertical)
            .font(.system(.subheadline, design: .serif))
            .lineLimit(3...5)
            .padding(12)
            .background(WhimsicalTheme.cream, in: .rect(cornerRadius: 12))
            .overlay {
                RoundedRectangle(cornerRadius: 12)
                    .stroke(WhimsicalTheme.blushPink.opacity(0.5), lineWidth: 1)
            }
    }

    private var sendButton: some View {
        Button {
            submitFeedback()
        } label: {
            HStack(spacing: 6) {
                Image(systemName: "paperplane.fill")
                    .font(.caption)
                Text("Send Feedback")
                    .font(.system(.subheadline, design: .serif, weight: .semibold))
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                rating > 0 ? WhimsicalTheme.deepRose : WhimsicalTheme.blushPink,
                in: Capsule()
            )
        }
        .disabled(rating == 0)
        .opacity(rating > 0 ? 1 : 0.6)
    }

    private var submittedState: some View {
        VStack(spacing: 10) {
            Image(systemName: "heart.circle.fill")
                .font(.system(size: 40))
                .foregroundStyle(WhimsicalTheme.deepRose)
                .symbolEffect(.bounce, value: submitted)

            Text("Thank you!")
                .font(.system(.headline, design: .serif))
                .foregroundStyle(.primary)

            Text("Your feedback means the world to us")
                .font(.system(.caption, design: .serif))
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 8)
        .transition(.scale.combined(with: .opacity))
    }

    private var composedBody: String {
        """
        Rating: \(rating)/5

        \(feedbackText)

        —
        Sent from Whimsical Walks
        """
    }

    private func submitFeedback() {
        let feedbackKey = "whimsical_feedback_history"
        var history = UserDefaults.standard.array(forKey: feedbackKey) as? [[String: Any]] ?? []
        let entry: [String: Any] = [
            "rating": rating,
            "text": feedbackText,
            "date": Date().timeIntervalSince1970
        ]
        history.append(entry)
        UserDefaults.standard.set(history, forKey: feedbackKey)

        if MFMailComposeViewController.canSendMail() {
            showMailSheet = true
        } else {
            let subject = "Whimsical Walks Feedback — \(rating)/5"
            let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let encodedBody = composedBody.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
            let urlString = "mailto:\(recipient)?subject=\(encodedSubject)&body=\(encodedBody)"
            if let url = URL(string: urlString), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url) { success in
                    if success {
                        markSubmitted()
                    } else {
                        showMailError = true
                    }
                }
            } else {
                showMailError = true
            }
        }
    }

    private func markSubmitted() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            submitted = true
        }
    }
}

private struct MailComposeView: UIViewControllerRepresentable {
    let recipient: String
    let subject: String
    let body: String
    let onFinish: (MFMailComposeResult) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(onFinish: onFinish)
    }

    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let vc = MFMailComposeViewController()
        vc.mailComposeDelegate = context.coordinator
        vc.setToRecipients([recipient])
        vc.setSubject(subject)
        vc.setMessageBody(body, isHTML: false)
        return vc
    }

    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {}

    final class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        let onFinish: (MFMailComposeResult) -> Void

        init(onFinish: @escaping (MFMailComposeResult) -> Void) {
            self.onFinish = onFinish
        }

        nonisolated func mailComposeController(
            _ controller: MFMailComposeViewController,
            didFinishWith result: MFMailComposeResult,
            error: Error?
        ) {
            let captured = result
            Task { @MainActor in
                controller.dismiss(animated: true) {
                    self.onFinish(captured)
                }
            }
        }
    }
}
