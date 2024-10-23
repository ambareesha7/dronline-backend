defmodule Web.Api.Patient.InsuranceController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, _params) do
    patient_id = conn.assigns.current_patient_id

    {:ok, insurance_account} = Insurance.fetch_by_patient_id(patient_id)

    conn |> render("show.proto", %{insurance_account: insurance_account})
  end

  @decode Proto.PatientProfile.UpdateInsuranceRequest
  def update(conn, _params) do
    patient_id = conn.assigns.current_patient_id
    params = conn.assigns.protobuf |> Map.from_struct()

    with {:ok, insurance_account} <- Insurance.set_patient_insurance(params, patient_id) do
      conn |> render("update.proto", %{insurance_account: insurance_account})
    end
  end

  def delete(conn, _params) do
    patient_id = conn.assigns.current_patient_id

    with {:ok, _} <- Insurance.remove_patient_insurance(patient_id) do
      conn |> render("show.proto", %{insurance_account: nil})
    end
  end
end

defmodule Web.Api.Patient.InsuranceView do
  use Web, :view

  def render("show.proto", %{insurance_account: nil}) do
    %Proto.PatientProfile.GetInsuranceResponse{
      insurance: nil
    }
  end

  def render("show.proto", %{insurance_account: insurance_account}) do
    %Proto.PatientProfile.GetInsuranceResponse{
      insurance: render_insurance(insurance_account)
    }
  end

  def render("update.proto", %{insurance_account: insurance_account}) do
    %Proto.PatientProfile.UpdateInsuranceResponse{
      insurance: render_insurance(insurance_account)
    }
  end

  defp render_insurance(insurance_account) do
    %Proto.PatientProfile.Insurance{
      member_id: insurance_account.member_id,
      provider: %Proto.Insurance.Provider{
        id: insurance_account.insurance_provider.id,
        name: insurance_account.insurance_provider.name,
        logo_url: insurance_account.insurance_provider.logo_url
      }
    }
  end
end
