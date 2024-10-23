defmodule ProtoEngine do
  def encode_to_iodata!(artifact) do
    Sentry.Context.set_extra_context(%{phoenix_resp_protobuf: artifact})

    artifact |> artifact.__struct__.encode()
  end
end
