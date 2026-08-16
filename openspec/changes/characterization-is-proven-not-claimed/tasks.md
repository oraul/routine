## 1. A birth claim is proven, not asserted

- [x] 1.1 Red→green: `routine-tdd characterize <scenario> -- <cmd>`
      records the pass as evidence when the command succeeds, and
      refuses when it fails — the claim "green at birth" checked the way
      `red` checks its own claim

- [x] 1.2 Red→green: a refused `characterize` persists the command's
      **verbatim** output to the task's own script-owned log, truncated
      per run, so the analyst reads what actually printed rather than a
      paraphrase

## 2. The return carries what the analyst needs to patch

- [ ] 2.1 Red→green: `routine-defect` attaches the captured failure to
      the task's defect record when one exists, and still records a
      return when none does — a defect from a source other than a
      characterization must not be refused for lacking one

## 3. The contracts say it

- [ ] 3.1 Red→green: `agents/developer.md` instructs the characterize
      phase, states that a red characterization is a defective spec
      rather than work, and requires the defect reason to state what was
      implemented and why — pinned in `test/agents_content.bats` on a
      word absent from the file today

- [ ] 3.2 Red→green: `agents/analyst.md` names the captured failure
      among the files a re-entering analyst reads, and
      `skills/routine/SKILL.md`'s revise payload names its path — pinned
      the same way

- [ ] 3.3 Red→green: `agents/developer.md` instructs the narrowest
      implementation per scenario and names the misreading — a later
      scenario passing at birth means an earlier one took too much, not
      that a characterization was found

## 4. The developer redoing a task can see the patch

- [ ] 4.1 Red→green: `agents/developer.md`'s closed context list admits
      the task's own `defect.md` when present — today it names the file
      only where the developer *writes* it, so a redoing developer may
      not read why its task came back

- [ ] 4.2 Red→green: the re-served rule distinguishes the two cases it
      currently conflates — an **interruption** leaves partial work and
      the same text, a **defect return** leaves no work and amended
      text, and the second is read before writing rather than diffed
      against the target

- [ ] 4.3 Red→green: `agents/analyst.md` writes the patch note into the
      returned task itself — what the defect invalidated and what
      changed in response. The `## Reconciliation` line it already
      writes lives in `grounding.md`, which is outside the developer's
      closed list, so today the account exists where the reader cannot
      reach it
