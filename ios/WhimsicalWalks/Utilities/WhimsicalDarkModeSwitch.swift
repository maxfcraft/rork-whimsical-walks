import SwiftUI

struct WhimsicalDarkModeSwitch: View {
    @Binding var isOn: Bool

    private let width: CGFloat = 64
    private let height: CGFloat = 34
    private let knobInset: CGFloat = 3

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                isOn.toggle()
            }
        } label: {
            ZStack(alignment: isOn ? .trailing : .leading) {
                Capsule()
                    .fill(
                        isOn
                            ? WhimsicalTheme.deepRose
                            : WhimsicalTheme.blushPink.opacity(0.55)
                    )
                    .overlay {
                        Capsule()
                            .stroke(WhimsicalTheme.deepRose.opacity(0.18), lineWidth: 0.5)
                    }
                    .frame(width: width, height: height)
                    .shadow(color: WhimsicalTheme.deepRose.opacity(isOn ? 0.25 : 0.0), radius: 8, y: 2)

                Circle()
                    .fill(Color.white)
                    .frame(width: height - knobInset * 2, height: height - knobInset * 2)
                    .shadow(color: .black.opacity(0.15), radius: 2, y: 1)
                    .padding(knobInset)
                    .overlay {
                        Image(systemName: isOn ? "moon.fill" : "sun.max.fill")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(isOn ? WhimsicalTheme.deepLavender : WhimsicalTheme.deepPeach)
                            .padding(knobInset)
                            .contentTransition(.symbolEffect(.replace))
                    }
            }
            .frame(width: width, height: height)
        }
        .buttonStyle(.plain)
    }
}
