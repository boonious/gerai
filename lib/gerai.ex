defmodule Gerai do
  @moduledoc """
  Documentation for Gerai.
  """

  @cache_server_name GeraiJson

  @doc """
  Get a serialised JSON from cache by ID

  ## Examples

      iex> Gerai.get("tt1316540")
      "{\\\"name\\\":\\\"The Turin Horse\\\",\\\"id\\\":\\\"tt1316540\\\",\\\"genre\\\":[\\\"Drama\\\"],\\\"directed_by\\\":[\\\"Béla Tarr\\\"]}"

  """
  @spec get(binary) :: binary
  def get(id), do: GenServer.call(@cache_server_name, {:get, id})
end
