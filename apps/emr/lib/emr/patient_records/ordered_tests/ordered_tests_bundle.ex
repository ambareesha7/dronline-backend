defmodule EMR.PatientRecords.OrderedTestsBundle do
  use Postgres.Schema
  use Postgres.Service

  alias EMR.PatientRecords.OrderedTest
  alias EMR.PatientRecords.Timeline.Item
  alias Postgres.Repo

  @behaviour EMR.PatientRecords.Timeline.ItemData

  schema "ordered_tests_bundles" do
    field :specialist_id, :integer
    field :patient_id, :integer
    field :timeline_id, :integer

    has_many :ordered_tests, OrderedTest,
      foreign_key: :bundle_id,
      references: :id,
      on_replace: :delete

    timestamps()
  end

  @spec create(pos_integer, pos_integer, pos_integer, map) ::
          {:ok, %__MODULE__{}} | {:error, Ecto.Changeset.t()}
  def create(patient_id, record_id, specialist_id, params) do
    %__MODULE__{patient_id: patient_id, timeline_id: record_id, specialist_id: specialist_id}
    |> create_changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, ordered_tests_bundle} ->
        {:ok,
         %Item{
           ordered_tests_bundle: ordered_tests_bundle
         }} =
          Item.create_ordered_tests_bundle_item(
            patient_id,
            record_id,
            ordered_tests_bundle.id
          )

        {:ok, ordered_tests_bundle}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  @spec fetch_history_for_record(pos_integer) ::
          {:ok, [%__MODULE__{}]}
  def fetch_history_for_record(record_id)
      when is_integer(record_id) do
    ordered_tests_bundles =
      __MODULE__
      |> where(timeline_id: ^record_id)
      |> order_by(desc: :inserted_at)
      |> preload(ordered_tests: [medical_test: [:medical_tests_category]])
      |> Repo.all()

    {:ok, ordered_tests_bundles}
  end

  @spec fetch_by_id(pos_integer) ::
          {:ok, %__MODULE__{}}
  def fetch_by_id(bundle_id) do
    ordered_tests_bundle =
      __MODULE__
      |> where(id: ^bundle_id)
      |> preload(ordered_tests: [medical_test: [:medical_tests_category]])
      |> Repo.one()

    {:ok, ordered_tests_bundle}
  end

  @fields [
    :patient_id,
    :specialist_id,
    :timeline_id
  ]
  defp create_changeset(%__MODULE__{} = struct, params) do
    struct
    |> change()
    |> put_assoc(:ordered_tests, get_items_from_params(params))
    |> validate_length(:ordered_tests, min: 1)
    |> validate_required(@fields)
  end

  @impl true
  def specialist_ids_in_item(%__MODULE__{} = struct) do
    [struct.specialist_id]
  end

  @impl true
  def display_name do
    "Ordered tests"
  end

  defp get_items_from_params(%{items: items}) do
    items
    |> Enum.map(fn item ->
      %EMR.PatientRecords.OrderedTest{
        medical_test_id: item.medical_test_id,
        description: item.description
      }
    end)
  end
end
