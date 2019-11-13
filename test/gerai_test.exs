defmodule GeraiTest do
  use ExUnit.Case
  use Plug.Test

  # doctest Gerai

  @cache_server_name GeraiJson
  @opts Gerai.Router.init([])

  setup_all do
    {:ok,
     id: "tt1316540",
     json:
       "{\"name\":\"The Turin Horse\",\"id\":\"tt1316540\",\"genre\":[\"Drama\"],\"directed_by\":[\"Béla Tarr\"]}",
     put_id: "1234",
     put_json:
       "{\"name\":\"article\",\"id\":\"1234\",\"components\":[{\"name\":\"article_body\",\"location\":\"/path/to/article/content\"}]}"}
  end

  describe "client (CRUD)" do
    test "get json", context do
      assert Gerai.get(context.id) == {:ok, context.json}
    end

    test "put json", context do
      assert Gerai.put(context.put_json) == :ok
      assert Gerai.get(context.put_id) == {:ok, context.put_json}
    end

    test "put handles malformed json" do
      assert Gerai.put("this is not a valid json string") == :error

      # json with missing id
      obj = %{"directed_by" => ["Hirokazu Koreeda"]}
      assert Gerai.put(Poison.encode!(obj)) == :error
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

    test "put call", context do
      assert GenServer.call(@cache_server_name, {:put, context.json}) == :ok
    end
  end

  describe "HTTP REST" do
    test "GET /" do
      conn =
        :get
        |> conn("/", "")
        |> Gerai.Router.call(@opts)

      assert conn.resp_body == "Welcome"
      assert conn.status == 200
    end

    test "GET 404" do
      conn =
        :get
        |> conn("/not_part_of_the_api", "")
        |> Gerai.Router.call(@opts)

      assert conn.resp_body == "Oops"
      assert conn.status == 404
    end

    test "GET by id", context do
      conn =
        :get
        |> conn("/?id=#{context.id}", "")
        |> Gerai.Router.call(@opts)

      assert conn.resp_body == context.json
      assert conn.status == 200
    end

    test "PUT json", context do
      conn =
        :put
        |> conn("/", context.put_json)
        |> Gerai.Router.call(@opts)

      assert conn.resp_body == "Put successfully"
      assert conn.status == 200

      # ensure json is in the cache
      assert Gerai.get(context.put_id) == {:ok, context.put_json}
    end

    test "PUT handles malformed json" do
      conn =
        :put
        |> conn("/", "not valid json")
        |> Gerai.Router.call(@opts)

      assert conn.resp_body == "Oops"
      assert conn.status == 501
    end

    test "POST json" do
      new_json = "{\"name\":\"blog title\",\"id\":\"uk-1234\", \"content\": \"content of blog\"}"

      conn =
        :post
        |> conn("/", new_json)
        |> Gerai.Router.call(@opts)

      assert conn.resp_body == "Post successfully"
      assert conn.status == 200

      # ensure json is in the cache
      assert Gerai.get("uk-1234") == {:ok, new_json}
    end

    test "POST handles malformed json" do
      conn =
        :post
        |> conn("/", "not valid json")
        |> Gerai.Router.call(@opts)

      assert conn.resp_body == "Oops"
      assert conn.status == 501
    end
  end
end
