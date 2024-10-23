defmodule Web.Api.ChannelsTokenView do
  use Web, :view

  def render("show.proto", %{token: token}) do
    %{
      token: token
    }
    |> Proto.validate!(Proto.Channels.GetTokenResponse)
    |> Proto.Channels.GetTokenResponse.new()
  end
end
