defmodule EMR.PatientRecords.Timeline.ItemData.Vitals do
  use Postgres.Schema

  @behaviour EMR.PatientRecords.Timeline.ItemData

  schema "vitals" do
    field :weight, :integer
    field :height, :integer

    field :systolic, :integer
    field :diastolic, :integer
    field :pulse, :integer

    field :ekg_file_url, :string

    field :nurse_id, :integer
    field :patient_id, :integer
    field :timeline_id, :integer

    timestamps()
  end

  @impl true
  def specialist_ids_in_item(%__MODULE__{} = struct) do
    [struct.nurse_id]
  end

  @impl true
  def display_name do
    "Provided Vitals"
  end
end
