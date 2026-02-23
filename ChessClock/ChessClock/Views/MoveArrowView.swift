import SwiftUI

/// Draws a filled shaft-and-arrowhead arrow from one chess square to another.
/// Used in GameReplayView to indicate which move arrived at the current position.
struct MoveArrowView: View {
    let from: ChessSquare
    let to: ChessSquare
    let isFlipped: Bool

    var body: some View {
        GeometryReader { geo in
            let sqSize = geo.size.width / 8.0
            let p1 = Self.squareCenter(sq: from, squareSize: sqSize, isFlipped: isFlipped)
            let p2 = Self.squareCenter(sq: to,   squareSize: sqSize, isFlipped: isFlipped)
            Self.arrowPath(from: p1, to: p2, squareSize: sqSize)
                .fill(Color(red: 1.0, green: 0.75, blue: 0.0).opacity(0.72))
        }
        .allowsHitTesting(false)
    }

    // MARK: - Geometry helpers (internal for testability)

    /// Pixel coordinate of the centre of `sq` within an 8×8 board of total width
    /// `8 × squareSize`. Top-left = (0,0). Respects `isFlipped`.
    static func squareCenter(sq: ChessSquare,
                             squareSize: CGFloat,
                             isFlipped: Bool) -> CGPoint {
        let screenCol = sq.fileIndex                                   // 0–7, left→right always
        let screenRow = isFlipped ? (7 - sq.rankIndex) : sq.rankIndex // 0 = topmost row
        return CGPoint(
            x: CGFloat(screenCol) * squareSize + squareSize * 0.5,
            y: CGFloat(screenRow) * squareSize + squareSize * 0.5
        )
    }

    // MARK: - Arrow path

    /// A single filled shape: rectangular shaft widening into a triangular arrowhead.
    static func arrowPath(from p1: CGPoint, to p2: CGPoint, squareSize: CGFloat) -> Path {
        let dx = p2.x - p1.x
        let dy = p2.y - p1.y
        let len = (dx * dx + dy * dy).squareRoot()
        guard len > 1 else { return Path() }

        let ux = dx / len           // unit vector toward destination
        let uy = dy / len
        let px = -uy                // perpendicular unit vector (left side)
        let py =  ux

        let shaft     = squareSize * 0.18   // half-width of shaft
        let headLen   = squareSize * 0.35   // length of the triangular arrowhead
        let headWidth = squareSize * 0.28   // half-width of the arrowhead base
        let startOff  = squareSize * 0.30   // pull start slightly inside source square

        let sx    = p1.x + ux * startOff   // shaft start
        let sy    = p1.y + uy * startOff
        let neckX = p2.x - ux * headLen    // where shaft meets arrowhead
        let neckY = p2.y - uy * headLen

        var path = Path()
        // Left shaft edge → left neck → left arrowhead wing → tip → right wing → right neck → right shaft
        path.move(to:    CGPoint(x: sx    + px * shaft,      y: sy    + py * shaft))
        path.addLine(to: CGPoint(x: neckX + px * shaft,      y: neckY + py * shaft))
        path.addLine(to: CGPoint(x: neckX + px * headWidth,  y: neckY + py * headWidth))
        path.addLine(to: p2)
        path.addLine(to: CGPoint(x: neckX - px * headWidth,  y: neckY - py * headWidth))
        path.addLine(to: CGPoint(x: neckX - px * shaft,      y: neckY - py * shaft))
        path.addLine(to: CGPoint(x: sx    - px * shaft,      y: sy    - py * shaft))
        path.closeSubpath()
        return path
    }
}

#Preview {
    let move = ChessMove.from(uci: "e2e4")!
    return BoardView(fen: "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1")
        .overlay { MoveArrowView(from: move.from, to: move.to, isFlipped: false) }
        .frame(width: 320)
}
