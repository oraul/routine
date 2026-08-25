# Design — the-replay-moves-only-the-rails

## The worktree is named for the app, on purpose

`routine_app_key` derives the app from the target's toplevel basename,
and every gate, hook path, and telemetry destination hangs off that
key. A worktree named after the replay would silently mint a second
state tree (`runs/<replay-name>/…`) and the preflight gate would
refuse on its missing hooks — measured against `lib/paths.sh` before
this design was written. So the worktree lives at
`runs/<app>/replays/<archived-id>-<sha8>/<app>`: the parent names the
replay, the leaf names the app, and the key resolves to the state tree
the original run used. Replay evidence lands beside the original
app's, under new ticket ids — which is the point: same app, same
rails' state, different rails' vintage.

## Order of operations protects WIP

Preconditions are checked first (requirement, anchor form, anchor
reachability, no existing worktree), the worktree is created second,
and the ticket is allocated last — so the only failure that can leave
state behind is the allocation refusal, and that path removes the
worktree before exiting. The reverse order would leave an empty live
ticket on a worktree failure, which blocks every later allocation
until someone aborts it.

## Only the requirement crosses

The replay copies `requirement.md` byte-identically and nothing else.
Grounding, briefings, tasks, and every judgment are what the current
rails must produce from the same question — copying any of them moves
the answer in with the question and the comparison collapses. The
anchor crosses as a checkout, not a file.

## The waiver is designed to go stale

`ticket.replay` is declared in `lib/roads.txt` waivered — it has never
fired and cannot until an operator starts the first replay run. The
moment one does, `routine-road-check` refuses the waiver as stale,
which is exactly the reminder to drop it: the C2 grammar working as
built.

## Pins and probes

Verified before writing (measured — the commands ran): all four
distinct archived anchors resolve in the target
(`git cat-file -e <sha>^{commit}`); ticket 0001 carries no
`Grounded-at:`; `routine-ticket-new` creates the directory, an empty
`index.tsv`, and the `ticket.new` line, printing the path; `replay`
and `ticket.replay` appear nowhere in `bin/`, `lib/roads.txt`, or the
specs today.
