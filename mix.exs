defmodule PhoenixTokenPlug.Mixfile do
  use Mix.Project

  @version "0.3.1"
  @url "https://github.com/bobbypriambodo/phoenix_token_plug"
  @maintainers [
    "Bobby Priambodo"
  ]

  def project do
    [app: :phoenix_token_plug,
     version: @version,
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     description: description(),
     package: package(),
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    []
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [{:phoenix, "~> 1.2"},
     {:plug, "~> 1.0"},
     {:credo, "~> 0.5", only: [:dev, :test]},
     {:ex_doc, "~> 0.14", only: :dev}]
  end

  defp description do
    """
    Collection of plugs for Phoenix.Token-based authentication.
    """
  end

  defp package do
    [files: ["lib", "mix.exs", "README.md", "LICENSE"],
     maintainers: @maintainers,
     licenses: ["MIT"],
     links: %{"GitHub" => @url}]
  end
end
