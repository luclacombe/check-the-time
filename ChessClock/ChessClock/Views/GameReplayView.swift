import SwiftUI

// MARK: - ReplayZone

/// Position zone relative to the puzzle start.
enum ReplayZone: Equatable {
    case before, start, after

    /// Classify a position index in the forward-indexed full-game timeline.
    ///   posIndex < puzzleStartPosIndex  → .before  (game context — older than puzzle)
    ///   posIndex == puzzleStartPosIndex → .start   (exact puzzle start position)
    ///   posIndex > puzzleStartPosIndex  → .after   (solution / newer — includes checkmate)
    static func classify(posIndex: Int, puzzleStartPosIndex: Int) -> ReplayZone {
        if posIndex < puzzleStartPosIndex { return .before }
        if posIndex == puzzleStartPosIndex { return .start }
        return .after
    }

    var label: String {
        switch self {
        case .before: return "Game context"
        case .start:  return "Puzzle start"
        case .after:  return "Solution"
        }
    }

    var color: Color {
        switch self {
        case .before: return Color(.systemGray)
        case .start:  return Color(red: 0.80, green: 0.62, blue: 0.11)  // gold
        case .after:  return Color.green
        }
    }
}

// MARK: - GameReplayView

/// Full-game replay viewer.
///
/// Position timeline (forward in game time):
///   posIndex 0              = standard starting position (all 32 pieces)
///   posIndex 1 … N-1       = game positions after each move
///   posIndex N              = checkmate position (after allMoves.last)
///
/// where N = game.allMoves.count.
///
/// Puzzle start posIndex = N − 1 − (hour − 1) × 2.
struct GameReplayView: View {
    let game: ChessGame
    let hour: Int
    let isFlipped: Bool
    let onBack: () -> Void

    // Complete position list (posIndex 0…N), pre-computed from game.allMoves.
    private let allPositions: [String]
    // posIndex of the puzzle-start square.
    private let puzzleStartPosIndex: Int

    @State private var posIndex: Int

    init(game: ChessGame, hour: Int, isFlipped: Bool, onBack: @escaping () -> Void) {
        self.game = game
        self.hour = hour
        self.isFlipped = isFlipped
        self.onBack = onBack

        let positions = Self.computeAllPositions(game: game)
        self.allPositions = positions

        let psi = max(0, positions.count - 2 - (hour - 1) * 2)
        self.puzzleStartPosIndex = psi
        self._posIndex = State(initialValue: psi)
    }

    // MARK: - Derived state

    private var totalMoves: Int { game.allMoves.count }

    private var zone: ReplayZone {
        ReplayZone.classify(posIndex: posIndex, puzzleStartPosIndex: puzzleStartPosIndex)
    }

    private var displayFEN: String {
        guard !allPositions.isEmpty, posIndex < allPositions.count else {
            return game.positions.first ?? ""
        }
        return allPositions[posIndex]
    }

    /// The move that arrived at the current position (for the arrow overlay).
    /// nil at posIndex 0 (starting position — no move played yet).
    private var moveArrow: ChessMove? {
        guard posIndex > 0, posIndex - 1 < game.allMoves.count else { return nil }
        return ChessMove.from(uci: game.allMoves[posIndex - 1])
    }

    /// "Starting position" at pos 0; "Checkmate" at the final pos; move UCI otherwise.
    private var moveLabel: String {
        if posIndex == 0 { return "Starting position" }
        guard posIndex - 1 < game.allMoves.count else { return "—" }
        return game.allMoves[posIndex - 1].uppercased()
    }

    private var bannerLabel: String {
        posIndex == totalMoves ? "Checkmate" : zone.label
    }

    private var bannerColor: Color {
        posIndex == totalMoves ? Color(red: 0.10, green: 0.65, blue: 0.10) : zone.color
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 8) {
            header
            zoneBanner
            board
            moveInfo
            navButtons
        }
        .padding(16)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .focusable()
        .onMoveCommand { direction in
            switch direction {
            case .left:  navigate(to: max(posIndex - 1, 0))
            case .right: navigate(to: min(posIndex + 1, totalMoves))
            default: break
            }
        }
    }

    // MARK: - Sub-views

    private var header: some View {
        HStack {
            Button(action: onBack) {
                HStack(spacing: 4) {
                    Image(systemName: "chevron.left")
                        .font(.caption.weight(.semibold))
                    Text("Back")
                        .font(.caption.weight(.semibold))
                }
                .foregroundColor(.secondary)
            }
            .buttonStyle(.plain)

            Spacer()

            VStack(alignment: .trailing, spacing: 1) {
                Text("\(game.white) vs \(game.black)")
                    .font(.caption.weight(.semibold))
                    .lineLimit(1)
                Text("\(game.year)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }

    private var zoneBanner: some View {
        Text(bannerLabel)
            .font(.caption.weight(.semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 4)
            .background(bannerColor)
            .clipShape(Capsule())
            .animation(.easeInOut(duration: 0.2), value: posIndex)
    }

    private var board: some View {
        // No .id(posIndex) — update board in-place to avoid flash.
        // The arrow fades in/out to signal which move was played.
        BoardView(fen: displayFEN, isFlipped: isFlipped)
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                if let arrow = moveArrow {
                    MoveArrowView(from: arrow.from, to: arrow.to, isFlipped: isFlipped)
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.18), value: posIndex)
    }

    private var moveInfo: some View {
        HStack {
            Text(moveLabel)
                .font(.caption.weight(.medium))
                .foregroundColor(.primary)
                .lineLimit(1)
            Spacer()
            Text("\(posIndex) / \(totalMoves)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }

    private var navButtons: some View {
        HStack(spacing: 12) {
            // ⏮ Game start (all 32 pieces)
            Button { navigate(to: 0) } label: {
                Image(systemName: "backward.end.fill")
            }
            .disabled(posIndex == 0)

            // ← Step backward (older)
            Button { navigate(to: max(posIndex - 1, 0)) } label: {
                Image(systemName: "chevron.left")
            }
            .disabled(posIndex == 0)

            // ⦿ Jump to puzzle start
            Button { navigate(to: puzzleStartPosIndex) } label: {
                Image(systemName: "record.circle")
            }

            // → Step forward (newer)
            Button { navigate(to: min(posIndex + 1, totalMoves)) } label: {
                Image(systemName: "chevron.right")
            }
            .disabled(posIndex == totalMoves)

            // ⏭ Checkmate (game end)
            Button { navigate(to: totalMoves) } label: {
                Image(systemName: "forward.end.fill")
            }
            .disabled(posIndex == totalMoves)
        }
        .buttonStyle(.bordered)
        .controlSize(.small)
    }

    // MARK: - Navigation

    private func navigate(to newIndex: Int) {
        withAnimation(.easeInOut(duration: 0.18)) {
            posIndex = newIndex
        }
    }

    // MARK: - Full position list computation

    /// Replay every move in `game.allMoves` from the standard starting position using
    /// ChessRules.apply. Returns an array of N+1 FEN strings where index 0 is the start
    /// and index N is the checkmate position.
    static func computeAllPositions(game: ChessGame) -> [String] {
        let startFEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"
        guard !game.allMoves.isEmpty,
              var state = ChessRules.parseState(fen: startFEN) else {
            return [startFEN]
        }
        var positions = [startFEN]
        for uci in game.allMoves {
            guard let move = ChessMove.from(uci: uci) else { break }
            state = ChessRules.apply(move, to: state)
            positions.append(Self.gameStateFEN(state))
        }
        return positions
    }

    /// Convert a GameState back to a minimal FEN string (piece placement + side to move).
    /// Castling and en-passant fields are zeroed — sufficient for display only.
    static func gameStateFEN(_ state: GameState) -> String {
        var ranks: [String] = []
        for ri in 0..<8 {
            var rank = ""; var empty = 0
            for fi in 0..<8 {
                if let p = state.board[ri][fi] {
                    if empty > 0 { rank += "\(empty)"; empty = 0 }
                    let sym: String
                    switch p.type {
                    case .king:   sym = "k"
                    case .queen:  sym = "q"
                    case .rook:   sym = "r"
                    case .bishop: sym = "b"
                    case .knight: sym = "n"
                    case .pawn:   sym = "p"
                    }
                    rank += p.color == .white ? sym.uppercased() : sym
                } else {
                    empty += 1
                }
            }
            if empty > 0 { rank += "\(empty)" }
            ranks.append(rank)
        }
        let active = state.activeColor == .white ? "w" : "b"
        return ranks.joined(separator: "/") + " \(active) - - 0 1"
    }
}

#Preview {
    let fens  = Array(repeating: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1", count: 23)
    let allMs = ["e2e4","e7e5","g1f3","b8c6","f1c4","g8f6","f3g5","d7d5","e4d5","c6a5"]
    let game  = ChessGame(
        white: "Kasparov", black: "Karpov",
        whiteElo: "2805", blackElo: "2750",
        tournament: "World Championship", year: 1984,
        moveSequence: Array(repeating: "e1e2", count: 23),
        allMoves: allMs, positions: fens
    )
    return GameReplayView(game: game, hour: 6, isFlipped: false, onBack: {})
        .frame(width: 312, height: 500)
}
