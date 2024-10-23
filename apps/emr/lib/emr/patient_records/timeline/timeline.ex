defmodule EMR.PatientRecords.Timeline do
  use Postgres.Schema
  use Postgres.Service

  alias EMR.PatientRecords.PatientRecord
  alias EMR.PatientRecords.Timeline.Item

  @spec fetch_by_id(String.t() | non_neg_integer) ::
          {:ok, %{timeline_items: [struct]}, [specialist_id :: pos_integer]}
          | {:error, :not_found}
  def fetch_by_id(record_id) do
    with {:ok, timeline} <- fetch_timeline_by_id(record_id),
         {:ok, specialists} <- fetch_specialists(record_id, timeline) do
      {:ok, timeline, specialists}
    end
  end

  @spec fetch_timeline_by_id(String.t() | non_neg_integer) ::
          {:ok, %{timeline_items: list(struct)}} | {:error, :not_found}
  defp fetch_timeline_by_id(record_id) do
    Item
    |> where(timeline_id: ^record_id)
    |> Item.join_and_preload_all_item_types()
    |> order_by([t], desc: t.inserted_at)
    |> Repo.all()
    |> case do
      [] ->
        case record_exists?(record_id) do
          true -> {:ok, %{timeline_items: []}}
          false -> {:error, :not_found}
        end

      timeline_items ->
        {:ok, %{timeline_items: timeline_items}}
    end
  end

  defp fetch_specialists(record_id, timeline) do
    timeline
    |> specialist_ids_in_timeline()
    |> case do
      [] ->
        {:ok, record} = fetch_record_by_id(record_id)
        {:ok, EMR.PatientRecords.PatientRecord.get_main_specialist_ids(record)}

      specialists ->
        {:ok, specialists}
    end
  end

  @spec fetch_record_by_id(String.t() | non_neg_integer) :: {:ok, struct} | {:error, :not_found}
  defp fetch_record_by_id(record_id) do
    PatientRecord
    |> where(id: ^record_id)
    |> Repo.fetch_one()
  end

  @spec specialist_ids_in_timeline(%{timeline_items: [struct]}) :: [pos_integer]
  defp specialist_ids_in_timeline(timeline) do
    timeline.timeline_items
    |> Enum.flat_map(&Item.specialist_ids_in_item/1)
    |> Enum.uniq()
  end

  @spec record_exists?(non_neg_integer) :: boolean
  defp record_exists?(record_id) do
    case Repo.fetch(EMR.PatientRecords.PatientRecord, record_id) do
      {:ok, _timeline} -> true
      {:error, :not_found} -> false
    end
  end
end
