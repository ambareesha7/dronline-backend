defmodule Web.PanelApi.AuthView do
  use Web, :view

  def render("login.proto", %{specialist: specialist}) do
    %{
      auth_token: specialist.auth_token,
      type:
        specialist.type
        |> Proto.enum(Proto.PanelAuthentication.LoginResponse.Type),
      active_package_type: specialist.package_type
    }
    |> Proto.validate!(Proto.PanelAuthentication.LoginResponse)
    |> Proto.PanelAuthentication.LoginResponse.new()
  end

  def render("verify.proto", %{specialist: specialist}) do
    %{
      auth_token: specialist.auth_token
    }
    |> Proto.validate!(Proto.PanelAuthentication.VerifyResponse)
    |> Proto.PanelAuthentication.VerifyResponse.new()
  end
end
