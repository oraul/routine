## Why

The retro is the feedback loop the Laws depend on: "abstractions are
earned from retro evidence" means every judgment about what to build
reads these numbers. Three of them are wrong, and the panel that was
just reverted inherited all three from here rather than inventing
them — deleting the copy left the original shipping.

- **Deliberate non-zero exits are counted as failures.** A `tdd.red`
  whose command fails *is the protocol working* — the red that passes
  is the violation — yet every red counts as a failure. `ticket.next`
  exits 3 and 4 (the line is blocked; every task is done) are normal
  protocol outcomes counted the same way. So the failure columns
  overstate, and the reader learns to discount them.
- **The script-failure list contains scenario names.** For `tdd.*`
  records the script field carries the scenario label, not a script
  path, so scenarios appear in a list that claims to name scripts.
- **A refused block starts a timer that never stops.** Block pairing
  reads `ticket.block` without checking its exit code, but
  `routine-block` refuses with a non-zero exit — and a refusal
  recorded as a block leaves a phantom "still blocked" entry forever.
- **The deepening queue ranks by rate with no denominator.** One run
  that failed once (1.00) outranks two hundred runs that failed eighty
  times (0.40), which is backwards for a queue that answers "which
  topic needs work next".

## What Changes

- **Failure classification becomes explicit per event**, never a
  blanket non-zero test: for `tdd.red` a non-zero exit is the expected
  outcome and a *zero* exit is the anomaly worth naming; for
  `ticket.next` exits 3 and 4 are outcomes while 1 and 2 are failures;
  every other event keeps non-zero as failure.
- **Script failures count only records whose script field is a path**
  (`bin/…` or `caffeine/…`), so the section names what it claims to.
- **Block pairing requires a passing transition** — a refused block is
  not a block, and cannot leave a phantom.
- **The deepening queue ranks by failure count**, with the rate and
  run count shown beside it. Count is the honest measure of
  accumulated pain and needs no arbitrary sample-size floor; a single
  unlucky run can no longer head the queue.

## Capabilities

### Modified Capabilities

- `retro`: failure classification, script-failure keying, block
  pairing, and the queue's ranking are stated and corrected.

## Impact

- Modified: `bin/routine-retro`, `test/retro.bats`.
