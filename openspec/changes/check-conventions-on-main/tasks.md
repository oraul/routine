## 1. The conventions job covers main

- [ ] 1.1 Red→green: `.github/workflows/ci.yml` runs `conventions` on
      both events with a per-event diff base (PR base ref, push
      `event.before`, parent-commit fallback) — pinned by
      `test/ci_workflow.bats`
