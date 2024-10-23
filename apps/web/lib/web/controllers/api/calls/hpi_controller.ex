defmodule Web.Api.Calls.HPIController do
  use Web, :controller

  action_fallback Web.FallbackController

  def show(conn, _params) do
    patient_id = conn.assigns.current_patient_id

    {:ok, hpi} = Calls.fetch_hpi(patient_id)

    render(conn, "show.proto", %{hpi: hpi})
  end

  @decode Proto.Calls.UpdateHPIRequest
  def update(conn, _params) do
    patient_id = conn.assigns.current_patient_id
    proto = conn.assigns.protobuf.hpi

    with {:ok, hpi} <- Calls.register_hpi_history(patient_id, proto) do
      render(conn, "update.proto", %{hpi: hpi})
    end
  end
end

defmodule Web.Api.Calls.HPIView do
  use Web, :view

  def render("show.proto", %{hpi: hpi}) do
    %{
      hpi: Web.View.EMR.render_hpi(hpi)
    }
    |> Proto.validate!(Proto.Calls.GetHPIResponse)
    |> Proto.Calls.GetHPIResponse.new()
  end

  def render("update.proto", %{hpi: hpi}) do
    %{
      hpi: Web.View.EMR.render_hpi(hpi),
      record_id: hpi.timeline_id
    }
    |> Proto.validate!(Proto.Calls.UpdateHPIResponse)
    |> Proto.Calls.UpdateHPIResponse.new()
  end
end
