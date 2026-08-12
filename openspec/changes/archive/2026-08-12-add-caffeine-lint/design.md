## Context

Council audit of `caffeine/`: format drift already live (two guides
instruct against a structure that no longer exists), zero provenance,
doc/sidecar rule lists hand-copied with no check, retro blind to run
counts and to doc-only topics entirely. The lint is the keystone — every
other caffeine change (instruments, data, catalog, beachheads) lands on
top of an enforced contract.

## Goals / Non-Goals

- **Goals**: the topic format becomes exit codes; provenance becomes
  grep-checkable fields; the deepening queue becomes computed.
- **Non-Goals**: interpreting the `applies` constraint (presence and
  shape only — interpreting it is an unearned abstraction); rule-level
  telemetry (needs a telemetry-spec change; deferred until the ranked
  section proves insufficient); fixing sidecar patterns (K2) or guide
  content truth (K3).

## Decisions

- **Metadata as fixed-form comment lines**, mirroring telemetry's
  fixed-key discipline: HTML comments after the doc's H1, `#` comments in
  the sidecar header — one `grep -qE` per field, no parser.
- **`caffeine-mode: doc-only` is declared, never inferred** — an
  accidentally missing sidecar must be distinguishable from a deliberate
  doc-only topic.
- **Rule strings are the canonical ids**: `check "<rule>"` first
  arguments, extracted by grep, must appear verbatim in the doc — the
  "sidecar mechanically rejects" list stops being a hand-copy.
- **Lint runs before shellcheck in selfcheck** — a malformed topic tree
  makes downstream results meaningless, the same argument as
  lint-before-bats.
- **Test file names become derivations** (`caffeine_<ns>_<topic>.bats`),
  removing the namespace collision waiting at ~15 topics.
- **Retro ranks by fail rate, descending** — the printed order is the
  deepening queue; doc-only topics appear with their run counts so the
  architecture namespace becomes visible for the first time. Output is
  sorted so the report is deterministic (evidence, not hash order).

## Risks / Trade-offs

- [Lint blocks unrelated work when a topic rots] → that is the point;
  the failure names the file and field.
- [Verbatim rule strings couple doc prose to code] → deliberate: the
  coupling exists either way, the lint just makes drift visible.

## Migration Plan

Lint lands green over the backfilled corpus in the same change. Rollback
= revert the merge commit.
