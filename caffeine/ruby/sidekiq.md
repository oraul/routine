# caffeine: ruby/sidekiq
<!-- caffeine-topic: ruby/sidekiq -->
<!-- caffeine-applies: sidekiq >=6.3 -->
<!-- caffeine-source: https://github.com/sidekiq/sidekiq/wiki/Best-Practices -->
<!-- caffeine-reviewed: 2026-08-12 -->

Loaded only when your task's manifest names `ruby/sidekiq`. The target's
own conventions outrank this guide where they conflict.

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

  # Retries stay ON. Defaults you are accepting by writing nothing:
  # 25 retries with exponential backoff spanning ~21 days, then the job
  # moves to the Dead set (kept ~6 months, capped). Tune with
  # sidekiq_retry_in / sidekiq_retries_exhausted — never retry: false
  # without a written dead-set plan. retry: 0 (dead immediately) and
  # retry: false (vanishes) are different decisions; know which one you
  # are making.
  def perform(order_id)
    # Arguments are JSON-native positionals: ids and scalars only.
    # Enable Sidekiq.strict_args! in the initializer: modern Sidekiq
    # REFUSES non-JSON arguments loudly. The kwargs trap is concrete:
    # JSON round-trips symbol keys to string keys and Sidekiq splats
    # positionally, so perform(user_id:) raises on execution, hours
    # after the enqueue looked fine.
    #
    # Fetch fresh — the record can have changed or vanished since
    # enqueue; absence is a normal outcome, not an error to retry.
    order = Order.find_by(id: order_id)
    return unless order

    # Idempotency guard: running twice must be safe, because it will
    # happen. Check the end state, not "have I run?".
    return if order.closed?

    order.close!
  end
end

# Enqueue site: many small jobs beat one heroic loop, and the bulk API
# beats N round-trips to Redis — one call, one pipeline.
CloseOrderJob.perform_bulk(order_ids.map { |id| [id] })

# Enqueue AFTER the data is committed, or the job can run against a
# transaction that never lands (the find_by above then hides the bug as
# "absence"). Enqueue in an after_commit hook — or on Rails >=7.2 set
# config.active_job.enqueue_after_transaction_commit and let the
# framework hold the enqueue for you (ActiveJob adapters only).
```

## Judgment

The target's own conventions outrank this skeleton where they conflict.

- **Delivery is honest, not magical.** OSS Sidekiq's basic fetch pops the
  job before running it: a hard kill (OOM, SIGKILL, node loss) LOSES the
  in-flight job — it does not re-run. Sidekiq Pro's super_fetch recovers
  such jobs. On OSS, idempotency protects against *repeats*; you still
  need a reconciliation path for *losses* (a sweeper that re-enqueues
  work the state machine says is missing).
- **Pass ids, not objects.** Arguments are serialized to JSON with string
  keys and may be deserialized hours later; fetch fresh inside `perform`
  and handle absence. If the app enqueues through ActiveJob, GlobalID
  hides this — prefer ids anyway so the argument log stays readable.
- **Small jobs, many jobs, one push.** A job that loops over thousands of
  records should enqueue thousands of jobs via `perform_bulk`; Sidekiq's
  parallelism is the loop, and each small job survives a deploy.
- **`retry: false` needs a story.** Legitimate only when a failure is
  handled some other way (a dead-set monitor via
  `sidekiq_retries_exhausted`, a reconciliation task); write that story
  next to the option or take the 25 retries.
- **Queue names are a latency contract**: put a job on `critical` only if
  someone will notice its latency; everything else earns `default`.
- **Deploys interrupt.** SIGTERM gives jobs ~25 seconds (the -t timeout)
  before a hard stop; long work belongs in checkpointed batches that can
  resume, not one heroic job that dies mid-flight.
