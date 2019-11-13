defmodule Gerai.Cache do
  @moduledoc false
  use GenServer

  # required to start cache server up in Supervisor tree
  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, nil, options)
  end

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
    object = Map.get(state, id)
    reply = if object, do: {:ok, object}, else: {:error, nil}
    {:reply, reply, state}
  end

  def handle_call({:put, json_s}, _from, state) when is_binary(json_s) do
    {status, object} = Poison.decode(json_s)

    if status == :ok and object["id"] do
      {:reply, :ok, Map.put(state, object["id"], json_s)}
    else
      {:reply, :error, state}
    end
  end
end
