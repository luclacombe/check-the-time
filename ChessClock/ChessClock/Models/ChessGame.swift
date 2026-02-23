import Foundation

struct ChessGame: Codable {
    let white: String        // e.g. "Kasparov, G"
    let black: String        // e.g. "Karpov, A"
    let whiteElo: String     // e.g. "2805" or "?" for historical/unknown
    let blackElo: String     // e.g. "2760" or "?"
    let tournament: String   // e.g. "World Chess Championship 1986"
    let year: Int            // e.g. 1986
    let month: String?       // e.g. "January", nil if not in PGN
    let round: String?       // e.g. "3", nil if not in PGN or unknown
    let mateBy: String       // "white" or "black" — who delivers the final checkmate
    let finalMove: String    // UCI notation of the checkmate move, e.g. "e7e8q"
    let moveSequence: [String]   // 23 UCIs; moveSequence[i] is the move from positions[i]; moveSequence[0] == finalMove
    let positions: [String]  // exactly 23 FEN strings
    // positions[0]  = board 1 move before checkmate  → clock hour 1 / puzzle mate-in-1
    // positions[i]  = board (i+1) moves before checkmate
    // positions[11] = board 12 moves before checkmate → clock hour 12
    // positions[2*(N-1)] = start of puzzle for hour N (always mating side to move)

    let allMoves: [String]   // All UCI moves from game start to checkmate (inclusive).
    // allMoves[0] = first move of game; allMoves.last == finalMove
    // Used by GameReplayView to replay the full game from the starting position.

    init(white: String, black: String, whiteElo: String, blackElo: String,
         tournament: String, year: Int,
         month: String? = nil, round: String? = nil,
         mateBy: String = "white",
         finalMove: String = "",
         moveSequence: [String] = [],
         allMoves: [String] = [],
         positions: [String]) {
        self.white = white
        self.black = black
        self.whiteElo = whiteElo
        self.blackElo = blackElo
        self.tournament = tournament
        self.year = year
        self.month = month
        self.round = round
        self.mateBy = mateBy
        self.finalMove = finalMove
        self.moveSequence = moveSequence
        self.allMoves = allMoves
        self.positions = positions
    }
}

extension ChessGame {
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            white: try c.decode(String.self, forKey: .white),
            black: try c.decode(String.self, forKey: .black),
            whiteElo: try c.decode(String.self, forKey: .whiteElo),
            blackElo: try c.decode(String.self, forKey: .blackElo),
            tournament: try c.decode(String.self, forKey: .tournament),
            year: try c.decode(Int.self, forKey: .year),
            month: try c.decodeIfPresent(String.self, forKey: .month),
            round: try c.decodeIfPresent(String.self, forKey: .round),
            mateBy: (try c.decodeIfPresent(String.self, forKey: .mateBy)) ?? "white",
            finalMove: (try c.decodeIfPresent(String.self, forKey: .finalMove)) ?? "",
            moveSequence: (try c.decodeIfPresent([String].self, forKey: .moveSequence)) ?? [],
            allMoves: (try c.decodeIfPresent([String].self, forKey: .allMoves)) ?? [],
            positions: try c.decode([String].self, forKey: .positions)
        )
    }
}
