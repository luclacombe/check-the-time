# TODO — Chess Clock

> This is the **source of truth** for all development tasks.
> Never mark an item done without verifying its acceptance criteria.
> Run `/sync` at the start and end of every session.

---

## In Progress

_Nothing in progress._

---

## Backlog

_Empty — next sprint pending._

---

## Done

### Sprint 3.9 — Visual Refinement (2026-02-23)

- [x] **S3.9-1: Update DesignTokens — pulse tokens, tube tokens, CTA sizing, remove shimmer** — ChessClockPulse, ChessClockTube, ChessClockCTADetail enums added; boardDetail 176→164; shimmerMinOpacity + anim.shimmer removed. `c044af5`
- [x] **S3.9-2: Rewrite MinuteBezelView — glass tube overlays, simplified ticks, remove shimmer** — FilledRingTrack parameterized with outerInset/innerInset; three tube overlay layers; tick marks simplified to single-layer gradient bars. `24fc694`
- [x] **S3.9-3: Add traveling pulse animation to MinuteBezelView** — RingCenterlinePath shape; TimelineView-driven dual pulses with layered glow (core + inner + outer); pulse speed scales with fill. `a12d36a`
- [x] **S3.9-4: Rewrite InfoPanelView — flanking icons, player indicators, smaller board/CTA** — Back/gear icons flank 164pt board; glassy white/black circle indicators; ELO right-aligned; CTA uses ChessClockCTADetail tokens. `9f05dca`
- [x] **S3.9-5: Update DESIGN.md — Face 1 ticks, Face 3 layout, token tables** — Gradient bar ticks replace halo description; flanking icons + 164pt board in Face 3; token tables updated. `326adc8`
- [x] **S3.9-6: Glass polish audit — GlassPillView + CTA pill** — Top-edge specular highlight on hover pill; 0.5pt white inner stroke on CTA pill; stroke opacity 0.25→0.30. `96fe5d1`

### Sprint 3.75 — Ring Geometry + Detail Face Fix (2026-02-23)

- [x] **S3.75-1: Update DesignTokens — gradient colors, shimmer amplitude, detail board size** — accentGoldLight/accentGoldDeep, ringGradient, shimmer 1.8s/0.50↔1.0, boardDetail 196→176, ringOuterEdge/ringInnerEdge/shimmerMinOpacity. `cc54fff`
- [x] **S3.75-2: Rewrite MinuteBezelView — filled ring shape, gradient, enhanced shimmer, flat ticks** — FilledRingTrack (even-odd fill) + ProgressWedge mask, gold gradient, .butt lineCap ticks at ring edges. `a65333b`
- [x] **S3.75-3: Add board edge bevel to BoardView** — 0.5pt dark strokeBorder overlay for ring-board definition. `16995a7`
- [x] **S3.75-4: Fix InfoPanelView layout — top padding, reduced board, tighter spacing** — 8pt top padding, 20pt header padding, 2pt board spacing, 6pt CTA spacing. `390bb0d`
- [x] **S3.75-5: Hide ring completely in Detail face** — Ring opacity 0.0 for .info, removed blur. `1eb003c`
- [x] **S3.75-6: Update DESIGN.md with Sprint 3.75 spec changes** — All tokens, layout, animation changes documented.

### Sprint 3.5 — Ring Polish + Detail Fix (2026-02-23)

- [x] **S3.5-1: Update DesignTokens — corner radii, ring geometry, tick sizes** — outer 14→18, ring 9→12, board 4→8, ringInset 5→6, bezelGap 1→0, tickLength 6→8, tickWidth 2→2.5, added shimmer animation token.
- [x] **S3.5-2: Add `second` to ClockState + ClockService** — ClockState gains `second: Int`, ClockService extracts `.second` from date components.
- [x] **S3.5-3: Rewrite MinuteBezelView — continuous sweep, shimmer, ticks** — Progress now `(minute*60+second)/3600`, linear interpolation per second, shimmer pulse (opacity 0.78↔1.0, 2.5s), tick dark halo for contrast.
- [x] **S3.5-4: Upgrade GlassPillView — shadow + inner stroke** — Drop shadow + tight shadow + 0.5pt white inner stroke for glass-edge effect.
- [x] **S3.5-5: Fix InfoPanelView — header, CTA floating pill** — Header gains 16pt padding + 13pt icons + 28×28 tap targets. CTA redesigned as floating capsule pill below board.
- [x] **S3.5-6: Update ClockView — pass second, detail ring styling** — Passes second to MinuteBezelView, detail ring 20% opacity + 0.5pt blur.
- [x] **S3.5-7: Update DESIGN.md — spec changes** — All sections updated: radii, dimensions, ring animation, pill, CTA, Sprint 3.5 section added.

### Sprint 3 — Detail Face (2026-02-23)

- [x] **S3-1: Update DesignTokens.swift — equalize bezel gaps + tick mark tokens** — ringInset 4→5, bezelGap 2→1, ring radius 10→9, tickLength 4→6, tickWidth 1.5→2. `c481cd1`
- [x] **S3-2: Fix MinuteBezelView tick marks — white, larger, always visible on top of fill** — All 4 cardinal ticks now .white, removed conditional gold/gray logic. `b73ff73`
- [x] **S3-3: Restructure ClockView — persistent ring layer, face-dependent opacity, animated transitions, onReplay routing** — MinuteBezelView extracted to persistent background, ring opacity per face, animated transitions, InfoPanelView gains onReplay. `6251f69`
- [x] **S3-4: Rewrite InfoPanelView body as Detail face layout** — 28pt header (chevron + gear), 196×196 board with CTA overlay, PlayerNameFormatter names, event line, removed Round/AM-PM/labels. `d31b00a`

### Sprint 2 — Clock + Glance (2026-02-23)

- [x] **S2-1: Update DesignTokens.swift — concentric radius system + ring dimensions** — outer=14, ring=10, board=4, ringStroke=8, ringInset=4, bezelGap=2. `bdeb036`
- [x] **S2-2: Update MinuteBezelView — concentric corner radius from token** — RingShape uses `ChessClockRadius.ring` (10pt). `bdeb036`
- [x] **S2-3: Update BoardView — token-based clip radius and color references** — Uses `ChessClockRadius.board` and `ChessClockColor` tokens. `bdeb036`
- [x] **S2-4: Build GlassPillView** — Reusable `.ultraThinMaterial` container with pill radius and space tokens. `b5ad8ac`
- [x] **S2-5: Build Glance face + apply outer clip in ClockView** — 14pt outer clip, blurred board + GlassPillView on hover, deleted old hover text + 6 tests. `b0addec`

### Sprint 1 — Foundation (2026-02-23)

- [x] **S1-1: Create DesignTokens.swift** — All color, typography, spacing, radius, dimension, and animation constants. `050ed42`
- [x] **S1-2: Replace cburnett PNGs with Merida gradient SVGs** — 12 SVGs downloaded from Lichess, PNGs deleted, Contents.json updated. `c2f9f69`
- [x] **S1-3: Add 6pt corner radius to BoardView** — `.clipShape(RoundedRectangle(cornerRadius: 6))`. `43cf99d`
- [x] **S1-4: Build MinuteBezelView** — Custom RingShape, gold fill with gray track, 4 cardinal tick marks, animated. `bd1979f`
- [x] **S1-5: Create PlayerNameFormatter** — PGN name inversion, initial handling, ELO formatting. `43cf99d`
- [x] **S1-6: Update ClockView — lock 300×300 frame and wire MinuteBezelView** — Fixed frame, removed padding, replaced MinuteSquareRingView. `4d8163d`
- [x] **S1-7: Delete ContentView.swift** — Legacy piece-grid test view removed. `43cf99d`
- [x] **S1-8: Delete MoveArrowView.swift and remove all usages** — File deleted, GameReplayView cleaned, 8 arrow tests removed (32 remain). `3c8c260`

### v0.5.1 (patch)

- [x] **Replay start position fix** — `puzzleStartPosIndex` formula corrected from `positions.count - 1` to `positions.count - 2`. Replay now opens at the true puzzle start (mating side to move, opponent's last move shown as context arrow). Previously opened one step too far forward at the checkmate position.
- [x] **GitHub Latest release** — Created formal GitHub Release for v0.5.1 via `gh release create --latest`, replacing the stale v0.4.0 Latest badge.

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
