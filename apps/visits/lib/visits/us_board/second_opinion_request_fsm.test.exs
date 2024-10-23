defmodule Visits.USBoard.SecondOpinionRequestFSMTest do
  use Postgres.DataCase, async: true

  alias Visits.USBoard.SecondOpinionRequestFSM

  describe "change_status/2" do
    setup do
      %{id: patient_id} = PatientProfile.Factory.insert(:patient)
      _basic_info = PatientProfile.Factory.insert(:basic_info, patient_id: patient_id)

      {:ok, %{id: request_id}} =
        %{
          patient_id: patient_id,
          patient_description: "Help me!",
          patient_email: "other@email.com",
          files: [%{path: "/file.com"}],
          status: "requested",
          transaction_reference: "5678",
          payment_method: "telr"
        }
        |> Visits.request_us_board_second_opinion()

      {:ok, request_id: request_id}
    end

    test "changes status and returns ok tuple when transition is possible", %{
      request_id: request_id
    } do
      assert {:ok, %{status: :assigned}} =
               SecondOpinionRequestFSM.change_status(request_id, :assigned)

      assert {:ok, %{status: :assigned}} =
               SecondOpinionRequestFSM.change_status(request_id, :assigned)

      assert {:ok, %{status: :rejected}} =
               SecondOpinionRequestFSM.change_status(request_id, :rejected)

      assert {:ok, %{status: :assigned}} =
               SecondOpinionRequestFSM.change_status(request_id, :assigned)

      assert {:ok, %{status: :in_progress}} =
               SecondOpinionRequestFSM.change_status(request_id, :in_progress)

      assert {:ok, %{status: :assigned}} =
               SecondOpinionRequestFSM.change_status(request_id, :assigned)

      assert {:ok, %{status: :in_progress}} =
               SecondOpinionRequestFSM.change_status(request_id, :in_progress)

      assert {:ok, %{status: :opinion_submitted}} =
               SecondOpinionRequestFSM.change_status(request_id, :opinion_submitted)

      assert {:ok, %{status: :call_scheduled}} =
               SecondOpinionRequestFSM.change_status(request_id, :call_scheduled)

      assert {:ok, %{status: :done}} = SecondOpinionRequestFSM.change_status(request_id, :done)
    end

    test "doesn't change a status and returns error tutple when transition is not possible", %{
      request_id: request_id
    } do
      assert {:error, :wrong_status_transition} =
               SecondOpinionRequestFSM.change_status(request_id, :in_progress)
    end
  end
end
