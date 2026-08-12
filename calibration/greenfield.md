# calibration: greenfield

Nothing exists yet; every decision you take quietly becomes a convention.
Structure is the first deliverable.

## Analyst

- The `## Contracts` section is the contract: inputs, outputs, invariants,
  and the boundaries to the rest of the system — the lint refuses a
  greenfield without it. Implementation freedom is the developer's; the
  contract is not.
- First briefing establishes the skeleton — layout, entry points, the first
  end-to-end walking path. Later briefings flesh it out feature by feature.
- Prefer more, smaller scenarios: with no existing behavior to lean on, the
  scenarios are the only description of the system there is.
- Name things from the domain, not the technology; those names outlive the
  code.

## Developer

- Walking skeleton first: the thinnest end-to-end slice that proves the
  structure, then widen. Depth before breadth is how greenfield rots.
- Every choice you make (layout, naming, test structure) will be copied by
  every later task — make the first instance exemplary, not expedient.
- Resist abstraction: two concrete cases before any helper; the codebase
  has no evidence yet to earn one (the same law this repo is built under).
- The bootstrap order is fixed: `routine-scaffold` halts until the human
  seeds `developer.sh`, so in a greenfield it starts as the thinnest
  truthful check the target can already run (a syntax check beats a
  hopeful `true`). The first task then wires real lint and test tooling
  and upgrades `developer.sh` to call it — that upgrade is part of the
  task's acceptance, not an afterthought.
