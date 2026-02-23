import SwiftUI

/// Detail face — shown when the user taps the board in the main clock view.
/// Header (back + gear) → 196×196 board → floating CTA pill → game metadata.
struct InfoPanelView: View {
    let state: ClockState
    @ObservedObject var guessService: GuessService
    let onBack: () -> Void
    let onGuess: () -> Void
    let onReplay: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // 1. Header
            HStack {
                Button(action: onBack) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: {}) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(width: 28, height: 28)
                }
                .buttonStyle(.plain)
            }
            .frame(height: ChessClockSize.headerHeight)
            .padding(.horizontal, 20)

            // 2. Board (no CTA overlay)
            BoardView(fen: state.fen, isFlipped: state.isFlipped)
                .frame(width: ChessClockSize.boardDetail, height: ChessClockSize.boardDetail)
                .clipShape(RoundedRectangle(cornerRadius: ChessClockRadius.board))
                .contentShape(Rectangle())
                .onTapGesture { tapAction() }
                .padding(.top, ChessClockSpace.xs)

            // 3. Floating CTA pill
            Button(action: tapAction) {
                HStack(spacing: 6) {
                    Image(systemName: ctaIcon)
                        .font(.system(size: 10, weight: .semibold))
                    Text(ctaText)
                        .font(.system(size: 12, weight: .semibold))
                }
                .foregroundColor(ctaForeground)
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .shadow(color: .black.opacity(0.15), radius: 6, x: 0, y: 2)
            }
            .buttonStyle(.plain)
            .padding(.top, 6)

            // 4. Game metadata
            VStack(alignment: .leading, spacing: ChessClockSpace.sm) {
                Text(PlayerNameFormatter.format(pgn: state.game.white, elo: state.game.whiteElo))
                    .font(ChessClockType.body)
                    .foregroundColor(.primary)

                Text(PlayerNameFormatter.format(pgn: state.game.black, elo: state.game.blackElo))
                    .font(ChessClockType.body)
                    .foregroundColor(.primary)

                Text(eventString)
                    .font(ChessClockType.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.top, ChessClockSpace.sm)
            .padding(.horizontal, ChessClockSpace.xl)
            .frame(maxWidth: .infinity, alignment: .leading)

            // 5. Bottom spacer
            Spacer()
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - CTA Properties

    private var ctaIcon: String {
        if !guessService.hasResult { return "play.fill" }
        if guessService.result?.succeeded == true { return "checkmark" }
        return "arrow.counterclockwise"
    }

    private var ctaText: String {
        if !guessService.hasResult { return "Play" }
        if guessService.result?.succeeded == true { return "Solved" }
        return "Review"
    }

    private var ctaForeground: Color {
        if !guessService.hasResult {
            return ChessClockColor.accentGold
        } else if guessService.result?.succeeded == true {
            return ChessClockColor.feedbackSuccess
        } else {
            return .secondary
        }
    }

    // MARK: - Helpers

    private func tapAction() {
        if guessService.hasResult {
            onReplay()
        } else {
            onGuess()
        }
    }

    private var eventString: String {
        if let month = state.game.month {
            return "\(state.game.tournament) · \(String(month.prefix(3))) \(state.game.year)"
        }
        return "\(state.game.tournament) · \(state.game.year)"
    }
}
