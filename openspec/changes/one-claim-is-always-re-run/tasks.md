# Tasks — one-claim-is-always-re-run

## 1. The lints name the sample

- [ ] 1.1 Red→green: `routine-spec-lint` names one sampled Evidence
      bullet per run, deterministically from the file's bytes,
      reported and never gating — `test/spec_lint.bats`
- [ ] 1.2 Red→green: `routine-record-lint` names one sampled non-floor
      entry per run across both sections, reported and never gating —
      `test/record_lint.bats`

## 2. The trust rule lifts its prohibition

- [ ] 2.1 Red→green: `agents/analyst.md` — re-verifying the sampled
      bullet never counts as a re-search; trust stays the default —
      pinned in `test/agents_content.bats`
