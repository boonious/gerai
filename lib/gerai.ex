defmodule Gerai do
  @moduledoc """
  Documentation for Gerai.
  """

  @doc """
  Get a serialised JSON from cache by ID

  ## Examples

      iex> Gerai.get("tt1316540")
      "{\\\"name\\\":\\\"The Turin Horse\\\",\\\"id\\\":\\\"tt1316540\\\",\\\"genre\\\":[\\\"Drama\\\"],\\\"directed_by\\\":[\\\"Béla Tarr\\\"]}"

  """
  @spec get(binary) :: binary
  def get(_id) do
    object = %{
      "directed_by" => ["Béla Tarr"],
      "genre" => ["Drama"],
      "id" => "tt1316540",
      "name" => "The Turin Horse"
    }

    Poison.encode!(object)
  end
end
