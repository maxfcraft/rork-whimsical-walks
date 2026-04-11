import SwiftUI
import StoreKit
import UIKit

// MARK: - Screen 1: Hook (Emotional Tension)

struct HookScreen: View {
    let onContinue: () -> Void
    @State private var titleVisible: Bool = false
    @State private var subtitleVisible: Bool = false
    @State private var ctaVisible: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 28) {
                VStack(spacing: 16) {
                    Text("Your days shouldn't\nfeel this boring")
                        .font(.system(size: 32, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.5), radius: 16, x: 0, y: 6)
                        .opacity(titleVisible ? 1 : 0)
                        .offset(y: titleVisible ? 0 : 30)

                    Text("You walk every day… but when was the\nlast time it felt like an adventure?")
                        .font(.system(size: 17, weight: .medium, design: .serif))
                        .foregroundStyle(.white.opacity(0.75))
                        .multilineTextAlignment(.center)
                        .lineSpacing(3)
                        .opacity(subtitleVisible ? 1 : 0)
                        .offset(y: subtitleVisible ? 0 : 16)
                }
            }
            .padding(.horizontal, 32)

            Spacer()

            Button(action: onContinue) {
                Text("Let's fix that")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundStyle(Color(red: 0.18, green: 0.10, blue: 0.25))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(.white, in: Capsule())
                    .shadow(color: .white.opacity(0.2), radius: 20, x: 0, y: 8)
            }
            .padding(.horizontal, 32)
            .opacity(ctaVisible ? 1 : 0)
            .offset(y: ctaVisible ? 0 : 20)

            Spacer().frame(height: 80)
        }
        .sensoryFeedback(.impact(flexibility: .soft), trigger: ctaVisible)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                titleVisible = true
            }
            withAnimation(.easeOut(duration: 0.7).delay(0.8)) {
                subtitleVisible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(1.4)) {
                ctaVisible = true
            }
        }
    }
}

// MARK: - Screen 2: Identity Shift

struct IdentityShiftScreen: View {
    let onContinue: () -> Void
    @State private var titleVisible: Bool = false
    @State private var subtitleVisible: Bool = false
    @State private var pathVisible: Bool = false
    @State private var element1Visible: Bool = false
    @State private var element2Visible: Bool = false
    @State private var element3Visible: Bool = false
    @State private var ctaVisible: Bool = false
    @State private var floatPhase: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 20) {
                Text("Become the kind of person\nwho sees magic everywhere")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.3), radius: 12, x: 0, y: 4)
                    .opacity(titleVisible ? 1 : 0)
                    .offset(y: titleVisible ? 0 : 24)

                Text("Small walks. Unexpected moments.\nA life that feels different.")
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundStyle(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
                    .lineSpacing(3)
                    .opacity(subtitleVisible ? 1 : 0)
                    .offset(y: subtitleVisible ? 0 : 12)
            }
            .padding(.horizontal, 28)

            Spacer().frame(height: 36)

            ZStack {
                pathwayScene
            }
            .frame(height: 240)
            .padding(.horizontal, 28)

            Spacer()

            Button(action: onContinue) {
                HStack(spacing: 8) {
                    Text("Show me")
                        .font(.system(size: 18, weight: .bold, design: .serif))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(Color(red: 0.3, green: 0.2, blue: 0.1))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(.white, in: Capsule())
                .shadow(color: .white.opacity(0.3), radius: 16, x: 0, y: 4)
            }
            .padding(.horizontal, 32)
            .opacity(ctaVisible ? 1 : 0)
            .offset(y: ctaVisible ? 0 : 16)

            Spacer().frame(height: 80)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.7).delay(0.2)) {
                titleVisible = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.7)) {
                subtitleVisible = true
            }
            withAnimation(.spring(response: 0.7, dampingFraction: 0.8).delay(1.0)) {
                pathVisible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(1.4)) {
                element1Visible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(1.7)) {
                element2Visible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(2.0)) {
                element3Visible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(2.3)) {
                ctaVisible = true
            }
            withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true).delay(1.5)) {
                floatPhase = true
            }
        }
    }

    private var pathwayScene: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 28)
                .fill(
                    LinearGradient(
                        colors: [
                            Color(red: 0.95, green: 0.92, blue: 0.85).opacity(0.15),
                            Color(red: 0.85, green: 0.78, blue: 0.70).opacity(0.08)
                        ],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 28)
                        .stroke(.white.opacity(0.12), lineWidth: 1)
                )
                .opacity(pathVisible ? 1 : 0)
                .scaleEffect(pathVisible ? 1 : 0.92)

            VStack(spacing: 0) {
                curvedPath
                    .stroke(
                        LinearGradient(
                            colors: [.white.opacity(0.4), .white.opacity(0.15)],
                            startPoint: .top,
                            endPoint: .bottom
                        ),
                        style: StrokeStyle(lineWidth: 3, lineCap: .round, dash: [8, 6])
                    )
                    .frame(height: 200)
            }
            .padding(20)
            .opacity(pathVisible ? 1 : 0)

            whimsicalElement(
                icon: "leaf.fill",
                color: WhimsicalTheme.sageGreen,
                label: "Hidden path",
                xOffset: -80, yOffset: -60
            )
            .opacity(element1Visible ? 1 : 0)
            .scaleEffect(element1Visible ? 1 : 0.3)
            .offset(y: floatPhase ? -3 : 3)

            whimsicalElement(
                icon: "camera.viewfinder",
                color: WhimsicalTheme.warmPeach,
                label: "Quest item",
                xOffset: 60, yOffset: -10
            )
            .opacity(element2Visible ? 1 : 0)
            .scaleEffect(element2Visible ? 1 : 0.3)
            .offset(y: floatPhase ? 3 : -3)

            whimsicalElement(
                icon: "sparkles",
                color: WhimsicalTheme.blushPink,
                label: "Whimsy spot",
                xOffset: -50, yOffset: 60
            )
            .opacity(element3Visible ? 1 : 0)
            .scaleEffect(element3Visible ? 1 : 0.3)
            .offset(y: floatPhase ? -2 : 2)
        }
    }

    private var curvedPath: Path {
        Path { path in
            path.move(to: CGPoint(x: 60, y: 180))
            path.addCurve(
                to: CGPoint(x: 240, y: 20),
                control1: CGPoint(x: 100, y: 100),
                control2: CGPoint(x: 200, y: 80)
            )
        }
    }

    private func whimsicalElement(icon: String, color: Color, label: String, xOffset: CGFloat, yOffset: CGFloat) -> some View {
        VStack(spacing: 4) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.25))
                    .frame(width: 50, height: 50)
                Circle()
                    .fill(.white.opacity(0.15))
                    .frame(width: 50, height: 50)
                Image(systemName: icon)
                    .font(.system(size: 20))
                    .foregroundStyle(.white.opacity(0.95))
            }
            .shadow(color: color.opacity(0.4), radius: 10)
            Text(label)
                .font(.system(size: 10, weight: .semibold, design: .serif))
                .foregroundStyle(.white.opacity(0.7))
        }
        .offset(x: xOffset, y: yOffset)
    }
}

// MARK: - Screen 3: Feature Preview

struct FeaturePreviewScreen: View {
    let onContinue: () -> Void
    @State private var headerVisible: Bool = false
    @State private var card1Visible: Bool = false
    @State private var card2Visible: Bool = false
    @State private var card3Visible: Bool = false
    @State private var ctaVisible: Bool = false
    @State private var polaroidTilt: Double = 0
    @State private var questPulse: Bool = false
    @State private var petBounce: CGFloat = 0

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            Text("Everything you need\nfor magical walks")
                .font(.system(size: 28, weight: .bold, design: .serif))
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
                .opacity(headerVisible ? 1 : 0)
                .offset(y: headerVisible ? 0 : 16)

            Spacer().frame(height: 28)

            VStack(spacing: 14) {
                featureCard(
                    icon: "camera.filters",
                    iconGradient: [WhimsicalTheme.deepRose, WhimsicalTheme.blushPink],
                    title: "Capture Moments",
                    subtitle: "Whimsical filters transform every\nphoto into a magical memory",
                    miniView: AnyView(
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(
                                    LinearGradient(
                                        colors: [WhimsicalTheme.blushPink, WhimsicalTheme.deepRose.opacity(0.5)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 48, height: 48)
                            Image(systemName: "sparkle")
                                .font(.system(size: 20))
                                .foregroundStyle(.white)
                        }
                        .rotationEffect(.degrees(polaroidTilt))
                    )
                )
                .opacity(card1Visible ? 1 : 0)
                .offset(x: card1Visible ? 0 : -50)

                featureCard(
                    icon: "map.fill",
                    iconGradient: [WhimsicalTheme.deepLavender, WhimsicalTheme.lavender],
                    title: "Complete Quests",
                    subtitle: "Daily photo challenges that make\nwalks feel like adventures",
                    miniView: AnyView(
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(WhimsicalTheme.deepLavender.opacity(0.3))
                                .frame(width: 48, height: 48)
                            Image(systemName: "map.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(WhimsicalTheme.deepLavender)
                                .scaleEffect(questPulse ? 1.12 : 1.0)
                        }
                    )
                )
                .opacity(card2Visible ? 1 : 0)
                .offset(x: card2Visible ? 0 : 50)

                featureCard(
                    icon: "pawprint.fill",
                    iconGradient: [WhimsicalTheme.deepSage, WhimsicalTheme.sageGreen],
                    title: "Collect Companions",
                    subtitle: "Unlock adorable pets as you\nexplore and walk more",
                    miniView: AnyView(
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .fill(WhimsicalTheme.deepSage.opacity(0.3))
                                .frame(width: 48, height: 48)
                            Image(systemName: "pawprint.fill")
                                .font(.system(size: 20))
                                .foregroundStyle(WhimsicalTheme.deepSage)
                                .offset(y: petBounce)
                        }
                    )
                )
                .opacity(card3Visible ? 1 : 0)
                .offset(x: card3Visible ? 0 : -50)
            }
            .padding(.horizontal, 28)

            Spacer()

            Button(action: onContinue) {
                Text("Continue")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(.white.opacity(0.2), in: Capsule())
                    .overlay(Capsule().stroke(.white.opacity(0.3), lineWidth: 1))
            }
            .padding(.horizontal, 32)
            .opacity(ctaVisible ? 1 : 0)
            .offset(y: ctaVisible ? 0 : 16)

            Spacer().frame(height: 80)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                headerVisible = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5)) {
                card1Visible = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.8)) {
                card2Visible = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(1.1)) {
                card3Visible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(1.5)) {
                ctaVisible = true
            }
            startMiniAnimations()
        }
    }

    private func featureCard(icon: String, iconGradient: [Color], title: String, subtitle: String, miniView: AnyView) -> some View {
        HStack(spacing: 14) {
            miniView

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 17, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                Text(subtitle)
                    .font(.system(size: 13, weight: .medium, design: .serif))
                    .foregroundStyle(.white.opacity(0.7))
                    .lineSpacing(2)
            }

            Spacer()
        }
        .padding(16)
        .background(.white.opacity(0.12), in: .rect(cornerRadius: 18))
        .overlay(
            RoundedRectangle(cornerRadius: 18)
                .stroke(.white.opacity(0.12), lineWidth: 1)
        )
    }

    private func startMiniAnimations() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true).delay(0.6)) {
            polaroidTilt = 8
        }
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true).delay(1.0)) {
            questPulse = true
        }
        withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true).delay(1.3)) {
            petBounce = -5
        }
    }
}

// MARK: - Screen 4a: Name

struct OnboardingNameScreen: View {
    let onContinue: () -> Void
    @State private var headerVisible: Bool = false
    @State private var nameFieldVisible: Bool = false
    @State private var ctaVisible: Bool = false
    @State private var userName: String = ""
    @FocusState private var nameFieldFocused: Bool

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 10) {
                Text("Let's make this yours")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)

                Text("What should we call you?")
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
            }
            .opacity(headerVisible ? 1 : 0)
            .offset(y: headerVisible ? 0 : 16)

            Spacer().frame(height: 40)

            VStack(alignment: .leading, spacing: 10) {
                TextField("Your name", text: $userName)
                    .font(.system(size: 20, weight: .medium, design: .serif))
                    .foregroundStyle(.white)
                    .padding(18)
                    .background(.white.opacity(0.12), in: .rect(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(.white.opacity(0.2), lineWidth: 1)
                    )
                    .focused($nameFieldFocused)
                    .tint(.white)
                    .autocorrectionDisabled()
                    .submitLabel(.continue)
                    .onSubmit {
                        saveName()
                        onContinue()
                    }
            }
            .padding(.horizontal, 32)
            .opacity(nameFieldVisible ? 1 : 0)
            .offset(y: nameFieldVisible ? 0 : 20)

            Spacer()

            Button(action: {
                saveName()
                onContinue()
            }) {
                Text("Continue")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(.white.opacity(0.2), in: Capsule())
                    .overlay(Capsule().stroke(.white.opacity(0.3), lineWidth: 1))
            }
            .padding(.horizontal, 32)
            .opacity(ctaVisible ? 1 : 0)
            .offset(y: ctaVisible ? 0 : 16)

            Spacer().frame(height: 80)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                headerVisible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.5)) {
                nameFieldVisible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.9)) {
                ctaVisible = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                nameFieldFocused = true
            }
        }
    }

    private func saveName() {
        let trimmed = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty {
            UserDefaults.standard.set(trimmed, forKey: "whimsical_user_name")
        }
    }
}

// MARK: - Screen 4b: Reason

struct OnboardingReasonScreen: View {
    let onContinue: () -> Void
    @State private var headerVisible: Bool = false
    @State private var optionsVisible: Bool = false
    @State private var ctaVisible: Bool = false
    @State private var selectedReason: String = ""

    private let reasons: [(id: String, label: String, icon: String)] = [
        ("happy", "Feel happier", "face.smiling.inverse"),
        ("active", "Be more active", "figure.walk"),
        ("romanticize", "Romanticize life", "sparkles"),
        ("outside", "Get outside more", "sun.max.fill"),
    ]

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 10) {
                Text("Let's make this yours")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)

                Text("Why are you interested in this?")
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
            }
            .opacity(headerVisible ? 1 : 0)
            .offset(y: headerVisible ? 0 : 16)

            Spacer().frame(height: 36)

            VStack(spacing: 10) {
                ForEach(reasons, id: \.id) { reason in
                    Button {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            selectedReason = reason.id
                        }
                    } label: {
                        HStack(spacing: 12) {
                            Image(systemName: reason.icon)
                                .font(.system(size: 18))
                                .foregroundStyle(.white.opacity(0.8))
                                .frame(width: 28)

                            Text(reason.label)
                                .font(.system(size: 16, weight: .medium, design: .serif))
                                .foregroundStyle(.white)

                            Spacer()

                            if selectedReason == reason.id {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.system(size: 20))
                                    .foregroundStyle(.white)
                                    .transition(.scale.combined(with: .opacity))
                            }
                        }
                        .padding(14)
                        .background(
                            selectedReason == reason.id
                                ? Color.white.opacity(0.2)
                                : Color.white.opacity(0.08),
                            in: .rect(cornerRadius: 14)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(
                                    selectedReason == reason.id
                                        ? Color.white.opacity(0.4)
                                        : Color.clear,
                                    lineWidth: 1.5
                                )
                        )
                    }
                    .sensoryFeedback(.selection, trigger: selectedReason)
                }
            }
            .padding(.horizontal, 28)
            .opacity(optionsVisible ? 1 : 0)
            .offset(y: optionsVisible ? 0 : 20)

            Spacer()

            Button(action: {
                saveReason()
                onContinue()
            }) {
                Text("Continue")
                    .font(.system(size: 18, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(.white.opacity(0.2), in: Capsule())
                    .overlay(Capsule().stroke(.white.opacity(0.3), lineWidth: 1))
            }
            .padding(.horizontal, 32)
            .opacity(ctaVisible ? 1 : 0)
            .offset(y: ctaVisible ? 0 : 16)

            Spacer().frame(height: 80)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
                headerVisible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.5)) {
                optionsVisible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(1.0)) {
                ctaVisible = true
            }
        }
    }

    private func saveReason() {
        if !selectedReason.isEmpty {
            UserDefaults.standard.set(selectedReason, forKey: "whimsical_user_reason")
        }
    }
}

// MARK: - Screen 5: Live Quest

struct LiveQuestScreen: View {
    let onPhotoTaken: (UIImage) -> Void
    @State private var phase: LiveQuestPhase = .intro
    @State private var introVisible: Bool = false
    @State private var questCardVisible: Bool = false
    @State private var startButtonVisible: Bool = false
    @State private var showCamera: Bool = false
    @State private var capturedImage: UIImage?
    @State private var photoPreviewVisible: Bool = false
    @State private var scannerActive: Bool = false
    @State private var scanLineY: CGFloat = 10
    @State private var scanLineOpacity: Double = 0
    @State private var scanText: String = ""
    @State private var scanTextOpacity: Double = 0
    @State private var checkmarkScale: CGFloat = 0
    @State private var checkmarkOpacity: Double = 0
    @State private var completionVisible: Bool = false
    @State private var sparklesActive: Bool = false
    @State private var confettiTrigger: Int = 0

    private enum LiveQuestPhase {
        case intro, waiting, photoTaken, scanning, complete
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            ZStack {
                if sparklesActive {
                    OnboardingQuestSparkles()
                }

                VStack(spacing: 20) {
                    if phase == .intro || phase == .waiting {
                        introSection
                    }

                    if phase == .photoTaken {
                        photoPreviewSection
                    }

                    if phase == .scanning {
                        scannerSection
                    }

                    if phase == .complete {
                        completionSection
                    }
                }
                .padding(.horizontal, 28)
            }

            Spacer()
        }
        .sheet(isPresented: $showCamera) {
            QuestCameraView { image in
                if let image {
                    capturedImage = image
                    showPhotoTaken()
                }
            }
        }
        .onAppear {
            startIntro()
        }
    }

    private var introSection: some View {
        VStack(spacing: 24) {
            VStack(spacing: 12) {
                Text("Your first quest\nstarts now")
                    .font(.system(size: 30, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 4)

                Text("Find the most whimsical\nobject around you")
                    .font(.system(size: 17, weight: .medium, design: .serif))
                    .foregroundStyle(.white.opacity(0.8))
                    .multilineTextAlignment(.center)
            }
            .opacity(introVisible ? 1 : 0)
            .offset(y: introVisible ? 0 : 20)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Circle()
                        .fill(WhimsicalTheme.softPink)
                        .frame(width: 10, height: 10)
                    Text("Easy")
                        .font(.system(.caption, design: .serif, weight: .semibold))
                        .foregroundStyle(WhimsicalTheme.accentSoftPink)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(WhimsicalTheme.softPink.opacity(0.4), in: Capsule())
                    Spacer()
                    Image(systemName: "camera.fill")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.5))
                }

                Text("Find Something Whimsical")
                    .font(.system(.headline, design: .serif))
                    .foregroundStyle(.white)

                Text("Spot something magical or surprising around you and snap a photo")
                    .font(.system(.subheadline, design: .serif))
                    .foregroundStyle(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white.opacity(0.12), in: .rect(cornerRadius: 20))
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.15), lineWidth: 1)
            )
            .opacity(questCardVisible ? 1 : 0)
            .offset(y: questCardVisible ? 0 : 30)
            .scaleEffect(questCardVisible ? 1 : 0.92)

            if phase == .waiting {
                Button {
                    showCamera = true
                } label: {
                    Label("Take Photo", systemImage: "camera.fill")
                        .font(.system(.body, design: .serif, weight: .semibold))
                        .foregroundStyle(WhimsicalTheme.deepRose)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(.white, in: .rect(cornerRadius: 16))
                        .shadow(color: WhimsicalTheme.deepRose.opacity(0.3), radius: 12, x: 0, y: 4)
                }
                .opacity(startButtonVisible ? 1 : 0)
                .offset(y: startButtonVisible ? 0 : 16)
            }
        }
    }

    private var photoPreviewSection: some View {
        VStack(spacing: 16) {
            if let image = capturedImage {
                Color.clear
                    .frame(height: 160)
                    .overlay {
                        Image(uiImage: image)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .allowsHitTesting(false)
                    }
                    .clipShape(.rect(cornerRadius: 18))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(.white.opacity(0.3), lineWidth: 1)
                    )
            }

            HStack(spacing: 10) {
                Image(systemName: "photo.fill")
                    .font(.title3)
                    .foregroundStyle(.white.opacity(0.7))
                Text("Photo captured!")
                    .font(.system(.body, design: .serif, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
            }

            Button {
                startVerification()
            } label: {
                Label("Verify Quest", systemImage: "camera.viewfinder")
                    .font(.system(.body, design: .serif, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(WhimsicalTheme.deepRose, in: .rect(cornerRadius: 16))
                    .shadow(color: WhimsicalTheme.deepRose.opacity(0.5), radius: 12, x: 0, y: 4)
            }
        }
        .opacity(photoPreviewVisible ? 1 : 0)
        .offset(y: photoPreviewVisible ? 0 : 20)
    }

    private var scannerSection: some View {
        VStack(spacing: 20) {
            ZStack {
                RoundedRectangle(cornerRadius: 18)
                    .fill(.white.opacity(0.06))
                    .frame(height: 140)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(WhimsicalTheme.deepRose.opacity(0.5), lineWidth: 1.5)
                    )

                GeometryReader { geo in
                    Rectangle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    WhimsicalTheme.deepRose.opacity(0),
                                    WhimsicalTheme.deepRose.opacity(0.9),
                                    WhimsicalTheme.deepRose.opacity(0)
                                ],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .frame(height: 3)
                        .opacity(scanLineOpacity)
                        .position(x: geo.size.width / 2, y: scanLineY)
                }
                .frame(height: 140)
                .clipShape(.rect(cornerRadius: 18))

                if phase == .complete {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 52))
                        .foregroundStyle(.white)
                        .shadow(color: WhimsicalTheme.deepRose.opacity(0.7), radius: 14)
                        .scaleEffect(checkmarkScale)
                        .opacity(checkmarkOpacity)
                }
            }

            Text(scanText)
                .font(.system(size: 16, weight: .semibold, design: .serif))
                .foregroundStyle(.white.opacity(0.9))
                .opacity(scanTextOpacity)
                .contentTransition(.numericText())
                .animation(.easeInOut(duration: 0.2), value: scanText)
        }
    }

    private var completionSection: some View {
        VStack(spacing: 18) {
            VStack(spacing: 8) {
                Text("✨ Whimsicality detected")
                    .font(.system(size: 22, weight: .bold, design: .serif))
                    .foregroundStyle(.white)

                Text("Added to your collection")
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundStyle(.white.opacity(0.7))
            }

            HStack(spacing: 12) {
                Image(systemName: "photo.fill.on.rectangle.fill")
                    .font(.title3)
                    .foregroundStyle(.white)
                Text("Saved to Polaroid library!")
                    .font(.system(.body, design: .serif, weight: .semibold))
                    .foregroundStyle(.white)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(WhimsicalTheme.deepSage.opacity(0.4), in: .rect(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(WhimsicalTheme.deepSage.opacity(0.3), lineWidth: 1)
            )

            if let position = PetSpritePosition(rawValue: 0) {
                HStack(spacing: 10) {
                    PetSpriteView(position: position, size: 40)
                    Text("Kiki is impressed!")
                        .font(.system(size: 14, weight: .medium, design: .serif))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.top, 4)
            }
        }
        .opacity(completionVisible ? 1 : 0)
        .offset(y: completionVisible ? 0 : 20)
        .scaleEffect(completionVisible ? 1 : 0.9)
    }

    private func startIntro() {
        withAnimation(.easeOut(duration: 0.6).delay(0.3)) {
            introVisible = true
        }
        withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.8)) {
            questCardVisible = true
        }

        Task {
            try? await Task.sleep(for: .seconds(1.3))
            phase = .waiting
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                startButtonVisible = true
            }
        }
    }

    private func showPhotoTaken() {
        withAnimation(.easeOut(duration: 0.3)) {
            startButtonVisible = false
            introVisible = false
            questCardVisible = false
        }

        Task {
            try? await Task.sleep(for: .seconds(0.4))
            phase = .photoTaken
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                photoPreviewVisible = true
            }
        }
    }

    private func startVerification() {
        withAnimation(.easeOut(duration: 0.3)) {
            photoPreviewVisible = false
        }

        Task {
            try? await Task.sleep(for: .seconds(0.3))
            phase = .scanning
            scannerActive = true
            sparklesActive = true

            withAnimation(.easeIn(duration: 0.3)) {
                scanLineOpacity = 1.0
                scanTextOpacity = 1.0
            }

            scanText = "Analyzing…"
            animateScanLine()

            try? await Task.sleep(for: .seconds(0.9))
            scanText = "Detecting whimsy…"

            try? await Task.sleep(for: .seconds(0.8))
            scanText = "Sprinkling fairy dust…"

            try? await Task.sleep(for: .seconds(0.7))
            scanText = "Weaving in the magic…"

            try? await Task.sleep(for: .seconds(0.6))

            withAnimation(.easeOut(duration: 0.3)) {
                scanLineOpacity = 0
            }

            scanText = "✨ Whimsicality detected"

            phase = .complete
            withAnimation(.spring(response: 0.5, dampingFraction: 0.5)) {
                checkmarkScale = 1.0
                checkmarkOpacity = 1.0
            }

            try? await Task.sleep(for: .seconds(1.0))

            withAnimation(.easeOut(duration: 0.3)) {
                scanTextOpacity = 0
                checkmarkOpacity = 0
                scannerActive = false
            }

            try? await Task.sleep(for: .seconds(0.4))
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                completionVisible = true
            }

            try? await Task.sleep(for: .seconds(2.0))

            if let image = capturedImage {
                onPhotoTaken(image)
            }
        }
    }

    private func animateScanLine() {
        scanLineY = 10

        func sweep() {
            guard scannerActive else { return }
            withAnimation(.easeInOut(duration: 0.7)) {
                scanLineY = 130
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                guard scannerActive else { return }
                withAnimation(.easeInOut(duration: 0.7)) {
                    scanLineY = 10
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) {
                    sweep()
                }
            }
        }

        sweep()
    }
}

struct OnboardingQuestSparkles: View {
    var body: some View {
        TimelineView(.animation(minimumInterval: 0.04)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate
                for i in 0..<16 {
                    let seed = Double(i) * 137.508
                    let x = (sin(seed + time * 0.6) * 0.4 + 0.5) * size.width
                    let y = (cos(seed * 0.7 + time * 0.4) * 0.4 + 0.5) * size.height
                    let pulse = sin(time * 2.5 + seed) * 0.5 + 0.5
                    let sparkSize = 2.0 + pulse * 5.0
                    let rect = CGRect(x: x - sparkSize / 2, y: y - sparkSize / 2, width: sparkSize, height: sparkSize)
                    context.opacity = pulse * 0.6
                    let colors: [Color] = [.white, WhimsicalTheme.blushPink, WhimsicalTheme.lavender, .white]
                    context.fill(Path(ellipseIn: rect), with: .color(colors[i % colors.count]))
                    if pulse > 0.7 {
                        let crossSize = sparkSize * 1.4
                        var cross = Path()
                        cross.move(to: CGPoint(x: x - crossSize, y: y))
                        cross.addLine(to: CGPoint(x: x + crossSize, y: y))
                        cross.move(to: CGPoint(x: x, y: y - crossSize))
                        cross.addLine(to: CGPoint(x: x, y: y + crossSize))
                        context.opacity = (pulse - 0.7) * 3.0
                        context.stroke(cross, with: .color(.white.opacity(0.5)), lineWidth: 0.5)
                    }
                }
            }
        }
        .allowsHitTesting(false)
        .ignoresSafeArea()
    }
}

// MARK: - Screen 6: Reinforcement

struct ReinforcementScreen: View {
    let capturedImage: UIImage?
    let onContinue: () -> Void
    @State private var headerVisible: Bool = false
    @State private var cardVisible: Bool = false
    @State private var ctaVisible: Bool = false
    @State private var glowPulse: Bool = false

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 10) {
                Text("See? You just made your\nworld more interesting")
                    .font(.system(size: 28, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)

                Text("This is what your walks\nfeel like now")
                    .font(.system(size: 16, weight: .medium, design: .serif))
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
            }
            .opacity(headerVisible ? 1 : 0)
            .offset(y: headerVisible ? 0 : 20)

            Spacer().frame(height: 32)

            VStack(spacing: 0) {
                if let image = capturedImage {
                    Color.clear
                        .frame(height: 220)
                        .overlay {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .allowsHitTesting(false)
                        }
                        .clipShape(.rect(cornerRadii: .init(topLeading: 20, topTrailing: 20)))
                } else {
                    Color.white.opacity(0.08)
                        .frame(height: 220)
                        .overlay {
                            VStack(spacing: 8) {
                                Image(systemName: "photo.fill")
                                    .font(.system(size: 36))
                                    .foregroundStyle(.white.opacity(0.3))
                                Text("Your whimsical find")
                                    .font(.system(size: 14, weight: .medium, design: .serif))
                                    .foregroundStyle(.white.opacity(0.4))
                            }
                        }
                        .clipShape(.rect(cornerRadii: .init(topLeading: 20, topTrailing: 20)))
                }

                HStack(spacing: 12) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("First Whimsical Find")
                            .font(.system(size: 16, weight: .bold, design: .serif))
                            .foregroundStyle(.white)
                        Text("Quest completed · Just now")
                            .font(.system(size: 13, weight: .medium, design: .serif))
                            .foregroundStyle(.white.opacity(0.5))
                    }

                    Spacer()

                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 24))
                        .foregroundStyle(WhimsicalTheme.deepSage)
                        .shadow(color: WhimsicalTheme.deepSage.opacity(glowPulse ? 0.6 : 0.2), radius: 8)
                }
                .padding(16)
                .background(.white.opacity(0.1), in: .rect(cornerRadii: .init(bottomLeading: 20, bottomTrailing: 20)))
            }
            .overlay(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(.white.opacity(0.15), lineWidth: 1)
            )
            .padding(.horizontal, 28)
            .opacity(cardVisible ? 1 : 0)
            .scaleEffect(cardVisible ? 1 : 0.9)
            .offset(y: cardVisible ? 0 : 30)

            Spacer()

            Button(action: onContinue) {
                HStack(spacing: 8) {
                    Text("Keep going")
                        .font(.system(size: 18, weight: .bold, design: .serif))
                    Image(systemName: "arrow.right")
                        .font(.system(size: 16, weight: .bold))
                }
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 18)
                .background(.white.opacity(0.2), in: Capsule())
                .overlay(Capsule().stroke(.white.opacity(0.3), lineWidth: 1))
            }
            .padding(.horizontal, 32)
            .opacity(ctaVisible ? 1 : 0)
            .offset(y: ctaVisible ? 0 : 16)

            Spacer().frame(height: 80)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                headerVisible = true
            }
            withAnimation(.spring(response: 0.6, dampingFraction: 0.75).delay(0.6)) {
                cardVisible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(1.2)) {
                ctaVisible = true
            }
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(0.8)) {
                glowPulse = true
            }
        }
    }
}

// MARK: - Screen 7: Review

struct OnboardingReviewScreen: View {
    let onContinue: () -> Void
    @State private var headerVisible: Bool = false
    @State private var sparkleScale: CGFloat = 0.5
    @State private var ctaVisible: Bool = false
    @State private var hasRequestedReview: Bool = false
    @State private var sparkleRotation: Double = 0
    @Environment(\.requestReview) private var requestReview

    var body: some View {
        VStack(spacing: 0) {
            Spacer()

            VStack(spacing: 24) {
                ZStack {
                    ForEach(0..<6, id: \.self) { i in
                        Image(systemName: "sparkle")
                            .font(.system(size: 16 + CGFloat(i % 3) * 4))
                            .foregroundStyle(.white.opacity(0.3 + Double(i) * 0.1))
                            .offset(
                                x: cos(Double(i) * .pi / 3 + sparkleRotation * 0.3) * 50,
                                y: sin(Double(i) * .pi / 3 + sparkleRotation * 0.3) * 50
                            )
                    }

                    Image(systemName: "heart.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [WhimsicalTheme.blushPink, WhimsicalTheme.deepRose],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .shadow(color: WhimsicalTheme.deepRose.opacity(0.4), radius: 16)
                        .scaleEffect(sparkleScale)
                }
                .frame(height: 120)

                VStack(spacing: 12) {
                    Text("Enjoying\nWhimsical Walks?")
                        .font(.system(size: 30, weight: .bold, design: .serif))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)

                    Text("Your feedback helps us\nkeep the magic going ✨")
                        .font(.system(size: 16, weight: .medium, design: .serif))
                        .foregroundStyle(.white.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
            }
            .opacity(headerVisible ? 1 : 0)
            .offset(y: headerVisible ? 0 : 20)

            Spacer()

            VStack(spacing: 14) {
                Button {
                    if !hasRequestedReview {
                        requestReview()
                        hasRequestedReview = true
                    }
                    Task {
                        try? await Task.sleep(for: .seconds(0.5))
                        onContinue()
                    }
                } label: {
                    HStack(spacing: 8) {
                        Image(systemName: "heart.fill")
                            .font(.body)
                        Text("Rate & Continue")
                            .font(.system(size: 18, weight: .bold, design: .serif))
                    }
                    .foregroundStyle(WhimsicalTheme.deepRose)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 17)
                    .background(.white, in: Capsule())
                    .shadow(color: WhimsicalTheme.deepRose.opacity(0.3), radius: 12, x: 0, y: 4)
                }

                Button {
                    onContinue()
                } label: {
                    Text("Maybe later")
                        .font(.system(size: 15, weight: .medium, design: .serif))
                        .foregroundStyle(.white.opacity(0.5))
                }
            }
            .padding(.horizontal, 32)
            .opacity(ctaVisible ? 1 : 0)
            .offset(y: ctaVisible ? 0 : 16)

            Spacer().frame(height: 80)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                headerVisible = true
            }
            withAnimation(.spring(response: 0.8, dampingFraction: 0.5).delay(0.4)) {
                sparkleScale = 1.0
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(1.0)) {
                ctaVisible = true
            }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                sparkleRotation = .pi * 2
            }
        }
    }
}
