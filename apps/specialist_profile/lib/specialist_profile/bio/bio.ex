defmodule SpecialistProfile.Bio do
  use Postgres.Schema
  use Postgres.Service

  @primary_key {:specialist_id, :integer, autogenerate: false}
  schema "specialist_bios" do
    field :description, :string

    embeds_many :education, __MODULE__.EducationEntry, on_replace: :delete
    embeds_many :work_experience, __MODULE__.WorkExperienceEntry, on_replace: :delete

    timestamps()
  end

  @spec update(pos_integer, map) :: {:ok, %__MODULE__{}} | {:error, Ecto.Changeset.t()}
  def update(specialist_id, params) when is_integer(specialist_id) do
    bio = Repo.get(__MODULE__, specialist_id) || %__MODULE__{specialist_id: specialist_id}

    bio
    |> cast(params, [:description])
    |> cast_embed(:education)
    |> cast_embed(:work_experience)
    |> validate_required([:description])
    |> Repo.insert_or_update()
  end

  @spec get_by_specialist_id(pos_integer) :: %__MODULE__{} | nil
  def get_by_specialist_id(specialist_id) when is_integer(specialist_id) do
    Repo.get(__MODULE__, specialist_id)
  end

  @spec get_by_specialist_ids([pos_integer]) :: [%__MODULE__{}]
  def get_by_specialist_ids(specialist_ids) when is_list(specialist_ids) do
    __MODULE__
    |> where([b], b.specialist_id in ^specialist_ids)
    |> Repo.all()
  end
end
