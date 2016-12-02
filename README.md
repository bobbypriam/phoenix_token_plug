# Phoenix.Token.Plug

Collection of plugs for `Phoenix.Token`-based authentication. Useful for authenticating API calls.

Heavily inspired by [Guardian](https://github.com/ueberauth/guardian).

## Why?

In building APIs with Phoenix, often we need to have authentication mechanisms. Some of the prevalent solution is Guardian.

However, Guardian uses JWT as its main currency. While not bad in itself, Phoenix already provides token signing and verification mechanism through [Phoenix.Token](https://hexdocs.pm/phoenix/Phoenix.Token.html), which is a lightweight alternative to JWT. For comparison of Phoenix.Token and JWT, see [here](https://elixirforum.com/t/how-is-phoenix-token-different-from-jwt/2349) and [here](https://elixirforum.com/t/roll-your-own-auth-split-thread/2662/19).

This library kind of mirrors a part of what Guardian does except that it uses Phoenix.Token.

## Installation

  1. Add `phoenix_token_plug` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:phoenix_token_plug, "~> 0.1.0"}]
    end
    ```

  2. Ensure `phoenix_token_plug` is started before your application:

    ```elixir
    def application do
      [applications: [:phoenix_token_plug]]
    end
    ```

## Usage

Add the plugs to your router (or one of your pipelines):

```elixir
defmodule MyApp.Router do
  # ...

  pipeline :api do
    plug :accepts, ["json"]

    # Checks for Authorization: Bearer <token> header, and adds
    # the token payload to conn.assigns.user if token exists
    plug Phoenix.Token.Plug.VerifyHeader,
      salt: "user",
      max_age: 1_209_600
  end

  pipeline :protected do
    # Checks if conn.assigns.user exists; if not, will
    # call MyApp.AuthController.unauthenticated/2
    plug Phoenix.Token.Plug.EnsureAuthenticated,
      handler: MyApp.AuthController # Or any other module
  end

  scope "/api", MyApp do
    pipe_through [:api, :protected]

    get "/protected", IndexController, :protected_route
  end

  # ...
end
```

And implement `unauthenticated/2`:

```elixir
defmodule MyApp.AuthController do
  # ...

  def unauthenticated(conn, _params) do
    conn
    |> put_status(401)
    |> json(%{error: "Unauthenticated!"})
  end

  # ...
end
```
