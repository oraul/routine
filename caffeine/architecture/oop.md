# caffeine: architecture/oop
<!-- caffeine-topic: architecture/oop -->
<!-- caffeine-applies: any -->
<!-- caffeine-source: https://www.poodr.com -->
<!-- caffeine-reviewed: 2026-08-12 -->
<!-- caffeine-mode: doc-only -->

Language-agnostic, doc-only: no grep judges design. Loaded when your
task's manifest names `architecture/oop`. The target's own conventions
outrank this guide where they conflict.

## The worked example

The moment that decides most designs is the second edit to the same
conditional. Before:

```ruby
# The same case statement edited twice this month — pricing.rb knows
# every customer kind, and every new kind reopens this file (and the
# three other files with the same case hiding in them).
def discount(customer)
  case customer.kind
  when :retail    then 0.0
  when :wholesale then 0.15
  when :partner   then 0.30   # <- this branch is this week's edit
  end
end
```

After — the conditional becomes a type, the branches become objects, and
the next kind is a new file instead of four edits:

```ruby
# Each kind owns its own number; pricing.rb never changes again.
class Retail    def discount = 0.0  end
class Wholesale def discount = 0.15 end
class Partner   def discount = 0.30 end

def discount(customer) = customer.kind.discount
```

The brake matters as much as the move: **the rule of three**. One
conditional is fine; the *second time you edit the same one*, extract.
Extracting on first sight is speculation — the same law this repo builds
abstractions under.

## Judgment

- **One reason to change — one actor.** The decidable form of SRP: a
  module answers to a single source of change requests (billing answers
  to finance, formatting to the style guide). The folk "no 'and' in the
  sentence" test shreds cohesive classes; the actor test doesn't.
- **Depend on abstractions at the boundaries you own.** High-level policy
  never imports low-level detail; invert with an interface the policy side
  defines.
- **Tell, don't ask.** A caller that inspects state to decide for an
  object (`if order.lines.empty? && !order.closed?`) is that object's
  method living outside it; move the decision to the data
  (`order.closeable?`).
- **Value objects for domain quantities** — but a half-done value object
  is a bug factory: it must implement `==`, `eql?`, and `hash` together
  (and freeze) or it fails silently as a Hash key; money, spans, and ids
  deserve the full set, not a lonely `==`.
- **Composition before inheritance.** Inherit only when the subclass is
  substitutable everywhere the parent appears, forever; otherwise inject
  the collaborator.
- **Small interfaces.** Objects expose the few messages their
  collaborators need (coupling stays low), not their internals — a chain
  of getters (`a.b.c.d`) is a boundary leak, not a convenience.
- **When NOT to bother**: a script, a migration, a one-shot report — code
  with a single actor and no second edit coming earns a plain procedure.
  Design pressure must come from change, not from doctrine.
