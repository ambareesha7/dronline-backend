defmodule Visits.Visit do
  @moduledoc """
  Postgres view (union all on pending, prepared and ended visits)

  Defined in `Postgres.Repo.Migrations.CreateVisitsLogView`
  """

  use Postgres.Schema
  use Postgres.Service

  @minutes_in_timeslot 30
  @seconds_in_minute 60
  @seconds_in_timeslot @minutes_in_timeslot * @seconds_in_minute

  @primary_key {:id, :binary_id, autogenerate: false}

  schema "visits_log" do
    field :start_time, :integer

    field :chosen_medical_category_id, :integer
    field :patient_id, :integer
    field :record_id, :integer
    field :specialist_id, :integer

    # PENDING or ENDED or CANCELED
    field :state, :string

    # Expected one of the following atoms:
    # :CANCELED, :DONE, :ONGOING, :SCHEDULED
    field :status, :any, virtual: true

    field :visit_type, Ecto.Enum, values: [:ONLINE, :IN_OFFICE, :US_BOARD]

    timestamps()
  end

  @spec fetch(String.t()) :: {:ok, %__MODULE__{}}
  def fetch(id) do
    visit = Repo.get(__MODULE__, id)

    {:ok, visit}
  end

  @spec fetch_for_patient(String.t()) ::
          {:ok,
           %{
             visit: %__MODULE__{},
             medical_category: %Visits.MedicalCategory{},
             payment: %Visits.Visit.Payment{}
           }}
  def fetch_for_patient(id) do
    visit =
      __MODULE__
      |> join(:left, [v], vp in Visits.Visit.Payment, on: v.record_id == vp.visit_id)
      |> join(:left, [v], usp in Visits.USBoard.SecondOpinionRequestPayment,
        on: v.record_id == usp.visit_id
      )
      |> join(:left, [v], mc in Visits.MedicalCategory, on: v.chosen_medical_category_id == mc.id)
      |> where([v], v.id == ^id)
      |> select([v, vp, usp, mc], %{
        visit: v,
        payment: vp,
        us_board_payment: usp,
        medical_category: mc
      })
      |> Repo.one()

    {:ok, assign_status(visit)}
  end

  @spec get_by_record_id(integer()) :: %__MODULE__{} | nil
  def get_by_record_id(record_id) do
    Repo.get_by(__MODULE__, %{record_id: record_id})
  end

  @spec fetch_by_record_id(integer()) :: %__MODULE__{} | nil
  def fetch_by_record_id(record_id) do
    Repo.fetch_by(__MODULE__, %{record_id: record_id})
  end

  @spec fetch_for_patients([pos_integer], map) ::
          {:ok, [%__MODULE__{}], next_token :: pos_integer | nil}
  def fetch_for_patients(patient_ids, params) do
    {:ok, result, next_token} =
      __MODULE__
      |> join(:left, [v], vp in Visits.Visit.Payment, on: v.record_id == vp.visit_id)
      |> join(:left, [v], usp in Visits.USBoard.SecondOpinionRequestPayment,
        on: v.record_id == usp.visit_id
      )
      |> join(:left, [v], mc in Visits.MedicalCategory, on: v.chosen_medical_category_id == mc.id)
      |> where([v], v.patient_id in ^patient_ids)
      |> where(^Postgres.Option.next_token(params, :start_time, :desc))
      |> status_filter(params)
      |> order_by(desc: :start_time)
      |> select([v, vp, usp, mc], %{
        visit: v,
        payment: vp,
        us_board_payment: usp,
        medical_category: mc
      })
      |> Repo.fetch_paginated(params, {:visit, :start_time})

    {:ok, Enum.map(result, &assign_status/1), next_token}
  end

  @spec fetch_for_record(pos_integer, pos_integer, map) ::
          {:ok, [%__MODULE__{}], next_token :: pos_integer | nil}
  def fetch_for_record(patient_id, record_id, params) do
    {:ok, result, next_token} =
      __MODULE__
      |> where(patient_id: ^patient_id)
      |> where(record_id: ^record_id)
      |> where(^Postgres.Option.next_token(params, :start_time, :desc))
      |> status_filter(params)
      |> order_by(desc: :start_time)
      |> Repo.fetch_paginated(params, :start_time)

    {:ok, Enum.map(result, &assign_status/1), next_token}
  end

  defp assign_status(%{visit: %__MODULE__{} = visit} = data) do
    Map.put(data, :visit, assign_status(visit))
  end

  defp assign_status(%__MODULE__{} = visit) do
    %__MODULE__{visit | status: parse_status(visit)}
  end

  defp parse_status(%__MODULE__{state: "CANCELED"}) do
    :CANCELED
  end

  defp parse_status(%__MODULE__{} = visit) do
    ongoing_slot_start_time = ongoing_slot_start_time()

    case visit.start_time do
      start_time when start_time < ongoing_slot_start_time -> :DONE
      start_time when start_time < ongoing_slot_start_time + @seconds_in_timeslot -> :ONGOING
      _ -> :SCHEDULED
    end
  end

  defp status_filter(query, %{"status" => "CANCELED"}) do
    query |> where([q], q.state == "CANCELED")
  end

  defp status_filter(query, %{"status" => "DONE"}) do
    query
    |> where([q], q.start_time < ^ongoing_slot_start_time())
  end

  defp status_filter(query, %{"status" => "ONGOING"}) do
    ongoing_slot_start_time = ongoing_slot_start_time()

    query
    |> where([q], q.start_time >= ^ongoing_slot_start_time)
    |> where([q], q.start_time < ^(ongoing_slot_start_time + @seconds_in_timeslot))
  end

  defp status_filter(query, %{"status" => "SCHEDULED"}) do
    query
    |> where([q], q.start_time >= ^(ongoing_slot_start_time() + @seconds_in_timeslot))
  end

  defp status_filter(query, _params) do
    query
  end

  defp ongoing_slot_start_time do
    now = DateTime.utc_now() |> DateTime.to_unix()
    div(now, @seconds_in_timeslot) * @seconds_in_timeslot
  end
end
