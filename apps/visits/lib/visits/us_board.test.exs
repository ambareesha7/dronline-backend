defmodule Visits.USBoardTest do
  use Postgres.DataCase, async: true

  alias Visits.USBoard
  alias Visits.USBoard.SecondOpinionAssignedSpecialist
  alias Visits.USBoard.SecondOpinionRequest

  describe "fetch_specialist_second_opinion_requests/1" do
    setup do
      specialist = Authentication.Factory.insert(:verified_and_approved_external)

      {:ok, specialist_id: specialist.id}
    end

    test "returns requests currently assigned to specialist, accepted or rejected by specialist",
         %{
           specialist_id: specialist_id
         } do
      {:ok, %{id: assigned_request_id}} = insert_us_board_request(%{status: :assigned})
      {:ok, %{id: accepted_request_id}} = insert_us_board_request(%{status: :in_progress})
      {:ok, %{id: rejected_request_id}} = insert_us_board_request(%{status: :rejected})

      _assigned_specialist =
        Visits.Factory.insert(:second_opinion_assigned_specialist,
          us_board_second_opinion_request_id: assigned_request_id,
          specialist_id: specialist_id,
          status: :assigned
        )

      _accepted_specialist =
        Visits.Factory.insert(:second_opinion_assigned_specialist,
          us_board_second_opinion_request_id: accepted_request_id,
          specialist_id: specialist_id,
          status: :accepted
        )

      _rejected_specialist =
        Visits.Factory.insert(:second_opinion_assigned_specialist,
          us_board_second_opinion_request_id: rejected_request_id,
          specialist_id: specialist_id,
          status: :rejected
        )

      assert {:ok,
              [
                %SecondOpinionRequest{id: ^rejected_request_id},
                %SecondOpinionRequest{id: ^accepted_request_id},
                %SecondOpinionRequest{id: ^assigned_request_id}
              ]} =
               USBoard.fetch_specialist_second_opinion_requests(specialist_id)
    end

    test "doesn't return requests assigned to other specialists", %{
      specialist_id: specialist_id
    } do
      specialist_2 = Authentication.Factory.insert(:verified_and_approved_external)

      {:ok, %{id: assigned_request_id}} = insert_us_board_request(%{status: :assigned})
      {:ok, %{id: assigned_request_id_2}} = insert_us_board_request(%{status: :assigned})

      %{id: accepted_specialist_id} =
        Visits.Factory.insert(:second_opinion_assigned_specialist,
          us_board_second_opinion_request_id: assigned_request_id,
          specialist_id: specialist_id,
          status: :assigned
        )

      _accepted_specialist =
        Visits.Factory.insert(:second_opinion_assigned_specialist,
          us_board_second_opinion_request_id: assigned_request_id_2,
          specialist_id: specialist_2.id,
          status: :assigned
        )

      assert {:ok,
              [
                %SecondOpinionRequest{
                  id: ^assigned_request_id,
                  assigned_specialists: [
                    %SecondOpinionAssignedSpecialist{
                      id: ^accepted_specialist_id,
                      specialist_id: ^specialist_id,
                      status: :assigned
                    }
                  ]
                }
              ]} =
               USBoard.fetch_specialist_second_opinion_requests(specialist_id)
    end

    test "returns only currently assigned specialist with request", %{
      specialist_id: specialist_id
    } do
      %{id: specialist_2_id} = Authentication.Factory.insert(:verified_and_approved_external)

      {:ok, %{id: assigned_request_id}} = insert_us_board_request(%{status: :assigned})

      _previously_assigned_specialist =
        USBoard.assign_specialist_to_second_opinion_request(specialist_id, assigned_request_id)

      {:ok, %{id: currently_assigned_specialist_id}} =
        USBoard.assign_specialist_to_second_opinion_request(specialist_2_id, assigned_request_id)

      assert {:ok,
              [
                %SecondOpinionRequest{
                  id: ^assigned_request_id,
                  assigned_specialists: [
                    %SecondOpinionAssignedSpecialist{
                      id: ^currently_assigned_specialist_id,
                      specialist_id: ^specialist_2_id,
                      status: :assigned
                    }
                  ]
                }
              ]} =
               USBoard.fetch_specialist_second_opinion_requests(specialist_2_id)
    end

    test "doesn't return request, when it's not assigned to a specialist anymore", %{
      specialist_id: specialist_id
    } do
      %{id: specialist_2_id} = Authentication.Factory.insert(:verified_and_approved_external)

      {:ok, %{id: assigned_request_id}} = insert_us_board_request(%{status: :assigned})

      _previously_assigned_specialist =
        USBoard.assign_specialist_to_second_opinion_request(specialist_id, assigned_request_id)

      _currently_assigned_specialist =
        USBoard.assign_specialist_to_second_opinion_request(specialist_2_id, assigned_request_id)

      assert {:ok, []} = USBoard.fetch_specialist_second_opinion_requests(specialist_id)
    end

    test "return twice reassigned requests", %{
      specialist_id: specialist_id
    } do
      {:ok, %{id: request_id}} = insert_us_board_request(%{status: :requested})

      {:ok, %{id: first_assigned_specialist_id}} =
        USBoard.assign_specialist_to_second_opinion_request(specialist_id, request_id)

      {:ok, _request} = SecondOpinionAssignedSpecialist.reject_request(specialist_id, request_id)

      {:ok, %{id: second_assigned_specialist_id}} =
        USBoard.assign_specialist_to_second_opinion_request(specialist_id, request_id)

      assert {:ok,
              [
                %SecondOpinionRequest{
                  id: ^request_id,
                  status: :assigned,
                  assigned_specialists: [
                    %SecondOpinionAssignedSpecialist{
                      id: ^second_assigned_specialist_id,
                      specialist_id: ^specialist_id,
                      status: :assigned
                    }
                  ]
                },
                %SecondOpinionRequest{
                  id: ^request_id,
                  status: :rejected,
                  assigned_specialists: [
                    %SecondOpinionAssignedSpecialist{
                      id: ^first_assigned_specialist_id,
                      specialist_id: ^specialist_id,
                      status: :rejected
                    }
                  ]
                }
              ]} =
               USBoard.fetch_specialist_second_opinion_requests(specialist_id)
    end

    test "doesn't return unassigned requests", %{
      specialist_id: specialist_id
    } do
      %{id: specialist_2_id} = Authentication.Factory.insert(:verified_and_approved_external)

      {:ok, %{id: request_id}} = insert_us_board_request(%{status: :requested})

      {:ok, _assigned_specialist} =
        USBoard.assign_specialist_to_second_opinion_request(specialist_id, request_id)

      {:ok, _assigned_specialist} =
        USBoard.assign_specialist_to_second_opinion_request(specialist_2_id, request_id)

      assert {:ok, []} = USBoard.fetch_specialist_second_opinion_requests(specialist_id)
    end
  end

  describe "get_accepted_specialist_id/1" do
    test "returns aproved specialist" do
      %{id: specialist_id} = Authentication.Factory.insert(:verified_and_approved_external)
      {:ok, %{id: request_id}} = insert_us_board_request(%{status: :requested})

      {:ok, _assigned_specialist} =
        USBoard.assign_specialist_to_second_opinion_request(specialist_id, request_id)

      {:ok, _} = Visits.accept_us_board_second_opinion(specialist_id, request_id)

      assert ^specialist_id = USBoard.get_accepted_specialist_id(request_id)
    end

    test "returns nil when there is no approved specialist" do
      %{id: specialist_id} = Authentication.Factory.insert(:verified_and_approved_external)
      {:ok, %{id: request_id}} = insert_us_board_request(%{status: :requested})

      {:ok, _assigned_specialist} =
        USBoard.assign_specialist_to_second_opinion_request(specialist_id, request_id)

      refute USBoard.get_accepted_specialist_id(request_id)
    end
  end

  defp insert_us_board_request(%{status: status}) do
    patient = PatientProfile.Factory.insert(:patient)

    %{patient_id: patient.id, status: status}
    |> Visits.Factory.second_opinion_request_default_params()
    |> Visits.request_us_board_second_opinion()
  end
end
