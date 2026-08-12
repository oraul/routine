## 1. The scripted checkpoint

- [x] 1.1 Red→green: `routine-approve` refuses without a passing
      `gate.analyst`, appends notes to `approve.md`, emits
      `ticket.approve`

## 2. The audit demands it

- [x] 2.1 Red→green: a passing `ticket.approve` joins the run-level
      audit checks; fixtures comply

## 3. The skill records the human

- [x] 3.1 Red→green: phase 3 calls `routine-approve` with the human's
      remarks
