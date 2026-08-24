# Design — batch-the-test-lint

## One awk per suite, not one per corpus, and not a rewrite of the walk

The batching lands at the file level: the existing per-file awk that
extracts names and bodies grows the judging, and the shell keeps the
`for file in "$dir"/*.bats` walk, the violation tally and the exits.
Per corpus would save another ~46 launches; it would also concentrate
every rule and every file's state in one program invocation, and the
walk is not where the cost is — 6,902 of the measured launches come
from per-test judging, 47 from the walk. The smallest structural
change that removes the measured cost wins.

## Everything the shell judged is string work awk already does

No rule in this lint needs shell semantics. The inventory, rule by
rule, against what awk offers:

- opener denylist, case-insensitive: `tolower(name) ~ /^(test|...)  /`
  — the literal-space-not-`\b` convention survives verbatim.
- word count: `split(name, w, " ")` / NF. length: `length(name)`.
- duplicates per suite: a `seen[name]++` array.
- expectation tokens: `index(body_line, tok)` per token — the same
  fixed-string semantics as `grep -F`.
- continuation joining, subject extraction: **already awk today**,
  pasted in with their comments.
- negated-grep detection, positive-for-subject, isolation patterns:
  ERE matches; awk's dialect is the same ERE those greps use. The one
  translation hazard is `grep -Eqi` (no awk `i` flag) — solved with
  `tolower()` — and `grep -F -- "$subject"` where the subject must be
  matched literally: solved with `index()`, never by regex-escaping.
- pairing's O(lines²) scan: two nested loops over an array of body
  lines, in process, where 500 comparisons cost 3 ms measured.

## The messages are contract, the order is kept, the tally stays shell

Violation lines print from awk byte-identically to today's
`report()` format: `test-lint: FILE: NAME — MESSAGE`. Ordering per
file is preserved as the current code produces it: naming-rule lines
in declaration order, then duplicates, then per-test body → pairing →
isolation. The shell counts emitted violation lines and keeps the
exact summary strings and exit codes. The 28 existing tests pin all of
this and MUST pass unmodified — any edit to an existing test to make
the rewrite fit is the rewrite being wrong.

## The cost pin: PATH shims, because strace does not exist on macOS

The property worth a spec clause is *launches bounded per file, not
per test* — wall clock is CI noise and strace is Linux-only while CI
runs macOS too. The pin: a fixture corpus of two suites × thirty
clean tests; a shim directory on PATH whose `grep`, `awk`, `sed`,
`sort`, `uniq` wrappers append one line to a tally file and exec the
real tool (absolute paths resolved when the shim is written, so the
shim never invokes itself); assert exit 0 and tally ≤ 30.

Thirty is deliberate slack: the batched design needs ~2 launches per
file plus a constant, so ≤ 30 for two files is loose enough to
survive refactoring and tight enough that per-test judging (60 tests
× ~15 ≈ 900) fails it by an order of magnitude. The bound encodes the
scaling law, not the implementation.

This test is genuinely red before the change and green after — the
red→green evidence for a change whose behavioural diff is empty.

## The two loop-tests collapse into batch-report characterizations

*Every mechanism opener in the denylist is caught* becomes one fixture
carrying all 17 bad names, one lint run, and 17 assertions that each
opener's name appears in the output — the same coverage, one launch
instead of 17, and it now also exercises report-everything-in-one-run,
which this suite pins elsewhere. The token-form test needed no
collapse — apply found it already single-fixture single-run since its
birth commit, refuting the proposal's premise about it. The collapsed
test is green before and after; the tasks label it characterization,
not red→green — the mislabelling lesson from `record-citations-in-
range` task 1.2 applies verbatim.

## Non-goals, with what would earn each

- **A per-corpus single process.** Earned if the 47-launch walk ever
  shows up in a measurement.
- **Parsing shell instead of scanning tokens.** The spec forbids it
  and the reason stands: a lint whose correctness needs a lint is not
  an improvement.
- **Shimming inside routine-selfcheck to enforce the bound
  everywhere.** One pin in the lint's own suite decides the property;
  a second enforcement point is a second implementation of it.
