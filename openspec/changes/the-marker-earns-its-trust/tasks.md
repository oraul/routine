# Tasks — the-marker-earns-its-trust

## 1. The lint checks the citation

- [ ] 1.1 Red→green: `routine-spec-lint` fails a non-floor Questions
      bullet whose ruled marker cites an answer no `approve.md` entry
      records (missing file included), naming the bullet and the
      missing ruling, while a marker citing a recorded `A<n>:` passes —
      `test/spec_lint.bats`

## 2. The ruling is probed before it is baked

- [x] 2.1 Red→green: the analyst's reconciliation rule extends the
      refutation obligation to overrides — probe implementability
      where the target can refute it, record the attempt either way,
      return a refuted ruling with the probe quoted —
      `agents/analyst.md`, pinned in `test/agents_content.bats`
