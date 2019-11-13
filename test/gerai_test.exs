defmodule GeraiTest do
  use ExUnit.Case
  # doctest Gerai

  describe "Gerai client" do
    test "get" do
      json =
        "{\"name\":\"The Turin Horse\",\"id\":\"tt1316540\",\"genre\":[\"Drama\"],\"directed_by\":[\"Béla Tarr\"]}"

      assert Gerai.get("tt1316540") == json
    end
  end
end
