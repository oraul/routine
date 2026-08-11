## 1. Scaffold and ticket allocation

- [x] 1.1 Red→green: `bin/routine-scaffold` creates `runs/<app>/{hooks,tickets}`
      idempotently and halts non-zero naming `developer.sh` until it exists
- [x] 1.2 Red→green: `bin/routine-ticket-new` allocates sequential 4-digit ids
      (scanning active and archived tickets), creates the dir + empty
      `index.tsv`, prints the path

## 2. The task line

- [x] 2.1 Red→green: `routine-next` appends missing tree tasks to the index as
      `pending` in strict file order, never touching existing rows' identity
- [x] 2.2 Red→green: `routine-next` returns the first runnable task and marks
      it `in_progress`; blocked-blocks-the-line and all-done get distinct
      exits
- [x] 2.3 Red→green: `routine-done` marks the `in_progress` task done with a
      fresh `updated_at`
- [x] 2.4 Red→green: `routine-block` refuses without `block.md`;
      `routine-unblock` refuses without `unblock.md`; together they park and
      release the line

## 3. Evidence

- [x] 3.1 Red→green: each lifecycle script emits exactly one `ticket.*`
      telemetry line into the ticket's `telemetry.jsonl`
