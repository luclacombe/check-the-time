import SwiftUI

/// Reusable frosted-glass container used for overlay pills (hover text, badges, etc.).
struct GlassPillView<Content: View>: View {
    @ViewBuilder var content: () -> Content

    var body: some View {
        content()
            .padding(.horizontal, ChessClockSpace.xl)
            .padding(.vertical, ChessClockSpace.lg)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: ChessClockRadius.pill))
    }
}
