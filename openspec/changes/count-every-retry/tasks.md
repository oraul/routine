## 1. The counters

- [x] 1.1 Red→green: `lib/episode.sh` gains `episode_developer_fail_count`
      (consecutive failing `gate.developer` lines for a task since its
      last passing one) and `episode_defect_count` (`spec.defective`
      lines for a task), both printing 0 for an absent file the way
      `episode_revise_count` does

## 2. The gate spends the developer budget

- [x] 2.1 Red→green: `routine-gate developer` refuses past 3 consecutive
      failures for the task, naming `routine-defect` and `routine-block`
      as the roads, and the developer contract states the limit the way
      the gate counts it instead of "about three"

## 3. The defect return is bounded

- [x] 3.1 Red→green: `routine-defect` refuses past 3 returns for one
      task, naming `routine-abort` — the same shape the analyst's
      exhausted revise budget already uses
