defmodule Phoenix.Token.Plug.VerifyHeader do
  @moduledoc """
  Checks if there is an authentication token is in the HTTP header.
  If one exists, it assigns the token payload to `conn.assigns.user`.

  It assumes one Authorization header with Bearer prefix, such as

      Authorization: Bearer <your Phoenix.Token>

  Note that this does *not* enforce authentication. To have protected
  routes, use this in conjuction with `Phoenix.Token.Plug.EnsureAuthenticated`.

  # Usage

  Add this to your `router.ex`, possibly inside a pipeline:

      plug Phoenix.Token.Plug.VerifyHeader,
        salt: "user",
        max_age: 1_209_600
  """

  import Plug.Conn

  @doc false
  def init(opts), do: opts

  @doc false
  def call(conn, opts) do
    token = fetch_token(conn, opts)
    case verify_token(conn, token, opts) do
      {:ok, payload} ->
        assign(conn, :user, payload)
      {:error, _} ->
        conn
    end
  end

  defp fetch_token(conn, _opts) do
    case get_req_header(conn, "authorization") do
      [] ->
        nil
      [token|_tail] ->
        token
        |> String.replace("Bearer ", "")
        |> String.trim
    end
  end

  defp verify_token(conn, token, opts) do
    salt = Keyword.get(opts, :salt, "user")
    max_age = Keyword.get(opts, :max_age, 1_209_600)

    Phoenix.Token.verify(conn, salt, token, max_age: max_age)
  end

end
