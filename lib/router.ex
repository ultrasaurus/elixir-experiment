defmodule Thing.Router do
  use Plug.Router
  require Logger

  plug Plug.Logger
  plug :match
  plug :dispatch

  def init(options) do
    options
  end

  def start_link do
    {:ok, _} = Plug.Adapters.Cowboy.http Thing.Router, []
  end

  get "/" do
    conn
    |> send_resp(200, "Hello World!")
    |> halt
  end

  match _ do
    conn
    |> send_resp(404, "whatever not found.")
    |> halt
  end
end
