# caffeine: ruby/rails
<!-- caffeine-topic: ruby/rails -->
<!-- caffeine-applies: rails >=7.0 -->
<!-- caffeine-source: https://guides.rubyonrails.org -->
<!-- caffeine-reviewed: 2026-08-12 -->

Loaded only when your task's manifest names `ruby/rails`. The target's
own conventions outrank this guide where they conflict.

The sidecar mechanically rejects (fix them, don't argue with them):

- leftover debugger
- string-interpolated SQL
- puts in app code (use the logger)
- rescue Exception (rescue StandardError instead)
- mass-assignment escape hatch (permit!/to_unsafe_h)

## The skeleton

```ruby
# app/controllers/orders_controller.rb — a controller action is three
# lines of intent: authorize, delegate, respond. Anything more is domain
# logic living in the wrong layer.
class OrdersController < ApplicationController
  def create
    # Authorize FIRST — the step everyone skips is the step that ships
    # the incident. Whatever the app uses (Pundit here), it happens
    # before any domain move.
    authorize Order

    # params stop here: permit exactly what this action needs, pass a
    # plain hash (or form object) inward — never the params object itself.
    result = Orders::Create.call(order_params, user: current_user)

    # The service returns a result the controller only translates; the
    # controller never inspects domain state to make domain decisions.
    if result.success?
      redirect_to result.order, notice: t('.created')
    else
      # Re-render with the model carrying its own errors — no flash-stuffed
      # error strings the view has to reassemble. @order because the
      # Rails-generated new.html.erb reads the instance variable.
      @order = result.order
      render :new, status: :unprocessable_entity
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
    # The Result the controller depends on is six honest lines — never
    # make callers probe nil to learn what happened.
    Result = Struct.new(:order, :errors, keyword_init: true) do
      def success? = errors.empty?
    end

    def self.call(attrs, user:, clock: Time.zone)
      order = user.orders.build(attrs)
      order.placed_at = clock.now
      # Side effects a reader would not expect on save (mail, events)
      # happen HERE, visibly — never hidden in model callbacks.
      if order.save
        OrderMailer.confirmation(order).deliver_later
        Result.new(order: order, errors: [])
      else
        Result.new(order: order, errors: order.errors.full_messages)
      end
    end
  end
end
```

## Judgment

The target's own conventions outrank this skeleton where they conflict.

- **Where domain logic lives — one rule, not two.** Logic about ONE
  record's own state and invariants belongs in the model (`order.close!`).
  A move that coordinates several records, a mailer, or a clock gets a
  named service object like `Orders::Create` above. If a model method
  starts touching other models' internals, it graduates to a service; if
  a service only reads and writes one record, it collapses into the
  model.
- **If the manifest also loads `architecture/hexagonal`**: in a vanilla
  Rails app the model layer IS the domain and ActiveRecord is its
  persistence adapter — apply hexagonal's direction-of-dependency rule
  at the service seam (services take plain values, never `params`; no
  HTTP types below the controller), and do not extract a port layer the
  target doesn't already have. The target's existing architecture wins.
- **Strong parameters at the boundary.** Never pass `params` deeper than
  the controller; permit exactly what the action needs — `permit!` and
  `to_unsafe_h` are the sidecar-banned escape hatches.
- **Use the framework's grain.** Callbacks for lifecycle invariants only —
  never for side effects a reader would not expect on `save`. Prefer
  explicit service calls in the action.
- **Migrations are forward-only in spirit**: additive first, destructive
  only after the code stops reading the old shape. Concretely: add the
  column, backfill in batches, then add the NOT NULL — three deploys,
  not one; and index creation on a live Postgres table wants
  `algorithm: :concurrently` with `disable_ddl_transaction!`.
- **Logging replaces printing.** `Rails.logger` with a level you would
  actually want in production; the sidecar's `puts` rule is the floor, not
  the bar.
- **Errors**: rescue the narrowest class that models the failure you can
  handle (`rescue_from` in `ApplicationController` for the app-wide
  translations, e.g. `ActionController::ParameterMissing` → 400); let
  the rest crash loudly in development and be reported in production.
