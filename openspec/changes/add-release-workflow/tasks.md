## 1. Scripted publication

- [ ] 1.1 Red→green: `.github/workflows/release.yml` is dispatchable
      with a tag input, runs `routine-release-check` before any publish
      step, and publishes with `gh release create`; structural bats
      lint pins the order
