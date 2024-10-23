defmodule Web.Api.Patient.AddressController do
  use Web, :controller

  alias EMR.PatientInvitations.AcceptInvitation

  action_fallback Web.FallbackController

  def show(conn, _params) do
    patient_id = conn.assigns.current_patient_id

    address =
      PatientProfile.get_address(patient_id) || get_related_adult_patient_address(patient_id)

    conn |> render("show.proto", %{address: address})
  end

  defp get_related_adult_patient_address(patient_id) do
    case PatientProfilesManagement.get_related_adult_patient_id(patient_id) do
      nil ->
        nil

      adult_patient_id ->
        PatientProfile.get_address(adult_patient_id)
    end
  end

  @decode Proto.PatientProfile.UpdateAddressRequest
  def update(conn, _params) do
    patient_id = conn.assigns.current_patient_id
    address_params = conn.assigns.protobuf.address |> Map.from_struct()

    with {:ok, address} <- PatientProfile.update_address(address_params, patient_id),
         :ok <- AcceptInvitation.connect_and_send_email_for_patient_invitations(patient_id) do
      conn |> render("update.proto", %{address: address})
    end
  end
end

defmodule Web.Api.Patient.AddressView do
  use Web, :view

  def render("show.proto", %{address: address}) do
    %Proto.PatientProfile.GetAddressResponse{
      address: Web.View.PatientProfile.render_address(address)
    }
  end

  def render("update.proto", %{address: address}) do
    %Proto.PatientProfile.UpdateAddressResponse{
      address: Web.View.PatientProfile.render_address(address)
    }
  end
end
