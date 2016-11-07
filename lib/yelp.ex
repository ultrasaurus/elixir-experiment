defmodule YelpServer do
  use GenServer
  require OAuther
  require Poison

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def lookup(pid, query, location) do
    GenServer.call(pid, {:lookup, query, location})
  end

  def config(pid) do
    GenServer.call(pid, {:config})
  end

  def init() do
    root_url = Application.get_env(:yelp, :root_url)
    creds = OAuther.credentials(Application.get_env(:yelp, :oauth))
    {:ok, %{root_url: root_url, creds: creds}}
  end

  def handle_call({:config}, _from, state) do
    {:reply, state}
  end

  def handle_call({:lookup, query, location}, _from_pid, state) do
    {:ok, config} = state
    IO.puts(config)
    # {:root_url, root_url} = config
    # {:creds, creds} = config

    # query = [{"term", query}, {"location", location}]

    # url = "#{root_url}/v2/search"

    # params = OAuther.sign("get", url, query, creds)
    # {header, req_params} = OAuther.header(params)

    # headers = [header]
    # qs = :hackney_url.qs(req_params)

    # case make_request("#{url}?#{qs}", [header], req_params) do
    #   {:body, status_code, decoded} ->
    #     {:reply, decoded, state}
    #   _ ->
    #     {:reply, state}
    # end
  end

  defp make_request(url, headers, req_params) do
    case :hackney.get(url, headers, {:form, req_params}) do
      {:ok, status_code, _resp_headers, client_ref} ->
        {:ok, body} = :hackney.body(client_ref)
        {:ok, decoded} = Poison.decode(body)
        {:resp, status_code, decoded}
      _ -> {:error}
    end
  end

end