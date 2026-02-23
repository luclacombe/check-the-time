import Foundation

enum PlayerNameFormatter {
    /// Inverts PGN "Last,First" format to "First Last" and appends ELO.
    ///
    /// Examples:
    ///   format(pgn: "Kasparov,Garry", elo: "2851") → "Garry Kasparov · 2851"
    ///   format(pgn: "Kramnik,V", elo: "2753")      → "V. Kramnik · 2753"
    ///   format(pgn: "Kasparov,Garry", elo: "?")     → "Garry Kasparov"
    ///   format(pgn: "Morphy", elo: "?")             → "Morphy"
    static func format(pgn: String, elo: String) -> String {
        let name: String
        if let commaIndex = pgn.firstIndex(of: ",") {
            let last = String(pgn[pgn.startIndex..<commaIndex])
            var first = String(pgn[pgn.index(after: commaIndex)...])
            // Single-letter initial: append period
            if first.count == 1 {
                first += "."
            }
            name = "\(first) \(last)"
        } else {
            name = pgn
        }

        if elo == "?" || elo.isEmpty {
            return name
        }
        return "\(name) · \(elo)"
    }
}
