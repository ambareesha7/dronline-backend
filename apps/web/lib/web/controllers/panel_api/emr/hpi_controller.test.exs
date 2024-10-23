defmodule Web.PanelApi.EMR.HPIControllerTest do
  use Web.ConnCase, async: true

  alias Proto.EMR.GetHPIHistoryResponse
  alias Proto.EMR.GetHPIResponse
  alias Proto.EMR.UpdateHPIRequest
  alias Proto.EMR.UpdateHPIResponse

  alias Proto.Errors.ErrorResponse
  alias Proto.Forms.Form

  describe "GET history" do
    setup [:authenticate_gp]

    test "succeeds", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      first_hpi = EMR.Factory.insert(:hpi, patient_id: patient.id, timeline_id: timeline.id)
      second_hpi = EMR.Factory.insert(:hpi, patient_id: patient.id, timeline_id: timeline.id)

      conn = get(conn, panel_emr_hpi_path(conn, :history, patient.id, timeline.id))

      assert %GetHPIHistoryResponse{hpis: [first_returned_hpi, second_returned_hpi]} =
               proto_response(conn, 200, GetHPIHistoryResponse)

      assert first_returned_hpi.inserted_at.timestamp == second_hpi.inserted_at |> Timex.to_unix()

      assert second_returned_hpi.inserted_at.timestamp ==
               first_hpi.inserted_at |> Timex.to_unix()
    end
  end

  describe "GET show" do
    setup [:authenticate_gp]

    test "succeeds when hpi doens't exist", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      conn = get(conn, panel_emr_hpi_path(conn, :show, patient.id, timeline.id))

      assert %GetHPIResponse{hpi: hpi} = proto_response(conn, 200, GetHPIResponse)
      assert %Form{} = hpi.form
      assert is_nil(hpi.inserted_at)
    end

    test "succeeds when hpi exists", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      inserted_hpi = EMR.Factory.insert(:hpi, patient_id: patient.id, timeline_id: timeline.id)

      conn = get(conn, panel_emr_hpi_path(conn, :show, patient.id, timeline.id))

      assert %GetHPIResponse{hpi: hpi} = proto_response(conn, 200, GetHPIResponse)
      assert %Form{} = hpi.form
      assert hpi.inserted_at.timestamp == inserted_hpi.inserted_at |> Timex.to_unix()
    end
  end

  describe "PUT update" do
    setup [:proto_content, :authenticate_gp]

    test "success when hpi doesn't exist", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      test_hpi_form = EMR.Factory.valid_hpi_form()

      proto =
        %{
          hpi: test_hpi_form
        }
        |> UpdateHPIRequest.new()
        |> UpdateHPIRequest.encode()

      conn = put(conn, panel_emr_hpi_path(conn, :update, patient.id, timeline.id), proto)

      assert %UpdateHPIResponse{hpi: hpi} = proto_response(conn, 200, UpdateHPIResponse)
      assert ^test_hpi_form = hpi.form
      refute is_nil(hpi.inserted_at)
    end

    test "returns an error when not all fields are filled in", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)

      proto =
        %{
          hpi: EMR.HPI.Template.template(:default)
        }
        |> UpdateHPIRequest.new()
        |> UpdateHPIRequest.encode()

      conn = put(conn, panel_emr_hpi_path(conn, :update, patient.id, timeline.id), proto)

      assert %ErrorResponse{} = proto_response(conn, 422, ErrorResponse)
    end

    test "success when hpi exist", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      timeline = EMR.Factory.insert(:automatic_record, patient_id: patient.id)
      _hpi = EMR.Factory.insert(:hpi, patient_id: patient.id, timeline_id: timeline.id)

      test_hpi_form = EMR.Factory.valid_hpi_form()

      proto =
        %{
          hpi: test_hpi_form
        }
        |> UpdateHPIRequest.new()
        |> UpdateHPIRequest.encode()

      conn = put(conn, panel_emr_hpi_path(conn, :update, patient.id, timeline.id), proto)

      assert %UpdateHPIResponse{hpi: hpi} = proto_response(conn, 200, UpdateHPIResponse)
      assert ^test_hpi_form = hpi.form
      refute is_nil(hpi.inserted_at)
    end
  end
end
