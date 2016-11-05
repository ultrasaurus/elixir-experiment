defmodule Thing.Mixfile do
  use Mix.Project

  def project do
    [app: :thing,
     version: "0.1.0",
     elixir: "~> 1.3",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps()]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: applications(Mix.env),
     mod: {Thing, []}]
  end

  defp applications(:dev) do
    applications(:all) ++ [:remix]
  end

  defp applications(_) do
   [
      :logger, :cowboy, :plug, :extwitter, 
      :oauth, :eex 
    ]
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
    [{:cowboy, "~> 1.0"},
    {:plug, "~> 1.0"},
    {:oauth, github: "tim/erlang-oauth"},
    {:extwitter, "~> 0.7.2"},
    {:exrm, "~> 1.0"},
    {:mix_test_watch, "~> 0.2.6", only: [:dev, :test]},
    {:remix, "~> 0.0.2", only: [:dev]}
  ]
  end
end




