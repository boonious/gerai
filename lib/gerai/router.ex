defmodule Gerai.Router do
  use Plug.Router

  plug(:match)
  plug(:dispatch)

  get "/" do
    conn = fetch_query_params(conn)
    params = conn.query_params
    send_resp(conn, 200, get(params["id"]))
  end

  match _ do
    send_resp(conn, 404, "Oops")
  end

  defp get(""), do: "Welcome"
  defp get(nil), do: "Welcome"

  defp get(id) do
    json = Gerai.get(id)
    if json, do: json, else: "Welcome"
  end
end
