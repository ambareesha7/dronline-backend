defmodule Web.Plugs.DecodeProtobuf do
  use Web, :plug
  import Mockery.Macro

  require Logger

  @impl Plug
  def init(opts), do: opts

  @impl Plug
  def call(conn, protobuf_module) do
    with true <- protobuf_content?(conn),
         {:ok, binary, conn} <- parse_body(conn, "") do
      decoded = handle_protobuf(binary, protobuf_module)

      _ = Logger.info(fn -> "Protobuf: #{inspect(decoded)}" end)

      conn |> assign(:protobuf, decoded)
    else
      _ ->
        conn
        |> send_resp(400, "")
        |> halt()
    end
  end

  @sensitive [
    Proto.AdminAuthentication.LoginRequest,
    Proto.PanelAuthentication.LoginRequest,
    Proto.PanelAuthentication.RecoverPasswordRequest,
    Proto.PanelAuthentication.SignupRequest
  ]

  # don't store login credentials in sentry
  defp handle_protobuf(binary, protobuf_module) when protobuf_module in @sensitive do
    decoded = mockable(__MODULE__).decode(protobuf_module, binary)
    Sentry.Context.set_extra_context(%{phoenix_req_protobuf: inspect(decoded)})

    decoded
  end

  defp handle_protobuf(binary, protobuf_module) do
    Sentry.Context.set_extra_context(%{phoenix_raw_req_protobuf: Base.encode64(binary)})

    decoded = mockable(__MODULE__).decode(protobuf_module, binary)
    Sentry.Context.set_extra_context(%{phoenix_req_protobuf: decoded})

    decoded
  end

  @doc false
  def decode(protobuf_module, binary) do
    protobuf_module.decode(binary)
  rescue
    e in Protobuf.DecodeError ->
      e
  end

  defp protobuf_content?(conn) do
    case get_req_header(conn, "content-type") do
      ["application/x-protobuf" <> _] ->
        true

      _ ->
        false
    end
  end

  def parse_body(%Plug.Conn{} = conn, acc \\ "") do
    case mockable(Plug.Conn).read_body(conn) do
      {:ok, body, next_conn} ->
        {:ok, acc <> body, next_conn}

      {:more, body, next_conn} ->
        parse_body(next_conn, acc <> body)

      other ->
        other
    end
  end
end
