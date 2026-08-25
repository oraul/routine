# Proposal — the-delta-carries-what-it-modifies

## Why — a modified requirement silently lost a line once already

The house rule is that a MODIFIED requirement's delta carries the
entire live requirement verbatim plus its additions — and nothing
gates it. C4's delta lost the final line of a carried scenario to an
off-by-one sed range; a hand diff caught it before sync, and only
habit demanded that diff (measured: the correcting commit in #101
restores the line). The v0.11.0 Gate entry recorded the hole and
named the script that would decide it. Since then the same hand diff
has run before every sync — #106, #107, #108 — three more times held
by habit. A carry that fails silently ships a spec that claims less
than it did the day before, with a green board.

## What changes

- **`bin/routine-change-check <change-id>`** judges every requirement
  under `## MODIFIED Requirements` in the change's deltas against the
  live spec: each live line — heading to next heading, blank lines
  exempt — must survive into the delta, identical or inside an
  extended line; the first lost line fails by name, as does modifying
  a requirement the live spec does not hold. ADDED sections are
  exempt; unknown id is usage. One `harness.change` telemetry line
  per run; the road declared and walked live before this ships.
- **Its place in the loop**: before sync, where the comparison still
  decides something — after sync the live spec contains the delta and
  the check is vacuous. The loop documentation already tells the
  driver to diff before sync; the diff becomes this exit code.

## What is not built

- **No byte-exactness proof.** A dropped line whose text coincides
  with part of an unrelated surviving line can escape — real prose
  makes that rare, and the check hunts the incident class (silent
  loss), not equality outside additions, which would require the
  check to know the additions. The author's diff remains the finer
  instrument; this is the one that cannot be forgotten.
- **No RENAMED/REMOVED handling.** Neither section has ever appeared
  in this repository's changes; earning condition: the first change
  that needs one.
- **No sync automation.** Assembling the synced spec stays the
  author's move (queued separately as routine-change-sync); this
  change only refuses a bad carry.

## Impact

- new: `bin/routine-change-check`, `test/change_check.bats`
- modified: `lib/roads.txt` (declares `harness.change`)
- specs: `conventions` (A delta carries what it modifies — ADDED)
