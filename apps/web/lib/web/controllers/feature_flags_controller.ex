defmodule Web.PublicApi.FeatureFlagsController do
  use Web, :controller

  def verify(conn, params) do
    enabled =
      params["flag_name"]
      |> FeatureFlags.enabled?()

    conn |> render("verify.proto", %{enabled: enabled})
  end
end

defmodule Web.PublicApi.FeatureFlagsView do
  use Web, :view

  def render("verify.proto", %{enabled: enabled}) do
    %Proto.FeatureFlags.VerifyResponse{
      enabled: enabled
    }
  end
end
