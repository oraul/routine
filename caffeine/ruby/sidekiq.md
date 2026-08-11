# caffeine: ruby/sidekiq

Loaded only when your task's manifest names `ruby/sidekiq`.

The sidecar mechanically rejects: `include Sidekiq::Worker`, keyword
arguments to `perform_async`/`perform_in`/`perform_at`, `sleep` inside job
classes, and `sidekiq_options retry: false`. Fix, don't argue.

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
