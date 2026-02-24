# TODO Done — Sprint 3.95: Ring Animation Fix (2026-02-24)

- [x] **S3.95-1: Diagnose ring animation root causes** — `.animation(.linear, value: second)` on root ZStack fought TimelineView; sin()-based cycle variation made phase erratic; 6 blur ops/frame (2 pulses x 3 layers) amplified artifacts
- [x] **S3.95-2: Scope animation modifier** — moved `.animation(.linear(duration: 1.0), value: second)` from parent ZStack to `fillGroup` only; tick marks and pulse layer excluded
- [x] **S3.95-3: Rewrite pulse system** — replaced dual TimelineView pulses (sharp core + 2 blur layers each) with 3 diffused energy pulses: primary warm glow (4.5s, 6%, blur 6), slow ambient wash (7.0s, 8%, blur 8), fast accent spark (3.0s, 4%, blur 5). All `.round` lineCap, fade-in at entry, ProgressWedge mask clips diagonal end (trimTo NOT clamped to progress)
- [x] **S3.95-4: Clean up DesignTokens** — removed `ChessClockPulse` enum (10 tokens), removed `ChessClockTube.centerHighlight` (imperceptible at 8% white)
- [x] **S3.95-5: Add board inner shadow** — 6pt black stroke, 4pt blur, 22% opacity overlay on BoardView in ClockView.boardWithRing (clock face only, not global)
- [x] **S3.95-6: Brighten tick marks + raise them** — gradient 0.40/0.15 → 0.70/0.30; added centered shadow (black 40%, radius 1.5) so ticks appear embossed on ring surface
- [x] **S3.95-7: Update DESIGN.md** — documented final pulse parameters, animation scoping rule, tick/shadow specs, removed deprecated shimmer/pulse tokens
