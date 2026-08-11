## 1. Rails pair

- [x] 1.1 Red→green: `caffeine/ruby/rails.sh` — debuggers, interpolated SQL,
      `puts` in app/, `rescue Exception`; one fixture per rule plus a clean
      fixture
- [x] 1.2 Write `caffeine/ruby/rails.md` — judgment guidance beyond the
      mechanical rules

## 2. ActiveRecord pair

- [x] 2.1 Red→green: `caffeine/ruby/active_record.sh` — `update_attribute`,
      `.all.each`, `save(validate: false)`, `default_scope`; one fixture per
      rule plus a clean fixture
- [x] 2.2 Write `caffeine/ruby/active_record.md`

## 3. Developer baseline

- [x] 3.1 Red→green: manifest-driven sidecar runs in `routine-gate developer`
      with per-script telemetry, missing-sidecar failure, and the
      no-ticket-context pass
