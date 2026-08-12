# caffeine: architecture/hexagonal
<!-- caffeine-topic: architecture/hexagonal -->
<!-- caffeine-applies: any -->
<!-- caffeine-source: https://alistair.cockburn.us/hexagonal-architecture -->
<!-- caffeine-reviewed: 2026-08-12 -->
<!-- caffeine-mode: doc-only -->

Language-agnostic, doc-only: ports and adapters is a discipline about
direction of dependency, not a framework. Loaded when your task's manifest
names `architecture/hexagonal`.

- **The domain is the center and imports nothing.** Business rules know no
  HTTP, no SQL, no queue, no framework annotation. If a domain file names a
  driver or a route, the boundary is already breached.
- **Ports are owned by the inside.** The domain defines the interfaces it
  needs (repositories, clocks, notifiers) in its own terms; adapters on the
  outside implement them. The dependency arrow always points inward.
- **Adapters are dumb translators**: an HTTP adapter maps request →
  domain call → response and nothing else; a persistence adapter maps
  domain objects ↔ rows. Logic discovered in an adapter is domain logic in
  the wrong house — move it.
- **One port per need, not per technology.** `UserRepository`, not
  `PostgresClient`; the technology name belongs only to the adapter.
- **Test the hexagon in isolation**: domain tests run with in-memory fakes
  of its own ports, no framework booted. If the domain cannot be tested
  without infrastructure, the ports are missing or leaky.
- **Entry points are also adapters** — CLI, web, and job runners all
  translate into the same application services; when two entry points
  duplicate orchestration, that orchestration belongs inside.
- **Cross the boundary with domain types**, never with transport shapes:
  request DTOs stop at the adapter; rows stop at the repository.

- **If the manifest also loads `ruby/rails`**: do not fight the
  framework. In a vanilla Rails app the model layer is the domain and
  ActiveRecord is its persistence adapter; apply the
  direction-of-dependency rule at the application-service seam instead
  of extracting a port layer the target does not have. The target's
  existing architecture wins.
