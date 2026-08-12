## Why

The council read every guide against its authoritative source and found
teaching that is false or dated: sidekiq's "objects corrupt silently"
predates `strict_args!`, "at-least-once guaranteed" is wrong for OSS
(SIGKILL loses in-flight jobs), and its skeleton demonstrates the
enqueue pattern the wiki says to replace; active_record teaches a
uniqueness validation with no unique index (the classic race) and
batches inside a transaction while its own `scope :recent` collides
with `find_each`'s order-discard; rails' skeleton is half `...`, skips
the authorize step its own rule demands, and contradicts both itself
and `architecture/hexagonal.md`; rspec never names `let!`, shared
examples, verifying doubles, or `build_stubbed` — and recommends
Timecop while its sidecar says travel helpers. The two architecture
docs are aphorisms with zero examples. No arbitration exists between
topics that can legally share one manifest.

## What Changes

- **sidekiq.md tells the truth**: `Sidekiq.strict_args!` and the
  symbol→string key round-trip replace "corrupts silently"; OSS
  delivery semantics stated honestly (basic fetch loses jobs on
  SIGKILL; Pro `super_fetch` recovers); `perform_bulk` replaces the
  loop; the retry numbers land (25 retries, ~21 days, the Dead set,
  `sidekiq_retries_exhausted`); the transaction/enqueue race and
  `after_commit` appear.
- **active_record.md closes its races**: uniqueness requires a matching
  unique index; batching moves outside the transaction; the
  `find_each`-discards-`order` warning lands next to the scope it
  collides with; N+1 gets a worked bad/good pair with
  `includes`/`strict_loading`.
- **rails.md becomes copyable**: the `Orders::Create` body and its
  Result object written out, `authorize` in the action, and one
  paragraph adjudicating model-vs-service — with an explicit arbitration
  note against `architecture/hexagonal` for manifests carrying both.
- **rspec.md gains its missing tools**: `let` vs `let!` (the
  never-invoked lazy-`let` trap), `shared_examples` as port-contract
  tests, `instance_double` as the named replacement for the banned
  `any_instance`, `build_stubbed` over `create`, and travel helpers
  aligned with the sidecar's own message.
- **The architecture docs teach**: oop gains a before/after
  conditional→polymorphism extraction, the actor-based SRP reading, the
  rule-of-three brake, and Ruby value-object mechanics; hexagonal gains
  an annotated directory tree with import arrows, primary/secondary
  port vocabulary, the transaction/unit-of-work answer, a Rails
  reconciliation, and a "when not to" section.
- **Format normalized**: one `## Judgment` heading and the deference
  line ("the target's own conventions outrank this guide") in every
  topic; the annotated-skeleton requirement extends to all guidance
  docs (architecture docs carry annotated structural examples).

## Capabilities

### New Capabilities

<!-- none -->

### Modified Capabilities

- `caffeine`: the annotated-skeleton requirement covers every guidance
  doc; guides must carry deference and cross-topic arbitration where
  topics conflict.

## Impact

- Modified: all six `caffeine/**.md` guides. Added:
  `test/caffeine_content.bats` (load-bearing strings present,
  known-wrong claims absent).
