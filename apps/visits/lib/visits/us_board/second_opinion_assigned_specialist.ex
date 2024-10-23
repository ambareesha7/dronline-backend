defmodule Visits.USBoard.SecondOpinionAssignedSpecialist do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "us_board_second_opinion_assigned_specialists" do
    field :specialist_id, :integer
    field :assigned_at, :utc_datetime_usec
    field :accepted_at, :utc_datetime_usec
    field :rejected_at, :utc_datetime_usec
    field :status, Ecto.Enum, values: [:assigned, :accepted, :rejected, :unassigned]

    belongs_to :us_board_second_opinion_request, Visits.USBoard.SecondOpinionRequest,
      type: :binary_id

    timestamps()
  end

  @required [:specialist_id, :us_board_second_opinion_request_id]
  @fields @required ++ [:assigned_at, :accepted_at, :rejected_at, :status]

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
  end

  def fetch_by_specialist_and_request(specialist_id, request_id) do
    __MODULE__
    |> where(specialist_id: ^specialist_id)
    |> where(us_board_second_opinion_request_id: ^request_id)
    |> where([s], s.status in [:assigned, :accepted])
    |> Repo.fetch_one()
  end

  def accept_request(specialist_id, request_id),
    do:
      update_status(specialist_id, request_id, %{
        accepted_at: DateTime.utc_now(),
        status: :accepted,
        rejected_at: nil,
        updated_at: DateTime.utc_now()
      })

  def reject_request(specialist_id, request_id),
    do:
      update_status(specialist_id, request_id, %{
        accepted_at: nil,
        status: :rejected,
        rejected_at: DateTime.utc_now(),
        updated_at: DateTime.utc_now()
      })

  defp update_status(specialist_id, request_id, status_params) do
    with {:ok, assigned_to_request} <- fetch_by_specialist_and_request(specialist_id, request_id),
         {:status, :assigned} <- {:status, assigned_to_request.status} do
      assigned_to_request
      |> changeset(status_params)
      |> Repo.update()
    else
      {:error, error} ->
        {:error, error}

      {:status, _status} ->
        {:error, :invalid_status}
    end
  end
end
