# Design — the-marker-earns-its-trust

## The seam has two failure classes, and only one is decidable

The F3 question was "ruling-vs-artifact consistency had no detector."
Designing the detector starts by splitting what "inconsistency" means:

1. **The citation class.** A bullet claims
   `RULED at approve (approve.md A<n>)` and the record holds no such
   answer — no `approve.md` at all, or no entry recording `A<n>:`.
   Fully decidable by a script: the marker names a file and an index,
   and both either exist or do not. No live incident has fired here
   yet; the check is built anyway because #106 turned the marker into
   something a gate acts on, and the operator's law — every path you
   open, you harness — does not wait for the first exploit of a path
   that was opened deliberately.
2. **The semantic class — the actual A2 collision.** The ruling
   existed, was correctly cited, and still contradicted the
   requirement: "explicit quantity records the key even for 1" cannot
   be built against a literal `quantity: 1` default, because the
   language cannot distinguish explicit-1 from omission. No script
   here can decide that two English sentences and a type system are
   jointly unsatisfiable — pretending otherwise would put a judgment
   behind an exit code, which the Laws forbid. The honest rail is an
   obligation, not a gate: the reconciliation probes the ruling's
   implementability where the target can refute it, exactly as the
   refutation-first rule already treats the analyst's own load-bearing
   claims. A ruling is a load-bearing claim the operator made; it
   earns the same attempt to kill it. In 0008 the killing probe was
   one `ruby -e` line, and it would have fired at reconciliation
   instead of mid-build.

## Where the citation check lives, and why only there

`routine-spec-lint`, in the existing per-bullet Questions loop. The
timeline makes one home sufficient: a marker is born at
reconciliation; the analyst gate (which runs the lint) must pass
again before the re-approve; and `routine-approve` refuses without a
passing analyst gate on record. So every marker meets the lint before
it can lift any refusal. The other candidate homes were rejected:

- **`routine-approve` itself** — would put the same check behind two
  exit codes; the gate already trusts the lint's verdict through
  `gate.analyst`, and a second implementation is a second thing to
  drift.
- **`routine-audit` at conclude** — redundant by construction: a
  marker added after the last proceed moves `grounding.md` and the
  fingerprint rule (#100) already refuses that conclude; a marker
  present before the proceed met the lint.

## What existence means, precisely

The cited index passes when any entry in the ticket's `approve.md`
records an `A<n>:` line for it — the file is append-only history and
a ruling may have been recorded in any earlier proceed. The check
does not verify *which* entry, whether the answer was a typed ruling
or a stands-line, or whether the marker's standing reading matches
the answer's words: attribution and agreement are judgments, and the
lint's contract is form. The boundary is stated in the spec sentence
itself so nobody reads the passing lint as more than it is.

## The probe obligation's shape

The obligation reuses the refutation-first grammar the analyst
already carries — attempt once, record the attempt as an Evidence
bullet either way, quote command and decisive output — extended to
overrides at reconciliation, with one addition: a refuted ruling
returns to the operator with the probe quoted, rather than being
baked. Forecast rulings (claims about unwritten code) stay under the
existing forecast rule — their grader is named, not probed in
advance.
