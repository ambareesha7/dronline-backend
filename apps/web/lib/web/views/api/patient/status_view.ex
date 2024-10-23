defmodule Web.Api.Patient.StatusView do
  use Web, :view

  def render("show.proto", %{status: status}) do
    %{
      onboarding_completed: status.onboarding_completed
    }
    |> Proto.validate!(Proto.PatientProfile.GetStatusResponse)
    |> Proto.PatientProfile.GetStatusResponse.new()
  end
end
