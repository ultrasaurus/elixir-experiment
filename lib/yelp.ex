defmodule Yelp do
  use GenServer
  # use Mix.Config
  require OAuther
  require Poison
  require HTTPoison

  def start_link(default) do
    GenServer.start_link(__MODULE__, default)
  end

  def lookup(pid, query, location) do
    GenServer.call(pid, {:lookup, query, location})
  end

  def config(pid) do
    GenServer.call(pid, {:config})
  end

  def init(config) do
    {:ok, config}
  end

  def handle_call({:config}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:lookup, term, location}, _from_pid, state) do
    # {:yelp, config} = state
    query = [{"term", term}, {"location", location}]
    url = route("/v2/search")

    case get_request("/v2/search", query) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:reply, process_body(body), state}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:reply, %{error: "not_found"}, state}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:reply, %{error: reason}, state}
    end
  end

  defp process_body(body) do
    body
    |> Poison.decode!
    |> Enum.map(fn({k, v}) -> {String.to_atom(k), v} end)
  end

  defp get_request(path, query) do
    url = route(path)
    creds = authCreds()
    params = OAuther.sign("get", url, query, creds)
    {header, req_params} = OAuther.header(params)
    headers = [header] 
    HTTPoison.get(url, headers, [params: req_params])
  end

  defp authCreds() do
    config = Application.get_all_env(:thing)[:yelp]
    OAuther.credentials(config)
  end

  defp route(path) do
    "https://api.yelp.com#{path}"
  end

end