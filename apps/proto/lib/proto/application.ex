defmodule Proto.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    # initialize atoms in runtime
    _ = Proto.Generics.Title.__message_props__()
    _ = Proto.Channels.SocketMessage.ChannelPayload.__message_props__()
    _ = Proto.PanelAuthentication.LoginResponse.Type.__message_props__()

    children = []

    opts = [strategy: :one_for_one, name: Proto.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
