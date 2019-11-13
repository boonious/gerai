defmodule GeraiTest do
  use ExUnit.Case
  # doctest Gerai

  describe "client (CRUD)" do
    test "get" do
      json =
        "{\"name\":\"The Turin Horse\",\"id\":\"tt1316540\",\"genre\":[\"Drama\"],\"directed_by\":[\"Béla Tarr\"]}"

      assert Gerai.get("tt1316540") == json
    end
  end

  describe "Cache server" do
    test "start" do
      {status, _pid} = GenServer.start(Gerai.Cache, nil)
      assert status == :ok
    end
  end
end
