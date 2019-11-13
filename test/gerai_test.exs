defmodule GeraiTest do
  use ExUnit.Case
  use Plug.Test

  # doctest Gerai

  @cache_server_name GeraiJson
  @opts Gerai.Router.init([])

  describe "client (CRUD)" do
    test "get" do
      json =
        "{\"name\":\"The Turin Horse\",\"id\":\"tt1316540\",\"genre\":[\"Drama\"],\"directed_by\":[\"Béla Tarr\"]}"

      assert Gerai.get("tt1316540") == json
    end
  end

  describe "Cache server" do
    test "start" do
      {status, _pid} = GenServer.start(Gerai.Cache, nil)
      assert status == :ok
    end

    test "get call" do
      json =
        "{\"name\":\"The Turin Horse\",\"id\":\"tt1316540\",\"genre\":[\"Drama\"],\"directed_by\":[\"Béla Tarr\"]}"

      id = "tt1316540"
      assert GenServer.call(@cache_server_name, {:get, id}) == json
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

    test "get by id" do
      json =
        "{\"name\":\"The Turin Horse\",\"id\":\"tt1316540\",\"genre\":[\"Drama\"],\"directed_by\":[\"Béla Tarr\"]}"

      conn =
        :get
        |> conn("/?id=tt1316540", "")
        |> Gerai.Router.call(@opts)

      assert conn.resp_body == json
      assert conn.status == 200
    end
  end
end
