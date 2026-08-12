## 1. Sidekiq truth

- [x] 1.1 Red→green: strict_args!/string-key round trip, honest OSS
      delivery semantics, perform_bulk, retry numbers, the
      transaction/enqueue race — wrong claims asserted absent

## 2. ActiveRecord races

- [x] 2.1 Red→green: unique-index caveat, batching outside the
      transaction, find_each/order warning, N+1 worked pair

## 3. Rails copyable and adjudicated

- [x] 3.1 Red→green: complete skeleton with Result object and
      authorize, model-vs-service paragraph, hexagonal arbitration in
      both docs

## 4. RSpec tools

- [ ] 4.1 Red→green: let!, shared examples as port contracts,
      instance_double, build_stubbed, travel helpers over Timecop

## 5. Architecture docs teach

- [ ] 5.1 Red→green: oop before/after extraction + SRP-as-actor +
      rule-of-three + value-object mechanics; hexagonal directory tree +
      port vocabulary + transactions + when-not-to; format normalized
      everywhere; skeleton requirement extends to all guidance docs
