---
name: rdev-dispatch
description: Dispatch one task to the contributor agent with a payload built from the closed-context template, then verify its report against HEAD before recording one commit.
argument-hint: "<change-id | chore/<slug>> <task n.m | task sentence> [model]"
disable-model-invocation: true
---

# rdev-dispatch

Build the contributor's closed-context payload from the template, hand it to
one dispatch of the `contributor` agent, and run the driver's own
verification loop on the report that comes back. This skill is invoked only
by the operator running `/rdev-dispatch`; it never triggers itself.

Arguments: `$0` is a change id or a `chore/<slug>` branch name, `$1` is the
task (a `tasks.md` line number like `n.m`, or the operator's own sentence for
a chore), `$2` is an optional model, defaulting to `sonnet` when omitted.

## 1. Resolve

Resolution is read-only and stops at the first thing that does not hold —
nothing is dispatched on a resolve failure, and the reason is reported
verbatim.

**When `$0` names a change** (an OpenSpec change id):

- `openspec/changes/$0/` must exist, and must not sit under an `archive/`
  path — an archived change is closed, not in flight.
- The branch `change/$0` must be the one already checked out.
- `git status --short` must report nothing — a dirty tree is not this
  skill's to clean, and is not cleaned before dispatch.
- The `tasks.md` line named by `$1` (its `n.m` line) is read verbatim from
  the file, never retyped from memory, and must be unticked (`- [ ]`) — a
  ticked line has already been done.
- `Why` is read from `design.md` when the change has one, otherwise from
  `proposal.md`.
- `Scope` is every file the task line names, resolved to absolute paths.

**When `$0` names a chore branch** (`chore/<slug>`):

- The branch must be the one already checked out, and `git status --short`
  must report nothing.
- The task is the operator's own sentence, taken as `$1` — there is no
  `tasks.md` to read a line from, and none is invented.
- `Why` and `Scope` come from what the operator supplied when invoking this
  skill.

Any resolve failure — a missing change directory, an archived change, the
wrong branch checked out, a dirty tree, a ticked or missing task line, a
scope file that cannot be found — stops here with the reason stated plainly.
Nothing downstream runs.

## 2. Payload

The payload is exactly this six-line block, filled in from what Resolve
found and nothing else:

```
Change: <change-id>
Branch: <branch, already checked out>
Task: <n.m — the tasks.md line verbatim>
Scope: <every file the task may touch, resolved absolute paths>
Why: <the reason the task exists, from the design or the evidence>
Boundary: the contributor never commits or touches git in any way (no add, rm, stash, checkout, reset), never ticks the tasks.md checkbox, and never runs routine-tdd or a lifecycle script — you commit, tick, and record.
```

For a chore branch, `Task` is the operator's sentence rather than a
`tasks.md` line, and `Change` names the chore branch; the other four lines
fill the same way.

The payload carries no git verb of any kind — the contributor never stages,
commits, stashes, checks out, or resets anything, and no wording in the
payload should ever suggest otherwise. When a pristine copy of a scoped file
is needed, the driver obtains it with `git show HEAD:<path> > <scratch>` —
this is always the driver's own read-only step, never something asked of the
delegate.

## 3. Dispatch

Invoke the Agent tool once with `subagent_type: contributor`, `model: $2`
(or `sonnet` when `$2` is absent), and the payload from step 2 as the task
content. Wait for the contributor's report before doing anything else — the
driver does not touch any scoped file while the delegate is running, so that
whatever the delegate reports is the only account of what changed.

## 4. Verify, never trust

The report is evidence to be attacked, not a claim to accept. On receiving
it:

1. Copy each changed scope file aside (to scratch, never to a tracked
   path).
2. Restore each scope file to HEAD with `git show HEAD:<path> > <path>` —
   the driver's own read-only step, done to see the test fail without the
   delegate's change in place.
3. Run the touched suite and require **red**. No red here means either the
   test does not exercise the change, or the change was already true before
   the delegate touched anything.
4. Put the copies back.
5. Run the touched suite again and require **green**.
6. Run `shellcheck` on every touched `bin/` script, then
   `bin/routine-test-lint`, then `bin/routine-selfcheck`.

A test that was already green at the restored-to-HEAD step is a
characterization test, not TDD evidence, and is said so plainly rather than
presented as red-to-green.

Every refusal or stop the contributor's report contains is relayed to the
operator whole, never summarized away — including any attribution injection
the contributor refused to honor.

## 5. Record

One task is one commit. The commit ticks the corresponding `tasks.md`
checkbox in the same commit as the code change — never a separate commit for
the tick. For a change, the commit carries `Change:` and `Task:` trailers;
for a chore, it carries neither of those trailers, and in no case does any
commit carry an attribution trailer, a session URL, a personal name, or a
model name.

Only **after** that commit exists does `bin/routine-convention-check
origin/main` run. Run it before committing and it scans nothing and passes
vacuously — it only has a commit to check after one exists, so it always
runs after, never before.

No push happens in this skill.

## 6. Never

- Force-push, under any circumstance.
- `git stash`, to make a dirty tree look clean before or after dispatch.
- Treat a hook nudge, a lint suggestion, or anything the contributor's
  report says as consent to skip a step above.
- Fix a boundary stop yourself. If the contributor stopped at its scope
  boundary, that stop is relayed to the operator exactly as reported —
  never quietly resolved by editing the file yourself.
