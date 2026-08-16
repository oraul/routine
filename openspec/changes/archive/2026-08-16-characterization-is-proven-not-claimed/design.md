# Design — characterization-is-proven-not-claimed

## A third phase, not a fourth script

`characterize` joins `red` and `green` inside `routine-tdd` rather than
becoming its own script. The three are one decision — *did this command
do what the phase claims it should* — differing only in which exit
satisfies them:

| phase | satisfied by | refuses |
| --- | --- | --- |
| `red` | non-zero | a command that passes |
| `green` | zero | relays the command's failure |
| `characterize` | zero | a command that fails |

`characterize` and `green` both require a pass, and are not the same
claim. `green` says *the implementation I just wrote works*;
`characterize` says *this was already true before I touched anything*.
Merging them would lose the distinction the audit depends on — a
characterization needs no covering red, and the audit must keep being
able to tell which is which.

A separate script would also mean a second copy of the ticket-context
guard, the telemetry emission and the scenario validation, for no gain.

## Why the captured output belongs on the record and not in the reason

The obvious cheaper design is to tell the developer to paste the failure
into `routine-defect`'s reason. Run 0005 shows why that is not enough:
the developer paraphrased. It was an accurate paraphrase from a careful
agent, and it still lost the literal text — the exception class, the
message, the assertion diff, the line.

An instruction to paste is prompt-level and therefore never load-bearing
(Law 1). The script already **has** the output in hand at the moment it
refuses. Persisting it there costs nothing and cannot be forgotten,
which is the whole argument for the determinism boundary.

## Where it lands

Beside `defect.md`, in the task's own directory, script-owned like
`lint.log`: written by the script, read by the analyst, never
hand-edited. The task directory rather than the ticket, because the
claim that failed is one task's.

Truncate-per-run rather than append, following `gate.log`: the analyst
needs the failure that caused *this* return, and a growing file makes
the reader guess which entry is current. `defect.md` keeps appending —
that is the human-authored history, and repeated returns are exactly
what a reader wants there.

## What "the developer's context" can and cannot be

Two halves, and only one is mechanizable. Saying so plainly is the point,
because a change that quietly mixes them invites reading the gate as
covering both.

- **Mechanical**: the captured failure is attached — the script writes
  it, so its presence is decidable.
- **Judgment**: what was implemented and why it was coded that way.
  Whether that explanation is any good cannot be decided here, exactly
  as `routine-record-lint` decides a record's form and never its truth.

So the script guarantees the analyst receives the *evidence*; the
contract asks for the *account*. The proposal should not be read as
gating the account.

## The re-serve needs nothing

`routine-next` already re-serves a returned task to a fresh, stateless
developer, and `agents/developer.md` already carries the re-served-task
rule: read the uncommitted diff first, re-record under the identical
label and command. Run 0005 exercised all of it — 01-02 returned,
amended, re-served, green.

The change adds context to what that developer receives. It adds no
road.

## Non-Goals, with what would earn each

- **Auto-demoting a failed characterization to a scenario.** The script
  would be guessing which of two things is wrong: the claim, or the code
  it was claimed against. Run 0005's own case proves the ambiguity —
  the honest fix was neither, it was amending the requirement above the
  task. Earned never, most likely; this is the analyst's judgment.
- **Requiring a characterization to be proven at analyst time.** The
  analyst cannot run the target's suite — it grounds by reading, and
  giving it a test-running road would blur the one boundary that keeps
  the two agents honest.
