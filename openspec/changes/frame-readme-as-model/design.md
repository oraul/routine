# Design — frame-readme-as-model

## The pipeline is a diagram of authority

A pipeline drawn as boxes and arrows would say what most READMEs say:
data goes in, phases happen, output comes out. That is not the
interesting thing about this loop, and it is not what a reader would
come here to take.

What is worth transferring is **who is answerable at each step**. Three
actors with different graders: a session holding the requirement, an
agent whose work a test grades, and a human who is the only one that can
say proceed. The pipeline shows the handoffs and, at each one, what
would happen if the wrong actor made that call.

So the diagram's columns are phase, decider, and what stops the run —
because the last column is the part that makes the model real rather
than aspirational.

## Keeping the install, demoting it

Deleting the install instructions would overcorrect. The code runs, the
suite is green, and someone who wants to watch the loop move should be
able to. What is wrong is its position: an `## Install` heading early in
a README is a call to action, and the call to action here is *read the
model*, not *adopt the plugin*.

It moves below the model and gains one honest sentence about what
running it will and will not give you.

## What transfers and what does not

A reader taking this into another project needs to know which parts are
load-bearing and which are this repository's accidents. Bash and bats are
accidents — the same model works with any language and any test runner.
The separations are not: script-owned state, evidence that outlives the
session, a gate whose exit code is the decision, and the rule that the
record is never delegated.

Naming that explicitly is the difference between a README that documents
a tool and one that hands over a model.

## Non-Goals, with what would earn each

- **Removing the install instructions.** The thing runs; hiding that
  would be its own dishonesty. Earned only if the code stops working.
- **An ASCII art rendering of the full state machine.** The five phases
  and their deciders fit in a table; a larger drawing would carry less
  and rot faster.
- **Rewriting the capability map.** It is accurate and it is the
  strongest evidence that the model was actually built rather than
  described.
- **Claiming the model is proven in production.** It is not. One
  concluded run exists against one target. The README says the loop is
  built and green, never that it is battle-tested.
