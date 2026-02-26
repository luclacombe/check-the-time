import SwiftUI

// MARK: - ReplayZone

/// Position zone relative to the puzzle start.
enum ReplayZone: Equatable {
    case before, start, after, checkmate

    /// Classify a position index in the forward-indexed full-game timeline.
    ///   posIndex == totalMoves            → .checkmate (final position)
    ///   posIndex < puzzleStartPosIndex    → .before  (opening — older than puzzle)
    ///   posIndex == puzzleStartPosIndex   → .start   (exact puzzle start position)
    ///   posIndex > puzzleStartPosIndex    → .after   (solution — includes moves after puzzle)
    static func classify(posIndex: Int, puzzleStartPosIndex: Int, totalMoves: Int) -> ReplayZone {
        if posIndex == totalMoves { return .checkmate }
        if posIndex < puzzleStartPosIndex { return .before }
        if posIndex == puzzleStartPosIndex { return .start }
        return .after
    }

    var label: String {
        switch self {
        case .before:    return "Opening"
        case .start:     return "Puzzle"
        case .after:     return "Solution"
        case .checkmate: return "Checkmate"
        }
    }

    var color: Color {
        switch self {
        case .before:    return Color(.systemGray)
        case .start:     return Color(red: 0.80, green: 0.62, blue: 0.11)  // gold
        case .after:     return Color.green
        case .checkmate: return Color(red: 0.10, green: 0.65, blue: 0.10)
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
    @FocusState private var isFocused: Bool

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
        ReplayZone.classify(posIndex: posIndex, puzzleStartPosIndex: puzzleStartPosIndex, totalMoves: totalMoves)
    }

    private var displayFEN: String {
        guard !allPositions.isEmpty, posIndex < allPositions.count else {
            return game.positions.first ?? ""
        }
        return allPositions[posIndex]
    }

    /// Highlighted from/to squares for the current move.
    private var currentHighlight: (from: ChessSquare, to: ChessSquare)? {
        guard posIndex > 0, posIndex - 1 < game.allMoves.count else { return nil }
        guard let move = ChessMove.from(uci: game.allMoves[posIndex - 1]) else { return nil }
        return (from: move.from, to: move.to)
    }

    // MARK: - Name helpers

    private var whiteName: String {
        game.white.components(separatedBy: ",").first ?? game.white
    }
    private var blackName: String {
        game.black.components(separatedBy: ",").first ?? game.black
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            boardSection
            backPill
            navStrip
        }
        .frame(width: 280, height: 280)
        .clipShape(RoundedRectangle(cornerRadius: ChessClockRadius.puzzleBoard))
        .modifier(FocusEffectDisabledModifier())
        .focusable(true)
        .focused($isFocused)
        .onHover { hovering in if hovering { isFocused = true } }
        .onMoveCommand { direction in
            switch direction {
            case .left:  navigate(to: max(posIndex - 1, 0))
            case .right: navigate(to: min(posIndex + 1, totalMoves))
            default: break
            }
        }
        .overlay {
            if #available(macOS 14.0, *) {
                Color.clear
                    .onKeyPress(phases: .down) { keyPress in
                        guard keyPress.modifiers == .command else { return .ignored }
                        switch keyPress.key {
                        case .leftArrow:
                            navigate(to: 0)
                            return .handled
                        case .rightArrow:
                            navigate(to: totalMoves)
                            return .handled
                        default:
                            return .ignored
                        }
                    }
            }
        }
    }

    // MARK: - Sub-views

    private var boardSection: some View {
        BoardView(fen: displayFEN, isFlipped: isFlipped, highlightedSquares: currentHighlight)
            .frame(width: 280, height: 280)
    }

    // MARK: - Back Pill

    private var backPill: some View {
        Button(action: onBack) {
            HStack(spacing: 4) {
                Image(systemName: "chevron.left")
                    .font(.system(size: 12))
                    .foregroundColor(Color.white.opacity(0.85))
                Text("\(whiteName) vs \(blackName)")
                    .font(ChessClockType.caption)
                    .foregroundColor(Color.white.opacity(0.85))
                    .lineLimit(1)
                    .truncationMode(.tail)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(ChessClockColor.pillBackground, in: RoundedRectangle(cornerRadius: ChessClockRadius.pill))
            .overlay(RoundedRectangle(cornerRadius: ChessClockRadius.pill).stroke(ChessClockColor.pillBorder, lineWidth: 0.5))
            .shadow(color: .black.opacity(0.25), radius: 4, y: 2)
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(8)
    }

    // MARK: - Nav Strip

    private var navStrip: some View {
        VStack(spacing: 0) {
            // Content HStack
            HStack {
                // Left arrow
                Button(action: { navigate(to: max(posIndex - 1, 0)) }) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)
                .focusable(false)
                .disabled(posIndex == 0)

                Spacer()

                // Center group
                HStack(spacing: 6) {
                    Text(zone.label)
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(zone.color)
                    Text("\u{00B7}")
                        .font(ChessClockType.micro)
                        .foregroundColor(Color.white.opacity(0.40))
                    Text(sanLabel)
                        .font(ChessClockType.mono)
                        .foregroundColor(Color.white.opacity(0.85))
                    Text("\u{00B7}")
                        .font(ChessClockType.micro)
                        .foregroundColor(Color.white.opacity(0.40))
                    Text("\(posIndex)/\(totalMoves)")
                        .font(ChessClockType.micro)
                        .foregroundColor(Color.white.opacity(0.60))
                }

                Spacer()

                // Right arrow
                Button(action: { navigate(to: min(posIndex + 1, totalMoves)) }) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 14))
                        .foregroundColor(.white)
                }
                .buttonStyle(.plain)
                .focusable(false)
                .disabled(posIndex == totalMoves)
            }
            .padding(.horizontal, 10)
            .padding(.top, 6)
            .padding(.bottom, 4)

            // Progress bar
            ReplayProgressBar(
                posIndex: posIndex,
                totalMoves: totalMoves,
                puzzleStartPosIndex: puzzleStartPosIndex,
                zone: zone,
                onSeek: { navigate(to: $0) }
            )
            .padding(.horizontal, 6)
            .padding(.bottom, 4)
        }
        .background(
            ChessClockColor.pillBackground
                .clipShape(
                    UnevenRoundedRectangle(
                        bottomLeadingRadius: ChessClockRadius.puzzleBoard,
                        bottomTrailingRadius: ChessClockRadius.puzzleBoard
                    )
                )
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
    }

    private var sanLabel: String {
        guard posIndex > 0 else { return "\u{2014}" }  // em dash
        guard posIndex - 1 < game.allMoves.count else { return "\u{2014}" }
        let uci = game.allMoves[posIndex - 1]
        guard let stateBeforeMove = ChessRules.parseState(fen: allPositions[posIndex - 1]) else {
            return uci.uppercased()
        }
        return SANFormatter.format(uci: uci, in: stateBeforeMove)
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

// MARK: - Focus Effect Availability Wrapper

private struct FocusEffectDisabledModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(macOS 14.0, *) {
            content.focusEffectDisabled()
        } else {
            content
        }
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
        .frame(width: 280, height: 280)
}
