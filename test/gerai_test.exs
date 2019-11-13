defmodule GeraiTest do
  use ExUnit.Case
  doctest Gerai

  test "greets the world" do
    assert Gerai.hello() == :world
  end
end
