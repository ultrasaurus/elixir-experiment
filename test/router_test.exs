defmodule RouterTest do
  use ExUnit.Case
  use Plug.Test

  alias Thing.Router
  @opts Router.init([])

  def json_conn(body, content_type \\ "application/json") do
    conn(:post, "/postmates/webhook", body) 
      |> put_req_header("content-type", content_type)
      |> Router.call(@opts)
  end

  def file_conn(filename, content_type \\ "application/json") do
    {:ok, binary} = File.read("test/request/#{filename}")
    body = Poison.decode!(binary)
    conn(:post, "/postmates/webhook", body)
      |> put_req_header("content-type", content_type)
      |> Router.call(@opts)
  end

  def parse(conn, opts \\ []) do
    opts = opts
        |> Keyword.put_new(:parsers, [:json])
        |> Keyword.put_new(:json_decoder, JSON)
    Plug.Parsers.call(conn, Plug.Parsers.init(opts))
  end

  test "succeeds for root route" do
    conn = conn(:get, "/", "")
      |> Router.call([])

    assert conn.state == :sent
    assert conn.status == 200
  end

  test "post receives body" do
    conn = json_conn(%{id: 123}) 
      |> parse()    
    assert conn.params["id"] == 123
  end

  test "post receives event_id" do
    conn = file_conn("evt_L0krJi484soCo-")

    assert conn.params["id"] == "evt_L0krJi484soCo-"
    assert conn.params["delivery_id"] == "del_L0kr80FV9O15kk"
  end

  test "post stores delivery id" do
    [status] = :ets.match(:delivery_lookup, {:"del_L0kr80FV9O15kk", :"$1"})
    assert status == [:pickup]
  end

end