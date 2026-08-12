## 1. Run-level checks

- [x] 1.1 Red→green: audit requires `ticket.new` first and a passing
      `gate.analyst`, reporting all violations in one run

## 2. Per-task checks

- [ ] 2.1 Red→green: every done task shows next, red-before-green per
      scenario, a passing developer gate, per-topic sidecar/doc
      evidence, and done

## 3. Balance

- [ ] 3.1 Red→green: block/unblock events balance per task

## 4. Conclude fails closed

- [ ] 4.1 Red→green: `routine-conclude` refuses (with evidence) unless
      the audit passes; fixtures gain honest protocol telemetry
