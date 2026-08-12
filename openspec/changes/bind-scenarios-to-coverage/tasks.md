## 1. Labels and non-empty manifests in the lint

- [ ] 1.1 Red→green: `routine-spec-lint` rejects a task without a
      `## Scenario: <label>` heading and a manifest without topics;
      lint and gate fixtures carry both

## 2. Coverage in the audit

- [ ] 2.1 Red→green: `routine-audit` requires one passing `tdd.green`
      per labeled scenario in every done task's file (hash-suffixed
      records match); audit and conclude fixtures carry labels

## 3. The agents speak the labels

- [ ] 3.1 Red→green: the analyst emits `## Scenario: <label>` headings
      and never an empty manifest (`testing/tdd` is the floor); the
      developer records evidence under the task's labels verbatim —
      pinned in `test/agents_content.bats`
