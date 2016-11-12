defmodule Thing.Router do
  use Plug.Router
  require Logger
  require EEx
  require OAuther

  if Mix.env == "dev" do
    plug Plug.Logger
  end

  plug Plug.Static, at: "/public", from: "public"
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
    homepage = EEx.eval_file("templates/home.html")
    conn
    |> put_resp_content_type("text/html")
    |> send_resp(200, homepage)
    |> halt
  end

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

  get "/order" do
    order_page = EEx.eval_file("templates/order.html")
    conn
    |> put_resp_header("content-type", "text/html")
    |> send_resp(200, order_page)
    |> halt
  end

  post "/aroundme" do
    geo = conn.params["geo"] |> Poison.Parser.parse!

    {:ok, body} = Yelp.lookup({:geo, Map.merge(geo, %{"term" => "food"})})
    payload = body |> Enum.into(%{}) |> Poison.Encoder.encode([])

    conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, payload)
      |> halt
  end

  post "/search" do
    lookup = {:term, conn.params["query"], conn.params["location"]}
    {:ok, body} = Yelp.lookup(lookup)
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
