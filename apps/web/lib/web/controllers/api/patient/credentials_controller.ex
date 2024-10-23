defmodule Web.Api.Patient.CredentialsController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, _params) do
    patient_id = conn.assigns.current_patient_id

    conn |> render("show.proto", %{id: patient_id})
  end
end

defmodule Web.Api.Patient.CredentialsView do
  use Web, :view

  def render("show.proto", %{id: id}) do
    %Proto.PatientProfile.GetCredentialsResponse{
      credentials: %Proto.PatientProfile.Credentials{id: id}
    }
  end
end
