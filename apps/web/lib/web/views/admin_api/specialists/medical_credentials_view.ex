defmodule Web.AdminApi.Specialists.MedicalCredentialsView do
  use Web, :view

  def render("show.proto", %{medical_credentials: medical_credentials}) do
    %{
      medical_credentials:
        render_one(medical_credentials, Proto.SpecialistProfileView, "medical_credentials.proto",
          as: :medical_credentials
        )
    }
    |> Proto.validate!(Proto.SpecialistProfile.GetMedicalCredentialsResponse)
    |> Proto.SpecialistProfile.GetMedicalCredentialsResponse.new()
  end

  def render("update.proto", %{medical_credentials: medical_credentials}) do
    %{
      medical_credentials:
        render_one(medical_credentials, Proto.SpecialistProfileView, "medical_credentials.proto",
          as: :medical_credentials
        )
    }
    |> Proto.validate!(Proto.SpecialistProfile.UpdateMedicalCredentialsResponse)
    |> Proto.SpecialistProfile.UpdateMedicalCredentialsResponse.new()
  end
end
