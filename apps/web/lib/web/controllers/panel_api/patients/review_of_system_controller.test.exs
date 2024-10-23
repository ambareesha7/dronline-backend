defmodule Web.PanelApi.Patients.ReviewOfSystemControllerTest do
  use Web.ConnCase, async: true

  alias Proto.PatientProfile.GetReviewOfSystemHistoryResponse
  alias Proto.PatientProfile.GetReviewOfSystemResponse
  alias Proto.PatientProfile.UpdateReviewOfSystemRequest
  alias Proto.PatientProfile.UpdateReviewOfSystemResponse

  describe "PUT update" do
    setup [:proto_content, :authenticate_gp]

    test "creates and return RoS with metadata about who provided it", %{
      conn: conn,
      current_gp: gp
    } do
      patient = PatientProfile.Factory.insert(:patient)
      input = PatientProfile.Factory.valid_review_of_system_form()

      proto =
        %{
          review_of_system: input
        }
        |> UpdateReviewOfSystemRequest.new()
        |> UpdateReviewOfSystemRequest.encode()

      conn = put(conn, panel_patients_review_of_system_path(conn, :update, patient), proto)

      assert %UpdateReviewOfSystemResponse{
               review_of_system:
                 %Proto.PatientProfile.ReviewOfSystem{} = returned_review_of_system
             } = proto_response(conn, 200, UpdateReviewOfSystemResponse)

      assert returned_review_of_system.form == input
      assert returned_review_of_system.provided_by_specialist_id == gp.id
    end

    test "returns error when patient doesn't exist", %{conn: conn} do
      patient_id = 0

      proto =
        %{
          review_of_system: PatientProfile.Factory.valid_review_of_system_form()
        }
        |> UpdateReviewOfSystemRequest.new()
        |> UpdateReviewOfSystemRequest.encode()

      conn = put(conn, panel_patients_review_of_system_path(conn, :update, patient_id), proto)

      assert response(conn, 404)
    end
  end

  describe "GET show" do
    setup [:authenticate_gp]

    test "returns latest RoS", %{conn: conn} do
      template = PatientProfile.ReviewOfSystem.Template.template()
      patient = PatientProfile.Factory.insert(:patient)

      conn = get(conn, panel_patients_review_of_system_path(conn, :show, patient))

      assert %GetReviewOfSystemResponse{
               review_of_system:
                 %Proto.PatientProfile.ReviewOfSystem{} = returned_review_of_system
             } = proto_response(conn, 200, GetReviewOfSystemResponse)

      assert returned_review_of_system.form == template
    end

    test "returns error when patient doesn't exist", %{conn: conn} do
      patient_id = 0

      conn = get(conn, panel_patients_review_of_system_path(conn, :show, patient_id))

      assert response(conn, 404)
    end
  end

  describe "GET history" do
    setup [:authenticate_gp]

    test "returns latest RoS", %{conn: conn, current_gp: gp} do
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: gp.id)

      patient = PatientProfile.Factory.insert(:patient)
      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient.id)

      input = PatientProfile.Factory.valid_review_of_system_form()
      {:ok, _ros} = PatientProfile.register_review_of_system_change(patient.id, input, gp.id)

      conn = get(conn, panel_patients_review_of_system_path(conn, :history, patient))

      assert %GetReviewOfSystemHistoryResponse{
               review_of_system_history: [
                 %Proto.PatientProfile.ReviewOfSystem{} = returned_review_of_system
               ],
               next_token: "",
               specialists: [
                 %Proto.Generics.Specialist{} = returned_specialist
               ]
             } = proto_response(conn, 200, GetReviewOfSystemHistoryResponse)

      assert returned_review_of_system.form == input
      assert returned_specialist.id == gp.id
    end

    test "returns error when patient doesn't exist", %{conn: conn} do
      patient_id = 0

      conn = get(conn, panel_patients_review_of_system_path(conn, :history, patient_id))

      assert response(conn, 404)
    end
  end
end
