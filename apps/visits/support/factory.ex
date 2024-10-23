defmodule Visits.Factory do
  alias Visits.USBoard.SecondOpinionAssignedSpecialist

  use Postgres.Service

  defp visit_default_params do
    %{
      id: UUID.uuid4(),
      start_time: DateTime.utc_now() |> DateTime.to_unix()
    }
  end

  defp second_opinion_assigned_specialist_default_params do
    now = DateTime.utc_now()

    %{
      specialist_id: :rand.uniform(1000),
      assigned_at: now,
      accepted_at: now,
      rejected_at: nil,
      status: :accepted
    }
  end

  def second_opinion_request_default_params(params \\ %{}) do
    default_params = %{
      patient_id: :rand.uniform(1000),
      patient_description: "I'm sick",
      patient_email: "patient@example.com",
      files: [%{path: "/file.pdf"}],
      status: :requested,
      amount: "499",
      currency: "AED",
      transaction_reference: UUID.uuid4(),
      payment_method: "telr"
    }

    Map.merge(default_params, params)
  end

  def insert(type, params \\ %{})

  def insert(:ended_visit,  params) do
    params = Map.merge(visit_default_params(), Enum.into(params, %{}))

    {:ok, visit} =
      Visits.EndedVisit.create(
        Map.merge(
          %Visits.PendingVisit{
            state: "PENDING",
            visit_type: :ONLINE
          },
          params
        )
      )

    visit
  end

  def insert(:us_board_second_opinion_request, params) do
    params = Map.merge(second_opinion_request_default_params(), Enum.into(params, %{}))

    {:ok, second_opinion_request} = Visits.request_us_board_second_opinion(params)

    second_opinion_request
  end

  def insert(:second_opinion_assigned_specialist, params) do
    params = Map.merge(second_opinion_assigned_specialist_default_params(), Enum.into(params, %{}))

    {:ok, assigned_specialist} =
      %SecondOpinionAssignedSpecialist{}
      |> SecondOpinionAssignedSpecialist.changeset(params)
      |> Repo.insert()

    assigned_specialist
  end
end
