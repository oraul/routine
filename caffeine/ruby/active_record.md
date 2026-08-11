# caffeine: ruby/active_record

Loaded only when your briefing's manifest names `ruby/active_record`.

The sidecar mechanically rejects: `update_attribute(`, `.all.each`,
`save(validate: false)`, and `default_scope`. Fix, don't argue.

Judgment the sidecar cannot check:

- **Validations are the contract.** Anything that skips them
  (`update_column`, raw SQL updates) needs a comment proving the invariant
  holds another way — prefer `update!` and let failures raise.
- **Query in the model, iterate in batches.** `find_each`/`in_batches` for
  anything unbounded; watch for N+1s and preload (`includes`) what the view
  actually walks.
- **Scopes compose; `default_scope` ambushes.** Named scopes say what they
  do at the call site; a default scope changes every query invisibly,
  including `Model.count` in a console two years from now.
- **Transactions wrap invariants, not conveniences**: group writes that
  must stand or fall together; never do network calls inside one.
- **Locking**: prefer optimistic (`lock_version`) unless contention is
  measured; `with_lock` blocks are short and never call out.
