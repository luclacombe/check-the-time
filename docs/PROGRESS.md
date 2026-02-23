# Progress Log

> Append a new entry at the start of each development session.
> Run `/sync` to auto-update this file.

---

## 2026-02-23 — Session (v0.5.1 patch)
**Goal:** Fix replay start position bug + GitHub Latest release badge
**Completed:**
- Fixed `puzzleStartPosIndex` formula: `positions.count - 1` → `positions.count - 2`
- Updated `testComputeAllPositions_puzzleStartMapsCorrectly` to match corrected formula (psi=9, not 10)
- All 40 tests pass (CODE_SIGN_IDENTITY="" workaround for transient keychain lock)
- Tagged v0.5.1 and pushed; created `gh release create v0.5.1 --latest` → GitHub now shows v0.5.1 Latest
- Updated README download link, TODO Done section, MAP.md patch note
**Next session:**
- Start at: v0.6.0 planning
**Notes:**
- The psi bug was subtle: for hour 1, psi=N pointed to checkmate (after your move); correct is N-1 (before your move, showing opponent's context arrow)
- Codesign intermittently fails in xcodebuild test; use CODE_SIGN_IDENTITY="" workaround if it recurs

---

## Template

```
## YYYY-MM-DD — Session N
**Goal:** [What we set out to do]
**Completed:**
- [Task ID] Description of what was done
**Blocked / Skipped:**
- [Task ID] Reason
**Next session:**
- Start at: [Task ID] [Task name]
**Notes:**
- [Any context to carry forward]
```

---
