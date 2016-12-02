defmodule Phoenix.Token.Plug.EnsureAuthenticated do
  @moduledoc """
  Ensures the verification by `Phoenix.Token.Plug.VerifyHeader`
  of the request was successful by checking the existence of
  `conn.assigns.user`.

  If one is not found, the `unauthenticated/2` function of the
  passed handler is invoked with the `Plug.Conn.t` object and
  its params.

  ## Usage

  Add this to your `router.ex`, possibly inside a pipeline:

      plug Phoenix.Token.Plug.EnsureAuthenticated,
        handler: MyApp.AuthController  # Or whatever module you want

  Then, in your `MyApp.AuthController`:

      defmodule MyApp.AuthController do
        # ...

        def unauthenticated(conn, _params) do
          conn
          |> put_status(401)
          |> json(%{error: "Unauthenticated!"})
        end

        # ...
      end
  """

  import Plug.Conn

  @doc false
  def init(opts), do: opts

  @doc false
  def call(conn, opts) do
    handler = Keyword.get(opts, :handler)
    case conn.assigns[:user] do
      nil ->
        conn = conn |> halt
        apply(handler, :unauthenticated, [conn, conn.params])
      _ ->
        conn
    end
  end

end
