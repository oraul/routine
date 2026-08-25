# Tasks — the-approval-binds-what-it-blessed

## 1. The question form joins the grammar

- [x] 1.1 Red→green: `routine-spec-lint` refuses a non-floor
      `## Questions` bullet without ` — provisional: <reading>`,
      per line, floor exempt — `test/spec_lint.bats`

## 2. The proceed is earned per question and fingerprinted

- [x] 2.1 Red→green: `lib/approve.sh` provides the shared fingerprint;
      `routine-approve` requires `<n>: <answer>` coverage of the open
      questions, refuses missing or unknown indices with nothing
      recorded, and writes a `Q<n>`/`A<n>` + `Approved-at:` entry on
      every proceed — `test/approve.bats`
- [ ] 2.2 Red→green: `routine-audit` recomputes the fingerprint when
      the last entry carries one and counts a mismatch as a violation;
      fingerprint-less tickets skip the rule — `test/audit.bats`

## 3. The contracts follow the mechanism

- [ ] 3.1 Red→green: the analyst's absence clause tightens (approve.md
      absent means approve has not yet run) and the skill's approve
      phase teaches the `<n>: <answer>` form — pinned in
      `test/agents_content.bats`
