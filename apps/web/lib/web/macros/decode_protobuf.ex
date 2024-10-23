defmodule Web.Macros.DecodeProtobuf do
  @plug Web.Plugs.DecodeProtobuf

  defmacro __using__(_opts) do
    quote do
      Module.register_attribute(__MODULE__, :req_protos, accumulate: true)
      @before_compile unquote(__MODULE__)
      @on_definition unquote(__MODULE__)
    end
  end

  def __on_definition__(env, _kind, name, _args, _guards, _body) do
    if proto_module = Module.get_attribute(env.module, :decode) do
      Module.put_attribute(env.module, :req_protos, %{action: name, proto_module: proto_module})
      Module.delete_attribute(env.module, :decode)
    end
  end

  defmacro __before_compile__(env) do
    req_protos = Module.get_attribute(env.module, :req_protos)

    plugs =
      Enum.map(req_protos, fn req_proto ->
        handle_req_proto(req_proto)
      end)

    quote do
      unquote(plugs)
    end
  end

  defp handle_req_proto(%{action: action, proto_module: proto_module}) do
    quote do
      plug unquote(@plug), unquote(proto_module) when var!(action) in [unquote(action)]
    end
  end
end
