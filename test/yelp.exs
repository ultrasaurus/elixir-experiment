defmodule YelpServerTest do
  use ExUnit.Case, async: true

  setup do
    {:ok, pid} = YelpServer.start_link
  end

  test "can get" do
    IO.inspect(config)
    assert {:reply, config} = YelpServer.config(pid)
  end

end