# caffeine: ruby/rails

Loaded only when your briefing's manifest names `ruby/rails`.

The sidecar mechanically rejects: leftover debuggers, string-interpolated
SQL in query methods, `puts` inside `app/`, and `rescue Exception`. Those
come back as gate failures — fix them, don't argue with them.

Judgment the sidecar cannot check:

- **Fat models, thin controllers, no clever concerns.** A controller action
  reads as: authorize, delegate, respond. Domain logic lives in the model
  or a plain object the model owns.
- **Strong parameters at the boundary.** Never pass `params` deeper than
  the controller; permit exactly what the action needs.
- **Use the framework's grain.** Callbacks for lifecycle invariants only —
  never for side effects a reader would not expect on `save`. Prefer
  explicit service calls in the action.
- **Migrations are forward-only in spirit**: additive first, destructive
  only after the code stops reading the old shape.
- **Logging replaces printing.** `Rails.logger` with a level you would
  actually want in production; the sidecar's `puts` rule is the floor, not
  the bar.
- **Errors**: rescue the narrowest class that models the failure you can
  handle; let the rest crash loudly in development and be reported in
  production.
