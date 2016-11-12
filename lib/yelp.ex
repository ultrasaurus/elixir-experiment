defmodule Yelp do
  use GenServer
  require OAuther
  require Poison
  require HTTPoison

  @table :yelp_responses

  def start_link(default) do
    GenServer.start_link(__MODULE__, default, name: __MODULE__)
  end

  def lookup({:geo, params}) do
    query = [
      {:ll, "#{params["latitude"]},#{params["longitude"]}"},
      {:term, params["term"]}
    ]
    GenServer.call(__MODULE__, {:lookup, query})
  end

  def lookup({:term, term, location}) do
    query = [{:term, term}, {:location, location}]
    GenServer.call(__MODULE__, {:lookup, query})
  end

  def cached_lookup(query, location) do
    GenServer.call(__MODULE__, {:cached_lookup, query, location})
  end

  def config() do
    GenServer.call(__MODULE__, {:config})
  end

  def init(_) do
    cache = :ets.new(@table, [:set, :named_table, :protected])
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

  def handle_call({:lookup, query}, _from_pid, {cache}) do
    
    # cache_key = :"#{term}/#{location}"
    key = cache_key(query)
    
    case :ets.lookup(cache, key) do
      [{^key, resp}] -> {:reply, {:ok, resp}, {cache}}
      _ -> case yelp_call(query) do
        {:ok, resp} -> 
          :ets.insert(cache, {key, resp})
          {:reply, {:ok, resp}, {cache}}
        {:error, reason} -> {:error, reason, {cache}}
      end
    end

  end

  defp yelp_call(query) do
    case get_request("/v2/search", query) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, process_body(body)}
      {:ok, %HTTPoison.Response{status_code: 404}} ->
        {:error, "not_found"}
      {:error, %HTTPoison.Error{reason: reason}} ->
        {:error, reason}
    end
  end

  defp cache_key(query) do
    str = query
      |> Enum.map(fn({k, v}) -> {Atom.to_string(k), to_qs(v)} end)
    {:ok, :hackney_url.qs(str)}
  end

  defp process_body(body) do
    body
    |> Poison.decode!
    |> to_atom
  end

  defp to_qs(v) when is_float(v) do
    Float.to_string(v)
  end
  defp to_qs(v) do
    v
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
  defp to_atom(float) when is_float(float) do
    Float.to_string(float)
  end
  defp to_atom(v), do: v
  defp key_to_atom(k) when is_list(k) do
    k |> String.to_atom
  end
  defp key_to_atom(k) do
    k
  end

  defp stringify({k, v}) when is_atom(k) do
    {Atom.to_string(k), v}
  end
  defp stringify({k, v}) do
    {k, v}
  end


  defp get_request(path, query) do
    url = route(path)
    creds = authCreds()

    str_query = Enum.map(query, &stringify/1)
    params = OAuther.sign("get", url, str_query, creds)
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