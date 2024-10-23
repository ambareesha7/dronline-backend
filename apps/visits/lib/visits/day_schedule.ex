defmodule Visits.DaySchedule do
  use Postgres.Schema
  use Postgres.Service

  schema "specialist_day_schedules_v3" do
    field :specialist_id, :integer
    field :date, :date

    embeds_many :free_timeslots, Visits.FreeTimeslot, on_replace: :delete
    embeds_many :taken_timeslots, Visits.TakenTimeslot, on_replace: :delete

    field :free_timeslots_count, :integer, default: 0
    field :taken_timeslots_count, :integer, default: 0

    timestamps()
  end

  @manually_provided_fields [:specialist_id, :date]
  @required_fields [:specialist_id, :date, :free_timeslots_count, :taken_timeslots_count]

  def insert_or_update(%__MODULE__{} = struct, free_timeslots, taken_timeslots) do
    {struct, params} = split_unstored_struct(struct)

    struct
    |> cast(params, @manually_provided_fields)
    |> cast(%{free_timeslots: normalize_embeds(free_timeslots)}, [])
    |> cast(%{taken_timeslots: normalize_embeds(taken_timeslots)}, [])
    |> cast_embed(:free_timeslots)
    |> cast_embed(:taken_timeslots)
    |> put_change(:free_timeslots_count, length(free_timeslots))
    |> put_change(:taken_timeslots_count, length(taken_timeslots))
    |> validate_required(@required_fields)
    |> validate_number(:specialist_id, greater_than: 0)
    |> Repo.insert_or_update()
  end

  def lock_for_update(specialist_id, dates) do
    Visits.DaySchedule
    |> where(specialist_id: ^specialist_id)
    |> where([ds], ds.date in ^dates)
    |> lock("FOR UPDATE")
    |> Repo.all()
  end

  defp normalize_embeds(embeds) when is_list(embeds) do
    for embed <- embeds, do: normalize_embed(embed)
  end

  defp normalize_embed(%_struct{} = struct), do: Map.from_struct(struct)
  defp normalize_embed(%{} = map), do: map

  defp split_unstored_struct(%__MODULE__{id: nil} = struct) do
    {%__MODULE__{}, Map.from_struct(struct)}
  end

  defp split_unstored_struct(%__MODULE__{} = struct) do
    {struct, %{}}
  end
end
