defmodule Gerai.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn = fetch_query_params(conn)
    params = conn.query_params
    send_resp(conn, 200, get(params["id"]))
  end

  put "/:json_id" do
    {_, json, _} = read_body(conn)

    {id_exist?, _} = Gerai.get(json_id)
    put_status = Gerai.put(json_id, json)

    case {put_status, id_exist?} do
      {:error, _} -> send_resp(conn, 500, "Internal Server Error")
      {:ok, :error} -> send_resp(conn, 201, "Created")
      {:ok, :ok} -> send_resp(conn, 200, "OK")
    end
  end

  post "/:json_id" do
    {_, json, _} = read_body(conn)

    put_status = Gerai.put(json_id, json)

    case {put_status} do
      {:error} -> send_resp(conn, 500, "Internal Server Error")
      {:ok} -> send_resp(conn, 200, "OK")
    end
  end

  delete "/:json_id" do
    status = Gerai.delete(json_id)

    case status do
      :ok -> send_resp(conn, 200, "OK")
      :error -> send_resp(conn, 204, "")
    end
  end

  match _ do
    send_resp(conn, 404, "Not Found")
  end

  defp get(id) when id == "" or id == nil do
    {_, objects} = Gerai.get(:all)

    "[" <> Enum.join(objects, ",") <> "]"
  end

  defp get(id) do
    {_status, json} = Gerai.get(id)
    if json, do: json, else: "[]"
  end
end
