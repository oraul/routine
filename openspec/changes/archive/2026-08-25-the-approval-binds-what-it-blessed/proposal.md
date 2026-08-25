# Proposal — the-approval-binds-what-it-blessed

## Why — the one human checkpoint has a one-word bypass

Three defects share the approve seam, all on the record:

1. **Any note unblocks all questions.** `routine-approve` lifts the
   refusal for every open question at once when any note is given —
   `note="${2:-}"`, checked only for non-emptiness (measured: the
   code). Ticket 0006 parked on four questions; one word would have
   answered all four. The gate built for adversarial review can be
   waved through.
2. **A proceed can predate what it approves.** Ticket 0005's only
   approval was stamped at 10:18:52, before the requirement's
   amendment landed (measured: the telemetry against the file
   history). No rail compares the approval's clock to the artifact's,
   and the contract that re-specified work is new work has no gate.
3. **The provisional reading is taught but never checked.** The
   analyst's contract mandates
   `- <question> — provisional: <reading>; operator may override`;
   the lint checks only that `## Questions` has a bullet. A question
   filed without the reading the decomposition was built on passes
   everything.

One seam, one change: the proceed is earned per question, every
proceed records what it blessed, and the question form joins the
grammar.

## What changes

- **Per-question answers.** With N non-floor questions open, the note
  must carry `<n>: <answer>` lines covering exactly the open indices;
  missing, unknown, or absent answers refuse with nothing recorded.
  Free-remark lines still ride. Answer quality stays the operator's —
  the gate decides coverage only.
- **Every proceed writes its entry.** `approve.md` gains a timestamped
  entry on every recorded proceed — `Q<n>`/`A<n>` pairs verbatim, free
  remarks, and an `Approved-at: <hash8>` fingerprint of
  `requirement.md`, `grounding.md`, and every briefing, hashed in
  sorted path order through the cksum derivation `routine-tdd` already
  records. One implementation, in `lib/`, shared with the audit.
- **The audit closes the loop.** When the last entry carries a
  fingerprint, a mismatch against the recomputed one is a violation
  naming re-approval. Pre-fingerprint runs skip the rule and stay
  auditable.
- **The lint learns the question form.** Every non-floor `## Questions`
  bullet carries ` — provisional: <reading>`, checked per line like
  Evidence.
- **The contracts follow.** The analyst's absence clause tightens —
  `approve.md` absent now means approve has not yet run, full stop —
  and the skill's approve phase teaches the `<n>: <answer>` form.

## Not built, with what would earn it

- **Judging answer content.** The gate decides coverage, never
  quality — the boundary every lint here holds. Nothing earns
  crossing it.
- **Question ids instead of positions.** Position pairing breaks if
  questions are reordered between refusal and answer; an id grammar
  would survive that but taxes every question with bookkeeping. Earned
  by the first real mis-pairing a reorder causes.
- **Fingerprinting the whole ticket tree.** Tasks, defects, and logs
  change legitimately after approve; the fingerprint covers exactly
  what the skill shows the operator. Widening is earned by an incident
  where an unblessed-but-shown artifact drifted.
- **A re-approve prompt in the skill on fingerprint mismatch.** The
  audit refusal at conclude is the rail; wiring an earlier check into
  develop is earned if a run ever burns significant work between a
  stale approve and its conclude-time catch.
