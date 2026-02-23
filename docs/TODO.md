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
