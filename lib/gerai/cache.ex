defmodule Gerai.Cache do
  @moduledoc false
  use GenServer

  def init(_args) do
    obj0 = %{
      "directed_by" => ["Béla Tarr"],
      "genre" => ["Drama"],
      "id" => "tt1316540",
      "name" => "The Turin Horse"
    }

    state = %{obj0["id"] => Poison.encode!(obj0)}
    {:ok, state}
  end

  def handle_call({:get, id}, _from, state) do
    {:reply, Map.get(state, id), state}
  end
end
