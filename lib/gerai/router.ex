defmodule Gerai.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn = fetch_query_params(conn)
    params = conn.query_params
    send_resp(conn, 200, get(params["id"]))
  end

  put "/" do
    {read_status, json, _} = read_body(conn)

    if read_status == :ok do
      status = Gerai.put(json)

      case status do
        :ok -> send_resp(conn, 200, "Put successfully")
        :error -> send_resp(conn, 501, "Oops")
      end
    else
      send_resp(conn, 501, "Oops")
    end
  end

  post "/" do
    {read_status, json, _} = read_body(conn)

    if read_status == :ok do
      status = Gerai.put(json)

      case status do
        :ok -> send_resp(conn, 200, "Post successfully")
        :error -> send_resp(conn, 501, "Oops")
      end
    else
      send_resp(conn, 501, "Oops")
    end
  end

  match _ do
    send_resp(conn, 404, "Oops")
  end

  defp get(""), do: "Welcome"
  defp get(nil), do: "Welcome"

  defp get(id) do
    {_status, json} = Gerai.get(id)
    if json, do: json, else: "Welcome"
  end
end
