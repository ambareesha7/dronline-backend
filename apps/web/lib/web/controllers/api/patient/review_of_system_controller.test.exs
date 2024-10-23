defmodule Web.Api.Patient.ReviewOfSystemControllerTest do
  use Web.ConnCase, async: true

  alias Proto.PatientProfile.GetReviewOfSystemHistoryResponse
  alias Proto.PatientProfile.GetReviewOfSystemResponse
  alias Proto.PatientProfile.UpdateReviewOfSystemRequest
  alias Proto.PatientProfile.UpdateReviewOfSystemResponse

  describe "PUT update" do
    setup [:proto_content, :authenticate_patient]

    test "creates and return RoS provided by patient", %{conn: conn} do
      input = PatientProfile.Factory.valid_review_of_system_form()

      proto =
        %{
          review_of_system: input
        }
        |> UpdateReviewOfSystemRequest.new()
        |> UpdateReviewOfSystemRequest.encode()

      conn = put(conn, patient_review_of_system_path(conn, :update), proto)

      assert %UpdateReviewOfSystemResponse{
               review_of_system:
                 %Proto.PatientProfile.ReviewOfSystem{} = returned_review_of_system
             } = proto_response(conn, 200, UpdateReviewOfSystemResponse)

      assert returned_review_of_system.form == input
      assert returned_review_of_system.provided_by_specialist_id == 0
    end
  end

  describe "GET show" do
    setup [:authenticate_patient]

    test "returns latest RoS", %{conn: conn} do
      template = PatientProfile.ReviewOfSystem.Template.template()

      conn = get(conn, patient_review_of_system_path(conn, :show))

      assert %GetReviewOfSystemResponse{
               review_of_system:
                 %Proto.PatientProfile.ReviewOfSystem{} = returned_review_of_system
             } = proto_response(conn, 200, GetReviewOfSystemResponse)

      assert returned_review_of_system.form == template
    end
  end

  describe "GET history" do
    setup [:authenticate_patient]

    test "returns latest RoS", %{conn: conn, current_patient: current_patient} do
      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: current_patient.id)

      specialist = Authentication.Factory.insert(:specialist)
      _basic_info = SpecialistProfile.Factory.insert(:basic_info, specialist_id: specialist.id)

      input = PatientProfile.Factory.valid_review_of_system_form()

      {:ok, _ros} =
        PatientProfile.register_review_of_system_change(current_patient.id, input, specialist.id)

      conn = get(conn, patient_review_of_system_path(conn, :history))

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
      assert returned_specialist.id == specialist.id
    end
  end
end
