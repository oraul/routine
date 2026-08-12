## 1. Attribution

- [x] 1.1 Red→green: ticket-bound events carry the ticket dir's basename
      and the `in_progress` task id, derived not passed

## 2. Refusals leave evidence

- [x] 2.1 Red→green: done/block/unblock/next/conclude emit their event
      with the real exit code on refusal and protocol outcomes

## 3. App-level evidence

- [x] 3.1 Red→green: scaffold emits `app.scaffold` always, deps emits
      `app.deps` only when `runs/<app>` exists

## 4. TDD phases

- [x] 4.1 Red→green: `bin/routine-tdd` runs the command, enforces the
      phase, and emits `tdd.red`/`tdd.green` with the scenario

## 5. Retro app dimension

- [x] 5.1 Red→green: blocked-seconds pairing scoped per app; colliding
      ticket ids in the fixture prove separation
