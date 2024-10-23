defmodule Web.Api.Patient.BMIControllerTest do
  use Web.ConnCase, async: true

  alias Proto.PatientProfile.GetBMIResponse
  alias Proto.PatientProfile.UpdateBMIRequest
  alias Proto.PatientProfile.UpdateBMIResponse

  alias Proto.PatientProfile.BMI

  alias Proto.Errors.ErrorResponse
  alias Proto.Errors.FormErrors

  describe "GET show" do
    setup [:authenticate_patient]

    test "success when bmi doesn't exist", %{conn: conn} do
      conn = get(conn, patient_bmi_path(conn, :show))

      assert %GetBMIResponse{bmi: %BMI{weight: nil}} = proto_response(conn, 200, GetBMIResponse)
    end

    test "success when bmi exist", %{conn: conn, current_patient: current_patient} do
      _bmi = PatientProfile.Factory.insert(:bmi, patient_id: current_patient.id, weight: 80)

      conn = get(conn, patient_bmi_path(conn, :show))

      assert %GetBMIResponse{bmi: %BMI{weight: %Proto.Generics.Weight{value: 80}}} =
               proto_response(conn, 200, GetBMIResponse)
    end
  end

  describe "PUT update" do
    setup [:proto_content, :authenticate_patient]

    test "success when bmi doesn't exist", %{conn: conn} do
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

      conn = put(conn, patient_bmi_path(conn, :update), proto)

      assert %UpdateBMIResponse{bmi: %BMI{weight: %Proto.Generics.Weight{value: 90}}} =
               proto_response(conn, 200, UpdateBMIResponse)
    end

    test "success when bmi exist", %{conn: conn, current_patient: current_patient} do
      _basic_info =
        PatientProfile.Factory.insert(:bmi, patient_id: current_patient.id, weight: 80)

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

      conn = put(conn, patient_bmi_path(conn, :update), proto)

      assert %UpdateBMIResponse{bmi: %BMI{weight: %Proto.Generics.Weight{value: 0}}} =
               proto_response(conn, 200, UpdateBMIResponse)
    end

    test "validation failure", %{conn: conn} do
      proto =
        %{
          bmi: BMI.new()
        }
        |> UpdateBMIRequest.new()
        |> UpdateBMIRequest.encode()

      conn = put(conn, patient_bmi_path(conn, :update), proto)

      %ErrorResponse{form_errors: %FormErrors{}} = proto_response(conn, 422, ErrorResponse)
    end
  end
end
