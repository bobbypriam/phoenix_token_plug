defmodule Phoenix.Token.Plug.VerifyHeader do
  @moduledoc """
  Checks if there is an authentication token in the HTTP header.
  """

  import Plug.Conn

  @doc false
  def init(default_opts), do: default_opts

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
    max_age = Keyword.get(opts, :max_age, 1209600)

    Phoenix.Token.verify(conn, salt, token, max_age: max_age)
  end

end
