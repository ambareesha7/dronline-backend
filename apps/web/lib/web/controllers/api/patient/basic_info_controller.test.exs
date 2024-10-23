defmodule Web.Api.Patient.BasicInfoControllerTest do
  use Web.ConnCase, async: true

  alias Proto.PatientProfile.GetBasicInfoResponse
  alias Proto.PatientProfile.UpdateBasicInfoRequest
  alias Proto.PatientProfile.UpdateBasicInfoResponse

  alias Proto.PatientProfile.BasicInfo
  alias Proto.PatientProfile.BasicInfoParams

  alias Proto.Errors.ErrorResponse
  alias Proto.Errors.FormErrors

  describe "GET show" do
    setup [:authenticate_patient]

    test "success when basic info doesn't exist", %{conn: conn} do
      conn = get(conn, patient_basic_info_path(conn, :show))

      assert %GetBasicInfoResponse{basic_info: %BasicInfo{first_name: ""}} =
               proto_response(conn, 200, GetBasicInfoResponse)
    end

    test "success when basic info exist", %{conn: conn, current_patient: current_patient} do
      _basic_info =
        PatientProfile.Factory.insert(:basic_info,
          patient_id: current_patient.id,
          first_name: "Ahmed"
        )

      conn = get(conn, patient_basic_info_path(conn, :show))

      assert %GetBasicInfoResponse{basic_info: %BasicInfo{first_name: "Ahmed"}} =
               proto_response(conn, 200, GetBasicInfoResponse)
    end
  end

  describe "PUT update" do
    setup [:proto_content, :authenticate_patient]

    test "success when basic info doesn't exist", %{conn: conn} do
      proto =
        %{
          basic_info_params:
            BasicInfoParams.new(
              title: :MR |> Proto.Generics.Title.value(),
              first_name: "Ahmed",
              last_name: "Ahmed",
              birth_date: Proto.Generics.DateTime.new(timestamp: 345_471_132),
              email: "ahmedahmed@ahmed.com"
            )
        }
        |> UpdateBasicInfoRequest.new()
        |> UpdateBasicInfoRequest.encode()

      conn = put(conn, patient_basic_info_path(conn, :update), proto)

      assert %UpdateBasicInfoResponse{basic_info: %BasicInfo{first_name: "Ahmed"}} =
               proto_response(conn, 200, UpdateBasicInfoResponse)
    end

    test "success when basic info exist", %{conn: conn, current_patient: current_patient} do
      _basic_info =
        PatientProfile.Factory.insert(:basic_info,
          patient_id: current_patient.id,
          first_name: "Mohhamad"
        )

      proto =
        %{
          basic_info_params:
            BasicInfoParams.new(
              title: :MR |> Proto.Generics.Title.value(),
              first_name: "Ahmed",
              last_name: "Ahmed",
              birth_date: Proto.Generics.DateTime.new(timestamp: 345_471_132),
              email: "ahmedahmed@ahmed.com"
            )
        }
        |> UpdateBasicInfoRequest.new()
        |> UpdateBasicInfoRequest.encode()

      conn = put(conn, patient_basic_info_path(conn, :update), proto)

      assert %UpdateBasicInfoResponse{basic_info: %BasicInfo{first_name: "Ahmed"}} =
               proto_response(conn, 200, UpdateBasicInfoResponse)
    end

    test "validation failure", %{conn: conn} do
      proto =
        %{
          basic_info_params: BasicInfoParams.new()
        }
        |> UpdateBasicInfoRequest.new()
        |> UpdateBasicInfoRequest.encode()

      conn = put(conn, patient_basic_info_path(conn, :update), proto)

      %ErrorResponse{form_errors: %FormErrors{}} = proto_response(conn, 422, ErrorResponse)
    end
  end
end
