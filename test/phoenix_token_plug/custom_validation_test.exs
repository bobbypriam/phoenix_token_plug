defmodule PhoenixTokenPlug.CustomValidationTest do
  use ExUnit.Case, async: true

  import Plug.Conn

  alias PhoenixTokenPlug.CustomValidation

  defmodule TokenEndpoint do
    def config(:secret_key_base), do: "abc123"
  end

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
  end

  @opts [
    validate_fn: &ValidationHandler.validate_true/3,
    handler: UnauthenticatedHandler,
  ]
  @user %{id: 1}

  test "does nothing if validate_fn returns true" do
    conn = conn() |> assign(:user, @user) |> CustomValidation.call(@opts)
    assert conn.status != 401
  end

  test "calls unauthenticated handler if validate_fn returns false" do
    opts = Keyword.put(@opts, :validate_fn, &ValidationHandler.validate_false/3)
    conn = conn() |> CustomValidation.call(opts)
    assert conn.status == 401
    assert conn.assigns.unauthenticated
  end

  test "can customize handler function" do
    opts =
      @opts
      |> Keyword.put(:validate_fn, &ValidationHandler.validate_false/3)
      |> Keyword.merge(handler_fn: :handle_error)
    conn = conn() |> CustomValidation.call(opts)
    assert conn.status == 401
    assert conn.assigns.other_handler_function
  end

  defp conn do
    %Plug.Conn{}
  end

end
