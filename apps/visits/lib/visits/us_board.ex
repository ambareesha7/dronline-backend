defmodule Visits.USBoard do
  import Ecto.Query

  alias Postgres.Repo
  alias Visits.USBoard.SecondOpinionAssignedSpecialist
  alias Visits.USBoard.SecondOpinionRequest
  alias Visits.USBoard.SecondOpinionRequestFSM

  def request_second_opinion(params) do
    %SecondOpinionRequest{}
    |> SecondOpinionRequest.changeset(params)
    |> Repo.insert()
  end

  def fetch_patient_second_opinion_requests(patient_id) do
    query =
      from r in SecondOpinionRequest,
        where: r.patient_id == ^patient_id,
        preload: [
          :us_board_second_opinion_request_payment,
          :assigned_specialists
        ],
        order_by: [desc: r.inserted_at]

    Repo.fetch_all(query)
  end

  def fetch_specialist_second_opinion_requests(specialist_id) do
    {:ok, assigned_specialists} =
      Visits.USBoard.SecondOpinionAssignedSpecialist
      |> where([s], s.status in [:assigned, :accepted, :rejected])
      |> where([s], s.specialist_id == ^specialist_id)
      |> order_by([s], desc: s.assigned_at)
      |> Repo.fetch_all()

    second_opinion_request_ids =
      Enum.map(assigned_specialists, & &1.us_board_second_opinion_request_id)

    {:ok, second_opinion_requests} =
      SecondOpinionRequest
      |> where([r], r.id in ^second_opinion_request_ids)
      |> Repo.fetch_all()

    put_request_status = fn request, assigned_specialist ->
      # If `requests_with_specialists` entry was rejected by specialist,
      # the status shouldn't be changed to the next request statuses, but should remain `:rejected`.
      #
      # If the same request is assigned to specialist again, after being rejected,
      # it gets a new `requests_with_specialists` entry as an equivalent.
      if assigned_specialist.status == :rejected do
        Map.put(request, :status, assigned_specialist.status)
      else
        request
      end
    end

    requests_with_specialists =
      Enum.map(assigned_specialists, fn assigned_specialist ->
        second_opinion_requests
        |> Enum.find(&(&1.id == assigned_specialist.us_board_second_opinion_request_id))
        |> Map.put(:assigned_specialists, [assigned_specialist])
        |> put_request_status.(assigned_specialist)
      end)

    {:ok, requests_with_specialists}
  end

  def fetch_second_opinion_request(request_id) do
    query =
      from r in SecondOpinionRequest,
        where: r.id == ^request_id,
        preload: [
          :us_board_second_opinion_request_payment,
          :assigned_specialists
        ]

    Repo.fetch_one(query)
  end

  @spec fetch_second_opinion_request_by_visit_id(String.t()) ::
          {:ok, %SecondOpinionRequest{}} | {:error, :not_found}
  def fetch_second_opinion_request_by_visit_id(visit_id) do
    query =
      from r in SecondOpinionRequest,
        where: r.visit_id == ^visit_id,
        preload: [
          :us_board_second_opinion_request_payment,
          :assigned_specialists
        ]

    Repo.fetch_one(query)
  end

  def fetch_payment_by_request_id(request_id) do
    query =
      from p in Visits.USBoard.SecondOpinionRequestPayment,
        where: p.us_board_second_opinion_request_id == ^request_id

    Repo.fetch_one(query)
  end

  def get_accepted_specialist_id(request_id) do
    Visits.USBoard.SecondOpinionAssignedSpecialist
    |> select([s], s.specialist_id)
    |> where([s], s.status in [:accepted])
    |> where([s], s.us_board_second_opinion_request_id == ^request_id)
    |> Repo.one()
  end

  def assign_specialist_to_second_opinion_request(specialist_id, request_id) do
    with {_count, nil} <- unassing_specialists_from_request(request_id),
         {:ok, assigned_specialist} <- assign_specialist_to_request(specialist_id, request_id),
         {:ok, _request} <- SecondOpinionRequestFSM.change_status(request_id, :assigned) do
      {:ok, assigned_specialist}
    end
  end

  def move_request_to_call_scheduled(request_id, visit_id) do
    with {:ok, _request} <- SecondOpinionRequestFSM.change_status(request_id, :call_scheduled) do
      assign_request_to_visit(request_id, visit_id)
    end
  end

  def move_request_to_in_progress(request_id),
    do: SecondOpinionRequestFSM.change_status(request_id, :in_progress)

  def move_request_to_opinion_submitted(request_id),
    do: SecondOpinionRequestFSM.change_status(request_id, :opinion_submitted)

  def move_request_to_rejected(request_id),
    do: SecondOpinionRequestFSM.change_status(request_id, :rejected)

  def move_request_to_done(request_id),
    do: SecondOpinionRequestFSM.change_status(request_id, :done)

  def move_request_to_landing_booking(request_id),
    do: SecondOpinionRequestFSM.change_status(request_id, :landing_booking)

  defp unassing_specialists_from_request(request_id) do
    utc_now = DateTime.utc_now()

    query =
      from(as in SecondOpinionAssignedSpecialist,
        where: as.us_board_second_opinion_request_id == ^request_id,
        where: as.status in [:assigned, :accepted],
        update: [set: [status: :unassigned, updated_at: ^utc_now]]
      )

    Repo.update_all(query, [])
  end

  defp assign_request_to_visit(request_id, visit_id) do
    SecondOpinionRequest
    |> Repo.get(request_id)
    |> SecondOpinionRequest.changeset(%{visit_id: visit_id})
    |> Repo.update()
  end

  defp assign_specialist_to_request(specialist_id, request_id) do
    params = %{
      specialist_id: specialist_id,
      us_board_second_opinion_request_id: request_id,
      assigned_at: DateTime.utc_now(),
      status: "assigned"
    }

    %SecondOpinionAssignedSpecialist{}
    |> SecondOpinionAssignedSpecialist.changeset(params)
    |> Repo.insert()
  end
end
