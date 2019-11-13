defmodule Gerai.Cache do
  @moduledoc false
  use GenServer

  # required to start cache server up in Supervisor tree
  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, nil, options)
  end

  def init(_args) do
    state = %{}
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

  def handle_call({:delete, id}, _from, state) do
    new_state = Map.delete(state, id)

    state_size = Map.size(state)
    new_state_size = Map.size(new_state)

    status = if state_size != new_state_size, do: :ok, else: :error
    {:reply, status, new_state}
  end
end
