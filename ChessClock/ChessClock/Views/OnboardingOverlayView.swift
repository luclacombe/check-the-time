import SwiftUI

struct OnboardingOverlayView: View {
    let onDismiss: () -> Void
    @State private var dontShowAgain = false

    var body: some View {
        ZStack {
            Color.black.opacity(0.6)

            VStack(spacing: 14) {
                Text("Chess Clock")
                    .font(ChessClockType.title)
                    .foregroundStyle(.primary)

                VStack(alignment: .leading, spacing: ChessClockSpace.sm) {
                    Text("The board shows a real game, moments before checkmate.")
                    Text("The gold ring counts the minutes.")
                    Text("A new puzzle every hour.")
                    Text("Tap the board to learn more.")
                }
                .font(ChessClockType.body)
                .foregroundStyle(.secondary)
                .frame(maxWidth: .infinity, alignment: .leading)

                Toggle(isOn: $dontShowAgain) {
                    Text("Don't show again")
                        .font(ChessClockType.caption)
                        .foregroundStyle(.secondary)
                }
                .toggleStyle(.checkbox)
                .controlSize(.small)

                Button("Continue") {
                    if dontShowAgain {
                        OnboardingService.dismissOnboarding()
                    }
                    onDismiss()
                }
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(ChessClockColor.accentGold)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(ChessClockColor.accentGold.opacity(0.12))
                .clipShape(Capsule())
                .buttonStyle(.plain)
                .padding(.top, 2)
            }
            .padding(20)
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: ChessClockRadius.card))
            .padding(20)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
