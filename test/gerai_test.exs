# TODO: need refactoring, cleaning and breaking up
# Could write a suite of HTTP tests with Bypass, and performance testing as well
defmodule GeraiTest do
  use ExUnit.Case
  use Plug.Test

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
      Gerai.put(context.id, context.json)
      assert Gerai.get(context.id) == {:ok, context.json}
    end

    test "get all jsons" do
      Gerai.put("test_all1", "{\"id\":\"test_all1\"}")
      Gerai.put("test_all2", "{\"id\":\"test_all2\"}")
      Gerai.put("test_all3", "{\"id\":\"test_all3\"}")

      {status, json_list} = Gerai.get(:all)
      objects = Enum.filter(json_list, fn x -> String.match?(x, ~r/test_all/) end)

      assert status == :ok
      assert length(objects) == 3
    end

    test "put json", context do
      assert Gerai.put(context.put_id, context.put_json) == :ok
      assert Gerai.get(context.put_id) == {:ok, context.put_json}
    end

    test "put handles malformed json" do
      assert Gerai.put("id", "this is not a valid json string") == :error

      # json with missing id
      obj = %{"directed_by" => ["Hirokazu Koreeda"]}
      assert Gerai.put("", Poison.encode!(obj)) == :error
    end

    test "delete json" do
      id = "uk-sport-1234"

      new_json =
        "{\"name\":\"sport blog title\",\"id\":\"uk-sport-1234\", \"content\": \"content of sport blog\"}"

      Gerai.put(id, new_json)

      # make sure content is in the cache for deletion
      assert Gerai.get(id) == {:ok, new_json}

      # delete json and make sure it no longer in the cache
      assert Gerai.delete(id) == :ok
      assert Gerai.get(id) == {:error, nil}
    end

    test "delete non-existing json" do
      assert Gerai.delete("not-existing-id") == :error
    end
  end

  describe "Cache server" do
    test "start" do
      {status, _pid} = GenServer.start(Gerai.Cache, nil)
      assert status == :ok
    end

    test "get call", context do
      Gerai.put(context.id, context.json)
      assert GenServer.call(@cache_server_name, {:get, context.id}) == {:ok, context.json}
    end

    test "put call", context do
      assert GenServer.call(@cache_server_name, {:put, context.id, context.json}) == :ok
    end

    test "delete call" do
      new_json =
        "{\"name\":\"politics blog title\",\"id\":\"uk-politics-678\", \"content\": \"content of politics blog\"}"

      id = "uk-politics-678"

      Gerai.put(id, new_json)

      assert GenServer.call(@cache_server_name, {:delete, id}) == :ok
      assert Gerai.get(id) == {:error, nil}
    end
  end

  describe "HTTP REST" do
    test "GET /" do
      Gerai.put("http_all1", "{\"id\":\"http_all1\"}")
      Gerai.put("http_all2", "{\"id\":\"http_all2\"}")

      conn =
        :get
        |> conn("/", "")
        |> Gerai.Router.call(@opts)

      assert String.contains?(conn.resp_body, "{\"id\":\"http_all1\"}")
      assert String.contains?(conn.resp_body, "{\"id\":\"http_all2\"}")
      assert conn.status == 200
    end

    test "GET 404" do
      conn =
        :get
        |> conn("/not_part_of_the_api", "")
        |> Gerai.Router.call(@opts)

      assert conn.resp_body == "Not Found"
      assert conn.status == 404
    end

    test "GET by id" do
      new_json =
        "{\"name\":\"music blog title\",\"id\":\"uk-music-678\", \"content\": \"content of music blog\"}"

      Gerai.put("uk-music-678", new_json)

      conn =
        :get
        |> conn("/?id=uk-music-678", "")
        |> Gerai.Router.call(@opts)

      assert conn.resp_body == new_json
      assert conn.status == 200
    end

    test "PUT json", context do
      Gerai.delete(context.put_id)

      conn =
        :put
        |> conn("/#{context.put_id}", context.put_json)
        |> Gerai.Router.call(@opts)

      assert conn.resp_body == "Created"
      assert conn.status == 201

      # ensure json is in the cache
      assert Gerai.get(context.put_id) == {:ok, context.put_json}

      # update json
      conn =
        :put
        |> conn("/#{context.put_id}", context.put_json)
        |> Gerai.Router.call(@opts)

      assert conn.resp_body == "OK"
      assert conn.status == 200
    end

    test "PUT handles malformed json" do
      conn =
        :put
        |> conn("/not_valid_json_id")
        |> Gerai.Router.call(@opts)

      assert conn.resp_body == "Internal Server Error"
      assert conn.status == 500
    end

    test "POST json" do
      new_json = "{\"name\":\"blog title\",\"id\":\"uk-1234\", \"content\": \"content of blog\"}"

      conn =
        :post
        |> conn("/uk-1234", new_json)
        |> Gerai.Router.call(@opts)

      assert conn.resp_body == "OK"
      assert conn.status == 200

      # ensure json is in the cache
      assert Gerai.get("uk-1234") == {:ok, new_json}
    end

    test "POST handles malformed json" do
      conn =
        :post
        |> conn("/not_valid_json_post_id")
        |> Gerai.Router.call(@opts)

      assert conn.resp_body == "Internal Server Error"
      assert conn.status == 500
    end

    test "DELETE json" do
      new_json =
        "{\"name\":\"O2 ATP final\",\"id\":\"uk-tennis-123\", \"content\": \"match report of the ATP final\"}"

      id = "uk-tennis-123"

      Gerai.put(id, new_json)
      assert Gerai.get(id) == {:ok, new_json}

      conn =
        :delete
        |> conn("/#{id}", nil)
        |> Gerai.Router.call(@opts)

      assert conn.resp_body == "OK"
      assert Gerai.get(id) == {:error, nil}
    end

    test "DELETE handles non existing json" do
      conn =
        :delete
        |> conn("/not-existing-json-id")
        |> Gerai.Router.call(@opts)

      assert conn.resp_body == ""
      assert conn.status == 204
    end
  end
end
