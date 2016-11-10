defmodule Yelp do
  use GenServer
  # use Mix.Config
  require OAuther
  require Poison
  require HTTPoison

  @table :yelp_responses

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def lookup(query, location) do
    GenServer.call(__MODULE__, {:lookup, query, location})
  end

  def cached_lookup(query, location) do
    GenServer.call(__MODULE__, {:cached_lookup, query, location})
  end

  def config() do
    GenServer.call(__MODULE__, {:config})
  end

  def init(_) do
    # :ets.new(@table, [:set, :named_table, :public])
    cache = :ets.new(@table, [:set, :named_table, :public])
    {:ok, {cache}}
  end

  def handle_call({:config}, _from, {cache}) do
    {:reply, {cache}, {cache}}
  end

  def handle_call({:cached_lookup, query, location}, _, {cache}) do
    cache_key = :"#{query}/#{location}"
    case :ets.lookup(cache, cache_key) do
      [{^cache_key, resp}] -> {:reply, {:ok, resp}, {cache}}
      [] -> 
        {:reply, {:error, :not_found}, {cache}}
    end
  end

  def handle_call({:lookup, term, location}, _from_pid, {cache}) do
    cache_key = :"#{term}/#{location}"
    case :ets.lookup(cache, cache_key) do
      [{^cache_key, resp}] -> {:reply, {:ok, resp}, {cache}}
      _ -> case yelp_call(term, location) do
        {:ok, resp} -> 
          :ets.insert(cache, {cache_key, resp})
          {:reply, {:ok, resp}, {cache}}
        {:error, reason} -> {:error, reason, {cache}}
      end
    end
  end

  defp yelp_call(term, location) do
    query = [{"term", term}, {"location", location}]

    case get_request("/v2/search", query) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, process_body(body)}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "not_found"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp process_body(body) do
    body
    |> Poison.decode!
    |> to_atom
  end

  defp to_atom(map) when is_map(map) do
    map |> Enum.reduce(%{}, fn({k,v}, acc) ->
      key = k |> key_to_atom
      val = v |> to_atom
      acc |> Map.put(key, val)
    end)
  end
  defp to_atom(list) when is_list(list) do
    list |> Enum.map(fn(x) -> to_atom(x) end)
  end
  defp to_atom(tuple) when is_tuple(tuple) do
    tuple |> Tuple.to_list |> to_atom |> List.to_tuple
  end
  defp to_atom(v), do: v
  defp key_to_atom(k) do
    k |> String.to_atom
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