defmodule Gerai do
  @moduledoc """
  Client functions for caching JSON objects.

  ## Examples

      iex> Gerai.put("tt1454468", "{\\\"name\\\":\\\"Gravity\\\",\\\"id\\\":\\\"tt1454468\\\"}")
      :ok

      iex> Gerai.get("tt1454468")
      {:ok, "{\\\"name\\\":\\\"Gravity\\\",\\\"id\\\":\\\"tt1454468\\\"}"}

      iex> Gerai.put("tt1316540", "{\\\"name\\\":\\\"The Turin Horse\\\",\\\"id\\\":\\\"tt1316540\\\"}")
      :ok

      iex> Gerai.get(:all)
      {:ok,
       ["{\\\"name\\\":\\\"The Turin Horse\\\",\\\"id\\\":\\\"tt1316540\\\"}",
        "{\\\"name\\\":\\\"Gravity\\\",\\\"id\\\":\\\"tt1454468\\\"}"]}

      iex> Gerai.delete("tt1454468")
      :ok
  """

  @cache_server_name GeraiJson

  @doc """
  Retrieve JSON objects from cache by ID or `:all`
  """
  @spec get(binary | :all) :: {:ok, binary | list[binary]} | {:error, nil}
  def get(id), do: GenServer.call(@cache_server_name, {:get, id})

  @doc """
  Cache a serialised JSON by ID
  """
  # TODO: perhaps in asyncronuous mode with `cast/handle_cast`
  # handles both post and put requests
  @spec put(binary, binary) :: :ok | :error
  def put("", _), do: :error
  def put(nil, _), do: :error
  def put(id, json), do: GenServer.call(@cache_server_name, {:put, id, json})

  @doc """
  Delete a JSON object from cache by ID
  """
  # TODO: perhaps in asyncronuous mode with `cast/handle_cast`
  @spec delete(binary) :: :ok | :error
  def delete(id), do: GenServer.call(@cache_server_name, {:delete, id})
end
