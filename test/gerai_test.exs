defmodule GeraiTest do
  use ExUnit.Case
  use Plug.Test

  # doctest Gerai

  @cache_server_name GeraiJson
  @opts Gerai.Router.init([])

  setup_all do
    json =
      "{\"name\":\"The Turin Horse\",\"id\":\"tt1316540\",\"genre\":[\"Drama\"],\"directed_by\":[\"Béla Tarr\"]}"

    id = "tt1316540"

    {:ok, json: json, id: id}
  end

  describe "client (CRUD)" do
    test "get", context do
      assert Gerai.get(context.id) == {:ok, context.json}
    end
  end

  describe "Cache server" do
    test "start" do
      {status, _pid} = GenServer.start(Gerai.Cache, nil)
      assert status == :ok
    end

    test "get call", context do
      assert GenServer.call(@cache_server_name, {:get, context.id}) == {:ok, context.json}
    end
  end

  describe "HTTP REST" do
    test "get /" do
      conn =
        :get
        |> conn("/", "")
        |> Gerai.Router.call(@opts)

      assert conn.resp_body == "Welcome"
      assert conn.status == 200
    end

    test "get 404" do
      conn =
        :get
        |> conn("/not_part_of_the_api", "")
        |> Gerai.Router.call(@opts)

      assert conn.resp_body == "Oops"
      assert conn.status == 404
    end

    test "get by id", context do
      conn =
        :get
        |> conn("/?id=#{context.id}", "")
        |> Gerai.Router.call(@opts)

      assert conn.resp_body == context.json
      assert conn.status == 200
    end
  end
end
