# Design — the-analyst-asks-what-only-the-operator-knows

## The line between a derivation and a question

The whole change rests on one distinction, so it has to be stated in a
form an agent can apply without a judgment call every time.

**A derivation is answerable from the target.** Its evidence is a file
and a line: this codebase raises rather than returns a flag, this class
checks settlement before arguments, these mutators return `self`. A
reader can disagree, but they disagree with a *reading of the code*.

**A question is not in the target at any depth.** No amount of reading
`lib/order.rb` reveals whether rounding should favour the customer or the
business. That is not a hard question — it is a question about intent, and
the code is the wrong place to look because the answer was never written
there.

The test the analyst applies: *could I cite a path and a line for this?*
If yes, it is a derivation and it belongs under `## Assumptions`. If the
honest citation would be "the requirement is silent and the code has no
opinion", it is a question.

## Where the questions live

In `grounding.md`, beside `## Assumptions`, not in a new file.

- `spec-lint` already enforces that file's sections and its
  `- none — <why>` floors, so the machinery exists.
- A reader comparing a derivation to a question wants them adjacent, not
  a file apart.
- `requirement.md` is the wrong home: it states what the system SHALL do,
  and an open question is precisely what has not been settled.

## The question carries its provisional answer

The obvious design — the analyst stops and asks — deadlocks. An analyst
that cannot decide cannot write a task, and every ambiguity would halt
the run. That is worse than ruling and recording, which is what it does
today.

So a question states three things: what was asked, what the analyst
decomposed against, and that the operator may overturn it. Work proceeds
on the provisional reading; the override stays cheap because approve
happens before any implementation; and the decision is attributed to
whoever actually made it.

This is the same shape `## Alternatives` already uses — a rejected road
recorded with its reason, not an empty slot.

## Why `routine-approve` refuses rather than reminds

Showing the questions makes them visible. Only an exit code makes them
answered, and this repository's whole argument is that a rule living in
prose holds while someone remembers it.

The refusal is narrow by construction: the `- none — <why>` floor means
asking is deliberate, so a refusal can only fire on a question the
analyst chose to raise. And the case where it bites hardest is the case
where stopping is right — a question nobody will answer means the
requirement is not ready.

What the gate cannot decide: whether the question is real, whether the
answer is good, or whether the human read it rather than typing a word to
get past it. Same boundary `routine-record-lint` holds — form, never
truth. Worth stating, because a gate that looks like it enforces
attention invites the belief that attention was paid.

## The cross-contract check, and why its red is not a fixture

`test/agents_content.bats` pins words per file. The check earned here is
different in kind: it asserts two files *agree*, which no existing test
does.

The strongest available evidence is that `main` is broken right now. So
the order is: write the check, run it against HEAD, watch it fail on the
real `#91` contradiction, then correct the contracts. A red nobody
manufactured.

That ordering is worth protecting. Correcting the contracts first would
destroy the only unforced red this change can get, and leave the check
provable solely against a fixture I wrote to fail.

**Scope**: the shared vocabulary of two known contracts — the TDD phases
and what evidence each records. Not a general consistency engine; a third
pair needing it would earn that, and none does.

## Non-Goals, with what would earn each

- **Judging requirement completeness.** No script can. Naming the
  dimensions that reliably go unstated (money rounding, boundaries, error
  type, duplicates, ordering) is guidance, and guidance belongs in
  `CONTRIBUTING.md`, never in a lint.
- **A channel for the analyst to ask mid-flight.** It is a stateless
  delegate with no way back to the human, and inventing one would put a
  human in the middle of a phase rather than at its boundary. The
  boundary already exists: approve.
- **Making the context field mandatory.** A target whose domain is
  obvious needs no essay, and a required field invites filler. It is part
  of the template; whether it is ever enforced waits for evidence that
  omitting it cost something.
