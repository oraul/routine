# Design — bind-scenarios-to-coverage

## The label is the join key, and it already half-exists

`routine-tdd` records `<scenario> [<hash8>]`; the audit pairs red and
green byte-exact on that string. What is missing is the other end of
the join: nothing says the recorded scenarios ARE the task's scenarios.
A `## Scenario: <label>` heading makes the label a grammar object the
lint can enforce and the audit can extract — no new state, no new
telemetry event, just a rule over files that already exist.

## Matching tolerates the hash, nothing else

The audit accepts a green for label `L` when the recorded scenario is
exactly `L` or begins `L [` — the hash suffix is `routine-tdd`'s
command binding, not part of the analyst's vocabulary. Anything else
(a renamed label, a paraphrase) is uncovered, by design: the developer
contract says verbatim, and the audit is where "verbatim" gets teeth.

## Per-scenario replaces per-task; the old check stays as a floor

The existing "at least one tdd.green per done task" check remains — it
catches a task whose file lost its labels after the fact. The new
per-label loop adds the coverage demand on top. Both read the same two
files the audit already reads; the audit stays a pure reader.

## Empty manifests were a fiction

`testing/tdd` is doc-only and applies to every task that goes red →
green — which is every task on these rails. A manifest with zero topics
therefore never means "none apply"; it means "didn't look". The lint
now says so, and the analyst's fallback is explicit: when nothing
domain-specific fits, the manifest is `- testing/tdd`, not empty.
