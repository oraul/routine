# tickets Specification (delta)

## MODIFIED Requirements

### Requirement: A replay moves only the rails
`bin/routine-replay <archived-ticket-dir>` SHALL create a fresh ticket
whose `requirement.md` is byte-identical to the archived one, against a
target worktree on a replay-named branch at the archived grounding's
`Grounded-at` anchor, because the claim "the rails improved" is
uncontrolled while the requirement's wording and the target's state
move with them — the replay holds both still so only the rails differ.
The worktree SHALL live under `runs/<app>/replays/<archived-id>-<sha8>/<app>`,
so the app key every gate derives from the target resolves to the same
state tree as the original run. The new ticket SHALL record its
provenance in `replay.md` — the archived ticket replayed, the anchor,
and the worktree path — and SHALL carry one `ticket.replay` telemetry
line after its `ticket.new`. The script SHALL print the archived run's
final event beside the new paths, so the operator knows what outcome
the replay is being compared against. It SHALL refuse, creating
nothing lasting: an archived ticket missing its `requirement.md` or a
well-formed anchor (runs that predate the anchor rule cannot be
replayed honestly and the refusal says so); an anchor the target
cannot resolve; a replay worktree that already exists; and a refused
ticket allocation — in that case the worktree it created is removed
before exiting, because a replay that failed to allocate must not
leave state a later run trips over. Allocation itself SHALL go through
`routine-ticket-new`, so WIP stays 1 and ids are never reused. The
comparison of outcomes SHALL remain the operator's judgment recorded
in retros and release records — the script holds variables still and
decides nothing about what the difference means.

#### Scenario: The question is held still
- **WHEN** `routine-replay` runs against an archived ticket with a
  reachable anchor
- **THEN** the new ticket's `requirement.md` is byte-identical to the
  archived one, the worktree's HEAD equals the anchor, `replay.md`
  names the archived ticket, the anchor, and the worktree, and the
  ticket's telemetry carries `ticket.replay`

#### Scenario: A run without an anchor cannot be replayed
- **WHEN** the archived grounding carries no well-formed
  `Grounded-at:` line
- **THEN** the script exits non-zero naming the missing anchor, and no
  worktree or ticket is created

#### Scenario: An unreachable anchor is refused
- **WHEN** the anchor is well-formed but the target cannot resolve it
- **THEN** the script exits non-zero naming the anchor

#### Scenario: A refused allocation leaves nothing behind
- **WHEN** a ticket is already live and `routine-ticket-new` refuses
- **THEN** the replay propagates the refusal and the worktree it
  created is removed

#### Scenario: The archived outcome is shown for comparison
- **WHEN** a replay ticket is created
- **THEN** the output names the archived run's final telemetry event

#### Scenario: The worktree passes the preflight
- **WHEN** a replay worktree is created
- **THEN** its HEAD is a branch (`replay/<archived-id>-<sha8>`) at the
  anchor commit, because the preflight gate refuses a detached HEAD —
  the first live replay was refused exactly there and had to branch by
  hand
