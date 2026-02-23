import SwiftUI

/// Detail face — shown when the user taps the board in the main clock view.
/// Header (back + gear) → 196×196 board with CTA overlay → game metadata.
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
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)

                Spacer()

                Button(action: {}) {
                    Image(systemName: "gearshape")
                        .font(.system(size: 11))
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .frame(height: ChessClockSize.headerHeight)

            // 2. Board with CTA overlay
            BoardView(fen: state.fen, isFlipped: state.isFlipped)
                .frame(width: ChessClockSize.boardDetail, height: ChessClockSize.boardDetail)
                .clipShape(RoundedRectangle(cornerRadius: ChessClockRadius.board))
                .overlay(alignment: .bottom) {
                    ctaOverlay
                }
                .contentShape(Rectangle())
                .onTapGesture { tapAction() }
                .padding(.top, ChessClockSpace.sm)

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
            .padding(.top, ChessClockSpace.md)
            .padding(.horizontal, ChessClockSpace.xl)
            .frame(maxWidth: .infinity, alignment: .leading)

            // 5. Bottom spacer
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - CTA Overlay

    private var ctaOverlay: some View {
        HStack(spacing: 4) {
            if !guessService.hasResult {
                // Not yet played
                Image(systemName: "play.fill")
                    .font(.system(size: 10))
                Text("Play")
                    .font(.system(size: 12, weight: .semibold))
            } else if guessService.result?.succeeded == true {
                // Solved
                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 10))
                Text("Solved · Review")
                    .font(.system(size: 12, weight: .semibold))
            } else {
                // Failed
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 10))
                Text("· Review")
                    .font(.system(size: 12, weight: .semibold))
            }
        }
        .foregroundColor(ctaForeground)
        .frame(maxWidth: .infinity)
        .frame(height: ChessClockSize.headerHeight)
        .background(ChessClockColor.ctaBg)
        .clipShape(UnevenRoundedRectangle(bottomLeadingRadius: ChessClockRadius.board, bottomTrailingRadius: ChessClockRadius.board))
        .contentShape(Rectangle())
        .onTapGesture { tapAction() }
    }

    private var ctaForeground: Color {
        if !guessService.hasResult {
            return ChessClockColor.accentGold
        } else if guessService.result?.succeeded == true {
            return ChessClockColor.feedbackSuccess
        } else {
            return ChessClockColor.feedbackError
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
