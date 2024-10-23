defmodule Web.Api.EMR.HPIControllerTest do
  use Web.ConnCase, async: true

  alias Proto.EMR.GetHPIHistoryResponse
  alias Proto.EMR.GetHPIResponse
  alias Proto.EMR.UpdateHPIRequest
  alias Proto.EMR.UpdateHPIResponse

  alias Proto.Forms.Form

  describe "GET history" do
    setup [:authenticate_patient]

    test "succeeds", %{conn: conn, current_patient: current_patient} do
      timeline = EMR.Factory.insert(:automatic_record, patient_id: current_patient.id)

      inserted_hpi =
        EMR.Factory.insert(:hpi, patient_id: current_patient.id, timeline_id: timeline.id)

      hpi_form = EMR.Factory.valid_hpi_form()
      changed_form = Map.put(hpi_form, :fields, [hd(hpi_form.fields) | hpi_form.fields])

      _hpi =
        EMR.Factory.insert(:hpi,
          patient_id: current_patient.id,
          timeline_id: timeline.id,
          form: changed_form
        )

      conn = get(conn, emr_hpi_path(conn, :history, timeline.id))

      assert %GetHPIHistoryResponse{hpis: [first_hpi, _second_hpi]} =
               proto_response(conn, 200, GetHPIHistoryResponse)

      assert first_hpi.inserted_at.timestamp == inserted_hpi.inserted_at |> Timex.to_unix()
    end
  end

  describe "GET show" do
    setup [:authenticate_patient]

    test "succeeds when hpi exists", %{conn: conn, current_patient: current_patient} do
      timeline = EMR.Factory.insert(:automatic_record, patient_id: current_patient.id)

      inserted_hpi =
        EMR.Factory.insert(:hpi, patient_id: current_patient.id, timeline_id: timeline.id)

      conn = get(conn, emr_hpi_path(conn, :show, timeline.id))

      assert %GetHPIResponse{hpi: hpi} = proto_response(conn, 200, GetHPIResponse)
      assert %Form{} = hpi.form
      assert hpi.inserted_at.timestamp == inserted_hpi.inserted_at |> Timex.to_unix()
    end

    test "succeeds when hpi doesn't exist", %{
      conn: conn,
      current_patient: current_patient
    } do
      timeline = EMR.Factory.insert(:automatic_record, patient_id: current_patient.id)

      conn = get(conn, emr_hpi_path(conn, :show, timeline.id))

      assert %GetHPIResponse{hpi: hpi} = proto_response(conn, 200, GetHPIResponse)
      assert List.first(hpi.form.fields).label == "Why are you seeing the doctor today?"
      assert is_nil(hpi.inserted_at)
    end

    test "succeeds when hpi doesn't exist (coronavirus)", %{
      conn: conn,
      current_patient: current_patient
    } do
      timeline = EMR.Factory.insert(:automatic_record, patient_id: current_patient.id)

      params = %{"coronavirus" => "true"}
      conn = get(conn, emr_hpi_path(conn, :show, timeline.id), params)

      assert %GetHPIResponse{hpi: hpi} = proto_response(conn, 200, GetHPIResponse)
      assert List.first(hpi.form.fields).label == "Do you have a temperature?"
      assert is_nil(hpi.inserted_at)
    end
  end

  describe "POST update" do
    setup [:authenticate_patient, :proto_content]

    test "success when hpi doesn't exist", %{conn: conn, current_patient: current_patient} do
      timeline = EMR.Factory.insert(:automatic_record, patient_id: current_patient.id)

      proto =
        %{
          hpi: EMR.Factory.valid_hpi_form()
        }
        |> UpdateHPIRequest.new()
        |> UpdateHPIRequest.encode()

      conn = put(conn, emr_hpi_path(conn, :update, timeline.id), proto)

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

      conn = put(conn, emr_hpi_path(conn, :update, timeline.id), proto)

      assert %UpdateHPIResponse{hpi: hpi} = proto_response(conn, 200, UpdateHPIResponse)
      assert %Form{fields: _} = hpi.form
      refute is_nil(hpi.inserted_at)
    end
  end
end
