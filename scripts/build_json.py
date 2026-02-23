import os
import json
import chess
import chess.pgn

INPUT = os.path.join(os.path.dirname(__file__), "curated_games.pgn")
OUTPUT = os.path.join(os.path.dirname(__file__), "games.json")
N = 23

MONTHS = {
    "01": "January", "02": "February", "03": "March",
    "04": "April",   "05": "May",      "06": "June",
    "07": "July",    "08": "August",   "09": "September",
    "10": "October", "11": "November", "12": "December",
}


def get_fens_before_checkmate(game_node, n=12):
    board = game_node.board()
    moves = list(game_node.mainline_moves())
    total = len(moves)

    for move in moves:
        board.push(move)
    if not board.is_checkmate():
        return None

    # Games must have enough moves for the deepest puzzle (hour 12 needs 23 total moves)
    if total < n:
        return None

    # board.turn is the mated side; the delivering side is the opposite
    mate_by = "black" if board.turn == chess.WHITE else "white"

    # The last move is the checkmate move; capture its UCI representation
    final_move_uci = moves[-1].uci() if moves else ""

    fens_at_move = []
    b = game_node.board()
    fens_at_move.append(b.fen())
    for move in moves:
        b.push(move)
        fens_at_move.append(b.fen())

    result = []
    for i in range(n):
        k = i + 1
        move_index = total - k
        if move_index >= 0:
            result.append(fens_at_move[move_index])
        else:
            result.append(fens_at_move[0])

    move_sequence = []
    for i in range(n):
        idx = total - 1 - i
        move_sequence.append(moves[idx].uci() if idx >= 0 else "")

    # All moves from game start to checkmate (inclusive), for full-game replay
    all_moves = [m.uci() for m in moves]

    return result, mate_by, final_move_uci, move_sequence, all_moves


records = []
skipped = 0

with open(INPUT, encoding="utf-8", errors="replace") as f:
    while True:
        try:
            game = chess.pgn.read_game(f)
        except Exception:
            skipped += 1
            continue
        if game is None:
            break

        try:
            result = get_fens_before_checkmate(game, N)
        except Exception:
            skipped += 1
            continue

        if result is None:
            skipped += 1
            continue

        positions, mate_by, final_move_uci, move_sequence, all_moves = result

        h = game.headers
        date_str = h.get("Date", "0.??.??")
        try:
            year = int(date_str.split(".")[0])
        except (ValueError, IndexError):
            year = 0

        # Extract month name (None if unknown/missing)
        month_str = None
        parts = date_str.split(".")
        if len(parts) >= 2:
            month_str = MONTHS.get(parts[1])  # None if "??" or not in map

        # Extract round (None if unknown/placeholder)
        raw_round = h.get("Round", "?").strip()
        round_str = None if raw_round in ("?", "-", "", "0") else raw_round

        white_elo = h.get("WhiteElo", "?")
        black_elo = h.get("BlackElo", "?")
        if not white_elo or white_elo == "?":
            white_elo = "?"
        if not black_elo or black_elo == "?":
            black_elo = "?"

        records.append({
            "white": h.get("White", "?"),
            "black": h.get("Black", "?"),
            "whiteElo": white_elo,
            "blackElo": black_elo,
            "tournament": h.get("Event", "Unknown") or "Unknown",
            "year": year,
            "month": month_str,
            "round": round_str,
            "mateBy": mate_by,
            "finalMove": final_move_uci,
            "moveSequence": move_sequence,
            "positions": positions,
            "allMoves": all_moves,
        })

with open(OUTPUT, "w", encoding="utf-8") as f:
    json.dump(records, f, ensure_ascii=False, indent=2)

all_n_positions = all(len(g["positions"]) == N for g in records)
all_n_move_seq = all(len(g["moveSequence"]) == N for g in records)
all_move_seq_match = all(g["moveSequence"][0] == g["finalMove"] for g in records if g["finalMove"])
print(f"All have {N} positions: {all_n_positions}")
print(f"All have {N} moveSequence: {all_n_move_seq}")
print(f"All moveSequence[0]==finalMove: {all_move_seq_match}")
print(f"Games written: {len(records)}")
print(f"Games skipped: {skipped}")
if records:
    s = records[0]
    print(f"Sample: {s['white']} vs {s['black']} ({s['year']}) month={s['month']} round={s['round']} mateBy={s['mateBy']}")
