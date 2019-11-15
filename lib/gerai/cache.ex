defmodule Gerai.Cache do
  @moduledoc false
  use GenServer

  # fire up the cache server, e.g. on application startup
  # via the Supervisor tree child spec - Gerai.Application
  def start_link(options \\ []) do
    GenServer.start_link(__MODULE__, nil, options)
  end

  @impl true
  def init(_args) do
    state = %{}
    {:ok, state}
  end

  # implemnting callbacks to handle CRUD features
  # TODO: explore the use of asynchrounous callbacks for some requests

  @impl true
  def handle_call({:get, :all}, _from, state) do
    {:reply, {:ok, Map.values(state)}, state}
  end

  @impl true
  def handle_call({:get, id}, _from, state) do
    object = Map.get(state, id)
    reply = if object, do: {:ok, object}, else: {:error, nil}
    {:reply, reply, state}
  end

  @impl true
  def handle_call({:put, id, json_s}, _from, state) when is_binary(json_s) do
    resp = Poison.decode(json_s)
    status = elem(resp, 0)

    if status == :ok do
      {:reply, :ok, Map.put(state, id, json_s)}
    else
      {:reply, :error, state}
    end
  end

  @impl true
  def handle_call({:delete, id}, _from, state) do
    new_state = Map.delete(state, id)

    state_size = Map.size(state)
    new_state_size = Map.size(new_state)

    status = if state_size != new_state_size, do: :ok, else: :error
    {:reply, status, new_state}
  end
end
