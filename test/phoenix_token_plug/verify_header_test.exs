defmodule Phoenix.Token.Plug.VerifyHeaderTest do
  use ExUnit.Case, async: true

  import Plug.Conn

  alias Phoenix.Token.Plug.VerifyHeader

  defmodule TokenEndpoint do
    def config(:secret_key_base), do: "abc123"
  end

  @user %{id: 1}

  test "does nothing if no token provided" do
    conn = conn() |> VerifyHeader.call([])
    assert conn.assigns[:user] == nil
  end

  test "does nothing if signing salt is different" do
    conn = authorized_conn("user") |> VerifyHeader.call(salt: "not_user")
    assert conn.assigns[:user] == nil
  end

  test "assigns user to conn if token valid" do
    conn = authorized_conn("user") |> VerifyHeader.call(salt: "user")
    assert conn.assigns.user == @user
  end

  test "salt defaults to \"user\"" do
    conn = authorized_conn("user") |> VerifyHeader.call([])
    assert conn.assigns.user == @user
  end

  test "can use salt other than user" do
    conn = authorized_conn("other_salt") |> VerifyHeader.call(salt: "other_salt")
    assert conn.assigns.user == @user
  end

  defp authorized_conn(salt) do
    token = get_token(conn, salt, @user)
    conn() |> put_req_header("authorization", "Bearer #{token}")
  end

  defp conn do
    %Plug.Conn{} |> Plug.Conn.put_private(:phoenix_endpoint, TokenEndpoint)
  end

  defp get_token(conn, salt, payload) do
    Phoenix.Token.sign(conn, salt, payload)
  end

end
