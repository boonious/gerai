defmodule Gerai do
  @moduledoc """
  Documentation for Gerai.

  ## Examples

      iex> Gerai.get("tt1316540")
      "{\\\"name\\\":\\\"The Turin Horse\\\",\\\"id\\\":\\\"tt1316540\\\",\\\"genre\\\":[\\\"Drama\\\"],\\\"directed_by\\\":[\\\"Béla Tarr\\\"]}"

  """

  @cache_server_name GeraiJson

  @doc """
  Get a serialised JSON from cache by ID
  """
  @spec get(binary) :: {:ok, binary} | {:error, nil}
  def get(id), do: GenServer.call(@cache_server_name, {:get, id})

  # TODO: implement as asyncronuous call `cast/handle_cast`
  @spec put(binary) :: :ok | :error
  def put(json), do: GenServer.call(@cache_server_name, {:put, json})
end
