import Foundation

// MARK: - SAN Formatter

/// Converts UCI move strings to Standard Algebraic Notation (SAN).
///
/// Pure static utility — no state, no side effects.
/// Relies on `ChessRules` for legal move generation, move application,
/// and check detection.
enum SANFormatter {

    /// Format a UCI move string (e.g. `"e2e4"`, `"e7e8q"`) into SAN
    /// (e.g. `"e4"`, `"e8=Q"`) given the current game state.
    ///
    /// Returns the UCI string unchanged if it cannot be parsed.
    static func format(uci: String, in state: GameState) -> String {
        guard let move = ChessMove.from(uci: uci) else { return uci }

        let piece = state.piece(at: move.from)

        // --- Castling ---
        if piece?.type == .king {
            if let san = castlingSAN(move) { return san + suffix(after: move, in: state) }
        }

        // --- Build SAN components ---
        var san = ""

        let isPawn = piece?.type == .pawn
        let isCapture = self.isCapture(move, isPawn: isPawn, state: state)

        // Piece prefix (non-pawn)
        if !isPawn, let p = piece {
            san += piecePrefix(p.type)
        }

        // Disambiguation (non-pawn only)
        if !isPawn, let p = piece {
            san += disambiguation(move: move, pieceType: p.type, state: state)
        }

        // Pawn captures include the departure file
        if isPawn && isCapture {
            san += String(move.from.fileChar)
        }

        // Capture symbol
        if isCapture {
            san += "x"
        }

        // Destination square
        san += move.to.algebraic

        // Promotion
        if let promo = move.promotion {
            san += "=" + piecePrefix(promo)
        }

        // Check / checkmate suffix
        san += suffix(after: move, in: state)

        return san
    }

    // MARK: - Private Helpers

    /// Returns the single-character piece prefix for SAN.
    private static func piecePrefix(_ type: PieceType) -> String {
        switch type {
        case .king:   return "K"
        case .queen:  return "Q"
        case .rook:   return "R"
        case .bishop: return "B"
        case .knight: return "N"
        case .pawn:   return ""
        }
    }

    /// Detect whether a move is a capture (including en passant).
    private static func isCapture(_ move: ChessMove, isPawn: Bool, state: GameState) -> Bool {
        // Normal capture: destination square occupied by opponent
        if let dest = state.piece(at: move.to) {
            if let src = state.piece(at: move.from), dest.color != src.color {
                return true
            }
        }
        // En passant: pawn moves diagonally to an empty square
        if isPawn && move.from.file != move.to.file && state.piece(at: move.to) == nil {
            return true
        }
        return false
    }

    /// Returns the castling SAN string if applicable, otherwise nil.
    private static func castlingSAN(_ move: ChessMove) -> String? {
        let fromAlg = move.from.algebraic
        let toAlg = move.to.algebraic
        switch (fromAlg, toAlg) {
        case ("e1", "g1"), ("e8", "g8"):
            return "O-O"
        case ("e1", "c1"), ("e8", "c8"):
            return "O-O-O"
        default:
            return nil
        }
    }

    /// Compute disambiguation string for piece moves.
    ///
    /// When two (or more) pieces of the same type can reach the same destination,
    /// we add the departure file, rank, or both to disambiguate.
    private static func disambiguation(move: ChessMove, pieceType: PieceType, state: GameState) -> String {
        let allLegal = ChessRules.legalMoves(in: state)

        // Find other legal moves where a piece of the same type reaches the same square
        let ambiguous = allLegal.filter { other in
            other.from != move.from
            && other.to == move.to
            && state.piece(at: other.from)?.type == pieceType
        }

        guard !ambiguous.isEmpty else { return "" }

        let sameFile = ambiguous.contains { $0.from.file == move.from.file }
        let sameRank = ambiguous.contains { $0.from.rank == move.from.rank }

        if sameFile && sameRank {
            // Both file and rank needed
            return String(move.from.fileChar) + "\(move.from.rank)"
        } else if sameFile {
            // Files match, use rank to disambiguate
            return "\(move.from.rank)"
        } else {
            // Default: use file
            return String(move.from.fileChar)
        }
    }

    /// Compute the suffix ("+", "#", or "") after applying the move.
    private static func suffix(after move: ChessMove, in state: GameState) -> String {
        let newState = ChessRules.apply(move, to: state)
        let opponent = state.activeColor  == .white ? PieceColor.black : .white

        guard ChessRules.isInCheck(opponent, in: newState) else { return "" }

        // Check if it's checkmate (opponent has no legal moves)
        let opponentMoves = ChessRules.legalMoves(in: newState)
        return opponentMoves.isEmpty ? "#" : "+"
    }
}
