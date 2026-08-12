# caffeine: js/vitest
<!-- caffeine-topic: js/vitest -->
<!-- caffeine-applies: vitest >=1 -->
<!-- caffeine-source: https://vitest.dev/guide/ -->
<!-- caffeine-reviewed: 2026-08-12 -->

Loaded only when your task's manifest names `js/vitest`. The target's
own test conventions outrank this guide where they conflict.

The sidecar mechanically rejects (fix them, don't argue with them):

- focused test left in (.only)
- silently skipped test (.skip)
- raw setTimeout in a test (use vi.useFakeTimers)
- console.log in a test

## The skeleton

```js
// src/order.test.js — colocate the test with the unit; the describe
// tree reads as sentences.
import { describe, it, expect, vi, beforeEach } from 'vitest'
import { OrderService } from './order'

describe('OrderService', () => {
  describe('create', () => {
    // Build collaborators per test — module-level shared state is how
    // suites become order-dependent. vi.fn() doubles are reset by
    // config (clearMocks: true), never by hand in each file.
    let store
    beforeEach(() => {
      store = { save: vi.fn().mockResolvedValue({ id: 'o1' }) }
    })

    it('persists the draft with a placed timestamp', async () => {
      // Fake the clock, never wait for it: fake timers make time a
      // value, and the sidecar's setTimeout rule is the floor.
      vi.useFakeTimers({ now: new Date('2026-08-12T00:00:00Z') })

      const service = new OrderService({ store })
      await service.create({ sku: 'A1' })

      // One behavior per example: this one is about persistence; the
      // timestamp's FORMAT belongs to its own example.
      expect(store.save).toHaveBeenCalledWith(
        expect.objectContaining({ placedAt: new Date('2026-08-12T00:00:00Z') })
      )
    })

    it('rejects an empty draft', async () => {
      const service = new OrderService({ store })
      // Async error contracts: await the rejection matcher — an
      // un-awaited .rejects assertion passes vacuously.
      await expect(service.create({})).rejects.toThrow('empty draft')
    })
  })
})
```

## Judgment

- **`.only` and `.skip` are session tools, not commits.** A focused test
  silently shrinks the suite to one file; a skip without a tracking
  reason is a deletion wearing a disguise.
- **Await every async assertion.** `expect(p).rejects`, `waitFor`,
  and async matchers all return promises; missing one `await` makes the
  test pass before the assertion runs.
- **Fake timers over real waits.** A test that sleeps is slow when it
  passes and flaky when the machine is; `vi.useFakeTimers` +
  `vi.advanceTimersByTime` make time deterministic.
- **Mock the boundary, not the internals.** `vi.mock` on your own
  modules couples tests to file layout; inject collaborators and double
  those instead.
- **The failure message is the audience**: prefer specific matchers
  (`toHaveBeenCalledWith`, `objectContaining`) over `toBeTruthy` — a
  failure should name the broken promise, not report "false".
