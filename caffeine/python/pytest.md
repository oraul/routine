# caffeine: python/pytest
<!-- caffeine-topic: python/pytest -->
<!-- caffeine-applies: pytest >=7 -->
<!-- caffeine-source: https://docs.pytest.org/en/stable/how-to/ -->
<!-- caffeine-reviewed: 2026-08-12 -->

Loaded only when your task's manifest names `python/pytest`. The
target's own test conventions outrank this guide where they conflict.

The sidecar mechanically rejects (fix them, don't argue with them):

- skip without a reason is a silent deletion
- time.sleep in a test (fake the clock)
- placeholder assertion (assert True)

## The skeleton

```python
# tests/test_order.py — plain functions, plain asserts: pytest's
# rewritten assert output IS the failure message, so assert the exact
# claim, never a boolean summary of it.
import pytest
from shop.order import Order, InvalidLine

# Fixtures are the composition root: dependencies are requested by
# name, built fresh per test, torn down by yield.
@pytest.fixture
def order():
    return Order(lines=[line(100), line(250)])

def test_total_sums_line_totals(order):
    assert order.total == 350   # not: assert order.total > 0

def test_negative_line_raises():
    # Error contracts pin the TYPE and the message the caller relies on.
    with pytest.raises(InvalidLine, match="negative"):
        Order(lines=[line(-50)]).total

# One behavior, many cases: parametrize instead of copy-paste; ids make
# the failure name the case.
@pytest.mark.parametrize("lines,total", [([], 0), ([100], 100)],
                         ids=["empty", "single"])
def test_total_edge_cases(lines, total):
    assert Order(lines=[line(v) for v in lines]).total == total

# A skip is a debt with a name — the reason (and a ticket) or nothing.
@pytest.mark.skip(reason="upstream flake, tracked in #42")
def test_provider_timeout():
    ...
```

## Judgment

- **Fixtures over setup methods.** Composition by argument list beats
  inheritance; a fixture used once inlines, a fixture used everywhere
  moves to `conftest.py` — and `conftest.py` is a public API, keep it
  small.
- **Fake the clock, never wait for it.** `time.sleep` in a test is slow
  when it passes and flaky when the machine is; monkeypatch the clock or
  use freezegun, and poll with a timeout only at real integration
  boundaries.
- **`assert True` asserts nothing** — it is a TODO wearing a green
  checkmark; write the real claim or write no test.
- **Parametrize the axis, not the copy.** Ten near-identical tests hide
  which case is new; one parametrized test with ids shows the space.
- **Markers are the suite's map**: `slow`, `integration`, `django_db` —
  declared in config so a typo'd marker errors instead of silently
  never running.
