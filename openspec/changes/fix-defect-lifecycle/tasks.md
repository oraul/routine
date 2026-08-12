## 1. Per-episode revise budget

- [x] 1.1 Red→green: the analyst gate counts only `spec.lint` failures
      after the most recent `spec.defective` line; 4 lifetime failures
      with a later defect return and 1 subsequent failure passes

## 2. Defect history appends

- [x] 2.1 Red→green: `routine-defect` appends timestamped entries; two
      returns on one task keep both reasons

## 3. Scripted abort

- [ ] 3.1 Red→green: `bin/routine-abort` refuses without a reason,
      writes `abort.md`, emits `ticket.abort`, archives the ticket with
      artifacts intact, prints the path; the skill's exhausted branch
      calls it
