defmodule EMR.PatientRecords.Timeline.ItemData.Call do
  use Postgres.Schema
  use Postgres.Service

  alias EMR.PatientRecords.Timeline.Commands.CreateCallItem

  @behaviour EMR.PatientRecords.Timeline.ItemData

  schema "calls" do
    field :patient_id, :integer
    field :specialist_id, :integer
    field :timeline_id, :integer
    field :medical_category_id, :integer

    timestamps()
  end

  @fields [:patient_id, :specialist_id, :timeline_id, :medical_category_id]
  defp create_changeset(%__MODULE__{} = call, params) do
    call |> cast(params, @fields)
  end

  def create(%CreateCallItem{} = cmd) do
    params = %{
      patient_id: cmd.patient_id,
      specialist_id: cmd.specialist_id,
      timeline_id: cmd.record_id,
      medical_category_id: cmd.medical_category_id
    }

    %__MODULE__{}
    |> create_changeset(params)
    |> Repo.insert()
  end

  @impl true
  def specialist_ids_in_item(%__MODULE__{} = struct) do
    [struct.specialist_id]
  end

  @impl true
  def display_name do
    "Connected"
  end
end
