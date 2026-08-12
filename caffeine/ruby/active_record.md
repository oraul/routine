# caffeine: ruby/active_record
<!-- caffeine-topic: ruby/active_record -->
<!-- caffeine-applies: rails >=7.0 -->
<!-- caffeine-source: https://guides.rubyonrails.org/active_record_querying.html -->
<!-- caffeine-reviewed: 2026-08-12 -->

Loaded only when your task's manifest names `ruby/active_record`. The
target's own conventions outrank this guide where they conflict.

The sidecar mechanically rejects (fix them, don't argue with them):

- update_attribute/update_column skip validations (use update!)
- unbatched iteration (use find_each)
- save(validate: false) skips validations
- default_scope (prefer named scopes)

## The skeleton

```ruby
# app/models/order.rb — the model owns its queries, its invariants, and
# nothing about the web.
class Order < ApplicationRecord
  belongs_to :customer            # required by default since Rails 5 —
                                  # it adds a presence validation; opt
                                  # out explicitly with optional: true.
  has_many :lines, class_name: 'OrderLine', dependent: :destroy

  # Named scopes compose and read at the call site; this is why
  # default_scope is banned — it changes every query invisibly.
  # CAUTION where they meet batching: find_each ignores any order a
  # scope sets (it forces primary-key batches and logs a warning), so
  # Order.recent.find_each silently drops the ordering below.
  scope :open,    -> { where(closed_at: nil) }
  scope :recent,  -> { order(created_at: :desc) }

  # Validations are the contract — but uniqueness validated in Ruby is a
  # SELECT-then-INSERT race: two concurrent requests both pass. It is
  # only a real contract with a matching unique index
  # (add_index :orders, :number, unique: true) and a rescue for the
  # ActiveRecord::RecordNotUnique the index raises when the race fires.
  validates :number, presence: true, uniqueness: true

  # N+1, the worked pair — the loop below fires one query PER ORDER:
  #   Order.open.each { |o| puts o.customer.name }
  # Preload what the loop walks, at the query site where the loop is:
  #   Order.open.includes(:customer).each { |o| puts o.customer.name }
  # includes picks the strategy (preload = separate queries,
  # eager_load = one LEFT JOIN); reach for those names directly when you
  # must force one. joins alone loads nothing — it filters.
  # strict_loading! (Rails 6.1+) turns a lazy walk into a raise, making
  # N+1 a test failure instead of a production graph.

  def close!(clock: Time.zone)
    # The transaction wraps exactly the invariant: rows that stand or
    # fall together. Never network calls inside; enqueue after commit.
    transaction do
      update!(closed_at: clock.now)
    end
    # Batch OUTSIDE the transaction: one transaction around an unbounded
    # scan holds locks and WAL for the whole run — it defeats the
    # batching. Each batch commits alone, so archive! must be idempotent
    # (a crash mid-scan means a re-run, and that must be safe).
    lines.in_batches(of: 500) do |batch|
      transaction { batch.each(&:archive!) }
    end
  end
end
```

## Judgment

The target's own conventions outrank this skeleton where they conflict.

- **Validations are the contract.** Anything that skips them
  (`update_column`, `update_all`, `delete_all` — which also skip
  callbacks — raw SQL) needs a comment proving the invariant holds
  another way; prefer `update!` and let failures raise. `unscoped` is
  the `default_scope` escape hatch and reads as a lie at the call site.
- **Query in the model, iterate in batches.** `find_each`/`in_batches`
  for anything unbounded; preload (`includes`) what the view actually
  walks, and let `strict_loading` fail the test suite when someone
  forgets.
- **Scopes compose; `default_scope` ambushes.** Named scopes say what
  they do at the call site; a default scope changes every query
  invisibly, including `Model.count` in a console two years from now.
- **Transactions wrap invariants, not conveniences**: bounded writes
  that stand or fall together. Nested `transaction` blocks join their
  parent unless `requires_new: true` — an inner rollback without it
  rolls back nothing by itself.
- **Locking, actionably.** Optimistic locking needs an integer
  `lock_version` column (default 0) and raises
  `ActiveRecord::StaleObjectError` — rescue it and retry or surface the
  conflict. `with_lock` is `SELECT ... FOR UPDATE` in its own
  transaction: keep the block short and never call out of process.
