defmodule Web.AdminApi.AuthView do
  use Web, :view

  def render("login.proto", %{admin: admin}) do
    %{
      auth_token: admin.auth_token
    }
    |> Proto.validate!(Proto.AdminAuthentication.LoginResponse)
    |> Proto.AdminAuthentication.LoginResponse.new()
  end
end
