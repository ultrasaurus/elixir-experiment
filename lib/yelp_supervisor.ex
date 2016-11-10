defmodule Yelp.Supervisor do
  use Supervisor

  def start_link do
    :supervisor.start_link(__MODULE__, [])
  end

  def init([]) do
    children = [
      worker(Yelp, [Yelp])
    ]
    opts = [strategy: :one_for_one]
    supervise(children, opts)
  end
end