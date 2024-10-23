defmodule EMR.HPI do
  use Postgres.Schema
  use Postgres.Service

  @behaviour EMR.PatientRecords.Timeline.ItemData

  schema "hpis" do
    field :patient_id, :integer
    field :timeline_id, :integer
    field :form, EMR.HPI.EctoType.Form, source: :encoded_form

    timestamps()
  end

  @fields [:form]
  defp changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_hpi_form_fields()
  end

  @doc """
  Fetches hpi based on timeline_id
  If record doesn't have one yet then returns empty one.
  """
  @spec fetch_last_for_timeline_id(pos_integer, pos_integer, :default | :coronavirus) ::
          {:ok, %__MODULE__{}}
  def fetch_last_for_timeline_id(patient_id, timeline_id, kind \\ :default) do
    __MODULE__
    |> where(patient_id: ^patient_id, timeline_id: ^timeline_id)
    |> order_by(desc: :inserted_at)
    |> limit(1)
    |> Repo.fetch_one()
    |> case do
      {:ok, hpi} ->
        {:ok, hpi}

      {:error, :not_found} ->
        {:ok,
         %__MODULE__{
           patient_id: patient_id,
           timeline_id: timeline_id,
           form: EMR.HPI.Template.template(kind)
         }}
    end
  end

  @spec fetch_history_for_timeline_id(pos_integer) :: {:ok, [%__MODULE__{}]}
  def fetch_history_for_timeline_id(timeline_id) do
    {:ok, hpis} =
      __MODULE__
      |> where(timeline_id: ^timeline_id)
      |> order_by(desc: :inserted_at)
      |> Repo.fetch_all()

    {:ok, hpis}
  end

  @doc """
  Creates a new hpi record for given timeline_id if the hpi is different than the old one
  """
  @spec register_history(pos_integer, pos_integer, Proto.Forms.Form.t()) ::
          {:ok, %__MODULE__{}} | {:error, Ecto.Changeset.t()}
  def register_history(patient_id, timeline_id, form) do
    params = %{form: form}

    {:ok, hpi} = fetch_last_for_timeline_id(patient_id, timeline_id, :default)

    hpi
    |> changeset(params)
    |> case do
      %Ecto.Changeset{valid?: false} = changeset ->
        {:error, changeset}

      %Ecto.Changeset{changes: changes, valid?: true} when map_size(changes) == 0 ->
        {:ok, hpi}

      _ ->
        insert_new_hpi(hpi, params)
    end
  end

  defp insert_new_hpi(hpi, params) do
    %__MODULE__{patient_id: hpi.patient_id, timeline_id: hpi.timeline_id}
    |> changeset(params)
    |> Repo.insert()
    |> case do
      {:ok, hpi} ->
        {:ok, _timeline_item} =
          EMR.PatientRecords.Timeline.Item.create_hpi_item(
            hpi.patient_id,
            hpi.timeline_id,
            hpi.id
          )

        {:ok, hpi}

      error ->
        error
    end
  end

  defp validate_hpi_form_fields(changeset) do
    form = get_field(changeset, :form)

    if form.fields == [], do: raise("invalid form template")

    if Enum.all?(form.fields, fn field -> proto_has_value?(field) end) do
      changeset
    else
      add_error(changeset, :_form, "All fields has to be filled in")
    end
  end

  defp proto_has_value?(%{value: {:string, %{value: value}}}) do
    value && value != ""
  end

  defp proto_has_value?(%{value: {:select, %{choice: nil}}}), do: false
  defp proto_has_value?(%{value: {:select, %{choice: _}}}), do: true

  @impl true
  def specialist_ids_in_item(%__MODULE__{}) do
    []
  end

  @impl true
  def display_name do
    "Provided HPI"
  end
end
