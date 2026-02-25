import SwiftUI

struct SettingsPlaceholderView: View {
    let onBack: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)

                Spacer()
            }
            .padding(.horizontal, 8)

            Spacer()

            VStack(spacing: ChessClockSpace.md) {
                Image(systemName: "gearshape")
                    .font(.system(size: 32, weight: .light))
                    .foregroundColor(.secondary.opacity(0.5))
                Text("Coming Soon")
                    .font(ChessClockType.title)
                    .foregroundColor(.secondary)
            }

            Spacer()
        }
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
