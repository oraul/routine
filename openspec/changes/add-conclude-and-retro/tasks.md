## 1. Conclude

- [x] 1.1 Red→green: `routine-conclude` refuses naming unfinished tasks while
      any index row is not done, moving nothing
- [x] 1.2 Red→green: on an all-done index it writes `report.md`, emits
      `ticket.conclude`, and moves the ticket to `tickets/archive/<id>/`

## 2. Retro

- [x] 2.1 Red→green: `routine-retro` aggregates runs/fails per event and
      fails per script across apps and archived tickets, writing no files
- [ ] 2.2 Red→green: duration min/p50/p95/max per event and time-in-blocked
      per task from block/unblock timestamp pairs
