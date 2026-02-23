# TODO — Chess Clock

> This is the **source of truth** for all development tasks.
> Never mark an item done without verifying its acceptance criteria.
> Run `/sync` at the start and end of every session.

---

## In Progress

_Nothing in progress._

---

## Backlog

_No tasks in backlog._

---

## Done

### v0.5.0

- [x] **P1 — InfoPanelView redesign** — Board is tappable card with bottom CTA overlay (AM/PM + result badge + "Play Puzzle"/"Review"). No separate button below board.
- [x] **P2 — GameReplayView (core)** — New `GameReplayView.swift`. `ReplayZone` enum. Zone banner. ⏮←[⦿]→⏭ navigation. Position counter. Keyboard arrow support. `onBack` returns to caller.
- [x] **P3 — Wire replay into ClockView + GuessMoveView** — `.replay` ViewMode. `onReplay` on `GuessMoveView`. "Review Game" button on both overlays (0.5s fade-in). Replay `onBack` → `.info`. Height 500 for replay.
- [x] **P5 (initial) — Tests** — 9 tests (zone + move label + nav clamping). All pass.
- [x] **Navigation to final position** — rawIndex range extended to -1…22. rawIndex -1 = post-checkmate board computed via `ChessRules.apply(moveSequence[0], positions[0])`. Position counter becomes N/24. "Checkmate" banner label at rawIndex -1. ⏭ jumps to -1; keyboard → clamps at -1.
- [x] **Animation fix** — Removed `.id(rawIndex)` + `.transition(.opacity)` from board. Board now updates in-place (no flash/pulse). Zone banner and arrow animate with `.easeInOut(0.18)`.
- [x] **Move arrow overlay** — New `MoveArrowView.swift`. Static `squareCenter(sq:squareSize:isFlipped:)` helper. Filled shaft+arrowhead `Path`. Amber colour (opacity 0.72). Overlaid on board in `GameReplayView`; fades in/out with `.transition(.opacity)`. Shows the move that arrived at current position; nil at rawIndex 22 (start of fragment).
- [x] **Comprehensive tests (33)** — `GameReplayViewTests.swift` rewritten: 8 zone, 5 move label, 4 position counter, 5 navigation, 8 arrow coordinates, 3 label text. All 33 pass.
- [x] **Full game replay** — `allMoves` field added to `games.json` (all UCI moves from game start to checkmate). `ChessGame` model updated. `GameReplayView` reimplemented with forward `posIndex` system (0=starting position, N=checkmate). `computeAllPositions(game:)` replays all moves from standard starting FEN via `ChessRules.apply`. Navigation spans the complete game history.
- [x] **Updated tests (40)** — `GameReplayViewTests.swift` extended with 7 `computeAllPositions` tests covering FEN correctness, move count, e2e4 pawn placement, empty allMoves, and puzzle-start mapping. All 40 tests pass.

_v0.1.0 tasks archived to docs/archive/TODO-done-v0.1.0.md_
_v0.2.0 tasks archived to docs/archive/TODO-done-v0.2.0.md_
_v0.3.0 tasks archived to docs/archive/TODO-done-v0.3.0.md_
_v0.4.0 tasks archived to docs/archive/TODO-done-v0.4.0.md_

---

## Notes

- Do not reorder Backlog items without a good reason — the order reflects dependencies
- Do not mark a task done without verifying its acceptance criteria
- If a task is blocked, note the blocker inline and move to the next unblocked task
