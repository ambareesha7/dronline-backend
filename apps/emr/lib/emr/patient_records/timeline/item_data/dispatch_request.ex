defmodule EMR.PatientRecords.Timeline.ItemData.DispatchRequest do
  use Postgres.Schema
  use Postgres.Service

  alias EMR.PatientRecords.Timeline.Commands.CreateDispatchRequestItem

  @behaviour EMR.PatientRecords.Timeline.ItemData

  schema "dispatch_request_timeline_items" do
    field :patient_location_address, :map
    field :record_id, :integer
    field :request_id, :string
    field :requester_id, :integer

    timestamps()
  end

  @fields [:patient_location_address, :record_id, :request_id, :requester_id]
  defp create_changeset(%__MODULE__{} = struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
  end

  def create(%CreateDispatchRequestItem{} = cmd) do
    params = Map.from_struct(cmd)

    %__MODULE__{}
    |> create_changeset(params)
    |> Repo.insert()
  end

  @impl true
  def specialist_ids_in_item(%__MODULE__{} = struct) do
    [struct.requester_id]
  end

  @impl true
  def display_name do
    "Dispatched T.U."
  end
end
