defmodule YelpTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  setup do
    root_url = "http://testapi.yelp.com"
    # cfg = Application.get_all_env(:yelp)
    # {:ok, pid} = Yelp.start_link(cfg)
    # on_exit fn ->
      # GenServer.stop(pid)
    # end
    {:ok, root_url: root_url}
  end

  test "stores a cache config" do
    use_cassette "fixture/yelp#1" do
      Yelp.lookup("pizza", "SF")
      {:ok, lookup} = Yelp.cached_lookup("pizza", "SF")
      assert Keyword.get(lookup, :total) == 2319
    end
  end

  describe "lookup" do
    test "has a lookup function" do
      use_cassette "fixture/yelp#1" do
        pizzerias = Yelp.lookup("pizza", "SF")

        assert is_list(pizzerias[:businesses])
      end
    end
  end

end