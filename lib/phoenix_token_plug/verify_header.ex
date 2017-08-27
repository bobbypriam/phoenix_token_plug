defmodule PhoenixTokenPlug.VerifyHeader do
  @moduledoc """
  Checks if there is an authentication token is in the HTTP header.
  If one exists, it assigns the token payload to `conn.assigns.user`,
  and the token itself to `conn.assigns.token`.

  It assumes one Authorization header with Bearer prefix, such as

      Authorization: Bearer <your Phoenix.Token>

  Note that this does *not* enforce authentication. To have protected
  routes, use this in conjuction with `PhoenixTokenPlug.EnsureAuthenticated`.

  # Usage

  Add this to your `router.ex`, possibly inside a pipeline:

      plug PhoenixTokenPlug.VerifyHeader,
        salt: "user",       # (optional) customize the salt for Phoenix.Token, defaults to "user"
        max_age: 1_209_600, # (optional) validate token max age in seconds, default to 1_209_600 (2 weeks)
        key: :foo           # (optional) customize the payload conn assign key, defaults to :user
  """

  import Plug.Conn

  @doc false
  def init(opts), do: opts

  @doc false
  def call(conn, opts) do
    key = Keyword.get(opts, :key, :user)
    token = fetch_token(get_req_header(conn, "authorization"))
    case verify_token(conn, token, opts) do
      {:ok, payload} ->
        conn
        |> assign(key, payload)
        |> assign(:token, token)
      {:error, _} ->
        conn
    end
  end

  defp fetch_token([]), do: nil
  defp fetch_token([token|_tail]) do
    token
    |> String.replace("Bearer ", "")
    |> String.trim
  end

  defp verify_token(conn, token, opts) do
    salt = Keyword.get(opts, :salt, "user")
    max_age = Keyword.get(opts, :max_age, 1_209_600)

    Phoenix.Token.verify(conn, salt, token, max_age: max_age)
  end

end
