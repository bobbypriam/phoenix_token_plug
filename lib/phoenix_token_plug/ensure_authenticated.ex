defmodule Phoenix.Token.Plug.EnsureAuthenticated do
  @moduledoc """
  Ensures the verification by Phoenix.Token.Plug.VerifyHeader
  of the request was successful.

  If one is not found, the `unauthenticated/2` function is invoked with the
  `Plug.Conn.t` object and its params.
  """

  import Plug.Conn

  @doc false
  def init(default_opts), do: default_opts

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
