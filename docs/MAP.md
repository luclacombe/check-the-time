# MAP — Features Beyond MVP

> Shipped version summaries and future feature backlog.

---

## Shipped

| Version | Highlights |
|---------|-----------|
| **v1.0.0** | Full UI overhaul: borderless NSPanel, Metal gold ring, 6-stage onboarding, game replay with SAN notation, DesignTokens centralization |
| **v0.5.x** | Game replay viewer, board-as-CTA, `allMoves` data field, 40 replay tests |
| **v0.4.0** | Inline puzzle (no second window), multi-move puzzle + retries, PuzzleEngine pure struct |
| **v0.3.0** | Hourly game rotation, interactive "Guess Move", ChessRules engine |
| **v0.2.0** | Test suite, bug fixes, per-device seed |

---

## Future

These are significant features that each deserve their own scoping and planning session.

### "Guess the time" share card
Wordle-style: show the board position, let the user guess the hour and minute, then reveal whether they were right. Generate a shareable text card (like Wordle's emoji grid) that can be copied and shared. This is the viral growth mechanic.

### Settings panel
Accessible from the menu bar menu. Initial settings:
- Toggle: show actual time vs. hide time (advanced mode)
- Future: choose piece theme, board colors

### Hide-the-time mode (advanced player)
Hide the minute ring, AM/PM indicator, and actual time. Only show the board and game info. The challenge: can you tell what time it is from the position? Reveal on click or keyboard shortcut.

### WidgetKit widget
A native macOS widget (for Notification Center / Desktop). Requires the $99 Apple Developer Program membership. Identical visual to the floating window but in widget format.

### Online game database
Replace the bundled `games.json` with live API calls to a backend (or directly to Lichess Broadcasts API). Keeps the game database fresh without app updates. Requires internet. Falls back to bundled games if offline.

### Game-chaining Hour to Hour
Instead of fully random rotation, the new game features one of the same players as the previous game. Creates a thematic through-line for the day. Example: Magnus Carlsen appears in both cycles.

---

## Design Principles for Future Features

- **Additive:** New features should not change the behavior existing users rely on
- **Optional by default:** Settings should default to the current MVP behavior
- **Chess-first:** Visual changes should feel like they belong in chess culture
- **Still compact:** The widget should remain small and non-intrusive
