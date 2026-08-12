## 1. Fail closed

- [x] 1.1 Red→green: developer gate fails naming the condition when
      `ROUTINE_TICKET_DIR` is unset or no task is `in_progress`

## 2. One root

- [x] 2.1 Red→green: spec-lint and caffeine resolve via `routine_root`;
      fixture roots symlink lib/caffeine/spec-lint and a fixture sidecar
      proves redirection

## 3. Stage evidence

- [x] 3.1 Red→green: `gate.hook`, `gate.hook.absent`, and
      `gate.developer.doc` events emitted per stage outcome

## 4. Lifecycle honesty

- [x] 4.1 Red→green: `routine-unblock [task-id]` releases exactly the named
      task or refuses; conclude prints the archived path
