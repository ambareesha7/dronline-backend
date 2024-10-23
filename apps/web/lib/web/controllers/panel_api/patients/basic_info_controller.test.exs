defmodule Web.PanelApi.Patients.BasicInfoControllerTest do
  use Web.ConnCase, async: true

  alias Proto.PatientProfile.GetBasicInfoResponse
  alias Proto.PatientProfile.UpdateBasicInfoRequest
  alias Proto.PatientProfile.UpdateBasicInfoResponse

  alias Proto.PatientProfile.BasicInfo
  alias Proto.PatientProfile.BasicInfoParams

  alias Proto.Errors.ErrorResponse
  alias Proto.Errors.FormErrors

  describe "GET show" do
    setup [:authenticate_gp]

    test "returns empty basic info when it doesn't exist", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)
      conn = get(conn, panel_patients_basic_info_path(conn, :show, patient))

      assert %GetBasicInfoResponse{
               basic_info: %BasicInfo{first_name: first_name, join_date: join_date}
             } = proto_response(conn, 200, GetBasicInfoResponse)

      assert first_name == ""
      assert join_date == Timex.to_unix(patient.inserted_at)
    end

    test "returns basic info when it exists", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)

      _basic_info =
        PatientProfile.Factory.insert(:basic_info, patient_id: patient.id, first_name: "Ahmed")

      conn = get(conn, panel_patients_basic_info_path(conn, :show, patient))

      assert %GetBasicInfoResponse{
               basic_info: %BasicInfo{first_name: first_name, join_date: join_date}
             } = proto_response(conn, 200, GetBasicInfoResponse)

      assert first_name == "Ahmed"
      assert join_date == Timex.to_unix(patient.inserted_at)
    end

    test "returns not_found error when patient doesn't exist", %{conn: conn} do
      conn = get(conn, panel_patients_basic_info_path(conn, :show, 0))

      assert response(conn, 404)
    end
  end

  describe "PUT update" do
    setup [:proto_content, :authenticate_gp]

    test "returns newly created basic info", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)

      proto =
        %{
          basic_info_params:
            BasicInfoParams.new(
              title: :MR |> Proto.Generics.Title.value(),
              first_name: "Ahmed",
              last_name: "Ahmed",
              birth_date: Proto.Generics.DateTime.new(),
              email: "ahmedahmed@ahmed.com",
              height: Proto.Generics.Height.new(),
              weight: Proto.Generics.Weight.new()
            )
        }
        |> UpdateBasicInfoRequest.new()
        |> UpdateBasicInfoRequest.encode()

      conn = put(conn, panel_patients_basic_info_path(conn, :update, patient), proto)

      assert %UpdateBasicInfoResponse{basic_info: %BasicInfo{first_name: "Ahmed"}} =
               proto_response(conn, 200, UpdateBasicInfoResponse)
    end

    test "returns updated basic info", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)

      _basic_info =
        PatientProfile.Factory.insert(:basic_info,
          patient_id: patient.id,
          first_name: "Mohhamad"
        )

      proto =
        %{
          basic_info_params:
            BasicInfoParams.new(
              title: :MR |> Proto.Generics.Title.value(),
              first_name: "Ahmed",
              last_name: "Ahmed",
              birth_date: Proto.Generics.DateTime.new(),
              email: "ahmedahmed@ahmed.com",
              height: Proto.Generics.Height.new(),
              weight: Proto.Generics.Weight.new()
            )
        }
        |> UpdateBasicInfoRequest.new()
        |> UpdateBasicInfoRequest.encode()

      conn = put(conn, panel_patients_basic_info_path(conn, :update, patient), proto)

      assert %UpdateBasicInfoResponse{basic_info: %BasicInfo{first_name: "Ahmed"}} =
               proto_response(conn, 200, UpdateBasicInfoResponse)
    end

    test "returns not_found error when patient doesn't exist", %{conn: conn} do
      proto =
        %{
          basic_info_params:
            BasicInfoParams.new(
              title: :MR |> Proto.Generics.Title.value(),
              first_name: "Ahmed",
              last_name: "Ahmed",
              birth_date: Proto.Generics.DateTime.new(),
              email: "ahmedahmed@ahmed.com",
              height: Proto.Generics.Height.new(),
              weight: Proto.Generics.Weight.new()
            )
        }
        |> UpdateBasicInfoRequest.new()
        |> UpdateBasicInfoRequest.encode()

      conn = put(conn, panel_patients_basic_info_path(conn, :update, 0), proto)
      assert response(conn, 404)
    end

    test "returns error on validation failure", %{conn: conn} do
      patient = PatientProfile.Factory.insert(:patient)

      proto =
        %{
          basic_info_params: BasicInfoParams.new()
        }
        |> UpdateBasicInfoRequest.new()
        |> UpdateBasicInfoRequest.encode()

      conn = put(conn, panel_patients_basic_info_path(conn, :update, patient), proto)

      %ErrorResponse{form_errors: %FormErrors{}} = proto_response(conn, 422, ErrorResponse)
    end
  end
end
