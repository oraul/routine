## 1. The grammar admits the second heading

- [x] 1.1 Red→green: `routine-spec-lint` accepts
      `## Characterization: <label>` headings; a task satisfies the
      scenario requirement with at least one heading of either kind,
      and a task with neither still fails naming the rule

## 2. The audit covers characterization through the gate

- [x] 2.1 Red→green: `routine-audit` demands no `tdd.green` for a task
      whose labels are all characterization (its passing developer gate
      is the coverage, and a skipped gate remains a violation), keeps
      the per-label green demand for every `## Scenario:` label, and
      passes the aborted 0002-shaped record it previously refused

## 3. The contracts name the heading

- [x] 3.1 Red→green: the analyst emits `## Characterization:` for
      green-at-birth pins and the developer routes them to the ordinary
      suite by name — pinned in agents_content.bats
