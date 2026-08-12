# caffeine: ruby/sidekiq
<!-- caffeine-topic: ruby/sidekiq -->
<!-- caffeine-applies: sidekiq >=6.3 -->
<!-- caffeine-source: https://github.com/sidekiq/sidekiq/wiki/Best-Practices -->
<!-- caffeine-reviewed: 2026-08-12 -->

Loaded only when your task's manifest names `ruby/sidekiq`.

The sidecar mechanically rejects (fix them, don't argue with them):

- legacy include Sidekiq::Worker (use Sidekiq::Job)
- keyword args to perform_* (arguments must be JSON-native)
- sleep inside a job pins a Sidekiq thread
- retry: false silently drops failures (state the dead-set plan)
- Sidekiq delayed extensions were removed (use a job class)

## The skeleton

```ruby
# app/jobs/close_order_job.rb — a job is a thin, idempotent shell around
# one domain call.
class CloseOrderJob
  include Sidekiq::Job   # never the legacy Sidekiq::Worker

  # Queue is a latency promise; default unless someone will page over it.
  # Retries stay ON: at-least-once delivery is the platform's contract,
  # and retry: false silently drops failures (state the dead-set plan if
  # you ever must).
  sidekiq_options queue: :default

  # Arguments are JSON-native positionals: ids and scalars only. Objects
  # and keyword args corrupt silently on the round-trip through Redis.
  def perform(order_id)
    # Fetch fresh — hours may have passed since enqueue; the record can
    # have changed or vanished, and absence is a normal outcome, not an
    # error to retry forever.
    order = Order.find_by(id: order_id)
    return unless order

    # Idempotency guard: running twice must be safe, because it will
    # happen. Check the end state, not "have I run?".
    return if order.closed?

    order.close!
  end
end

# Enqueue site: many small jobs beat one heroic loop — Sidekiq's
# parallelism IS the loop, and each job survives a deploy.
order_ids.each { |id| CloseOrderJob.perform_async(id) }
```

Judgment the sidecar cannot check:

- **Jobs are idempotent or they are bugs.** Sidekiq guarantees at-least-once
  execution; every job must survive running twice (guard with state checks
  or unique keys, not hope).
- **Pass ids, not objects.** Arguments are serialized to JSON and may be
  deserialized hours later; a record can change or vanish in between —
  fetch it fresh inside `perform` and handle its absence.
- **Small jobs, many jobs.** A job that loops over thousands of records
  should enqueue thousands of jobs; Sidekiq's parallelism is the loop.
- **`retry: false` needs a story.** Legitimate only when a failure is
  handled some other way (a dead-set monitor, a reconciliation task);
  write that story next to the option or take the retries.
- **Queue names are a latency contract**: put a job on `critical` only if
  someone will notice its latency; everything else earns `default`.
- **Time limits**: long-running work belongs in batches with checkpoints,
  not one heroic job that dies at deploy time.
