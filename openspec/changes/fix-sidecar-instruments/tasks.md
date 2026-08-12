## 1. One instrument library

- [x] 1.1 Red→green: `lib/sidecar.sh` with id-bearing `check`,
      directory-based vendor exclusion, and exit-2 internal errors; all
      four sidecars migrate; the caffeine lint reads the new signature

## 2. Repaired patterns, honest rules

- [ ] 2.1 Red→green: the three verified-wrong patterns fixed and the
      rule set upgraded (rails mass-assignment, broadened active_record,
      rspec disabled-examples + full spec/ scope, sidekiq .delay), with
      tripping and near-miss fixtures per changed rule
