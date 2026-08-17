# Proposal — the-analyst-asks-what-only-the-operator-knows

## Why — three findings, one file

All three land in `agents/analyst.md` and its spec. Splitting them means
editing the same contract three times, so they ride together.

### 1. A contradiction shipped in #91, and it blocks the release

`#91` gave the developer a third TDD phase: a
`## Characterization: <label>` scenario proves its birth claim with
`routine-tdd characterize`. It updated `agents/developer.md` and
`openspec/specs/tdd/spec.md` — and not `agents/analyst.md`, which still
says a characterization is a pin where "the developer records no TDD
evidence for it", nor `openspec/specs/spec-grammar/spec.md`, which says
the same.

Run 0006 found it on the first task. The analyst, following its own
contract, wrote *"record no TDD evidence, never through routine-tdd"*
into the acceptance lists of tasks 01, 02 and 04. The developer, following
its contract, must prove the claim with `characterize` — which writes a
`tdd.characterize` line under that exact label. It could satisfy neither
side without breaking the other, so it called `routine-defect` and named
both.

The loop worked. The change did not.

### 2. Every pin is single-file, so an interface cannot be checked

This is the third time this project has broken what travels *between*
agents: **E1** — scouted knowledge died at approve; **E4** — the
delegation payloads described artifacts they never named; **#91** — the
two contracts now disagree about the same phase.

`test/agents_content.bats` pins load-bearing *words* in each file
independently. Nothing anywhere asserts that the analyst's description of
the developer's job matches the developer's contract. The failure mode is
invisible by construction, which is why three careful changes walked into
it.

Three occurrences is a pattern by the standard this repository applies to
everything else, so the check is earned.

### 3. The analyst decides things only the operator can answer

`## Assumptions` currently holds two different kinds of claim:

- **Derivations** — defensible from the target itself. *"An unknown name
  raises rather than shrugs, from the class's raise-don't-shrug idiom."*
  *"The settled check precedes the argument check, mirroring `add_item`."*
  The analyst reading conventions and following them is the design
  working. It must not ask about these.
- **Questions only the operator can answer** — measured, across two runs:
  does the rounding favour the customer or the business (3050 at 33% is
  2043 or 2044)? Is a 0% discount a no-op or a mistake? Should half a
  percent exist? Which duplicate copy does a removal take? Nothing in the
  target knows, because these are product intent, not code.

Roughly ten such entries across runs 0005 and 0006, both classes mixed
freely. Recording a product decision as a settled assumption is a
decision made by an agent with no standing to make it.

And the human never sees them: `skills/routine/SKILL.md`'s approve step
shows `requirement.md` and every `briefing.md`. `## Assumptions` lives in
`grounding.md`. The analyst itself names the stakes — *"changing it after
task 01-01 lands is a caller-visible break"* — so these are cheap to
overturn at approve and expensive after, and approve is exactly where
they are invisible.

## What changes

1. `agents/analyst.md` and `openspec/specs/spec-grammar/spec.md` describe
   the characterization phase as `#91` actually built it.
2. `test/agents_content.bats` gains a **cross-contract** check: the two
   agent files must agree about the phases they both describe. Its red is
   `main` as it stands today, not a fixture.
3. The analyst separates a derivation from a question, records the
   questions where the floor applies, and **states the provisional
   reading it decomposed against** so the loop never stalls waiting for
   an answer.
4. The approve step shows the questions, and `routine-approve` refuses a
   proceed that leaves non-floor questions unanswered.
5. The specify payload gains a context field — today it carries
   `Requirement`, `ROUTINE_TICKET_DIR` and `TARGET`, and nothing tells the
   analyst what the app is or what the operator cares about, so it derives
   from the code and nothing else.

## The question carries its provisional answer

Otherwise this deadlocks: an analyst that cannot decide cannot write
tasks, and a loop that stops at every ambiguity is worse than one that
rules and records. So a question states what the analyst decomposed
against *and* that the operator may overturn it. Work proceeds; the
override is cheap; the decision is attributed.

## Why the refusal is a gate and not a suggestion

Showing the questions makes them visible. Only an exit code makes them
answered. The `- none — <why>` floor means asking is a deliberate act
rather than a default, so a refusal only fires when the analyst
deliberately raised something — and a question nobody will answer means
the requirement is not ready, which is precisely when the loop should
stop.

## Not built, with what would earn it

- **A script judging whether a question is a real question, or whether a
  requirement is complete.** Form, never truth — the boundary
  `routine-record-lint` already holds.
- **A general cross-file consistency engine.** The check earned here is
  the shared-vocabulary one between two known contracts. Generalising to
  arbitrary files is speculation until a third pair needs it.
