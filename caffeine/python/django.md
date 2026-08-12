# caffeine: python/django
<!-- caffeine-topic: python/django -->
<!-- caffeine-applies: django >=4.2 -->
<!-- caffeine-source: https://docs.djangoproject.com/en/stable/topics/ -->
<!-- caffeine-reviewed: 2026-08-12 -->

Loaded only when your task's manifest names `python/django`. The
target's own conventions outrank this guide where they conflict.

The sidecar mechanically rejects (fix them, don't argue with them):

- committed DEBUG = True (never in settings)
- bare except swallows everything (name the exception)
- f-string SQL (use query parameters)
- print in app code (use logging)

## The skeleton

```python
# shop/services.py — the domain move as a named function: models own
# their invariants, services coordinate; views only translate.
import logging

logger = logging.getLogger(__name__)  # logging, never print — print
                                      # vanishes under gunicorn and
                                      # carries no level or context.

def close_order(order, *, clock=timezone.now):
    # Guard with the narrowest exception you can handle; a bare
    # `except:` also catches KeyboardInterrupt and SystemExit — the
    # sidecar rejects it on sight.
    if order.closed_at is not None:
        return order  # idempotent: calling twice is safe by design

    order.closed_at = clock()
    # update_fields: write what changed, not the whole row — concurrent
    # writers stop clobbering each other's columns.
    order.save(update_fields=["closed_at"])
    logger.info("order closed", extra={"order_id": order.pk})
    return order

# shop/queries.py — the ORM parameterizes for you; raw SQL must too.
# NEVER: cursor.execute(f"... WHERE id = {oid}")  — injection by format
# ALWAYS: cursor.execute("... WHERE id = %s", [oid])
def orders_for_report(since):
    # select_related walks FKs in one JOIN; prefetch_related batches
    # M2M/reverse — the N+1 fix is visible at the query site.
    return (Order.objects.filter(placed_at__gte=since)
            .select_related("customer")
            .prefetch_related("lines"))
```

## Judgment

- **Settings split by trust, not convenience.** `DEBUG`, keys, and hosts
  come from the environment (`django-environ` or `os.environ`); a
  committed `DEBUG = True` leaks stack traces and settings to the world
  the day it deploys.
- **Fat models, thin views, named services.** One record's invariants
  live on the model; moves that coordinate records, mail, or clocks get
  a service function; views validate, delegate, respond.
- **Migrations are forward-only in spirit**: additive first, backfill in
  batches, constrain last — and never mix schema and data migration in
  one file; `RunPython` gets its own, with a reverse.
- **QuerySets are lazy — chain freely, iterate deliberately.** `.count()`
  over `len()`, `.exists()` over truthiness, `.iterator()` for unbounded
  scans; N+1 shows in `connection.queries` before it shows in
  production.
- **transaction.atomic wraps invariants**: bounded writes that stand or
  fall together, enqueue after commit (`transaction.on_commit`), never
  network calls inside.
