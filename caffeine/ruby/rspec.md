# caffeine: ruby/rspec
<!-- caffeine-topic: ruby/rspec -->
<!-- caffeine-applies: rspec >=3.0 -->
<!-- caffeine-source: https://www.betterspecs.org -->
<!-- caffeine-reviewed: 2026-08-12 -->

Loaded only when your task's manifest names `ruby/rspec`. The structure
below is Better Specs distilled — copy the shape, and read the comments
as your insight channel. The target's own spec conventions outrank this
skeleton where they conflict.

The sidecar mechanically rejects (fix them, don't argue with them):

- legacy should syntax (use expect)
- leftover focus mark
- sleep in a spec (use test doubles or travel helpers)
- any_instance stubs objects the example never built
- silently disabled example (xit/xdescribe/xcontext)

## The skeleton

```ruby
# spec/models/order_spec.rb — one spec file per class, path mirrors app/.
RSpec.describe Order do
  # '.method' for class methods, '#method' for instance methods: failure
  # output then reads as documentation ("Order#total sums the line totals").
  describe '#total' do
    # subject names the thing under test exactly once; examples shrink to
    # one line because construction lives here, not in every it-block.
    subject(:order) { described_class.new(lines: lines) }

    # let is lazy and rebuilt per example — declare only what this describe
    # needs. Never share mutable state via before(:all) or instance vars.
    let(:lines) { [line_totalling(100), line_totalling(250)] }

    # context strings start with when/with/without so the tree reads as
    # sentences; each context overrides only the let it disagrees with.
    context 'with multiple lines' do
      it 'sums the line totals' do
        # One behavior per example: a failure names exactly one broken
        # promise. Two expects testing one behavior is fine; two behaviors
        # in one example is not.
        expect(order.total).to eq(350)
      end
    end

    context 'without lines' do
      let(:lines) { [] }   # the only difference from the happy path

      it 'is zero' do
        expect(order.total).to eq(0)
      end
    end

    context 'when a line is negative' do
      let(:lines) { [line_totalling(-50)] }

      # Test the error contract, not the implementation of the guard.
      it 'raises InvalidLine' do
        expect { order.total }.to raise_error(Order::InvalidLine)
      end
    end
  end
end
```

## Judgment beyond the skeleton

- **Test the interface, not the internals**: private methods are tested
  through the public behavior that uses them; a spec naming `send(:...)`
  is a design complaint filed in the wrong place.
- **Expect the mock only when the message *is* the behavior** (a command
  sent to a collaborator); for queries, stub the return and assert on the
  outcome instead.
- **Slow specs are design feedback**: needing the database or the clock in
  a unit spec means a seam is missing — extract the port before reaching
  for `sleep`, `Timecop`, or a real connection.
- **The failure message is the audience**: before committing, break the
  code mentally and ask whether the spec's failure output would tell a
  stranger what promise broke and where.
