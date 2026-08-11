## Context

See proposal.md — Why. Sidecars must run on bash 3.2 + BSD grep against
arbitrary Ruby codebases; the gate must find the *current* briefing without
the LLM telling it which one.

## Goals / Non-Goals

- **Goals**: two proven topic pairs; the manifest-driven developer baseline;
  per-sidecar telemetry.
- **Non-Goals**: languages beyond the two Ruby seeds (§10), semantic
  analysis (N+1 detection and friends stay in the `.md`), configurable rule
  sets.

## Decisions

- **Current briefing = the in-progress index row**: the baseline derives it
  with `index_first_with_status`, needing no new argument surface. No
  in-progress task → treated like no manifest (log and pass): the gate can
  run before `routine-next` marks work without lying.
- **Rules are BSD-grep ERE only**, scanning `*.rb` and excluding
  `vendor/` and `node_modules/`: whole-word precision is traded for
  portability; false positives are the analyst's cue to narrow the manifest,
  and rule quality is retro-fed.
- **Sidecars stay telemetry-free**; the gate wraps each run and emits
  `gate.developer.script` — one writer, one line per invocation, matching
  the telemetry spec's event list.
- **`puts` rule scoped to `app/`** because scripts and Rakefiles print
  legitimately; the other rules scan the whole tree.

## Risks / Trade-offs

- [Comments trip the greps] → accepted: mechanical means mechanical; the
  developer deletes dead text or the analyst drops the topic.
- [Manifest topic names couple briefings to sidecar paths] → that coupling
  is the contract (naming is derivation): `- ruby/rails` ⇒
  `caffeine/ruby/rails.sh`.

## Migration Plan

Additive; the developer gate without ticket context behaves exactly as
before. Rollback = revert the merge commit.
