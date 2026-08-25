# Proposal — the-marker-earns-its-trust

## Why — the gate now trusts a marker nobody checks

Two facts collided this release, one old, one new.

The old one: ticket 0008's A2 collision. The operator ruled "an
explicit quantity records the key even for 1"; the requirement's
literal `quantity: 1` default made explicit-1 and omission
indistinguishable in the target language, so the ruling and the
requirement could not both be built. Nothing detected the
contradiction at reconciliation — the developer discovered it
mid-build, the only consistent reading was implemented, and the
ruling had to be amended on the record afterwards, costing a fourth
proceed (measured:
`runs/shopapp/tickets/archive/0008/approve.md`, the entry marked
"AMENDED by the operator").

The new one: #106 taught `routine-approve` to lift its per-question
refusal for any bullet carrying
`RULED at approve (approve.md A<n>)` — and deliberately built no
check that the cited `A<n>` exists. Its own record states the
earning condition: "a recorded marker whose cited ruling is absent
or contradicts it." That is now a path a gate trusts with nothing
harnessing it, and the operator's standing law is that every opened
path is harnessed.

## What changes

- **The lint checks the citation.** A non-floor Questions bullet
  carrying the ruled marker must cite an answer the ticket's
  `approve.md` actually records; a marker with no `approve.md` behind
  it, or citing an index no entry holds, fails `routine-spec-lint`
  naming the bullet and the missing ruling. The check runs where the
  marker is born — the analyst gate re-runs after every
  reconciliation and before every re-approve — so a bogus marker is
  refused before it can lift any refusal.
- **The ruling is probed before it is baked.** The analyst's
  reconciliation gains the refutation obligation the A2 collision
  earned: before baking an override, attempt once to refute its
  implementability where the target as it stands can refute it,
  record the attempt as Evidence either way, and return a refuted
  ruling to the operator with the probe quoted instead of baking it.
  In 0008 the settling probe was one `ruby -e` line against keyword
  defaults, available and cheap at reconciliation time.

## What is not built

- **No machine judgment of agreement.** Whether the marker's standing
  reading says what the recorded answer meant, and whether a ruling
  still fits an amended requirement, are judgments; the lint checks
  existence only, and the semantic half lives in the analyst's probed
  reconciliation and the operator's read at the checkpoint. Earning
  condition for more: a marker citing a ruling that exists but
  contradicts it surviving both the probe obligation and the
  checkpoint.
- **No audit-time duplicate.** A marker added after the last proceed
  already fails the conclude by fingerprint (#100); a marker present
  before approve already meets this lint at the analyst gate. One
  check, one home.

## Impact

- `bin/routine-spec-lint` — the citation check; pinned in
  `test/spec_lint.bats`
- `agents/analyst.md` — the probed-reconciliation obligation; pinned
  in `test/agents_content.bats`
- specs: `spec-grammar` (Grounding is part of the ticket grammar —
  MODIFIED), `operation` (The analyst decomposes and never
  implements — MODIFIED)
