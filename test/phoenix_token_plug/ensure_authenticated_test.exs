defmodule PhoenixTokenPlug.EnsureAuthenticatedTest do
  use ExUnit.Case, async: true

  import Plug.Conn

  alias PhoenixTokenPlug.EnsureAuthenticated

  defmodule UnauthenticatedHandler do
    def unauthenticated(conn, _params) do
      conn |> put_status(401) |> assign(:unauthenticated, true)
    end
  end

  @opts handler: UnauthenticatedHandler
  @user %{id: 1}

  test "does nothing if conn.assigns.user exists" do
    conn = conn() |> assign(:user, @user) |> EnsureAuthenticated.call(@opts)
    assert conn.status != 401
  end

  test "calls unauthenticated handler if conn.assigns.user does not exist" do
    conn = conn() |> EnsureAuthenticated.call(@opts)
    assert conn.status == 401
    assert conn.assigns.unauthenticated
  end

  defp conn do
    %Plug.Conn{}
  end

end
