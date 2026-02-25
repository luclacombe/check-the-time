# TODO — Chess Clock

> This is the **source of truth** for all development tasks.
> Never mark an item done without verifying its acceptance criteria.
> Run `/sync` at the start and end of every session.

---

## In Progress

_Nothing in progress._

---

## Backlog

_Nothing in backlog._

---

## Done

### Sprint 4 — Puzzle Face ✓

> **Goal:** Ship the interactive puzzle in a fixed 300×300 square with no text overlays during play.

- [x] **S4-1: DesignTokens — add puzzleBoard radius token and update tick length** — Added `ChessClockRadius.puzzleBoard = 4` and changed `ChessClockSize.tickLength` from 8 to 12. `ef0d488`
- [x] **S4-2: InteractiveBoardView — gold selection color, gold legal-move dots, piece hover lift** — Replaced yellow/black interaction colors with gold tokens; added per-piece hover scale (1.03) and selected scale (1.05). `531b577`
- [x] **S4-3: GoldRingLayerView — extend ticks to 12pt, add board-surface shadow, taper gradient to white 0.20** — `innerEnd` 13→14; board shadow CAShapeLayer per tick; dim gradient tapers 0.45→0.20. `5f59127`
- [x] **S4-4: GuessMoveView — fixed 280×280 board, ZStack layout, 4pt corner radius** — Root body ZStack, board at .frame(280,280), clipShape puzzleBoard (4pt), headerOverlay placeholder. `23cf909`
- [x] **S4-5: GuessMoveView — header overlay: back + last names + "Mate in N" + tries indicator** — 36pt translucent header; last names from PGN; gold/red/outline tries circles. `e164378`
- [x] **S4-6: GuessMoveView — remove statusText, contextLine, and opponent text badge** — Deleted statusText, opponentMoveText state and assignments; isOpponentAnimating retained. `8bbb1a0`
- [x] **S4-7: GuessMoveView + InteractiveBoardView — wrong move: snap-back + red square pulse, no text overlay** — Deleted wrongFlashOverlay; redPulseSquare red flash + snapBackSquare spring in InteractiveBoardView; no 1.2s delay in handleMove(.wrong). `ff240aa`
- [x] **S4-8: GuessMoveView — replace successOverlay and failedOverlay with spec-compliant result cards** — 36pt icon, ChessClockRadius.card (12pt), "Solved"/"Not solved", Review(gold)/Done buttons; deleted statsLine and solutionMoves(). `2e35484`
- [x] **S4-9: PromotionPickerView — column at promotion file, no title, 35×35 pieces, ultraThinMaterial cells** — VStack column at file x-position, ultraThinMaterial cells, 0.30 scrim, no title, badge(4pt) radius. `93c6e40`
- [x] **S4-10: GuessMoveView — opponent auto-play: 0.4s pause, from/to highlight, no text** — Delay 0.8s→0.4s; lastOpponentMove highlight via BoardView + InteractiveBoardView highlightedSquares param; cleared on user's correct move. `1a29734`
- [x] **S4-11: InfoPanelView — CTA pill hover animation (scaleEffect + brightness)** — isHovered state; scaleEffect(1.04) + brightness(0.08); 0.12s easeInOut; all three pill states share isHovered. `61f5d72`

### Sprint 4P — Ring Performance (Zero-Copy IOSurface + Timer Lifecycle) ✓

- [x] **S4P-1: GoldNoiseRenderer — IOSurface zero-copy + async rendering** — Rewrote Metal pipeline with double-buffered IOSurface-backed textures, async GPU completion, eliminated all CPU readback. `30ff743`
- [x] **S4P-2: GoldRingLayerView + ClockView — Timer lifecycle + IOSurface integration** — Added `isActive` parameter, timer pauses when popover closes, adapted to async IOSurface rendering. `5444fc4`
- [x] **S4P-3: ClockService — Lazy timer start** — Removed eager `startTimer()` from init(). `b74d3c7`
- [x] **S4P-4: Docs update** — Updated DESIGN.md and Views/CLAUDE.md with IOSurface architecture.

_Sprint 4 ring tasks archived to docs/archive/TODO-done-sprint-4-ring.md_
_Sprint 3.95 tasks archived to docs/archive/TODO-done-sprint-3.95.md_
_v0.5.1 tasks archived to docs/archive/TODO-done-v0.5.1.md_
_Sprint 1 tasks archived to docs/archive/TODO-done-sprint-1.md_
_Sprint 2 tasks archived to docs/archive/TODO-done-sprint-2.md_
_Sprint 3 tasks archived to docs/archive/TODO-done-sprint-3.md_
_Sprint 3.5 tasks archived to docs/archive/TODO-done-sprint-3.5.md_
_Sprint 3.75 tasks archived to docs/archive/TODO-done-sprint-3.75.md_
_Sprint 3.9 tasks archived to docs/archive/TODO-done-sprint-3.9.md_
_v0.1.0 tasks archived to docs/archive/TODO-done-v0.1.0.md_
_v0.2.0 tasks archived to docs/archive/TODO-done-v0.2.0.md_
_v0.3.0 tasks archived to docs/archive/TODO-done-v0.3.0.md_
_v0.4.0 tasks archived to docs/archive/TODO-done-v0.4.0.md_
_v0.5.0 tasks archived to docs/archive/TODO-done-v0.5.0.md_

---

## Notes

- Do not reorder Backlog items without a good reason — the order reflects dependencies
- Do not mark a task done without verifying its acceptance criteria
- If a task is blocked, note the blocker inline and move to the next unblocked task
