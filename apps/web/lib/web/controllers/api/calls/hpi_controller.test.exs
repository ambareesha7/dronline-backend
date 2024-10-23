defmodule Web.Api.Calls.HPIControllerTest do
  use Web.ConnCase, async: true

  alias Proto.Calls.GetHPIResponse
  alias Proto.Calls.UpdateHPIRequest
  alias Proto.Calls.UpdateHPIResponse

  alias Proto.Forms.Form

  describe "GET show" do
    setup [:authenticate_patient]

    test "succeeds when hpi doens't exist", %{conn: conn} do
      conn = get(conn, calls_hpi_path(conn, :show))

      assert %GetHPIResponse{hpi: hpi} = proto_response(conn, 200, GetHPIResponse)
      assert %Form{} = hpi.form
      assert is_nil(hpi.inserted_at)
    end

    test "succeeds when hpi exists", %{conn: conn, current_patient: current_patient} do
      timeline = EMR.Factory.insert(:automatic_record, patient_id: current_patient.id)

      inserted_hpi =
        EMR.Factory.insert(:hpi, patient_id: current_patient.id, timeline_id: timeline.id)

      conn = get(conn, calls_hpi_path(conn, :show))

      assert %GetHPIResponse{hpi: hpi} = proto_response(conn, 200, GetHPIResponse)
      assert %Form{} = hpi.form
      assert hpi.inserted_at.timestamp == inserted_hpi.inserted_at |> Timex.to_unix()
    end
  end

  describe "PUT update" do
    setup [:proto_content, :authenticate_patient]

    test "success when hpi doesn't exist", %{conn: conn} do
      proto =
        %{
          hpi: EMR.Factory.valid_hpi_form()
        }
        |> UpdateHPIRequest.new()
        |> UpdateHPIRequest.encode()

      conn = put(conn, calls_hpi_path(conn, :update), proto)

      assert %UpdateHPIResponse{hpi: hpi} = proto_response(conn, 200, UpdateHPIResponse)
      assert %Form{fields: _} = hpi.form
      refute is_nil(hpi.inserted_at)
    end

    test "success when hpi exist", %{conn: conn, current_patient: current_patient} do
      timeline = EMR.Factory.insert(:automatic_record, patient_id: current_patient.id)
      _hpi = EMR.Factory.insert(:hpi, patient_id: current_patient.id, timeline_id: timeline.id)

      proto =
        %{
          hpi: EMR.Factory.valid_hpi_form()
        }
        |> UpdateHPIRequest.new()
        |> UpdateHPIRequest.encode()

      conn = put(conn, calls_hpi_path(conn, :update), proto)

      assert %UpdateHPIResponse{hpi: hpi} = proto_response(conn, 200, UpdateHPIResponse)
      assert %Form{fields: _} = hpi.form
      refute is_nil(hpi.inserted_at)
    end
  end
end
