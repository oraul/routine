## 1. A pass takes the stale refusal log with it

- [ ] 1.1 Red→green: after a refused `characterize` writes the task's
      `characterize.log`, a later passing `characterize` for the same
      task removes it — red today (the pass path removes only its own
      tmp file), green after
