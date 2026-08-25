# Design — the-approval-binds-what-it-blessed

## Position pairing, and why not ids

Answers pair to questions by position among the non-floor bullets,
`1`-based, in file order. The refusal prints each open question with
its index, so the operator answers what they were shown. Ids were
rejected for now: they tax every question with bookkeeping to solve a
reorder race no run has exhibited — the earning condition is recorded
in the proposal. Duplicate indices in one note refuse (two answers to
one question is a contradiction to resolve, not evidence to record).

## The fingerprint covers what the operator saw

The skill's approve phase shows `requirement.md`, every `briefing.md`,
and the questions from `grounding.md` — so the fingerprint hashes
exactly `requirement.md`, `grounding.md`, and `briefings/*/briefing.md`
in sorted path order, via `cksum` with the same `%08x` derivation
`routine-tdd` records. `cksum` is POSIX; no shasum/sha1sum portability
split. The implementation lives once in `lib/approve.sh` and both
`routine-approve` and `routine-audit` source it — two implementations
of one hash would disagree with nothing to catch it, the exact failure
the release spec names for record grammar.

## The audit rule is conditional by design

The rule fires only when the last `approve.md` entry carries
`Approved-at:` — every proceed recorded under this version does, while
archived runs 0001–0006 (no file, or note-only entries) skip it and
stay auditable. A healthy defect-return run stays green by
construction: the loop re-gates and re-approves after re-specify, so
the last approval postdates the last artifact edit; a run concluded on
a stale approval is exactly the violation.

## The lint checks the reading, not the override tail

The grammar requires ` — provisional: <reading>` with a non-empty
reading on non-floor question bullets, per line like Evidence. The
`; operator may override` tail stays contract prose, unchecked: the
reading is load-bearing (it is what the decomposition was built on);
the tail is teaching. The floor stays exempt, and floor detection uses
the same `none — ` prefix rule `routine-approve` already applies.

## Contract follow-through

C1 wrote "absence means no remarks were recorded or approve has not
yet run" into the analyst's re-entry clause. This change makes the
first half false — every proceed writes the file — so the clause
tightens in the same change that changes the behavior, not in a later
cleanup: a contract sentence that outlives its mechanism is the drift
this repository keeps refusing.

## Pins

Verified absent at HEAD before writing (measured — the greps ran):
`Approved-at` and `fingerprint` absent from `bin/`, `lib/`, `test/`,
`openspec/specs/`, `agents/`, `skills/`; `provisional` absent from
`bin/routine-spec-lint` and `test/spec_lint.bats` (present only in
spec prose and the analyst contract, which are not pin targets).
