defmodule SpecialistProfile.BasicInfo do
  use Postgres.Schema
  use Postgres.Service

  alias __MODULE__
  alias Ecto.Multi
  alias SpecialistProfile.Status

  schema "specialist_basic_infos" do
    field :title, :string
    field :first_name, :string
    field :last_name, :string
    field :birth_date, :date
    field :image_url, :string
    field :phone_number, :string
    field :gender, :string
    field :medical_title, :string, default: "UNKNOWN_MEDICAL_TITLE"

    field :specialist_id, :integer

    timestamps()
  end

  @fields [
    :birth_date,
    :first_name,
    :gender,
    :image_url,
    :last_name,
    :medical_title,
    :phone_number,
    :title
  ]
  def changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@fields)
    |> validate_inclusion(:title, ["MR", "MRS", "MS"])
    |> validate_inclusion(:gender, ["MALE", "FEMALE", "OTHER"])
    |> validate_inclusion(:medical_title, [
      "UNKNOWN_MEDICAL_TITLE",
      "M_D",
      "D_O",
      "PH_D",
      "D_D_S",
      "N_P",
      "P_A",
      "R_N",
      "R_D",
      "R_D_N",
      "D_P_M",
      "M_B_B_S"
    ])
  end

  @doc """
  Fetches basic info of specialist for given specialist id
  """
  @spec fetch_by_specialist_id(pos_integer, keyword | nil) :: {:ok, %BasicInfo{}}
  def fetch_by_specialist_id(specialist_id, opts \\ nil) do
    BasicInfo
    |> where(specialist_id: ^specialist_id)
    |> Repo.fetch_one()
    |> case do
      {:ok, basic_info} ->
        {:ok, basic_info}

      {:error, :not_found} ->
        if opts[:error] do
          {:error, :not_found}
        else
          {:ok, %BasicInfo{specialist_id: specialist_id}}
        end
    end
  end

  @doc """
  Update basic info of specialist identified by specialist id with passed params
  """
  @spec update(map, pos_integer) :: {:ok, map} | {:error, Ecto.Changeset.t()}
  def update(params, specialist_id) do
    Multi.new()
    |> Multi.run(:update_basic_info, &update_basic_info(&1, &2, specialist_id, params))
    |> Multi.run(:handle_onboarding_status, &handle_onboarding_status(&1, &2, specialist_id))
    |> Repo.transaction()
    |> case do
      {:ok, %{update_basic_info: basic_info}} ->
        {:ok, basic_info}

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  defp update_basic_info(_repo, _multi, specialist_id, params) do
    {:ok, basic_info} = fetch_by_specialist_id(specialist_id)

    basic_info
    |> BasicInfo.changeset(params)
    |> Repo.insert_or_update()
  end

  defp handle_onboarding_status(_repo, _multi, specialist_id) do
    Status.handle_onboarding_status(specialist_id)

    {:ok, :handled}
  end

  @spec fetch_by_specialist_ids([pos_integer]) :: {:ok, [%__MODULE__{}]}
  def fetch_by_specialist_ids(specialist_ids) do
    __MODULE__
    |> where([bi], bi.specialist_id in ^specialist_ids)
    |> Repo.fetch_all()
  end
end
