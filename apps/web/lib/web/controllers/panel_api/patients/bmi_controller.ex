defmodule Web.PanelApi.Patients.BMIController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, params) do
    %{"patient_id" => patient_id} = params

    {:ok, bmi} = PatientProfile.fetch_bmi(patient_id)

    conn |> render("show.proto", %{bmi: bmi})
  end

  @decode Proto.PatientProfile.UpdateBMIRequest
  def update(conn, params) do
    %{"patient_id" => patient_id} = params
    patient_id = String.to_integer(patient_id)

    params = conn.assigns.protobuf.bmi |> parse_params()

    with {:ok, bmi} <- PatientProfile.update_bmi(params, patient_id) do
      conn |> render("update.proto", %{bmi: bmi})
    end
  end

  defp parse_params(bmi_proto) do
    %{
      height: bmi_proto.height |> parse_value(),
      weight: bmi_proto.weight |> parse_value()
    }
  end

  defp parse_value(nil), do: nil
  defp parse_value(%{value: value}), do: value
end

defmodule Web.PanelApi.Patients.BMIView do
  use Web, :view

  def render("show.proto", %{bmi: bmi}) do
    %Proto.PatientProfile.GetBMIResponse{
      bmi: Web.View.PatientProfile.render_bmi(bmi)
    }
  end

  def render("update.proto", %{bmi: bmi}) do
    %Proto.PatientProfile.UpdateBMIResponse{
      bmi: Web.View.PatientProfile.render_bmi(bmi)
    }
  end
end
