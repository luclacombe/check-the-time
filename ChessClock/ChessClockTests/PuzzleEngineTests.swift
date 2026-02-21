import XCTest
@testable import ChessClock

/// Tests for PuzzleEngine — the pure-struct puzzle logic.
///
/// Test games use empty-board FENs with alternating active colors.
/// White-mates game: positions[i] has white to move if i is even, black if i is odd.
/// This maps to: user (white) moves at positions[0,2,4,...], opponent at positions[1,3,5,...]
final class PuzzleEngineTests: XCTestCase {

    // MARK: - Test helpers

    private let wFEN = "8/8/8/8/8/8/8/8 w - - 0 1"  // white to move
    private let bFEN = "8/8/8/8/8/8/8/8 b - - 0 1"  // black to move

    private let moveSeq = ["a1a2","a2a3","a3a4","a4a5","a5a6","a6a7",
                           "a7a8","a8b8","b8b7","b7b6","b6b5","b5b4"]

    private func makeWhiteMatesGame() -> ChessGame {
        let positions = (0..<12).map { i in i % 2 == 0 ? wFEN : bFEN }
        return ChessGame(
            white: "W", black: "B", whiteElo: "?", blackElo: "?",
            tournament: "T", year: 2024,
            mateBy: "white", finalMove: moveSeq[0],
            moveSequence: moveSeq, positions: positions
        )
    }

    private func makeBlackMatesGame() -> ChessGame {
        // Black mates: positions[0] has black to move (delivers checkmate)
        let positions = (0..<12).map { i in i % 2 == 0 ? bFEN : wFEN }
        return ChessGame(
            white: "W", black: "B", whiteElo: "?", blackElo: "?",
            tournament: "T", year: 2024,
            mateBy: "black", finalMove: moveSeq[0],
            moveSequence: moveSeq, positions: positions
        )
    }

    // MARK: - Test 1: Hour 1, white mates, user goes first

    func testHour1_isUserTurnAtStart() {
        let engine = PuzzleEngine(game: makeWhiteMatesGame(), hour: 1)
        XCTAssertEqual(engine.currentPositionIndex, 0, "Should start at positions[0]")
        XCTAssertTrue(engine.isUserTurn, "White mates, positions[0]=wFEN → user's turn")
    }

    // MARK: - Test 2: Hour 1, correct move → success

    func testHour1_correctMove_returnsSuccess() {
        var engine = PuzzleEngine(game: makeWhiteMatesGame(), hour: 1)
        let result = engine.submit(uci: moveSeq[0])
        if case .success = result { /* pass */ } else {
            XCTFail("Expected .success, got \(result)")
        }
        XCTAssertTrue(engine.succeeded)
        XCTAssertTrue(engine.isComplete)
    }

    // MARK: - Test 3: Hour 1, wrong move → wrong with triesRemaining 2

    func testHour1_wrongMove_returnsWrong_triesRemaining2() {
        var engine = PuzzleEngine(game: makeWhiteMatesGame(), hour: 1)
        let result = engine.submit(uci: "z1z2")
        if case .wrong(let remaining, _) = result {
            XCTAssertEqual(remaining, 2, "After 1st wrong, 2 tries remain")
        } else {
            XCTFail("Expected .wrong, got \(result)")
        }
        XCTAssertEqual(engine.triesUsed, 2)
        XCTAssertFalse(engine.isComplete)
    }

    // MARK: - Test 4: Three wrong moves → failed

    func testHour1_threeWrongMoves_returnsFailed() {
        var engine = PuzzleEngine(game: makeWhiteMatesGame(), hour: 1)
        _ = engine.submit(uci: "bad1")
        _ = engine.submit(uci: "bad2")
        let result = engine.submit(uci: "bad3")
        if case .failed = result { /* pass */ } else {
            XCTFail("Expected .failed after 3 wrong moves, got \(result)")
        }
        XCTAssertTrue(engine.isComplete)
        XCTAssertFalse(engine.succeeded)
    }

    // MARK: - Test 5: Wrong then correct → success

    func testHour1_wrongThenCorrect_succeeds() {
        var engine = PuzzleEngine(game: makeWhiteMatesGame(), hour: 1)
        _ = engine.submit(uci: "bad")    // try 1 wrong
        let result = engine.submit(uci: moveSeq[0])  // try 2 correct
        if case .success = result { /* pass */ } else {
            XCTFail("Expected .success, got \(result)")
        }
        XCTAssertTrue(engine.succeeded)
    }

    // MARK: - Test 6: Hour 2, opponent goes first (positions[1] = bFEN for white-mates)

    func testHour2_opponentFirstAtStart() {
        let engine = PuzzleEngine(game: makeWhiteMatesGame(), hour: 2)
        XCTAssertEqual(engine.currentPositionIndex, 1, "Hour 2 starts at positions[1]")
        XCTAssertFalse(engine.isUserTurn, "positions[1]=bFEN, user is white → not user's turn")
    }

    // MARK: - Test 7: Hour 2, advance past opponent → lands on user turn

    func testHour2_advancePastOpponent_landsOnUserTurn() {
        var engine = PuzzleEngine(game: makeWhiteMatesGame(), hour: 2)
        let autoPlays = engine.advancePastOpponentMoves()
        XCTAssertEqual(autoPlays.count, 1, "One opponent move to auto-play")
        XCTAssertEqual(autoPlays[0].uci, moveSeq[1], "Auto-played moveSequence[1]")
        XCTAssertEqual(engine.currentPositionIndex, 0, "Now at positions[0]")
        XCTAssertTrue(engine.isUserTurn, "positions[0]=wFEN → user's turn")
    }

    // MARK: - Test 8: Hour 3, user goes first (positions[2] = wFEN for white-mates)

    func testHour3_userFirstAtStart() {
        let engine = PuzzleEngine(game: makeWhiteMatesGame(), hour: 3)
        XCTAssertTrue(engine.isUserTurn, "Hour 3, positions[2]=wFEN → user first")
    }

    // MARK: - Test 9: Hour 6 full success path
    // positions[5]=bFEN: opponent first → auto-play → positions[4]=wFEN: user
    // → auto-play positions[3]→positions[2] → user → auto-play [1]→[0] → user → success

    func testHour6_fullSuccessPath() {
        var engine = PuzzleEngine(game: makeWhiteMatesGame(), hour: 6)

        // Initial advance: opponent at positions[5]
        let initialAutos = engine.advancePastOpponentMoves()
        XCTAssertEqual(initialAutos.count, 1, "One auto-play from positions[5]")
        XCTAssertEqual(engine.currentPositionIndex, 4, "Now at positions[4]")
        XCTAssertTrue(engine.isUserTurn)

        // User plays moveSequence[4] — advance to positions[3] (opp), auto to positions[2] (user)
        let r1 = engine.submit(uci: moveSeq[4])
        if case .correctContinue(let autos) = r1 {
            XCTAssertEqual(autos.count, 1, "One auto-play at positions[3]")
            XCTAssertEqual(engine.currentPositionIndex, 2)
        } else { XCTFail("Expected .correctContinue, got \(r1)") }

        // User plays moveSequence[2] — advance to positions[1] (opp), auto to positions[0] (user)
        let r2 = engine.submit(uci: moveSeq[2])
        if case .correctContinue(let autos) = r2 {
            XCTAssertEqual(autos.count, 1, "One auto-play at positions[1]")
            XCTAssertEqual(engine.currentPositionIndex, 0)
        } else { XCTFail("Expected .correctContinue, got \(r2)") }

        // User plays moveSequence[0] — checkmate!
        let r3 = engine.submit(uci: moveSeq[0])
        if case .success = r3 { /* pass */ } else { XCTFail("Expected .success, got \(r3)") }
        XCTAssertTrue(engine.succeeded)
        XCTAssertTrue(engine.isComplete)
    }

    // MARK: - Test 10: Wrong move resets position index to start

    func testWrongMoveResetsToStartIndex() {
        var engine = PuzzleEngine(game: makeWhiteMatesGame(), hour: 3)
        XCTAssertEqual(engine.currentPositionIndex, 2)
        _ = engine.submit(uci: "bad")
        XCTAssertEqual(engine.currentPositionIndex, 2, "Reset to startPositionIndex=2")
        XCTAssertEqual(engine.triesUsed, 2)
    }

    // MARK: - Test 11: triesUsed increments correctly

    func testTriesUsedIncrements() {
        var engine = PuzzleEngine(game: makeWhiteMatesGame(), hour: 1)
        XCTAssertEqual(engine.triesUsed, 1)
        _ = engine.submit(uci: "bad")
        XCTAssertEqual(engine.triesUsed, 2)
        _ = engine.submit(uci: "bad")
        XCTAssertEqual(engine.triesUsed, 3)
        let result = engine.submit(uci: "bad")
        if case .failed = result { /* pass */ } else { XCTFail("Expected .failed") }
    }

    // MARK: - Test 12: expectedMove matches moveSequence at startPositionIndex

    func testExpectedMoveMatchesMoveSequenceAtStart() {
        let game = makeWhiteMatesGame()
        let engine = PuzzleEngine(game: game, hour: 1)
        XCTAssertEqual(engine.expectedMove, game.moveSequence[0])
        XCTAssertEqual(engine.expectedMove, game.finalMove)
    }

    // MARK: - Test 13: Black-mates game, user is black

    func testBlackMatesGame_userIsBlack() {
        let engine = PuzzleEngine(game: makeBlackMatesGame(), hour: 1)
        // positions[0] = bFEN (black to move = mating side = user)
        XCTAssertTrue(engine.isUserTurn, "Black mates, positions[0]=bFEN → user's turn")
    }

    // MARK: - Test 14: wrong → triesRemaining sequence

    func testTriesRemainingSequence() {
        var engine = PuzzleEngine(game: makeWhiteMatesGame(), hour: 1)
        // First wrong: triesUsed becomes 2, triesRemaining = 2
        let r1 = engine.submit(uci: "bad")
        if case .wrong(let rem, _) = r1 { XCTAssertEqual(rem, 2) } else { XCTFail() }
        // Second wrong: triesUsed becomes 3, triesRemaining = 1
        let r2 = engine.submit(uci: "bad")
        if case .wrong(let rem, _) = r2 { XCTAssertEqual(rem, 1) } else { XCTFail() }
        // Third wrong: .failed
        let r3 = engine.submit(uci: "bad")
        if case .failed = r3 { /* pass */ } else { XCTFail() }
    }
}
