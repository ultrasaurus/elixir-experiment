defmodule Thing do
  use Application

  def hello do
    "Hello"
  end

  def hello(name) do
    "Hello, " <> name <> " new version"
  end

  def increment(nil), do: 1
  def increment(value) do
    value + 1
  end

  def follower_count(name, count \\ 10) do
    ExTwitter.followers(name, count: count).items
      |> Enum.map(fn(person) -> person.location end)
  end

  def follower_cities(name, count \\ 1) do
    ExTwitter.followers(name, count: count).items
      |> Enum.map(fn(person) -> person.location end)
      |> Enum.reduce(%{}, fn(loc, acc) ->
            Map.put(acc, loc, Thing.increment(acc[loc]))
            end
      )
  end

  # See http://elixir-lang.org/docs/stable/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # Define workers and child supervisors to be supervised
    children = [
      # Starts a worker by calling: Thing.Worker.start_link(arg1, arg2, arg3)
      worker(Thing.Router, []),
      supervisor(Yelp.Supervisor, [])
    ]

    # See http://elixir-lang.org/docs/stable/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Thing.Supervisor]
    :ets.new(:delivery_lookup, [:set, :named_table, :public])
    Supervisor.start_link(children, opts)
  end
end
