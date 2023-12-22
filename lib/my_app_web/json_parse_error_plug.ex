defmodule MyAppWeb.JSONParseErrorPlug do
  import Plug.Conn

  def init(opts) do
    opts
  end

  def call(conn, _opts) do
    case get_req_header(conn, "content-type") do
      [] -> handle_json_body(conn)
      [content_type] ->
        case content_type do
          << "multipart/form-data", _rest :: binary >> -> conn
          _ -> handle_json_body(conn)
        end
    end
  end


  defp handle_json_body(conn) do
    case Plug.Conn.read_body(conn) do
      {:error, :timeout} ->
        raise Plug.TimeoutError

      {:error, _} ->
        raise Plug.BadRequestError

      {:more, _, conn} ->
        error = %{errors: %{detail: "Payload too large"}}
        render_error(conn, error)

      {:ok, "", conn} ->
        body = "{}"
        update_in(conn.assigns[:raw_body], &[body | &1 || []])

      {:ok, body, conn} ->
        case Jason.decode(body) do
          {:ok, _result} ->
            update_in(conn.assigns[:raw_body], &[body | &1 || []])

          {:error, _reason} ->
            error = %{errors: %{detail: "Malformed JSON in the body"}}
            render_error(conn, error)
        end
    end
  end

  def render_error(conn, error) do
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(400, Jason.encode!(error))
    |> halt
  end
end
