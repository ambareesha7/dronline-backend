defmodule Web.Api.PanelPatient.BMIControllerTest do
  use Web.ConnCase, async: true

  alias Proto.PatientProfile.GetBMIResponse
  alias Proto.PatientProfile.UpdateBMIRequest
  alias Proto.PatientProfile.UpdateBMIResponse

  alias Proto.PatientProfile.BMI

  alias Proto.Errors.ErrorResponse
  alias Proto.Errors.FormErrors

  describe "GET show" do
    setup [:authenticate_gp]

    test "success when bmi doesn't exist", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      conn = get(conn, panel_patients_bmi_path(conn, :show, patient))

      assert %GetBMIResponse{bmi: %BMI{weight: nil}} = proto_response(conn, 200, GetBMIResponse)
    end

    test "success when bmi exist", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      _bmi = PatientProfile.Factory.insert(:bmi, patient_id: patient.id, weight: 80)

      conn = get(conn, panel_patients_bmi_path(conn, :show, patient))

      assert %GetBMIResponse{bmi: %BMI{weight: %Proto.Generics.Weight{value: 80}}} =
               proto_response(conn, 200, GetBMIResponse)
    end
  end

  describe "PUT update" do
    setup [:proto_content, :authenticate_gp]

    test "success when bmi doesn't exist", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)

      proto =
        %{
          bmi:
            BMI.new(
              height: Proto.Generics.Height.new(),
              weight: Proto.Generics.Weight.new(value: 90)
            )
        }
        |> UpdateBMIRequest.new()
        |> UpdateBMIRequest.encode()

      conn = put(conn, panel_patients_bmi_path(conn, :update, patient), proto)

      assert %UpdateBMIResponse{bmi: %BMI{weight: %Proto.Generics.Weight{value: 90}}} =
               proto_response(conn, 200, UpdateBMIResponse)
    end

    test "success when bmi exist", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      _bmi = PatientProfile.Factory.insert(:bmi, patient_id: patient.id, weight: 80)

      proto =
        %{
          bmi:
            BMI.new(
              height: Proto.Generics.Height.new(),
              weight: Proto.Generics.Weight.new()
            )
        }
        |> UpdateBMIRequest.new()
        |> UpdateBMIRequest.encode()

      conn = put(conn, panel_patients_bmi_path(conn, :update, patient), proto)

      assert %UpdateBMIResponse{bmi: %BMI{weight: %Proto.Generics.Weight{value: 0}}} =
               proto_response(conn, 200, UpdateBMIResponse)
    end

    test "validation failure", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)

      proto =
        %{
          bmi: BMI.new()
        }
        |> UpdateBMIRequest.new()
        |> UpdateBMIRequest.encode()

      conn = put(conn, panel_patients_bmi_path(conn, :update, patient), proto)

      %ErrorResponse{form_errors: %FormErrors{}} = proto_response(conn, 422, ErrorResponse)
    end
  end
end
