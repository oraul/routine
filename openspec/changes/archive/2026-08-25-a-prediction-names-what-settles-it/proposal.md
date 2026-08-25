# Proposal — a-prediction-names-what-settles-it

## Why — two kinds of claim wear the same sentence

The operator's rule, and this session is its evidence file. Four
exhibits, all on this project's own record:

1. A driver stated "reverting the fix leaves 415 green" in a published
   release record. The number was 418: the suite had grown after the
   entry was written. Accurate-sounding, unmeasured, wrong.
2. The same driver relayed ten of an analyst's measurements to the
   operator as fact before checking any. All ten held — luck, the
   v0.9.0 record says so, not method.
3. A proposal claimed a test "has the same shape" as a looping one,
   inferred from its 220 ms timing. The contributor read the test's
   birth commit: single-fixture, single-run, from the start. A timing
   number had become a structural claim nobody read the code for.
4. The counter-example that proves the cheap fix works: the same
   change's forecast — "under 1 s, under 400 launches" — was labelled
   a forecast with its instruments named, and was settled by
   measurement at 0.17 s and 62. Nothing had to be walked back,
   because the claim never pretended to be a finding.

The failure is not making predictions. It is a prediction wearing a
measurement's sentence, so no reader — operator, next agent, or the
author five minutes later — can tell which they are holding.

## The vocabulary already exists; this change generalises it

Routine already forces the split in two places: a release record's
Gate entry must name *the script that would decide it*, and an
analyst's `## Questions` entry must carry *provisional: <reading>;
operator may override*. Both are the same shape — an unsettled claim
paired with what settles it. What is missing is the rule stated where
sessions and the analyst read before working.

## What changes

- `CLAUDE.md` gains the rule in the session contract: every claim is
  either **measured** — say what ran — or a **prediction** — name the
  evidence that settles it. Never a third thing. Test-pinned like the
  rest of the contract, because an unpinned contract line is the drift
  this repository keeps refusing.
- `agents/analyst.md` gains the same rule for its own output: the
  analyst forecasts constantly — a scenario will be red, a pin is
  green at birth, a simulated implementation will behave some way —
  and ticket 0006's re-entry presented a simulation of unwritten code
  in the same voice as ten verified probes of real code. A forecast in
  its artifacts names what grades it, which in this loop nearly always
  already exists: `routine-tdd red` grades "this will be red",
  `characterize` grades "this was already true", the developer gate
  grades the rest.
- `openspec/specs/guidance/spec.md` and
  `openspec/specs/operation/spec.md` carry the SHALLs; the content
  pins land in `test/guidance_content.bats` and
  `test/agents_content.bats`.

## Not built, with what would earn it

- **A lint scoring whether a prediction is good or its named evidence
  adequate.** Form, never truth — the boundary `routine-record-lint`
  holds. If anything is ever earned here it is that the two classes
  are *distinguishable* in an artifact, and only a second incident of
  an indistinguishable one would earn even that.
- **The rule in `agents/developer.md`.** The developer's claims are
  already graded by scripts within minutes — red by `routine-tdd`,
  green by the gate. The gap this closes is where claims travel
  ungraded: session prose and analyst artifacts.
