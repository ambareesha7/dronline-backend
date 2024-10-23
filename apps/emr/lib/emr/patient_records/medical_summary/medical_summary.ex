defmodule EMR.PatientRecords.MedicalSummary do
  use Postgres.Schema
  use Postgres.Service

  alias EMR.PatientRecords.MedicalLibrary.Condition
  alias EMR.PatientRecords.MedicalLibrary.Procedure
  alias EMR.PatientRecords.PatientRecord

  schema "medical_summaries" do
    field :data, :binary

    field :request_uuid, :string

    field :specialist_id, :integer
    field :is_draft, :boolean
    field :edited_at, :naive_datetime

    belongs_to :timeline, PatientRecord

    many_to_many(
      :conditions,
      Condition,
      join_through: "medical_summaries_conditions",
      on_replace: :delete
    )

    many_to_many(
      :procedures,
      Procedure,
      join_through: "medical_summaries_procedures",
      on_replace: :delete
    )

    timestamps()
  end

  @required_fields [:data, :specialist_id, :timeline_id, :request_uuid]

  @spec create(pos_integer, pos_integer, Proto.EMR.AddMedicalSummaryRequest.t(), String.t()) ::
          {:ok, %__MODULE__{}}
          | {:error, %Ecto.Changeset{}}
  def create(specialist_id, timeline_id, proto, request_uuid) do
    %{
      conditions: conditions,
      procedures: procedures,
      medical_summary_data: summary_data
    } = proto

    params = %{
      request_uuid: request_uuid,
      specialist_id: specialist_id,
      timeline_id: timeline_id,
      conditions: load_conditions(conditions),
      procedures: load_procedures(procedures),
      data: Proto.EMR.MedicalSummaryData.encode(summary_data)
    }

    uuid_match_summary = Repo.get_by(__MODULE__, request_uuid: request_uuid)

    draft_match_summary =
      Repo.get_by(__MODULE__,
        timeline_id: timeline_id,
        specialist_id: specialist_id,
        is_draft: true
      )

    changeset =
      uuid_match_summary
      |> Kernel.||(draft_match_summary)
      |> Kernel.||(%__MODULE__{})
      |> changeset(params)

    with {:ok, medical_summary} <- Repo.insert_or_update(changeset) do
      set_previous_summary_edited_at(medical_summary.id, medical_summary.timeline_id)

      {:ok, medical_summary}
    end
  end

  @spec create_draft(
          pos_integer,
          pos_integer,
          Proto.EMR.AddMedicalSummaryDraftRequest.t()
        ) ::
          {:ok, %__MODULE__{}}
          | {:error, %Ecto.Changeset{}}
  def create_draft(specialist_id, timeline_id, proto) do
    %{
      conditions: conditions,
      procedures: procedures,
      medical_summary_data: summary_data
    } = proto

    params = %{
      specialist_id: specialist_id,
      timeline_id: timeline_id,
      conditions: load_conditions(conditions),
      procedures: load_procedures(procedures),
      data: Proto.EMR.MedicalSummaryData.encode(summary_data)
    }

    medical_summary_draft =
      Repo.get_by(__MODULE__,
        specialist_id: specialist_id,
        timeline_id: timeline_id,
        is_draft: true
      )

    medical_summary_draft
    |> Kernel.||(%__MODULE__{})
    |> draft_changeset(params)
    |> Repo.insert_or_update()
  end

  def draft_changeset(medical_summary, params) do
    medical_summary
    |> Repo.preload([:conditions, :procedures])
    |> change(%{is_draft: true})
    |> cast(params, @required_fields)
    |> put_assoc(:conditions, params.conditions)
    |> put_assoc(:procedures, params.procedures)
  end

  def changeset(medical_summary, params) do
    medical_summary
    |> Repo.preload([:conditions, :procedures])
    |> change(%{is_draft: false})
    |> cast(params, @required_fields)
    |> validate_required(@required_fields)
    |> put_assoc(:conditions, params.conditions)
    |> put_assoc(:procedures, params.procedures)
    |> validate_assoc_length(:conditions, min: 1)
    |> validate_assoc_length(:procedures, min: 1)
  end

  defp validate_assoc_length(changeset, assoc_name, options) do
    assoc = get_field(changeset, assoc_name)

    case Keyword.get(options, :min) do
      nil ->
        changeset

      number ->
        if Enum.count(assoc) >= number do
          changeset
        else
          add_error(changeset, assoc_name, "should have at least %{count} item(s)",
            count: number,
            validation: :length,
            kind: :min,
            type: :list
          )
        end
    end
  end

  @spec fetch_by_id(pos_integer) ::
          {:ok, %__MODULE__{}}
  def fetch_by_id(medical_summary_id) do
    medical_summary =
      __MODULE__
      |> where(id: ^medical_summary_id)
      |> join(:left, [s], c in assoc(s, :conditions))
      |> join(:left, [s, _], t in assoc(s, :procedures))
      |> preload([_s, c, t], conditions: c, procedures: t)
      |> Repo.one()

    {:ok, medical_summary}
  end

  @spec fetch(pos_integer) :: {:ok, [%__MODULE__{}]}
  def fetch(record_id) do
    __MODULE__
    |> where(timeline_id: ^record_id, is_draft: false)
    |> order_by(desc: :inserted_at)
    |> join(:left, [s], c in assoc(s, :conditions))
    |> join(:left, [s, _], t in assoc(s, :procedures))
    |> preload([_s, c, t], conditions: c, procedures: t)
    |> Repo.fetch_all()
  end

  @spec fetch_latest_for_specialist(pos_integer, pos_integer) :: %__MODULE__{} | nil
  def fetch_latest_for_specialist(specialist_id, record_id) do
    __MODULE__
    |> where(specialist_id: ^specialist_id, timeline_id: ^record_id)
    |> join(:left, [s], c in assoc(s, :conditions))
    |> join(:left, [s, _], t in assoc(s, :procedures))
    |> preload([_s, c, t], conditions: c, procedures: t)
    |> order_by(desc: :inserted_at)
    |> Repo.all()
    |> Enum.at(0)
  end

  @spec fetch_draft(pos_integer, pos_integer) :: %__MODULE__{} | nil
  def fetch_draft(specialist_id, record_id) do
    __MODULE__
    |> where(specialist_id: ^specialist_id, timeline_id: ^record_id, is_draft: true)
    |> join(:left, [s], c in assoc(s, :conditions))
    |> join(:left, [s, _], t in assoc(s, :procedures))
    |> preload([_s, c, t], conditions: c, procedures: t)
    |> Repo.one()
  end

  @spec remove_draft(pos_integer, pos_integer) :: :ok
  def remove_draft(specialist_id, record_id) do
    _ =
      __MODULE__
      |> where(specialist_id: ^specialist_id, timeline_id: ^record_id, is_draft: true)
      |> Repo.delete_all()

    :ok
  end

  defp load_conditions(ids) do
    Condition
    |> where([c], c.id in ^ids)
    |> Repo.all()
  end

  defp load_procedures(ids) do
    Procedure
    |> where([t], t.id in ^ids)
    |> Repo.all()
  end

  defp set_previous_summary_edited_at(summary_id, timeline_id) do
    now = NaiveDateTime.utc_now()

    __MODULE__
    |> where(
      [s],
      s.id != ^summary_id and s.timeline_id == ^timeline_id and is_nil(s.edited_at)
    )
    |> update([s],
      set: [
        edited_at: ^now
      ]
    )
    |> Repo.update_all([])
  end

  # defp parse(medical_summary) do
  #   specialist = medical_summary.specialist
  #
  #   %{
  #     inserted_at: medical_summary.inserted_at |> Timex.to_unix(),
  #     medical_summary_data: medical_summary.data |> Proto.EMR.MedicalSummaryData.decode(),
  #     specialist: %{
  #       type: specialist.type |> String.to_existing_atom(),
  #       first_name: specialist.basic_info.first_name,
  #       last_name: specialist.basic_info.last_name,
  #       avatar_url: specialist.basic_info.image_url,
  #       medical_categories: parse_medical_categories(specialist.medical_categories),
  #       package_type: specialist.package_type |> String.to_existing_atom()
  #     }
  #   }
  # end
  #
  # defp parse_medical_categories(medical_categories) do
  #   Enum.map(medical_categories, &Map.get(&1, :name))
  # end
end
