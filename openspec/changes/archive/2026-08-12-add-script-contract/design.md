# Design — add-script-contract

## Flat lines, not YAML

The tempting format is fenced YAML; the lint Laws forbid it in
practice. Every checker here is bash 3.2 + grep/awk, and nested YAML
needs a parser. The caffeine headers already picked the right grammar —
one fact per fixed-form comment line — and it bought verbatim
cross-checks for free. The script frontmatter reuses that exact move:
`# routine-<key>: <value>`, repeated keys for repeated facts
(`routine-exit` once per code). Greppable, diff-friendly, and an agent
parses it with `head`.

## Cross-agreement over presence

A presence check ("has a description") rots into decoration. The value
is in the rules that bind frontmatter to body so drift is impossible:
usage must equal the `usage:` string the script itself prints; the
documented exit set must equal the literal `exit <n>` set found in the
body; the named test file must exist and mention the script; the two
context env vars must be declared iff referenced. These are the same
verbatim-agreement teeth the caffeine lint grew (doc names every
sidecar rule), applied to `bin/`.

## The dynamic-exit convention

`routine-gate`, the lints, and `routine-selfcheck` end in
`exit "$fails"`-style verdicts — no literal to cross-check. Convention:
a dynamic exit covers exactly the codes 0 and 1, so such a script
documents both (and any additional literal codes it also uses, e.g. a
usage `exit 2`). `routine-tdd green` relays an arbitrary failing
command exit; that is the exit-1 line's prose, not a new code.

## Acceptance is a pointer, not a restatement

Scripts already carry acceptance in two enforced places: spec scenarios
and bats tests. A third copy inside the frontmatter would be a third
thing to drift — the G6 lesson. So the frontmatter points
(`routine-test:`) and the lint verifies the pointer is live (file
exists, names the script). The same reasoning keeps `routine-reads`/
`routine-writes` optional prose: nothing mechanical can hold them
honest yet, so they carry no required weight.

## The manual is computed, never curated

`routine-manual` assembles the catalog from the frontmatter at run
time, the `routine-caffeine-list` move. A curated manual would be the
drifting-prose problem reborn one level up.

## lib/ stays out

Sourced libraries have no usage or exit contract; stretching one schema
over two shapes is how contracts go mushy. A thinner lib schema can be
its own change if retro evidence ever asks for it.
