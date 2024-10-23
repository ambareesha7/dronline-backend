defmodule Web.PanelApi.Patients.AddressController do
  use Web, :controller

  alias EMR.PatientInvitations.AcceptInvitation

  action_fallback Web.FallbackController

  plug Web.Plugs.VerifySpecialistPatientConnection, param_name: "patient_id"

  def show(conn, params) do
    %{"patient_id" => patient_id} = params

    with {:ok, _patient} <- PatientProfile.fetch_by_id(patient_id) do
      address = PatientProfile.get_address(patient_id)

      conn |> render("show.proto", %{address: address})
    end
  end

  @decode Proto.PatientProfile.UpdateAddressRequest
  def update(conn, params) do
    patient_id = params["patient_id"] |> String.to_integer()
    address_params = conn.assigns.protobuf.address |> Map.from_struct()

    with {:ok, _patient} <- PatientProfile.fetch_by_id(patient_id),
         {:ok, address} <- PatientProfile.update_address(address_params, patient_id),
         :ok <- AcceptInvitation.connect_and_send_email_for_patient_invitations(patient_id) do
      conn |> render("update.proto", %{address: address})
    end
  end
end

defmodule Web.PanelApi.Patients.AddressView do
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
