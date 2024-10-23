defmodule Web.Api.EMR.HPIController do
  use Web, :controller

  action_fallback Web.FallbackController

  def history(conn, params) do
    record_id = params["record_id"]

    with {:ok, hpis} <- EMR.fetch_hpi_history(record_id) do
      render(conn, "history.proto", %{hpis: hpis})
    end
  end

  def show(conn, params) do
    # TODO: check if the record is for current patient
    patient_id = conn.assigns.current_patient_id
    record_id = String.to_integer(params["record_id"])
    kind = if params["coronavirus"] == "true", do: :coronavirus, else: :default

    with {:ok, hpi} <- EMR.fetch_hpi(patient_id, record_id, kind) do
      render(conn, "show.proto", %{hpi: hpi})
    end
  end

  @decode Proto.EMR.UpdateHPIRequest
  def update(conn, params) do
    # TODO: check if the record is for current patient
    patient_id = conn.assigns.current_patient_id
    record_id = String.to_integer(params["record_id"])
    proto = conn.assigns.protobuf.hpi

    with {:ok, hpi} <- EMR.register_hpi_history(patient_id, record_id, proto) do
      render(conn, "update.proto", %{hpi: hpi})
    end
  end
end

defmodule Web.Api.EMR.HPIView do
  use Web, :view

  def render("history.proto", %{hpis: hpis}) do
    %{
      hpis: Enum.map(hpis, &Web.View.EMR.render_hpi/1)
    }
    |> Proto.validate!(Proto.EMR.GetHPIHistoryResponse)
    |> Proto.EMR.GetHPIHistoryResponse.new()
  end

  def render("show.proto", %{hpi: hpi}) do
    %{
      hpi: Web.View.EMR.render_hpi(hpi)
    }
    |> Proto.validate!(Proto.EMR.GetHPIResponse)
    |> Proto.EMR.GetHPIResponse.new()
  end

  def render("update.proto", %{hpi: hpi}) do
    %{
      hpi: Web.View.EMR.render_hpi(hpi)
    }
    |> Proto.validate!(Proto.EMR.UpdateHPIResponse)
    |> Proto.EMR.UpdateHPIResponse.new()
  end
end
