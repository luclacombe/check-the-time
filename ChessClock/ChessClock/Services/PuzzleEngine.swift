import Foundation

/// Pure value-type puzzle engine. No side effects, no persistence.
/// Drives the multi-move "Guess Move" puzzle from hour 1 (mate-in-1) through hour 12.
struct PuzzleEngine {

    // MARK: - Result type

    enum SubmitResult {
        /// Correct move. opponentMoves = (uci, resultingFEN) pairs auto-played by opponent.
        /// Empty when the user's next turn follows immediately.
        case correctContinue(opponentMoves: [(uci: String, fen: String)])
        /// All user moves found — puzzle solved!
        case success
        /// Wrong move. Engine reset to startPositionIndex internally.
        /// resetAutoPlays = opponent auto-plays already applied at reset start.
        case wrong(triesRemaining: Int, resetAutoPlays: [(uci: String, fen: String)])
        /// Used all 3 tries without solving. Puzzle over.
        case failed
    }

    // MARK: - State

    let game: ChessGame
    let hour: Int                              // 1–12

    private(set) var currentPositionIndex: Int // indexes game.positions; starts at hour-1
    private(set) var triesUsed: Int = 1        // 1 = first try
    private(set) var isComplete: Bool = false
    private(set) var succeeded: Bool = false

    // MARK: - Computed properties

    /// The index (into game.positions) where this puzzle starts.
    /// Skips to the mating-side position so hour N = exactly N user moves.
    /// positions[0] = mate in 1 (mating side to move).
    /// positions[2] = mate in 2 (mating side to move, opponent at positions[1]).
    /// positions[2*(N-1)] = mate in N.
    var startPositionIndex: Int { (hour - 1) * 2 }

    /// FEN of the current board position.
    var currentFEN: String { game.positions[currentPositionIndex] }

    /// True when the mating side is to move at the current position (= user's turn).
    var isUserTurn: Bool {
        guard !isComplete else { return false }
        guard let state = ChessRules.parseState(fen: currentFEN) else { return false }
        let matingColor: PieceColor = game.mateBy == "white" ? .white : .black
        return state.activeColor == matingColor
    }

    /// The correct UCI move from the current position.
    var expectedMove: String { game.moveSequence[currentPositionIndex] }

    // MARK: - Init

    init(game: ChessGame, hour: Int) {
        self.game = game
        self.hour = hour
        self.currentPositionIndex = (hour - 1) * 2
    }

    // MARK: - Public API

    /// Auto-advance past consecutive opponent moves from the current position.
    /// Returns (uci, nextFEN) pairs for the UI to animate. Stops when user's turn or complete.
    mutating func advancePastOpponentMoves() -> [(uci: String, fen: String)] {
        var plays: [(uci: String, fen: String)] = []
        while !isComplete && !isUserTurn {
            let uci = expectedMove
            advanceOne()
            let nextFEN = isComplete ? "" : currentFEN
            plays.append((uci: uci, fen: nextFEN))
        }
        return plays
    }

    /// Submit a move from the user. Returns the outcome.
    mutating func submit(uci: String) -> SubmitResult {
        guard !isComplete else { return .correctContinue(opponentMoves: []) }
        guard isUserTurn else { return .correctContinue(opponentMoves: []) }

        if uci == expectedMove {
            advanceOne()
            if isComplete { return .success }
            let opponentMoves = advancePastOpponentMoves()
            return isComplete ? .success : .correctContinue(opponentMoves: opponentMoves)
        } else {
            if triesUsed >= 3 {
                isComplete = true
                succeeded = false
                return .failed
            } else {
                triesUsed += 1
                resetToStart()
                let resetAutoPlays = advancePastOpponentMoves()
                return .wrong(triesRemaining: 3 - triesUsed + 1, resetAutoPlays: resetAutoPlays)
            }
        }
    }

    // MARK: - Private

    private mutating func advanceOne() {
        if currentPositionIndex == 0 {
            isComplete = true
            succeeded = true
        } else {
            currentPositionIndex -= 1
        }
    }

    private mutating func resetToStart() {
        currentPositionIndex = startPositionIndex
    }
}
