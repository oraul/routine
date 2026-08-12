# caffeine: js/express
<!-- caffeine-topic: js/express -->
<!-- caffeine-applies: express >=4 -->
<!-- caffeine-source: https://expressjs.com/en/advanced/best-practice-performance.html -->
<!-- caffeine-reviewed: 2026-08-12 -->

Loaded only when your task's manifest names `js/express`. The target's
own conventions outrank this guide where they conflict.

The sidecar mechanically rejects (fix them, don't argue with them):

- synchronous fs call in request code (use the promise API)
- console.log in app code (use a logger)
- leftover debugger statement
- wildcard CORS (scope the origin)

## The skeleton

```js
// src/routes/orders.js — a route is three lines of intent: validate,
// delegate, respond. Domain logic in a route handler is logic the test
// suite can only reach through HTTP.
import { Router } from 'express'
export const orders = Router()

orders.post('/', async (req, res, next) => {
  try {
    // The body stops here: validate/parse into a plain object at the
    // boundary; never pass req deeper than the handler.
    const draft = parseOrderDraft(req.body)

    // async all the way down — one readFileSync in a handler blocks the
    // ONE event loop every request shares; that is why the sidecar
    // rejects the *Sync family on sight.
    const order = await orderService.create(draft, { user: req.user })

    res.status(201).json(order)
  } catch (err) {
    // Async errors must reach next() — an unhandled rejection in a
    // handler is a hung request (and pre-Express-5, a crash).
    next(err)
  }
})

// src/app.js — the error middleware keeps the four-argument signature;
// Express dispatches by arity, so dropping `next` silently unregisters
// the handler.
app.use((err, req, res, next) => {
  req.log.error({ err }, 'request failed')   // structured logger, not console
  res.status(err.status ?? 500).json({ error: 'internal' })
})
```

## Judgment

- **The event loop is shared.** Every `*Sync` call and every unbounded
  CPU loop in request code stalls all concurrent requests; async I/O and
  worker threads are the pressure valves.
- **Middleware order is the architecture.** Body parsing → auth →
  routes → 404 → error handler; a middleware registered after the
  routes never runs for them, and Express reports none of this.
- **Scope CORS to real origins.** `cors()` with no options reflects
  every origin — legitimate only for a truly public read-only API;
  everything else names its origins.
- **Validate at the edge, once.** A schema (zod, joi) at the boundary
  turns `req.body` into a typed value; handlers and services never
  defensively re-check.
- **Trust proxy deliberately.** Behind a load balancer, `req.ip` and
  secure cookies are wrong until `app.set('trust proxy', 1)` — and
  wrong in the other direction if set while directly exposed.
