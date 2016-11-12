defmodule YelpTest do
  use ExUnit.Case, async: false
  use ExVCR.Mock, adapter: ExVCR.Adapter.Hackney

  test "stores a cache config" do
    use_cassette "fixture/yelp#1" do
      Yelp.lookup({:term, "pizza", "SF"})
      {:ok, lookup} = Yelp.lookup({:term, "pizza", "SF"})
      assert lookup["total"] == 2319
    end
  end

  describe "lookup" do
    test "has a lookup function" do
      use_cassette "fixture/yelp#1" do
        {:ok, pizzerias} = Yelp.lookup({:term, "pizza", "SF"})

        assert pizzerias["total"] == 2319
      end
    end

    test "geolookup" do
      use_cassette "fixture/yelpgeo" do
        {:ok, biz} = Yelp.lookup({:geo, %{
          "latitude" => 37.760488699999996,
          "longitude" => -122.41708100000001,
          "term" => "food"
        }})
        assert biz["total"] == 6732
      end
    end
  end

end
