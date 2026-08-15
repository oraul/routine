# Design — spec-lint-resolves-its-root

## The fix is one line; the pin is the point

Swapping the path for `routine_root()` is trivial and, against the real
corpus, changes nothing — the fallback resolves to the same directory.
A change whose diff does nothing observable is a change that needs its
observable consequence pinned, or nobody can tell it worked.

So the test is not "the script calls `routine_root`" — that pins an
implementation. It is: a fixture `ROUTINE_ROOT` redirects manifest
resolution, so a task naming a topic that exists only in the fixture
passes, and one naming a topic that exists only in the real corpus
fails. That is the capability Law 6 says a hardcoded path costs, and it
was genuinely absent.

## Why this was invisible for so long

`routine-spec-lint` has 26 tests and they all pass. None could reach
this, because reaching it requires exactly the thing the bug prevents.
A hardcoded root is self-concealing: the code path it breaks is the one
a test would need in order to break it.

That is worth recording beyond this fix. The mutation check proved every
suite notices its script dying; it cannot prove a suite reaches every
path, and this is a path no suite could reach.

## Non-Goals, with what would earn each

- **Auditing every script for hardcoded paths.** `routine-script-lint`
  could check that a script sourcing `lib/paths.sh` actually calls
  `routine_root()`. Earned if a second instance is found — one is a
  fix, two is a pattern.
- **Changing what `routine_root()` returns.** Out of scope and load-
  bearing everywhere.
- **Extracting spec-lint's other paths.** Only the caffeine root is
  wrong; the rest already take the ticket directory as an argument.
