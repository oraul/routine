## Why

Law 5 names the seam explicitly — app hooks and caffeine sidecars — and
still gets misread, because the sentence before it describes the core in
the same words: "Today that core is bash 3.2 + BSD/GNU coreutils
scripts". Both sides of the boundary are bash scripts, so "it is a bash
script" identifies nothing, and a reader reaching for the fastest
discriminator picks language and lands on the wrong side.

Twice in one day, in this repository, a `bin/` script was placed on the
seam side of Law 5 by the driving session:

- the v0.15.0 release record claimed `routine-render-check` "was written
  in bash, under the seam rule" — caught by the record lint's own
  spot-check before publishing;
- the migration's naming analysis argued that `bin/routine-done` "stays
  bash forever under Law 5", and built a conclusion on it — caught by
  the operator.

Both are the same error. A law that two independent readings get wrong
the same way is not being misread; it is underspecified. The cost is
not academic: the first reading would have shipped a false claim in a
published record, and the second nearly decided the migration's command
grammar on a false premise.

## What Changes

- Law 5 states which side a file is on by **location**, not by
  language: everything under `bin/` and `lib/` is core and is destined
  for the binary; the seam is exactly `runs/<app>/hooks/<gate>.sh` and
  the caffeine sidecars.
- Law 5 says plainly that a core script being written in bash today is
  a fact about the migration's progress, never a claim about which side
  of the seam it sits on.
- The `guidance` capability requires those statements and pins them,
  the same way it pins the rest of the law.

## What is deliberately not built

- No change to where the boundary actually falls. This change moves no
  file across it and does not revisit what the seam is for; it makes
  the existing boundary say which side a given file is on.
- No lint that classifies a file as core or seam. The law becoming
  unambiguous is what this change is; a script deciding it would need a
  reason to exist beyond two prose misreadings, and does not have one
  yet. The earning condition is a misclassification that survives
  review rather than being caught in it.
