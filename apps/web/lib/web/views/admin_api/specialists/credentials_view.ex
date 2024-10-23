defmodule Web.AdminApi.Specialists.CredentialsView do
  use Web, :view

  def render("show.proto", %{credentials: credentials}) do
    %{
      credentials:
        render_one(credentials, Proto.SpecialistProfileView, "credentials.proto",
          as: :credentials
        )
    }
    |> Proto.validate!(Proto.SpecialistProfile.GetCredentialsResponse)
    |> Proto.SpecialistProfile.GetCredentialsResponse.new()
  end
end
