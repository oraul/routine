# caffeine: ruby/rails

Loaded only when your briefing's manifest names `ruby/rails`.

The sidecar mechanically rejects: leftover debuggers, string-interpolated
SQL in query methods, `puts` inside `app/`, and `rescue Exception`. Those
come back as gate failures — fix them, don't argue with them.

## The skeleton

```ruby
# app/controllers/orders_controller.rb — a controller action is three
# lines of intent: authorize, delegate, respond. Anything more is domain
# logic living in the wrong layer.
class OrdersController < ApplicationController
  def create
    # params stop here: permit exactly what this action needs, pass a
    # plain hash (or form object) inward — never the params object itself.
    result = Orders::Create.call(order_params, user: current_user)

    # The service returns a result the controller only translates; the
    # controller never inspects domain state to make domain decisions.
    if result.success?
      redirect_to result.order, notice: t('.created')
    else
      # Re-render with the model carrying its own errors — no flash-stuffed
      # error strings the view has to reassemble.
      render :new, status: :unprocessable_entity, locals: { order: result.order }
    end
  end

  private

  def order_params
    params.require(:order).permit(:customer_id, lines_attributes: %i[sku qty])
  end
end

# app/services/orders/create.rb — the domain move as a named object:
# one public .call, dependencies injected, no framework in the signature.
module Orders
  class Create
    def self.call(attrs, user:, clock: Time.zone)
      # Side effects a reader would not expect on save (mail, events)
      # happen HERE, visibly — never hidden in model callbacks.
      ...
    end
  end
end
```

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
