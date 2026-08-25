# Proposal — the-scrub-becomes-an-exit-code

## Why — a hard rule held by hands has been exercised seven times

Every pull request created from this environment arrives with a
session URL injected into its footer, and the hard rule — no session
URLs, ever — is currently enforced by reading the body back and
editing it by hand. The v0.11.0 record's Gate entry counted five
scrubs and named the queued script; #106 and #107 made it seven
(measured: both bodies read back this session carried
the injected session URL until edited). Seven for seven the hand
has caught it. A rule that fails once rewrites history and rotates
credentials, and vigilance is the one gate in this repository that
is not an exit code.

## What changes

- **`bin/routine-pr-body-check <file>`** scans a saved pull request
  body for the sensitive shapes and exits non-zero naming each hit's
  line number and pattern class — never echoing the matched text,
  because the check's output travels where the body was about to.
  Clean body, exit 0; missing or unreadable file, exit 2. One
  `harness.prbody` telemetry line per run; the road declared in
  `lib/roads.txt` and walked live before this change ships.
- **The pattern list gets one implementation.** The sensitive shapes
  move from `routine-convention-check`'s inline string to
  `lib/sensitive.sh`, sourced by both checks — two lists would drift,
  and a pattern added to one hunt but not the other is a hole with a
  green board. The convention check's behavior does not change; its
  exclusion list adds the shared library, which must name what it
  hunts.

## What is not built

- **No fetch.** The script reads a file; whoever holds API access
  saves the body first. A script that fetched would need credentials
  and a network, and every gate here judges local state.
- **No footer-presence rule.** The attribution footer is practice,
  not a hard rule with an incident history; the check hunts what
  leaks, not what beautifies. Earning condition: a shipped body
  missing the footer that someone actually cares about.
- **No auto-scrub.** The check refuses; the rewrite stays the
  author's, because a script that edits prose it does not understand
  is how a body loses its meaning with a green exit code.

## Impact

- new: `bin/routine-pr-body-check`, `lib/sensitive.sh`,
  `test/pr_body_check.bats`
- modified: `bin/routine-convention-check` (sources the shared lib,
  behavior unchanged), `lib/roads.txt` (declares `harness.prbody`)
- specs: `conventions` (Sensitive patterns fail the check — MODIFIED;
  The pull request body is checked before it ships — ADDED)
