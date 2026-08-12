# caffeine: architecture/oop
<!-- caffeine-topic: architecture/oop -->
<!-- caffeine-applies: any -->
<!-- caffeine-source: https://www.poodr.com -->
<!-- caffeine-reviewed: 2026-08-12 -->
<!-- caffeine-mode: doc-only -->

Language-agnostic, doc-only: no grep judges design. Loaded when your task's
manifest names `architecture/oop`.

- **One reason to change.** Every class/module owns a single responsibility
  stated in one sentence; if the sentence needs "and", split it.
- **Depend on abstractions at the boundaries you own.** High-level policy
  never imports low-level detail; invert with an interface the policy side
  defines.
- **Open for extension, closed for surgery**: adding a variant should mean
  adding a type, not editing a switch in five places. If you just edited
  the same conditional twice, extract the polymorphism now.
- **Substitutability is the test for inheritance**: a subtype must honor
  every promise of its parent (contracts, invariants, error behavior) or it
  is not a subtype — prefer composition.
- **Small interfaces, told not asked.** Clients see only what they use;
  objects expose behavior, not their fields — if a caller inspects state to
  decide what to do to the object, that decision belongs inside it.
- **Value objects for values**: identity-free concepts (money, ranges,
  ids) are immutable types with their own behavior, never bare primitives
  passed in parallel.
- **Constructors establish invariants completely** — an object that exists
  is valid; no init-then-configure two-step.
