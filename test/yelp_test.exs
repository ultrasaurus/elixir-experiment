defmodule YelpTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  test "stores a cache config" do
    use_cassette "fixture/yelp#1" do
      Yelp.lookup("pizza", "SF")
      {:ok, lookup} = Yelp.cached_lookup("pizza", "SF")
      assert lookup[:total] == 2319
    end
  end

  describe "lookup" do
    test "has a lookup function" do
      use_cassette "fixture/yelp#1" do
        {:ok, pizzerias} = Yelp.lookup("pizza", "SF")

        assert is_list(pizzerias[:businesses])
        assert pizzerias[:total] == 2319
      end
    end
  end

end
