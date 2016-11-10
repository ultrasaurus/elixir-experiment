defmodule YelpTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney
  require HTTPoison

  setup_all do
    HTTPoison.start
  end

  setup do
    root_url = "http://testapi.yelp.com"
    cfg = Application.get_all_env(:yelp)
    {:ok, pid} = Yelp.start_link(cfg)
    {:ok, pid: pid, root_url: root_url}
  end

  describe "lookup" do
    test "has a lookup function", %{pid: pid} do
      use_cassette "fixture/yelp#1" do
        pizzerias = Yelp.lookup(pid, "pizza", "SF")

        assert is_list(pizzerias[:businesses])
      end
    end
  end

end