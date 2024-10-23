defmodule Admin.USBoardTest do
  use Postgres.DataCase, async: true

  alias Admin.USBoard

  describe "fetch_specialists_history_for_requests/1" do
    test "returns multiple requests with assigned specialists" do
      %{specialist_id: specialist_id_1, request_id: request_id_1} =
        get_us_board_request_with_assigned_specialist()

      {:ok, %{rejected_at: request_id_1_rejected_at}} =
        Visits.reject_us_board_second_opinion(specialist_id_1, request_id_1)

      %{specialist_id: specialist_id_2, request_id: request_id_2} =
        get_us_board_request_with_assigned_specialist()

      {:ok, %{accepted_at: request_id_2_accepted_at}} =
        Visits.accept_us_board_second_opinion(specialist_id_2, request_id_2)

      response = USBoard.fetch_specialists_history_for_requests([request_id_1, request_id_2])

      assert [
               %{
                 specialist_id: ^specialist_id_1,
                 accepted_at: nil,
                 rejected_at: ^request_id_1_rejected_at
               }
             ] =
               Map.get(response, request_id_1)

      assert [
               %{
                 specialist_id: ^specialist_id_2,
                 accepted_at: ^request_id_2_accepted_at,
                 rejected_at: nil
               }
             ] =
               Map.get(response, request_id_2)
    end

    test "returns assigned specialists" do
      %{specialist_id: specialist_id, request_id: request_id} =
        get_us_board_request_with_assigned_specialist()

      assert %{
               ^request_id => [
                 %{specialist_id: ^specialist_id, accepted_at: nil, rejected_at: nil}
               ]
             } = USBoard.fetch_specialists_history_for_requests([request_id])
    end

    test "returns rejected specialists" do
      %{specialist_id: specialist_id, request_id: request_id} =
        get_us_board_request_with_assigned_specialist()

      {:ok, %{rejected_at: rejected_at}} =
        Visits.reject_us_board_second_opinion(specialist_id, request_id)

      assert %{
               ^request_id => [
                 %{specialist_id: ^specialist_id, accepted_at: nil, rejected_at: ^rejected_at}
               ]
             } = USBoard.fetch_specialists_history_for_requests([request_id])
    end

    test "returns accepted specialists" do
      %{specialist_id: specialist_id, request_id: request_id} =
        get_us_board_request_with_assigned_specialist()

      {:ok, %{accepted_at: accepted_at}} =
        Visits.accept_us_board_second_opinion(specialist_id, request_id)

      assert %{
               ^request_id => [
                 %{specialist_id: ^specialist_id, accepted_at: ^accepted_at, rejected_at: nil}
               ]
             } = USBoard.fetch_specialists_history_for_requests([request_id])
    end

    test "omits request ids with no assigned specialists" do
      %{request_id: request_id} = get_us_board_request_with_assigned_specialist()

      invalid_request_id = UUID.uuid4()

      response = USBoard.fetch_specialists_history_for_requests([request_id, invalid_request_id])

      refute Map.get(response, invalid_request_id)
      assert Map.get(response, request_id)
    end

    test "returns assigned specialists in order of assiging" do
      %{specialist_id: newest_specialist_id, request_id: request_id} =
        get_us_board_request_with_assigned_specialist()

      %{id: oldest_specialist_id} = Authentication.Factory.insert(:verified_specialist)

      _oldest_assigned_specialist =
        Visits.Factory.insert(:second_opinion_assigned_specialist,
          us_board_second_opinion_request_id: request_id,
          specialist_id: oldest_specialist_id,
          assigned_at: DateTime.utc_now() |> Timex.shift(hours: -2),
          status: :assigned
        )

      %{id: older_specialist_id} = Authentication.Factory.insert(:verified_specialist)

      _newest_assigned_specialist_id =
        Visits.Factory.insert(:second_opinion_assigned_specialist,
          us_board_second_opinion_request_id: request_id,
          specialist_id: older_specialist_id,
          assigned_at: DateTime.utc_now() |> Timex.shift(hours: -1),
          status: :assigned
        )

      assert %{
               ^request_id => [
                 %{specialist_id: ^newest_specialist_id},
                 %{specialist_id: ^older_specialist_id},
                 %{specialist_id: ^oldest_specialist_id}
               ]
             } = USBoard.fetch_specialists_history_for_requests([request_id])
    end

    test "returns empty map when there are no specialists assigned to the request" do
      %{id: patient_id} = PatientProfile.Factory.insert(:patient)
      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient_id)

      {:ok, %{id: request_id}} =
        %{patient_id: patient_id, transaction_reference: "1234"}
        |> Visits.Factory.second_opinion_request_default_params()
        |> Visits.request_us_board_second_opinion()

      assert %{} = USBoard.fetch_specialists_history_for_requests([request_id])
    end
  end

  defp get_us_board_request_with_assigned_specialist do
    %{id: patient_id} = PatientProfile.Factory.insert(:patient)
    _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient_id)

    {:ok, %{id: request_id}} =
      %{patient_id: patient_id, transaction_reference: "1234"}
      |> Visits.Factory.second_opinion_request_default_params()
      |> Visits.request_us_board_second_opinion()

    %{id: specialist_id} = Authentication.Factory.insert(:verified_specialist)

    Visits.USBoard.assign_specialist_to_second_opinion_request(specialist_id, request_id)

    %{specialist_id: specialist_id, request_id: request_id}
  end
end
