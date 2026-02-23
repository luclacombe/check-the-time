import XCTest
@testable import ChessClock

/// Tests for PuzzleEngine — the pure-struct puzzle logic.
///
/// Test games use empty-board FENs with alternating active colors.
/// White-mates game: positions[i] has white to move if i is even, black if i is odd.
/// This maps to: user (white) moves at positions[0,2,4,...], opponent at positions[1,3,5,...]
/// Arrays have 23 entries to match the production games.json schema.
/// startPositionIndex = (hour-1)*2 so hour N always starts on the mating side's turn.
final class PuzzleEngineTests: XCTestCase {

    // MARK: - Test helpers

    private let wFEN = "8/8/8/8/8/8/8/8 w - - 0 1"  // white to move
    private let bFEN = "8/8/8/8/8/8/8/8 b - - 0 1"  // black to move

    // 23 distinct UCIs — moveSeq[0] is the checkmate move (from positions[0])
    private let moveSeq = [
        "a1a2","b1b2","c1c2","d1d2","e1e2","f1f2","g1g2","h1h2",
        "a2a3","b2b3","c2c3","d2d3","e2e3","f2f3","g2g3","h2h3",
        "a3a4","b3b4","c3c4","d3d4","e3e4","f3f4","g3g4"
    ]

    private func makeWhiteMatesGame() -> ChessGame {
        let positions = (0..<23).map { i in i % 2 == 0 ? wFEN : bFEN }
        return ChessGame(
            white: "W", black: "B", whiteElo: "?", blackElo: "?",
            tournament: "T", year: 2024,
            mateBy: "white", finalMove: moveSeq[0],
            moveSequence: moveSeq, positions: positions
        )
    }

    private func makeBlackMatesGame() -> ChessGame {
        // Black mates: positions[0] has black to move (delivers checkmate)
        let positions = (0..<23).map { i in i % 2 == 0 ? bFEN : wFEN }
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

    // MARK: - Test 6: Hour 2, user goes first at positions[2] (not the opponent)

    func testHour2_userFirstAtStart() {
        let engine = PuzzleEngine(game: makeWhiteMatesGame(), hour: 2)
        XCTAssertEqual(engine.currentPositionIndex, 2, "Hour 2 starts at positions[(2-1)*2]=positions[2]")
        XCTAssertTrue(engine.isUserTurn, "positions[2]=wFEN, user is white → user's turn immediately")
    }

    // MARK: - Test 7: Hour 2 full path — user plays 2 moves (not 1)

    func testHour2_twoUserMoves_success() {
        var engine = PuzzleEngine(game: makeWhiteMatesGame(), hour: 2)
        // No initial auto-plays needed — user moves first
        let initialAutos = engine.advancePastOpponentMoves()
        XCTAssertEqual(initialAutos.count, 0, "Hour 2: no opponent auto-play at start")
        XCTAssertEqual(engine.currentPositionIndex, 2)

        // User plays moveSequence[2] → positions[1]=bFEN (opponent), auto to positions[0]=wFEN
        let r1 = engine.submit(uci: moveSeq[2])
        if case .correctContinue(let autos) = r1 {
            XCTAssertEqual(autos.count, 1, "One opponent auto-play after user's first move")
            XCTAssertEqual(autos[0].uci, moveSeq[1])
            XCTAssertEqual(engine.currentPositionIndex, 0)
        } else { XCTFail("Expected .correctContinue, got \(r1)") }

        // User plays moveSequence[0] — checkmate! (second user move)
        let r2 = engine.submit(uci: moveSeq[0])
        if case .success = r2 { /* pass */ } else { XCTFail("Expected .success, got \(r2)") }
        XCTAssertTrue(engine.succeeded)
    }

    // MARK: - Test 8: Hour 3, user goes first at positions[4]

    func testHour3_userFirstAtStart() {
        let engine = PuzzleEngine(game: makeWhiteMatesGame(), hour: 3)
        XCTAssertEqual(engine.currentPositionIndex, 4, "Hour 3 starts at positions[(3-1)*2]=positions[4]")
        XCTAssertTrue(engine.isUserTurn, "Hour 3, positions[4]=wFEN → user first")
    }

    // MARK: - Test 9: Hour 6 full success path — user plays exactly 6 moves
    // startPositionIndex = (6-1)*2 = 10
    // Sequence: user[10]→opp[9]→user[8]→opp[7]→user[6]→opp[5]→user[4]→opp[3]→user[2]→opp[1]→user[0]→success

    func testHour6_fullSuccessPath() {
        var engine = PuzzleEngine(game: makeWhiteMatesGame(), hour: 6)
        XCTAssertEqual(engine.currentPositionIndex, 10, "Hour 6 starts at positions[10]")
        XCTAssertTrue(engine.isUserTurn)

        // No initial auto-plays — user goes first at positions[10] (wFEN)
        let initialAutos = engine.advancePastOpponentMoves()
        XCTAssertEqual(initialAutos.count, 0, "No initial auto-plays at positions[10]")

        // Move 1: user plays moveSeq[10] → positions[9]=bFEN (opp), auto to positions[8]=wFEN
        let r1 = engine.submit(uci: moveSeq[10])
        if case .correctContinue(let autos) = r1 {
            XCTAssertEqual(autos.count, 1); XCTAssertEqual(engine.currentPositionIndex, 8)
        } else { XCTFail("r1: \(r1)") }

        // Move 2: user plays moveSeq[8] → opp auto to positions[6]
        let r2 = engine.submit(uci: moveSeq[8])
        if case .correctContinue(let autos) = r2 {
            XCTAssertEqual(autos.count, 1); XCTAssertEqual(engine.currentPositionIndex, 6)
        } else { XCTFail("r2: \(r2)") }

        // Move 3: user plays moveSeq[6] → opp auto to positions[4]
        let r3 = engine.submit(uci: moveSeq[6])
        if case .correctContinue(let autos) = r3 {
            XCTAssertEqual(autos.count, 1); XCTAssertEqual(engine.currentPositionIndex, 4)
        } else { XCTFail("r3: \(r3)") }

        // Move 4: user plays moveSeq[4] → opp auto to positions[2]
        let r4 = engine.submit(uci: moveSeq[4])
        if case .correctContinue(let autos) = r4 {
            XCTAssertEqual(autos.count, 1); XCTAssertEqual(engine.currentPositionIndex, 2)
        } else { XCTFail("r4: \(r4)") }

        // Move 5: user plays moveSeq[2] → opp auto to positions[0]
        let r5 = engine.submit(uci: moveSeq[2])
        if case .correctContinue(let autos) = r5 {
            XCTAssertEqual(autos.count, 1); XCTAssertEqual(engine.currentPositionIndex, 0)
        } else { XCTFail("r5: \(r5)") }

        // Move 6: user plays moveSeq[0] — checkmate!
        let r6 = engine.submit(uci: moveSeq[0])
        if case .success = r6 { /* pass */ } else { XCTFail("r6: \(r6)") }
        XCTAssertTrue(engine.succeeded)
        XCTAssertTrue(engine.isComplete)
    }

    // MARK: - Test 10: Wrong move resets position index to start

    func testWrongMoveResetsToStartIndex() {
        var engine = PuzzleEngine(game: makeWhiteMatesGame(), hour: 3)
        XCTAssertEqual(engine.currentPositionIndex, 4)
        _ = engine.submit(uci: "bad")
        XCTAssertEqual(engine.currentPositionIndex, 4, "Reset to startPositionIndex=4")
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
