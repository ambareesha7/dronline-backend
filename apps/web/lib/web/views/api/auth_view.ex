defmodule Web.Api.AuthView do
  use Web, :view

  def render("login.proto", %{patient: patient}) do
    %{
      auth_token: patient.auth_token
    }
    |> Proto.validate!(Proto.Authentication.LoginResponse)
    |> Proto.Authentication.LoginResponse.new()
  end
end
