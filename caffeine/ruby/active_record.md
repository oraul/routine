# caffeine: ruby/active_record

Loaded only when your briefing's manifest names `ruby/active_record`.

The sidecar mechanically rejects: `update_attribute(`, `.all.each`,
`save(validate: false)`, and `default_scope`. Fix, don't argue.

## The skeleton

```ruby
# app/models/order.rb — the model owns its queries, its invariants, and
# nothing about the web.
class Order < ApplicationRecord
  belongs_to :customer
  has_many :lines, class_name: 'OrderLine'

  # Named scopes compose and read at the call site; this is why
  # default_scope is banned — it changes every query invisibly.
  scope :open,    -> { where(closed_at: nil) }
  scope :recent,  -> { order(created_at: :desc) }

  # Validations are the contract: anything skipping them (update_column,
  # raw SQL) needs a comment proving the invariant holds another way.
  validates :number, presence: true, uniqueness: true

  # Reads the view walks get preloaded by the caller:
  #   Order.open.includes(:lines, :customer) — includes at the query site,
  # not buried here, so the N+1 fix is visible where the loop is.

  def close!(clock: Time.zone)
    # Transactions wrap invariants that stand or fall together — and never
    # contain network calls; enqueue after commit.
    transaction do
      update!(closed_at: clock.now)
      lines.find_each(&:archive!)   # unbounded set ⇒ batched, always
    end
  end
end
```

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
