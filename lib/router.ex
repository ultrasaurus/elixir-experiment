defmodule Thing.Router do
  use Plug.Router
  require Logger
  require EEx
  require OAuther

  # plug Plug.Logger
  plug Plug.Parsers,
    parsers: [:urlencoded, :multipart, :json],
    pass: ["*/*"],
    json_decoder: Poison
  plug :match
  plug :dispatch

  @table :delivery_lookup

  def init(options) do
    options
  end

  def start_link do
    {:ok, _} = Plug.Adapters.Cowboy.http Thing.Router, []
  end

  get "/" do
    conn
    |> send_resp(200, Thing.hello)
    |> halt
  end

  # get "/:name" do
  #   conn
  #   |> send_resp(200, Thing.hello("#{name}"))
  #   |> halt
  # end

  ## 1. Authenticate with uber
  ## 2. Make a delivery request
  ## 3. Register a webhook 
  ## 4. Update UI
  get "/auth" do
    auth_page = EEx.eval_file("templates/auth.html")
    conn
    |> put_resp_header("Content-Type", "text/html")
    |> send_resp(200, auth_page)
    |> halt
  end

  get "/search" do
    # TODO: Move
    search_page = EEx.eval_file("templates/search.html")
    conn
      |> put_resp_header("content-type", "text/html")
      |> send_resp(200, search_page)
      |> halt
  end

  post "/search" do
    {:ok, body} = Yelp.lookup(Yelp, conn.params["query"], conn.params["location"])
    payload = body 
    |> Enum.into(%{}) 
    |> Poison.Encoder.encode([])  

    conn
      |> put_resp_header("content-type", "application/json")
      |> send_resp(200, payload)
      |> halt
  end

 
  post "/postmates/webhook" do
    # id = conn.params["id"]
    data = conn.params["data"]
    delivery_id = conn.params["delivery_id"]
    status = data["status"]

    :ets.insert(@table, {:"#{delivery_id}", :"#{status}"})

    body = %{
      id: delivery_id,
      status: status
    } |> Poison.Encoder.encode([])    

    conn
    |> put_resp_header("content-type", "application/json")
    |> send_resp(200, body)
    |> halt
  end

  match _ do
    conn
    |> send_resp(404, "whatever not found.")
    |> halt
  end
end
