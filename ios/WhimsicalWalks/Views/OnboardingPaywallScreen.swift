import SwiftUI
import RevenueCat

struct OnboardingPaywallScreen: View {
    let store: StoreViewModel
    let onComplete: () -> Void
    @State private var selectedPackageId: String = "$rc_annual"
    @State private var headerVisible: Bool = false
    @State private var cardsVisible: Bool = false
    @State private var ctaVisible: Bool = false
    @State private var ctaPulse: Bool = false

    private var currentOffering: Offering? {
        store.offerings?.current
    }

    private var monthlyPackage: Package? {
        currentOffering?.availablePackages.first(where: { $0.identifier == "$rc_monthly" })
    }

    private var yearlyPackage: Package? {
        currentOffering?.availablePackages.first(where: { $0.identifier == "$rc_annual" })
    }

    private var selectedPackage: Package? {
        currentOffering?.availablePackages.first(where: { $0.identifier == selectedPackageId })
    }

    private var yearlySavingsPercent: Int {
        guard let monthly = monthlyPackage, let yearly = yearlyPackage else { return 0 }
        let monthlyAnnualCost = NSDecimalNumber(decimal: monthly.storeProduct.price * 12).doubleValue
        guard monthlyAnnualCost > 0 else { return 0 }
        let yearlyPrice = NSDecimalNumber(decimal: yearly.storeProduct.price).doubleValue
        let savings = (1.0 - (yearlyPrice / monthlyAnnualCost)) * 100
        return Int(savings.rounded())
    }

    private var yearlyPerMonth: String {
        guard let yearly = yearlyPackage else { return "" }
        let perMonth = yearly.storeProduct.price / 12
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = yearly.storeProduct.priceFormatter?.locale ?? .current
        return formatter.string(from: perMonth as NSDecimalNumber) ?? ""
    }

    private var billingDescription: String {
        guard let pkg = selectedPackage else { return "" }
        let price = pkg.storeProduct.localizedPriceString
        switch pkg.packageType {
        case .annual: return "then \(price)/year after your 3-day free trial"
        case .monthly: return "then \(price)/month after your 3-day free trial"
        default: return "then \(price) after your 3-day free trial"
        }
    }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Spacer().frame(height: 60)

                heroSection
                    .opacity(headerVisible ? 1 : 0)
                    .offset(y: headerVisible ? 0 : 20)

                Spacer().frame(height: 28)

                valuePoints
                    .opacity(headerVisible ? 1 : 0)

                Spacer().frame(height: 28)

                if store.isLoading {
                    ProgressView()
                        .tint(.white)
                        .padding(.vertical, 40)
                } else if currentOffering != nil {
                    pricingSection
                        .opacity(cardsVisible ? 1 : 0)
                        .offset(y: cardsVisible ? 0 : 16)

                    Spacer().frame(height: 24)

                    ctaSection
                        .opacity(ctaVisible ? 1 : 0)
                        .scaleEffect(ctaVisible ? 1 : 0.95)
                } else if store.loadFailed {
                    loadFailedSection
                        .opacity(cardsVisible ? 1 : 0)

                    Spacer().frame(height: 16)

                    Button {
                        onComplete()
                    } label: {
                        Text("Continue for now")
                            .font(.system(size: 16, weight: .medium, design: .serif))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                    .opacity(cardsVisible ? 1 : 0)
                } else {
                    ProgressView()
                        .tint(.white)
                        .padding(.vertical, 40)
                }

                Spacer().frame(height: 16)

                footerSection

                Spacer().frame(height: 50)
            }
            .padding(.horizontal, 24)
        }
        .scrollDismissesKeyboard(.immediately)
        .task {
            if store.offerings == nil && !store.isLoading {
                await store.fetchOfferings()
            }
        }
        .onAppear {
            store.error = nil
            withAnimation(.easeOut(duration: 0.7).delay(0.2)) {
                headerVisible = true
            }
            withAnimation(.easeOut(duration: 0.6).delay(0.6)) {
                cardsVisible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(1.0)) {
                ctaVisible = true
            }
            startPulse()
        }
    }

    private var heroSection: some View {
        VStack(spacing: 12) {
            Text("Whimsical Walks")
                .font(.custom(FontRegistration.keshia, size: 36))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)

            Text("Unlock the full experience")
                .font(.system(size: 17, weight: .medium, design: .serif))
                .foregroundStyle(.white.opacity(0.8))
        }
    }

    private var valuePoints: some View {
        VStack(spacing: 12) {
            ValueBullet(icon: "camera.filters", text: "Magical photo filters on every walk")
            ValueBullet(icon: "map.fill", text: "Fresh daily quests & adventures")
            ValueBullet(icon: "pawprint.fill", text: "Adorable pets that grow with you")
        }
    }

    private var pricingSection: some View {
        VStack(spacing: 12) {
            if let yearly = yearlyPackage {
                PricingCard(
                    package: yearly,
                    isSelected: selectedPackageId == "$rc_annual",
                    badge: yearlySavingsPercent > 0 ? "Save \(yearlySavingsPercent)%" : nil,
                    subtitle: yearlyPerMonth.isEmpty ? nil : "just \(yearlyPerMonth)/mo"
                ) {
                    selectedPackageId = "$rc_annual"
                }
            }

            if let monthly = monthlyPackage {
                PricingCard(
                    package: monthly,
                    isSelected: selectedPackageId == "$rc_monthly",
                    badge: nil,
                    subtitle: nil
                ) {
                    selectedPackageId = "$rc_monthly"
                }
            }
        }
        .sensoryFeedback(.selection, trigger: selectedPackageId)
    }

    private var loadFailedSection: some View {
        VStack(spacing: 16) {
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 36))
                .foregroundStyle(.white.opacity(0.6))

            Text(store.error ?? "Could not load plans")
                .font(.system(size: 15, weight: .medium, design: .serif))
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)

            Button {
                Task { await store.fetchOfferings() }
            } label: {
                Text("Try Again")
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundStyle(WhimsicalTheme.deepRose)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(.white, in: Capsule())
            }
        }
        .padding(.vertical, 30)
    }

    private var ctaSection: some View {
        VStack(spacing: 12) {
            if !billingDescription.isEmpty {
                Text(billingDescription)
                    .font(.system(size: 16, weight: .semibold, design: .serif))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
            }

            Button {
                guard let pkg = selectedPackage else { return }
                Task {
                    let success = await store.purchase(package: pkg)
                    if success { onComplete() }
                }
            } label: {
                HStack(spacing: 8) {
                    if store.isPurchasing {
                        ProgressView()
                            .tint(WhimsicalTheme.deepRose)
                    }
                    Text("Try Free for 3 Days")
                        .font(.system(size: 18, weight: .bold, design: .serif))
                }
                .foregroundStyle(WhimsicalTheme.deepRose)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 17)
                .background(.white, in: Capsule())
                .shadow(color: WhimsicalTheme.deepRose.opacity(0.35), radius: ctaPulse ? 16 : 10, x: 0, y: ctaPulse ? 8 : 5)
            }
            .disabled(store.isPurchasing)
            .sensoryFeedback(.impact(flexibility: .soft), trigger: store.isPurchasing)

            Text("Cancel anytime in your App Store settings.")
                .font(.system(size: 13, weight: .regular, design: .serif))
                .foregroundStyle(.white.opacity(0.75))
        }
    }

    private var footerSection: some View {
        VStack(spacing: 8) {
            Button("Restore Purchases") {
                Task {
                    await store.restore()
                    if store.isPremium { onComplete() }
                }
            }
            .font(.system(size: 14, weight: .medium, design: .serif))
            .foregroundStyle(.white.opacity(0.7))

            HStack(spacing: 16) {
                Link("Terms of Service", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                Link("Privacy Policy", destination: URL(string: "https://www.apple.com/legal/privacy/")!)
            }
            .font(.system(size: 13, weight: .regular))
            .foregroundStyle(.white.opacity(0.65))

            Text("Payment will be charged to your Apple ID account at confirmation of purchase. Subscription automatically renews unless it is canceled at least 24 hours before the end of the current period.")
                .font(.system(size: 11, weight: .regular))
                .foregroundStyle(.white.opacity(0.55))
                .multilineTextAlignment(.center)
                .padding(.horizontal, 8)
        }
    }

    private func startPulse() {
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true).delay(1.2)) {
            ctaPulse = true
        }
    }
}

struct ValueBullet: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.body)
                .foregroundStyle(.white)
                .frame(width: 28)
            Text(text)
                .font(.system(size: 16, weight: .medium, design: .serif))
                .foregroundStyle(.white.opacity(0.9))
            Spacer()
        }
        .padding(.horizontal, 4)
    }
}

struct PreviewPricingCard: View {
    let title: String
    let price: String
    let isSelected: Bool
    let badge: String?
    let subtitle: String?
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.white : Color.white.opacity(0.35), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if isSelected {
                        Circle()
                            .fill(.white)
                            .frame(width: 14, height: 14)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(title)
                            .font(.system(size: 17, weight: .semibold, design: .serif))
                            .foregroundStyle(.white)

                        if let badge {
                            Text(badge)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(WhimsicalTheme.deepRose)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(.white, in: Capsule())
                        }
                    }

                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 13, weight: .regular, design: .serif))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }

                Spacer()

                Text(price)
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
            }
            .padding(16)
            .background(
                isSelected
                    ? Color.white.opacity(0.2)
                    : Color.white.opacity(0.08),
                in: .rect(cornerRadius: 18)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? Color.white.opacity(0.5) : Color.clear, lineWidth: 1.5)
            )
        }
    }
}

struct PricingCard: View {
    let package: Package
    let isSelected: Bool
    let badge: String?
    let subtitle: String?
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color.white : Color.white.opacity(0.35), lineWidth: 2)
                        .frame(width: 24, height: 24)
                    if isSelected {
                        Circle()
                            .fill(.white)
                            .frame(width: 14, height: 14)
                    }
                }

                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 8) {
                        Text(package.storeProduct.localizedTitle)
                            .font(.system(size: 17, weight: .semibold, design: .serif))
                            .foregroundStyle(.white)

                        if let badge {
                            Text(badge)
                                .font(.system(size: 11, weight: .bold))
                                .foregroundStyle(WhimsicalTheme.deepRose)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 3)
                                .background(.white, in: Capsule())
                        }
                    }

                    if let subtitle {
                        Text(subtitle)
                            .font(.system(size: 13, weight: .regular, design: .serif))
                            .foregroundStyle(.white.opacity(0.6))
                    }
                }

                Spacer()

                Text(package.storeProduct.localizedPriceString)
                    .font(.system(size: 20, weight: .bold, design: .serif))
                    .foregroundStyle(.white)
            }
            .padding(16)
            .background(
                isSelected
                    ? Color.white.opacity(0.2)
                    : Color.white.opacity(0.08),
                in: .rect(cornerRadius: 18)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 18)
                    .stroke(isSelected ? Color.white.opacity(0.5) : Color.clear, lineWidth: 1.5)
            )
        }
    }
}
