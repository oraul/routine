## Context

Council sidecar audit: 16 rules, four copy-paste skeletons, verified
false positives and negatives, an output format the developer agent
cannot parse (rule sentences contain colons), and no way to distinguish
a broken sidecar from a clean target.

## Goals / Non-Goals

- **Goals**: one instrument library, honest exclusion, repaired
  patterns, high-signal rules, a closed test matrix.
- **Non-Goals**: content truth in the guides (K3); rule-level telemetry
  (deferred until the retro's ranked section proves insufficient);
  cross-file rules like uniqueness-vs-schema (worth a later change with
  its own design).

## Decisions

- **The library lives in `lib/sidecar.sh`**, not under `caffeine/` —
  the caffeine lint owns `caffeine/*/*` as topics, and the library is
  harness code: shellchecked by selfcheck like every other lib.
- **Rule ids ride the check signature** (`check R1 "<rule>" ...`) and
  the bracket form `topic[R1]` makes the output splittable on `] ` —
  the rule *string* remains the canonical name the lint matches
  verbatim against the doc; the id is the parse handle.
- **Exit 2 on grep internal error**: `scan` treats grep status >1 as a
  broken instrument and aborts the sidecar — the gate relays it, and
  the audit records a non-zero, never a false green.
- **Pattern repairs stay BSD-portable**: no `\b`, no `-P`;
  `--exclude-dir` is supported by both GNU and BSD grep.
- **Rule budget stays 3–5**: additions displace weaker forms by
  broadening existing patterns instead of stacking new rules where
  possible; each sidecar ends at exactly 5 or keeps 4.

## Risks / Trade-offs

- [Broadened patterns can surface new hits in existing targets] →
  intended: they were false negatives; the near-miss fixtures pin the
  legitimate forms that must keep passing.
- [Changing the check signature touches the lint] → one sed pattern,
  spec'd in the same change; the lint's verbatim-rule check is
  unaffected because the rule string stays the second token.

## Migration Plan

All four sidecars migrate in one change; the gate's interface (exit
codes, TARGET) is unchanged. Rollback = revert the merge commit.
