# Proposal — one-claim-is-always-re-run

## Why — trust as a prohibition is a blind spot

Two rules make this loop deliberately trusting: the analyst on an
anchor-current re-entry is told to trust every claim and not re-open
the files, and no lint judges whether a recorded claim is true. Both
boundaries are right — and together they structurally forbid the one
check that catches a curated record: re-running a sample of what was
recorded. The exhibits are on the record:

1. Two developer self-reports omitted their refused attempts; only
   telemetry — the meter the reporter cannot edit — held the truth
   (the v0.10.0 record).
2. A driver relayed ten measurements as fact, all luck (the v0.9.0
   record's own last entry).
3. The audit run while designing this program produced a
   conclusion-first staleness claim of its own, and only a spot-check
   caught it — recorded in #98's design.

Curation survives exactly where nothing is ever re-run. The fix is
not less trust — it is a sample nobody gets to choose.

## What changes

- **`routine-spec-lint` names one sampled Evidence bullet per run** —
  index derived from the grounding's own bytes (`cksum`), never the
  author's choice, so verification cannot be steered toward
  convenient claims. Reported on stdout; gates nothing.
- **`routine-record-lint` names one sampled entry per run** — from
  `## Caffeine` and `## Gate` together, floors exempt — as the
  spot-check whose evidence is re-run before publishing. Reported;
  gates nothing.
- **The trust rule lifts its prohibition without losing its
  default.** The analyst's contract: re-verifying the sampled bullet
  never counts as a re-search. Trust stays the norm; the sample is
  the audit the norm was missing.
- Specs: `spec-grammar`, `release`, and `operation` MODIFIED.

## Not built, with what would earn it

- **A gating spot-check.** The sample is reported, never refusing:
  whether the re-run confirms the claim is a judgment, and a gate
  that judged truth would cross the boundary every lint here holds.
  Teeth are earned the first time a sampled re-run catches a false
  claim that shipped — then the retro decides what a refusal would
  have needed to see.
- **Mechanical re-execution of the sampled claim.** A probe bullet
  quotes its command inside a free one-line claim; without a rigid
  probe grammar a script cannot extract and re-run it reliably, and
  C1 deliberately refused that grammar. Earned only with it.
- **Sampling more than one claim.** One per run is the smallest
  version that makes curation risky; a wider sample taxes every run
  and is earned by evidence that one is not enough.
- **Random selection.** Deterministic-from-bytes means the same file
  always names the same sample — reproducible in CI and in a retro —
  while still moving whenever the file moves. Randomness adds
  unreproducibility and buys nothing until an author is shown gaming
  the derivation, which itself would be the incident that earns it.
