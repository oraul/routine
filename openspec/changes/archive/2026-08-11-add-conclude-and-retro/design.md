## Context

See proposal.md — Why. Constraint that shapes everything here: BSD awk has
no `mktime`, and the runtime allows no Python/jq (Law 5), yet the retro must
subtract ISO-8601 timestamps.

## Goals / Non-Goals

- **Goals**: a scripted ticket ending; a retro any machine can compute from
  plain files with awk alone.
- **Non-Goals**: dashboards, stored histograms, `--export` (§10 rejects
  them); cross-run trend analysis; pruning archived tickets.

## Decisions

- **Timestamp math in pure awk** via the civil-days algorithm (days from
  epoch computed arithmetically from Y/M/D, then seconds) — portable to BSD
  awk, ~10 lines, tested against fixture pairs.
- **Telemetry parsing exploits the fixed key order**: split on `"` gives
  every value at a fixed field index; no JSON library, per the telemetry
  spec's stated rationale.
- **Percentiles by sort**: durations per event collected, sorted with
  `sort -n`, p50/p95 read by index — nearest-rank, no interpolation.
- **Conclude emits before moving** the directory, so the `ticket.conclude`
  line travels inside the archived ticket's own `telemetry.jsonl`.
- **`report.md` derives from the index only** (id, task table, timestamps):
  boring, deterministic, no prose generation.

## Risks / Trade-offs

- [Unpaired block/unblock (still blocked at retro time)] → reported as
  unclosed with no duration, rather than guessing an end time.
- [Large telemetry files] → linear awk passes; no caching by design
  (selfcheck caching is explicitly not built, §10).

## Migration Plan

New scripts only. Rollback = revert the merge commit.
