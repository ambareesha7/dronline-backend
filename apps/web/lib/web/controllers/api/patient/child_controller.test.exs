defmodule Web.Api.Patient.ChildControllerTest do
  use Web.ConnCase, async: true

  alias Proto.PatientProfile.AddChildProfileRequest
  alias Proto.PatientProfile.AddChildProfileResponse
  alias Proto.PatientProfile.GetChildrenProfilesResponse

  alias Proto.PatientProfile.BasicInfo
  alias Proto.PatientProfile.BasicInfoParams
  alias Proto.PatientProfile.ChildProfile

  alias Proto.Errors.ErrorResponse
  alias Proto.Errors.FormErrors

  describe "POST create" do
    setup [:proto_content, :authenticate_patient]

    test "creates child profile and returns its basic_info and auth_token", %{conn: conn} do
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
        |> AddChildProfileRequest.new()
        |> AddChildProfileRequest.encode()

      conn = post(conn, patient_child_path(conn, :create), proto)

      assert %AddChildProfileResponse{
               child_profile: %ChildProfile{
                 auth_token: auth_token,
                 basic_info: %BasicInfo{first_name: "Ahmed"}
               }
             } = proto_response(conn, 200, AddChildProfileResponse)

      assert auth_token != ""
    end

    test "returns errors on validation failures", %{conn: conn} do
      proto =
        %{
          basic_info_params: BasicInfoParams.new()
        }
        |> AddChildProfileRequest.new()
        |> AddChildProfileRequest.encode()

      conn = post(conn, patient_child_path(conn, :create), proto)

      assert %ErrorResponse{form_errors: %FormErrors{}} = proto_response(conn, 422, ErrorResponse)
    end
  end

  describe "GET index" do
    setup [:authenticate_patient]

    test "returns list of child profiles", %{conn: conn, current_patient: adult_patient} do
      child_basic_info_params = %{
        title: "MR",
        gender: "MALE",
        first_name: "Ahmed",
        last_name: "Ahmed",
        birth_date: ~D[2000-11-15],
        email: "ahmedahmed@ahmed.com"
      }

      {:ok, {child_profile, _basic_info}} =
        PatientProfilesManagement.add_related_child_profile(
          child_basic_info_params,
          adult_patient.id
        )

      {:ok, auth_token_entry} =
        Authentication.generate_auth_token_entry_for_patient(child_profile.id)

      conn = get(conn, patient_child_path(conn, :index))

      assert %GetChildrenProfilesResponse{
               child_profiles: [
                 %ChildProfile{
                   auth_token: auth_token,
                   basic_info: %BasicInfo{first_name: "Ahmed"},
                   patient_id: returned_child_id
                 }
               ]
             } = proto_response(conn, 200, GetChildrenProfilesResponse)

      assert auth_token == auth_token_entry.auth_token
      assert returned_child_id == child_profile.id
    end

    test "returns empty list if current patient doesn't have associated children", %{conn: conn} do
      conn = get(conn, patient_child_path(conn, :index))

      assert %GetChildrenProfilesResponse{
               child_profiles: []
             } = proto_response(conn, 200, GetChildrenProfilesResponse)
    end
  end
end
