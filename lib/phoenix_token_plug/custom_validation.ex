defmodule PhoenixTokenPlug.CustomValidation do
  @moduledoc """
  Plug that allows you to have further custom validation
  for your token.

  ## Usage

  Add this to your `router.ex`, possibly inside a pipeline:

      plug PhoenixTokenPlug.CustomValidation,
        validate_fn: &MyApp.AuthController.not_blacklisted?/3  # Or whatever function you want
        handler: MyApp.AuthController                          # Or whatever module you want

  The function to be passed to `validate_fn` must accept three
  parameters, namely the `conn`, `token`, and `params`. It also
  must return a boolean indicating whether the request is
  validated. A return value of `true` indicates that the
  validation is successful and the request may continue through
  the next series of plugs, while `false` will halt the `conn`
  and calls the `handler`.

  The signature of `handler` and `handler_fn` is the same as the
  one used for `PhoenixTokenPlug.EnsureAuthenticated`.

  An example of the `validate_fn` is as follows:

      defmodule MyApp.AuthController do
        # ...

        def not_blacklisted?(_conn, token, _params) do
          not Auth.blacklisted?(token)
        end

        # ...
      end

  Note: you must put this plug after `PhoenixTokenPlug.VerifyHeader`.

  You might pass several options to the plug:

      plug PhoenixTokenPlug.CustomValidation,
        validate_fn: &MyApp.AuthController.not_blacklisted?/3  # (required) The validate function
        handler: MyApp.AuthController                          # (required) The handler module
        handler_fn: :handle_error                              # (optional) Customize the handler function, defaults to :unauthenticated
  """

  import Plug.Conn

  @doc false
  def init(opts), do: opts

  @doc false
  def call(conn, opts) do
    token = conn.assigns.token
    validate_fn = Keyword.get(opts, :validate_fn)
    handler = Keyword.get(opts, :handler)
    handler_fn = Keyword.get(opts, :handler_fn, :unauthenticated)

    validation_result = apply(validate_fn, [conn, token, conn.params])

    if validation_result do
      conn
    else
      conn = conn |> halt
      apply(handler, handler_fn, [conn, conn.params])
    end
  end

end
