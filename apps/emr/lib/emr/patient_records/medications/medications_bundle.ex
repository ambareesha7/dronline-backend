defmodule EMR.PatientRecords.MedicationsBundle do
  use Postgres.Schema
  use Postgres.Service

  alias __MODULE__.Medication
  alias EMR.PatientRecords.Timeline.Item
  alias Postgres.Repo

  @behaviour EMR.PatientRecords.Timeline.ItemData

  schema "medications_bundles" do
    field :specialist_id, :integer
    field :patient_id, :integer
    field :timeline_id, :integer

    embeds_many :medications, Medication, on_replace: :delete

    timestamps()
  end

  @spec create(pos_integer, pos_integer, pos_integer, map) ::
          {:ok, nil} | {:error, Ecto.Changeset.t()}
  def create(patient_id, record_id, specialist_id, params) do
    %__MODULE__{patient_id: patient_id, timeline_id: record_id, specialist_id: specialist_id}
    |> create_changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, medications_bundle} ->
        {:ok, _timeline_item} =
          Item.create_medications_bundle_item(
            patient_id,
            record_id,
            medications_bundle.id
          )

        {:ok, medications_bundle}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @spec fetch_history_for_record(pos_integer) ::
          {:ok, [%__MODULE__{}]}
  def fetch_history_for_record(record_id)
      when is_integer(record_id) do
    medications_bundles =
      __MODULE__
      |> where(timeline_id: ^record_id)
      |> order_by(desc: :inserted_at)
      |> Repo.all()

    payments_params =
      medications_bundles
      |> Enum.map(& &1.id)
      |> EMR.Medications.Payments.fetch_by_medications_bundle_ids()

    medications_bundles =
      Enum.map(medications_bundles, fn bundle ->
        payments_params = Enum.find(payments_params, &(&1.medications_bundle_id == bundle.id))

        Map.put(bundle, :payments_params, payments_params)
      end)

    {:ok, medications_bundles}
  end

  @spec fetch_by_id(pos_integer) ::
          {:ok, %__MODULE__{}}
  def fetch_by_id(bundle_id) do
    medications_bundle =
      __MODULE__
      |> where(id: ^bundle_id)
      |> Repo.one()

    payments_params = EMR.Medications.Payments.fetch_by_medications_bundle_id(bundle_id)

    {:ok, Map.put(medications_bundle, :payments_params, payments_params)}
  end

  @spec fetch_by_bundle_id(pos_integer) :: {:ok, %__MODULE__{}} | {:error, any}
  def fetch_by_bundle_id(bundle_id) do
    medications_bundle =
      __MODULE__
      |> where(id: ^bundle_id)
      |> Repo.one()

    case medications_bundle do
      nil ->
        {:error, :not_found}

      %__MODULE__{} ->
        {:ok, medications_bundle}
    end
  end

  @fields [
    :patient_id,
    :specialist_id,
    :timeline_id
  ]
  defp create_changeset(%__MODULE__{} = struct, params) do
    struct
    |> change()
    |> put_embed(:medications, get_items_from_params(params))
    |> validate_length(:medications, min: 1)
    |> validate_required(@fields)
  end

  defp get_items_from_params(%{items: []}) do
    nil
  end

  defp get_items_from_params(%{items: items}) do
    items
    |> Enum.map(fn item ->
      struct(Medication, item)
    end)
  end

  @impl true
  def specialist_ids_in_item(%__MODULE__{} = struct) do
    [struct.specialist_id]
  end

  @impl true
  def display_name do
    "Assigned Medications"
  end
end

defmodule EMR.PatientRecords.MedicationsBundle.Medication do
  use Postgres.Schema

  embedded_schema do
    field :medication_id, :string
    field :name, :string
    field :direction, :string
    field :quantity, :string
    field :refills, :integer
    # TODO: remove default after setting prices
    field :price_aed, :integer, default: 0
  end

  @fields [:name, :direction, :quantity, :refills, :price_aed]
  @required_fields [:name, :direction, :quantity, :refills, :price_aed]

  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
  end
end
