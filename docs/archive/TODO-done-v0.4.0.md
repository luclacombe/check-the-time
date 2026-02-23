# TODO Done — v0.4.0

_Archived from docs/TODO.md on 2026-02-23_

---

### v0.4.0 — Complete (2026-02-21)

- [x] **P0** · Pipeline — Add `moveSequence` to `build_json.py` + regenerate `games.json` — `ce8fbdc`
- [x] **P1** · Model — Add `moveSequence` to `ChessGame` — `40446ee`
- [x] **P2** · Engine — Create `PuzzleEngine.swift` (14 tests, all pass) — `40446ee`
- [x] **Inline** · Tests — Add `moveSequence` coverage to `GameLibraryTests` (3 new tests) — `85d0040`
- [x] **P3** · Service — Redesign `GuessService` with `PuzzleResult`, `PuzzleStats`, 3-try logic (10 tests, all pass) — `6ab6b2b`
- [x] **P4.1** · UI — Remove `GuessMoveWindowManager`; inline puzzle via `ViewMode` enum in `ClockView` — `f7070e3`
- [x] **P4.2** · UI — Rewrite `GuessMoveView` for multi-move puzzle with animated opponent moves, wrong flash, success/failed overlays — `f7070e3`
- [x] **P5.1** · Polish — Hover tooltip showing chess time ("6 PM — 6 Moves to Checkmate") with 6 passing tests — `f7070e3`
- [x] **P5.2** · Polish — `WindowObserver` NSViewRepresentable resets `viewMode` to `.clock` on popover open — `f7070e3`
- [x] **P6** · Final validation — Manual smoke test checklist (11 items); all automated tests pass ✓

**P6 Manual Smoke Test Checklist:**
1. [x] Hover clock board → see "N PM/AM — N Moves to Checkmate" (or "Mate in 1")
2. [x] Click board → info panel, no new window
3. [x] Click "Guess Move" → puzzle opens inline in same popover, no new window
4. [x] Hour 1: one move to guess (mate in 1)
5. [x] Hour > 1: after correct move, opponent move auto-plays on board; then next user move
6. [x] Wrong move: board resets, try counter shows used tries, no new window
7. [x] Three wrong moves: failed overlay shows correct moves, inline
8. [x] Solve puzzle: success overlay shows stats, inline
9. [x] View Result (already played): puzzle mode shows result inline
10. [x] Close popover → reopen → lands on clock view (not info or puzzle)
11. [x] Stats persist: complete 2 puzzles, quit and reopen app, stats still show
