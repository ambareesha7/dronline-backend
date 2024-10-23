defmodule Visits.PendingVisit do
  use Postgres.Schema
  use Postgres.Service

  @minutes_in_timeslot 30
  @seconds_in_minute 60
  @seconds_in_timeslot @minutes_in_timeslot * @seconds_in_minute

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "pending_visits" do
    field :start_time, :integer

    field :chosen_medical_category_id, :integer
    field :patient_id, :integer
    field :record_id, :integer
    field :specialist_id, :integer
    field :team_id, :integer
    field :visit_type, Ecto.Enum, values: [:ONLINE, :IN_OFFICE, :US_BOARD]

    field :state, :string, virtual: true, default: "PENDING"

    timestamps()
  end

  @required_fields [
    :chosen_medical_category_id,
    :patient_id,
    :record_id,
    :specialist_id,
    :start_time,
    :visit_type
  ]

  @fields @required_fields ++ [:team_id]

  defp changeset(%__MODULE__{} = struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> validate_number(:chosen_medical_category_id, greater_than: 0)
    |> validate_number(:patient_id, greater_than: 0)
    |> validate_number(:record_id, greater_than: 0)
    |> validate_number(:specialist_id, greater_than: 0)
  end

  def create(params) do
    %__MODULE__{}
    |> changeset(params)
    |> Repo.insert()
  end

  @spec get(pos_integer) :: %__MODULE__{} | nil
  def get(id) do
    Repo.get(__MODULE__, id)
  end

  @spec get_pending_visits(integer()) :: [%__MODULE__{}]
  def get_pending_visits(gp_id) do
    team_id = Teams.specialist_team_id(gp_id)

    now = DateTime.utc_now() |> DateTime.to_unix()

    __MODULE__
    |> where(team_id: ^team_id)
    |> where([v], v.start_time > ^(now - @seconds_in_timeslot))
    |> limit(50)
    |> order_by(asc: :start_time)
    |> Repo.all()
  end

  @spec get_upcoming_for_reminder(pos_integer, Keyword.t()) :: [__MODULE__]
  def get_upcoming_for_reminder(seconds_to_visit, opts \\ []) when seconds_to_visit > 60 do
    now = Timex.now() |> Timex.to_unix()
    since = now + seconds_to_visit - @seconds_in_minute
    till = now + seconds_to_visit + @seconds_in_minute

    __MODULE__
    |> join(:left, [v], r in "sent_visit_reminders_v2", on: v.id == r.visit_id)
    |> where(
      [v, r],
      is_nil(r) and
        v.start_time > ^since and
        v.start_time < ^till
    )
    |> Repo.all(opts)
  end

  @spec get_starting_for_reminder(pos_integer, Keyword.t()) :: [__MODULE__]
  def get_starting_for_reminder(seconds_to_visit, opts \\ []) do
    now = Timex.now() |> Timex.to_unix()
    since = now
    till = now + seconds_to_visit

    __MODULE__
    |> join(:left, [v], r in "sent_visit_starting_reminders", on: v.id == r.visit_id)
    |> where(
      [v, r],
      is_nil(r) and
        v.start_time >= ^since and
        v.start_time < ^till
    )
    |> Repo.all(opts)
  end

  @spec get_pending_visits_for_specialist(pos_integer) :: [%__MODULE__{}]
  def get_pending_visits_for_specialist(specialist_id, params \\ %{}) do
    now = DateTime.utc_now() |> DateTime.to_unix()

    __MODULE__
    |> where(specialist_id: ^specialist_id)
    |> where([v], v.start_time > ^(now - @seconds_in_timeslot))
    |> limit_by(params)
    |> filter_by(:visit_types, params)
    |> filter_by(:today, params)
    |> filter_by(:exclude_today, params)
    |> order_by(asc: :start_time)
    |> Repo.all()
  end

  defp limit_by(query, params) do
    limit = Map.get(params, :limit)

    if limit do
      limit(query, ^params.limit)
    else
      limit(query, 50)
    end
  end

  defp filter_by(query, :visit_types, %{visit_types: types}) when is_list(types) do
    if Enum.empty?(types) do
      query
    else
      where(query, [v], v.visit_type in ^types)
    end
  end

  defp filter_by(query, :today, %{today: true}) do
    end_of_day =
      DateTime.utc_now()
      |> Timex.end_of_day()
      |> DateTime.to_unix()

    where(query, [v], v.start_time < ^end_of_day)
  end

  defp filter_by(query, :exclude_today, %{exclude_today: true}) do
    start_of_day = DateTime.utc_now() |> Timex.beginning_of_day() |> DateTime.to_unix()
    end_of_day = DateTime.utc_now() |> Timex.end_of_day() |> DateTime.to_unix()

    where(query, [v], not (v.start_time >= ^start_of_day and v.start_time <= ^end_of_day))
  end

  defp filter_by(query, _, _params), do: query
end
