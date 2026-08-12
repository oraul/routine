# caffeine: architecture/hexagonal
<!-- caffeine-topic: architecture/hexagonal -->
<!-- caffeine-applies: any -->
<!-- caffeine-source: https://alistair.cockburn.us/hexagonal-architecture -->
<!-- caffeine-reviewed: 2026-08-12 -->
<!-- caffeine-mode: doc-only -->

Language-agnostic, doc-only: ports and adapters is a discipline about
direction of dependency, not a framework. Loaded when your task's
manifest names `architecture/hexagonal`. The target's own conventions
outrank this guide where they conflict.

## The structure, annotated

```text
app/
  domain/               # the center: imports NOTHING below this tree
    order.rb            #   business rules; no SQL, no HTTP, no gems
    ports/              #   interfaces the DOMAIN defines and owns
      order_repository.rb   # "what I need", written by the needer
  application/          # use-case orchestration (application services):
    close_order.rb      #   one verb per file; wires domain to ports;
                        #   THIS is where the transaction boundary lives
  adapters/
    http/               # PRIMARY (driving) adapters: the world calls us
      orders_controller.rb  # translates requests -> application calls
    persistence/        # SECONDARY (driven) adapters: we call the world
      sql_order_repository.rb  # implements domain/ports/*, knows SQL
#
# The one legal import direction: adapters/ -> application/ -> domain/.
# An import arrow pointing the other way is the whole pattern failing.
```

## Judgment

- **The domain is the center and imports nothing.** Business rules know no
  HTTP, no SQL, no queue, no framework annotation. Logic discovered in an
  adapter is domain logic in the wrong house.
- **Ports are owned by the inside** — the domain defines the interfaces it
  needs (secondary/driven ports like the repository above); entry points
  are primary/driving adapters speaking to application services. Using
  the field's names matters: it makes every article and codebase in the
  pattern legible.
- **Transactions live in the application service**, not the domain (which
  must not know a database exists) and not the adapter (which must not
  make business decisions): the use case opens the unit of work, invokes
  the domain, commits — one place, visible.
- **Adapters are dumb translators.** Mapping in, mapping out, no branching
  on business state. If a DTO mapping starts making decisions, the domain
  is going anemic — move the decision inward.
- **Domain tests run with in-memory fakes of its own ports** — and the
  fake and the real adapter must pass one shared contract-test set (see
  `ruby/rspec`'s shared examples), or the fake drifts and the green suite
  lies.
- **If the manifest also loads `ruby/rails`**: do not fight the
  framework. In a vanilla Rails app the model layer is the domain and
  ActiveRecord is its persistence adapter; apply the
  direction-of-dependency rule at the application-service seam instead
  of extracting a port layer the target does not have. The target's
  existing architecture wins.
- **When NOT to pay the tax**: a CRUD app with one database and no second
  delivery mechanism gets no benefit from the indirection — ports earn
  their keep when a second adapter (test fake, new transport, new store)
  actually arrives. Structure must come from need, not ceremony.
