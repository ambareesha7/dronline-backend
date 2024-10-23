defmodule PatientProfile.ReviewOfSystem do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "reviews_of_system" do
    field :form, PatientProfile.ReviewOfSystem.EctoType.Form, source: :encoded_form

    field :patient_id, :integer

    # optional metadata
    field :provided_by_specialist_id, :integer

    timestamps()
  end

  defp changeset(struct, params) do
    struct
    |> cast(params, [:form])
    |> validate_required([:form, :patient_id])
    |> validate_form_fields()
  end

  @doc """
  Get RoS based on patient_id
  If patient doesn't have one yet then returns empty one.
  """
  @spec get_latest(pos_integer) :: %__MODULE__{}
  def get_latest(patient_id) do
    __MODULE__
    |> where(patient_id: ^patient_id)
    |> order_by(desc: :inserted_at)
    |> limit(1)
    |> Repo.one()
    |> case do
      nil ->
        %__MODULE__{
          patient_id: patient_id,
          form: PatientProfile.ReviewOfSystem.Template.template(),
          inserted_at: DateTime.utc_now()
        }

      %__MODULE__{} = ros ->
        ros
    end
  end

  @spec fetch_paginated(pos_integer, map) :: {:ok, [%__MODULE__{}], String.t()}
  def fetch_paginated(patient_id, params) do
    {:ok, result, next_token} =
      __MODULE__
      |> where(patient_id: ^patient_id)
      |> where(^Postgres.Option.next_token(params, :inserted_at, :desc))
      |> order_by(desc: :inserted_at)
      |> Repo.fetch_paginated(params, :inserted_at)

    {:ok, result, parse_next_token(next_token)}
  end

  defp parse_next_token(nil), do: ""
  defp parse_next_token(nt), do: NaiveDateTime.to_iso8601(nt)

  @doc """
  Creates a new RoS for given patient if the RoS is different than the old one
  """
  @spec register_change(pos_integer, Proto.Forms.Form.t(), pos_integer | nil) ::
          {:ok, %__MODULE__{}} | {:error, Ecto.Changeset.t()}
  def register_change(patient_id, form, provided_by_specialist_id \\ nil) do
    ros = get_latest(patient_id)

    ros
    |> changeset(%{form: form})
    |> case do
      %Ecto.Changeset{valid?: false} = changeset ->
        {:error, changeset}

      %Ecto.Changeset{changes: changes, valid?: true} when map_size(changes) == 0 ->
        {:ok, ros}

      _changeset ->
        Repo.insert(%__MODULE__{
          patient_id: patient_id,
          form: form,
          provided_by_specialist_id: provided_by_specialist_id
        })
    end
  end

  defp validate_form_fields(changeset) do
    form = get_field(changeset, :form)

    if form.fields == [], do: raise("invalid form template")

    changeset
  end
end
