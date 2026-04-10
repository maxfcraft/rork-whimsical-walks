import SwiftUI
import RevenueCat

struct SettingsPaywallView: View {
    let store: StoreViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var selectedPackageId: String = "$rc_annual"

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

    var body: some View {
        ZStack {
            OnboardingBackground(page: 5)

            ScrollView(showsIndicators: false) {
                VStack(spacing: 0) {
                    HStack {
                        Spacer()
                        Button {
                            dismiss()
                        } label: {
                            Image(systemName: "xmark")
                                .font(.body.weight(.semibold))
                                .foregroundStyle(.white.opacity(0.6))
                                .frame(width: 32, height: 32)
                                .background(.white.opacity(0.15), in: Circle())
                        }
                    }
                    .padding(.top, 16)

                    Spacer().frame(height: 20)

                    VStack(spacing: 12) {
                        Text("Whimsical Walks")
                            .font(.custom(FontRegistration.keshia, size: 36))
                            .foregroundStyle(.white)

                        Text("Renew your subscription")
                            .font(.system(size: 17, weight: .medium, design: .serif))
                            .foregroundStyle(.white.opacity(0.8))
                    }

                    Spacer().frame(height: 28)

                    VStack(spacing: 12) {
                        ValueBullet(icon: "camera.filters", text: "Magical photo filters on every walk")
                        ValueBullet(icon: "map.fill", text: "Fresh daily quests & adventures")
                        ValueBullet(icon: "pawprint.fill", text: "Adorable pets that grow with you")
                    }

                    Spacer().frame(height: 28)

                    if store.isLoading {
                        ProgressView()
                            .tint(.white)
                            .padding(.vertical, 40)
                    } else if currentOffering != nil {
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

                        Spacer().frame(height: 24)

                        Button {
                            guard let pkg = selectedPackage else { return }
                            Task {
                                let success = await store.purchase(package: pkg)
                                if success { dismiss() }
                            }
                        } label: {
                            HStack(spacing: 8) {
                                if store.isPurchasing {
                                    ProgressView()
                                        .tint(WhimsicalTheme.deepRose)
                                }
                                Text("Subscribe Now")
                                    .font(.system(size: 18, weight: .bold, design: .serif))
                            }
                            .foregroundStyle(WhimsicalTheme.deepRose)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 17)
                            .background(.white, in: Capsule())
                            .shadow(color: WhimsicalTheme.deepRose.opacity(0.3), radius: 12, x: 0, y: 6)
                        }
                        .disabled(store.isPurchasing)
                    } else if store.loadFailed {
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
                    } else {
                        ProgressView()
                            .tint(.white)
                            .padding(.vertical, 40)
                    }

                    Spacer().frame(height: 16)

                    Button("Restore Purchases") {
                        Task {
                            await store.restore()
                            if store.isPremium { dismiss() }
                        }
                    }
                    .font(.system(size: 14, weight: .medium, design: .serif))
                    .foregroundStyle(.white.opacity(0.55))

                    Spacer().frame(height: 12)

                    HStack(spacing: 16) {
                        Link("Terms of Service", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                        Link("Privacy Policy", destination: URL(string: "https://www.apple.com/legal/privacy/")!)
                    }
                    .font(.system(size: 12, weight: .regular))
                    .foregroundStyle(.white.opacity(0.4))

                    Spacer().frame(height: 40)
                }
                .padding(.horizontal, 24)
            }
        }
        .ignoresSafeArea()
        .onChange(of: store.isPremium) { _, isPremium in
            if isPremium { dismiss() }
        }
        .task {
            store.error = nil
            if store.offerings == nil && !store.isLoading {
                await store.fetchOfferings()
            }
        }
    }
}
