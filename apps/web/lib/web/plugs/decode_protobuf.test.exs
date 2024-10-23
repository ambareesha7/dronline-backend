defmodule ExampleProto do
  @moduledoc false
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
          text: String.t()
        }
  defstruct [:text]

  field(:text, 1, type: :string)
end

defmodule Web.Plugs.DecodeProtobufTest do
  use Web.ConnCase, async: true
  import Mockery

  alias Web.Plugs.DecodeProtobuf

  @proto %ExampleProto{text: "example"} |> ExampleProto.encode()

  test "decodes message from body" do
    conn =
      :get
      |> build_conn("/", @proto)
      |> put_req_header("content-type", "application/x-protobuf")
      |> DecodeProtobuf.call(ExampleProto)

    assert %ExampleProto{text: "example"} = conn.assigns.protobuf
  end

  test "decodes message from chunked body" do
    mock(Plug.Conn, [read_body: 1], fn conn ->
      Plug.Conn.read_body(conn, length: 1)
    end)

    conn =
      :get
      |> build_conn("/", @proto)
      |> put_req_header("content-type", "application/x-protobuf")
      |> DecodeProtobuf.call(ExampleProto)

    assert %ExampleProto{text: "example"} = conn.assigns.protobuf
  end

  test "returns 400 and halts when content-type is invalid", %{conn: conn} do
    conn =
      conn
      |> put_req_header("content-type", "application/json")
      |> DecodeProtobuf.call(ExampleProto)

    assert conn.halted
    assert response(conn, 400)
  end

  test "returns 400 and halts when body can't be read", %{conn: conn} do
    mock(Plug.Conn, :read_body, {:error, :closed})

    conn =
      conn
      |> put_req_header("content-type", "application/x-protobuf")
      |> DecodeProtobuf.call(ExampleProto)

    assert conn.halted
    assert response(conn, 400)
  end
end
