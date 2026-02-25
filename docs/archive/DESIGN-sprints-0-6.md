# DESIGN.md — Archived Sprint Plans (0–6)

> Archived from `docs/DESIGN.md` on 2026-02-25.
> These sprints are all completed. See git history for full context.

---

## Sprint 0 — Design Document ✓
Locked v1.0 design spec before any code.

## Sprint 1 — Foundation ✓
- [x] `DesignTokens.swift` — all color, type, spacing, radius, animation constants
- [x] Merida gradient SVGs replacing cburnett PNGs (12 assets)
- [x] `MinuteBezelView` — rounded rect ring, gold fill, gray track, 4 cardinal tick marks
- [x] `PlayerNameFormatter` — invert PGN names, handle initials, format ELO
- [x] Locked app frame to 300×300; deleted `ContentView.swift`, `MoveArrowView.swift`

## Sprint 2 — Clock + Glance ✓
- [x] Concentric corner radii (18→12→8pt); 8pt ring stroke
- [x] Clock face: board 280×280, gold ring fill, no text or affordances
- [x] Glance face: board blur on hover, `GlassPillView` with time + "Mate in N"

## Sprint 3 — Detail Face ✓
- [x] `InfoPanelView`: board 164pt, board scale animation (280→164), flanking back+gear icons
- [x] CTA floating pill, player metadata with glassy indicators, event line
- [x] Ring dims to 0% opacity in Detail face

## Sprint 3.5 — Ring Polish ✓
- [x] `second` added to `ClockState` for continuous sweep; shimmer pulse
- [x] `GlassPillView` upgrade: layered shadows + inner stroke for glass edge

## Sprint 3.75 — Ring Geometry Fix ✓
- [x] `FilledRingTrack` (even-odd fill) + `ProgressWedge` mask replaced stroke-based ring
- [x] Board edge bevel (0.5pt dark `strokeBorder`)

## Sprint 3.9 — Visual Refinement ✓
- [x] Glass tube overlays: inner specular (white 20%) + outer shadow (black 8%)
- [x] Tick marks: single gradient stroke (white 0.40→0.15 outer-to-inner), removed black halo
- [x] `GlassPillView`: top specular highlight, stroke opacity 0.30
- [x] Player indicators: glassy beads with top-lit gradient + micro drop shadow

## Sprint 3.95 — Ring Fix ✓
- [x] Removed `.animation` from root ZStack (was conflicting with `TimelineView`)
- [x] Replaced pulse system with 3 diffused energy pulses; removed `ChessClockPulse` enum
- [x] Added board inner shadow (6pt stroke, 4pt blur, 22% opacity)

## Sprints 4R → 4F → 4N → 4P — Ring Performance ✓
Evolution: SwiftUI shapes (10–15% CPU) → `CAGradientLayer` rotation (artifacts) → locations drift (chuggy) → Metal noise + IOSurface (<0.1% CPU open, ~0% closed).
- [x] `GoldRingLayerView` — `NSViewRepresentable` wrapping `CALayer` hierarchy
- [x] `GoldNoiseShader.metal` — 3D simplex noise, 2-octave FBM, 5-tone gold color ramp
- [x] `GoldNoiseRenderer` — Metal compute pipeline, 150×150 half-res, IOSurface zero-copy
- [x] 10 FPS Timer, async GPU completion (`addCompletedHandler`), `isActive` pauses on hide
- [x] Removed: `CAGradientLayer`, locations drift, `CGImage` readback, `waitUntilCompleted()`

## Sprint 4 — Puzzle Face ✓
- [x] Puzzle face layout: board 280×280, translucent header overlay, ring hidden
- [x] Header: back + short player names + "Mate in N" + tries indicator (all in 36pt overlay)
- [x] Remove: all instruction text, "Opponent is moving...", "Opponent: G3F3", "Not that move"
- [x] Wrong move feedback: piece snap-back + red square pulse (no text overlay)
- [x] Correct move feedback: piece slide + from/to highlight (no text)
- [x] Opponent auto-play: animated piece movement only (no text)
- [x] Update InteractiveBoardView: gold selection color, gold legal-move dots
- [x] Puzzle result cards: clean material cards with "Solved"/"Not solved", "Review"/"Done"
- [x] Promotion picker: column layout at promotion file, no title text
- [x] Tick mark extension: 8pt → 12pt, board-side shadow
- [x] CTA pill hover animation (Detail face)

## Sprint 4.5 — Polish & Header Redesign ✓
- [x] S4.5-1 Tick z-order
- [x] S4.5-2 Detail face vertical balance
- [x] S4.5-3 Interaction color polish (squareSelected 0.50, legalDot 0.55)
- [x] S4.5-4 Legal dot size (0.38 diameter)
- [x] S4.5-5 Puzzle header auto-hide pills
- [x] S4.5-6 Wrong move border flash
- [x] S4.5-7 Result overlay frosted glass

## Sprint 5 — Puzzle Visual Overhaul & Polish ✓
- [x] S5-1 InfoPanelView vertical centering
- [x] S5-2 GoldNoiseShader + GoldNoiseRenderer — marble color ramp, colorScheme/tint params
- [x] S5-3 DesignTokens — pill colors, ring tint targets, ChessClockTiming enum
- [x] S5-4 PuzzleRingView — marble noise ring with TintPhase state machine
- [x] S5-5 GuessMoveView header pills overhaul
- [x] S5-6 ClockView + GuessMoveView — ring integration + feedback wiring
- [x] S5-7 GuessMoveView result overlays — compact card, board blur, capsule buttons

## Sprint 6 — Replay Face Overhaul + Ring Polish + Settings ✓
- [x] S6-1: SANFormatter — UCI to SAN conversion
- [x] S6-2: ReplayZone update — "Opening"/"Puzzle"/"Solution"/"Checkmate"
- [x] S6-3: GameReplayView layout rewrite — ZStack overlay architecture
- [x] S6-4: Replay header pills — two-pill HStack with auto-hide
- [x] S6-5: Nav overlay — 5-button nav, SAN labels, position counter
- [x] S6-6: Keyboard + focus cleanup — no blue rings, arrows work immediately
- [x] S6-7: Minor tick marks — 12 total (4 cardinal + 8 minor)
- [x] S6-8: Semicircle ring tip — rounded "snake body" leading edge
- [x] S6-9: Settings placeholder — gear icon → "Coming Soon" screen

---

## Ring Animation Architecture (Sprint 4N/4P)

Metal compute shader (`GoldNoiseShader.metal`) produces 3D FBM simplex noise mapped through a 5-tone gold color ramp. `GoldNoiseRenderer` manages the pipeline with double-buffered IOSurface-backed textures at half resolution (150×150), upscaled by `CALayer.contentsGravity = .resize`. 10 FPS Timer. Looks like slowly flowing liquid gold.

```
NSViewRepresentable ("GoldRingLayerView")
  └─ NSView (wantsLayer = true, isFlipped = true)
      ├─ trackLayer: CAShapeLayer              — gray 15% ring (even-odd, static)
      ├─ goldContainer: CALayer                — masked by progressMask (pie wedge)
      │   ├─ noiseLayer: CALayer               — Metal noise IOSurface, ring-masked, 10 FPS
      │   │   └─ GoldNoiseRenderer             — Metal compute pipeline, half-res (150×150), IOSurface zero-copy
      │   ├─ specularStrip: CAShapeLayer       — white 20% inner highlight (static)
      │   └─ shadowStrip: CAShapeLayer         — black 8% outer shadow (static)
      ├─ progressMask: CAShapeLayer            — pie wedge from center, updated 1/sec
      └─ ticksLayer: CALayer                   — 12 ticks (4 cardinal + 8 minor, static)
```

Performance: <0.1% CPU sustained when open, ~0% when closed. GPU ~0.05ms/frame. IOSurface zero-copy — no CPU readback. Timer pauses when popover not visible.
