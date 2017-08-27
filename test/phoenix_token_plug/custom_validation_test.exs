defmodule PhoenixTokenPlug.CustomValidationTest do
  use ExUnit.Case, async: true

  import Plug.Conn

  alias PhoenixTokenPlug.CustomValidation

  defmodule UnauthenticatedHandler do
    def unauthenticated(conn, _params) do
      conn |> put_status(401) |> assign(:unauthenticated, true)
    end

    def handle_error(conn, _params) do
      conn |> put_status(401) |> assign(:other_handler_function, true)
    end
  end

  defmodule ValidationHandler do
    def validate_true(_conn, _token, _params), do: true

    def validate_false(_conn, _token, _params), do: false

    def validate_params(conn, token, _params) do
      conn.assigns.user != nil &&
      conn.assigns.token != nil &&
      token != nil &&
      conn.assigns.token == token
    end
  end

  @opts [
    validate_fn: &ValidationHandler.validate_true/3,
    handler: UnauthenticatedHandler,
  ]
  @user %{id: 1}
  @token "abc123"

  test "does nothing if validate_fn returns true" do
    conn = authorized_conn() |> CustomValidation.call(@opts)
    assert conn.status != 401
  end

  test "passes correct params to validate_fn" do
    opts = Keyword.put(@opts, :validate_fn, &ValidationHandler.validate_params/3)
    conn = authorized_conn() |> CustomValidation.call(opts)
    assert conn.status != 401
  end

  test "calls unauthenticated handler if validate_fn returns false" do
    opts = Keyword.put(@opts, :validate_fn, &ValidationHandler.validate_false/3)
    conn = authorized_conn() |> CustomValidation.call(opts)
    assert conn.status == 401
    assert conn.assigns.unauthenticated
  end

  test "can customize handler function" do
    opts =
      @opts
      |> Keyword.put(:validate_fn, &ValidationHandler.validate_false/3)
      |> Keyword.merge(handler_fn: :handle_error)
    conn = authorized_conn() |> CustomValidation.call(opts)
    assert conn.status == 401
    assert conn.assigns.other_handler_function
  end

  defp authorized_conn do
    conn()
    |> assign(:user, @user)
    |> assign(:token, @token)
  end

  defp conn do
    %Plug.Conn{}
  end

end
