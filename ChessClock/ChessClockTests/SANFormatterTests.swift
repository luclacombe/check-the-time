import XCTest
@testable import ChessClock

final class SANFormatterTests: XCTestCase {

    // MARK: - Helpers

    private func state(_ fen: String) -> GameState {
        guard let s = ChessRules.parseState(fen: fen) else {
            fatalError("Invalid FEN: \(fen)")
        }
        return s
    }

    // MARK: - 1. Simple Pawn Move

    func testSimplePawnMove() {
        // Starting position, e2-e4
        let s = state("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
        XCTAssertEqual(SANFormatter.format(uci: "e2e4", in: s), "e4")
    }

    // MARK: - 2. Pawn Capture

    func testPawnCapture() {
        // White pawn on e4, black pawn on d5 — exd5
        let s = state("rnbqkbnr/ppp1pppp/8/3p4/4P3/8/PPPP1PPP/RNBQKBNR w KQkq d6 0 2")
        XCTAssertEqual(SANFormatter.format(uci: "e4d5", in: s), "exd5")
    }

    // MARK: - 3. Piece Move (Knight)

    func testPieceMove() {
        // Starting position, Nf3
        let s = state("rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
        XCTAssertEqual(SANFormatter.format(uci: "g1f3", in: s), "Nf3")
    }

    // MARK: - 4. Piece Capture

    func testPieceCapture() {
        // Knight on f3 captures pawn on e5
        let s = state("rnbqkbnr/pppp1ppp/8/4p3/8/5N2/PPPPPPPP/RNBQKB1R w KQkq - 0 2")
        XCTAssertEqual(SANFormatter.format(uci: "f3e5", in: s), "Nxe5")
    }

    // MARK: - 5. Disambiguation by File

    func testDisambiguationByFile() {
        // Two rooks on a1 and h1 can both go to d1 — need file disambiguation
        // Position: white King e2, rook a1, rook h1; black King e8
        let s = state("4k3/8/8/8/8/8/4K3/R6R w - - 0 1")
        XCTAssertEqual(SANFormatter.format(uci: "a1d1", in: s), "Rad1")
        XCTAssertEqual(SANFormatter.format(uci: "h1d1", in: s), "Rhd1")
    }

    // MARK: - 6. Disambiguation by Rank

    func testDisambiguationByRank() {
        // Two rooks on the same file, different ranks — need rank disambiguation
        // Position: white King a1, rook e1, rook e8; black King h8
        // Actually e8 has a rook so let's use a cleaner setup:
        // white King a1, rook e1, rook e4; black King h8
        let s = state("7k/8/8/8/4R3/8/8/K3R3 w - - 0 1")
        XCTAssertEqual(SANFormatter.format(uci: "e1e2", in: s), "R1e2")
        XCTAssertEqual(SANFormatter.format(uci: "e4e2", in: s), "R4e2")
    }

    // MARK: - 7. Castling Kingside

    func testCastlingKingside() {
        // White can castle kingside: e1g1
        let s = state("r1bqkbnr/pppppppp/2n5/8/8/5NP1/PPPPPPBP/RNBQK2R w KQkq - 0 4")
        XCTAssertEqual(SANFormatter.format(uci: "e1g1", in: s), "O-O")
    }

    // MARK: - 8. Castling Queenside

    func testCastlingQueenside() {
        // White can castle queenside: e1c1
        // King e1, rook a1, no pieces on b1/c1/d1, those squares not attacked
        let s = state("4k3/8/8/8/8/8/8/R3K3 w Q - 0 1")
        XCTAssertEqual(SANFormatter.format(uci: "e1c1", in: s), "O-O-O")
    }

    // MARK: - 9. Promotion

    func testPromotion() {
        // White pawn on e7, e8 empty, black King on h6 (not on any line from e8)
        let s = state("8/4P3/7k/8/8/8/8/4K3 w - - 0 1")
        XCTAssertEqual(SANFormatter.format(uci: "e7e8q", in: s), "e8=Q")
    }

    func testPromotionWithCheck() {
        // White pawn on e7, e8 empty, black King on a8 (queen on e8 checks along rank 8)
        let s = state("k7/4P3/8/8/8/8/8/4K3 w - - 0 1")
        XCTAssertEqual(SANFormatter.format(uci: "e7e8q", in: s), "e8=Q+")
    }

    // MARK: - 10. Promotion with Capture

    func testPromotionWithCapture() {
        // White pawn on d7, black rook on e8, black King on h8
        // d7e8q captures the rook; queen on e8 does NOT check king on h8 (same rank but h8 is accessible)
        // Actually: e8 to h8 IS on rank 8, so queen DOES give check.
        // Use black King on b6 instead (not on rank 8, file d/e, or diagonal from e8)
        let s = state("4r3/3P4/1k6/8/8/8/8/4K3 w - - 0 1")
        XCTAssertEqual(SANFormatter.format(uci: "d7e8q", in: s), "dxe8=Q")
    }

    // MARK: - 11. Check

    func testCheck() {
        // White queen delivers check
        // White King e1, Queen d1, black King e8, pawn d7
        // Qd1-d7 would be illegal because of the pawn, let's use a direct check:
        // White King a1, Queen a2, black King a8 — Qa7+
        let s = state("k7/8/8/8/8/8/Q7/K7 w - - 0 1")
        XCTAssertEqual(SANFormatter.format(uci: "a2a7", in: s), "Qa7+")
    }

    // MARK: - 12. Checkmate

    func testCheckmate() {
        // Classic back-rank mate setup
        // Black King g8, pawns f7/g7/h7; White Rook on a1, White King h1
        // White plays Ra8# (back-rank mate)
        let s = state("6k1/5ppp/8/8/8/8/8/R6K w - - 0 1")
        XCTAssertEqual(SANFormatter.format(uci: "a1a8", in: s), "Ra8#")
    }

    // MARK: - 13. En Passant

    func testEnPassant() {
        // White pawn on e5, black pawn just moved d7-d5 (en passant target d6)
        // White plays exd6 (en passant)
        let s = state("rnbqkbnr/ppp1pppp/8/3pP3/8/8/PPPP1PPP/RNBQKBNR w KQkq d6 0 3")
        XCTAssertEqual(SANFormatter.format(uci: "e5d6", in: s), "exd6")
    }

    // MARK: - Additional Coverage

    func testBishopMove() {
        // White Bishop on e4, white King a1, black King h8
        let s = state("7k/8/8/8/4B3/8/8/K7 w - - 0 1")
        XCTAssertEqual(SANFormatter.format(uci: "e4d5", in: s), "Bd5")
    }

    func testBlackCastlingKingside() {
        // Black castles kingside: e8g8
        let s = state("rnbqk2r/ppppppbp/5np1/8/8/5NP1/PPPPPPBP/RNBQK2R b KQkq - 0 4")
        XCTAssertEqual(SANFormatter.format(uci: "e8g8", in: s), "O-O")
    }

    func testKnightPromotion() {
        // Underpromotion to knight — knight on e8 does NOT check king on a8
        // (knight attacks c7, d6, f6, g7 — not a8)
        let s = state("k7/4P3/8/8/8/8/8/4K3 w - - 0 1")
        XCTAssertEqual(SANFormatter.format(uci: "e7e8n", in: s), "e8=N")
    }

    func testKnightPromotionWithCheck() {
        // Knight on d8 DOES attack c6 and f7. Put the king on f7? No, king can't be on f7 if pawn promotes on d8.
        // Knight on d8 attacks c6, e6, b7, f7. Put black king on c6.
        // White pawn on d7, d8 empty, black King on c6
        let s = state("8/3P4/2k5/8/8/8/8/4K3 w - - 0 1")
        XCTAssertEqual(SANFormatter.format(uci: "d7d8n", in: s), "d8=N+")
    }

    func testSimplePawnMoveBlack() {
        // Black to move: e7-e5
        let s = state("rnbqkbnr/pppppppp/8/8/4P3/8/PPPP1PPP/RNBQKBNR b KQkq e3 0 1")
        XCTAssertEqual(SANFormatter.format(uci: "e7e5", in: s), "e5")
    }

    func testQueenCapture() {
        // White queen on d4 captures pawn on d7
        // After Qxd7, queen on d7 does NOT check king on a8
        // (d7→a8 is not on a rank/file/diagonal)
        let s = state("k7/3p4/8/8/3Q4/8/8/K7 w - - 0 1")
        XCTAssertEqual(SANFormatter.format(uci: "d4d7", in: s), "Qxd7")
    }
}
