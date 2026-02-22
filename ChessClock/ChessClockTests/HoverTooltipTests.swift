import XCTest
@testable import ChessClock

/// Tests for the hover tooltip format function (P5.1).
final class HoverTooltipTests: XCTestCase {

    func testHoverText_hour1_AM() {
        XCTAssertEqual(ClockView.hoverText(hour: 1, isAM: true), "1 AM — Mate in 1")
    }

    func testHoverText_hour1_PM() {
        XCTAssertEqual(ClockView.hoverText(hour: 1, isAM: false), "1 PM — Mate in 1")
    }

    func testHoverText_hour6_PM() {
        XCTAssertEqual(ClockView.hoverText(hour: 6, isAM: false), "6 PM — 6 Moves to Checkmate")
    }

    func testHoverText_hour12_AM() {
        XCTAssertEqual(ClockView.hoverText(hour: 12, isAM: true), "12 AM — 12 Moves to Checkmate")
    }

    func testHoverText_hour2_AM() {
        XCTAssertEqual(ClockView.hoverText(hour: 2, isAM: true), "2 AM — 2 Moves to Checkmate")
    }

    func testHoverText_neverSaysMateInX_forX_greaterThan1() {
        for h in 2...12 {
            let text = ClockView.hoverText(hour: h, isAM: true)
            XCTAssertFalse(text.contains("Mate in \(h)"),
                           "Hour \(h) should NOT say 'Mate in \(h)' — only hour 1 uses that phrasing")
            XCTAssertTrue(text.contains("Moves to Checkmate"),
                          "Hour \(h) should contain 'Moves to Checkmate'")
        }
    }
}
