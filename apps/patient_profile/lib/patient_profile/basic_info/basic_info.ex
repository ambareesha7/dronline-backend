defmodule PatientProfile.BasicInfo do
  use Postgres.Schema
  use Postgres.Service

  alias PatientProfile.BasicInfo

  schema "patient_basic_infos" do
    field :birth_date, :date
    field :email, :string
    field :first_name, :string
    field :last_name, :string
    field :title, :string
    field :gender, :string

    field :is_insured, :boolean
    field :insurance_provider_name, :string
    field :insurance_member_id, :string

    field :avatar_resource_path, :string

    field :patient_id, :integer

    timestamps()
  end

  @required_fields [:email, :first_name, :last_name]
  @fields [:birth_date, :avatar_resource_path, :title, :gender] ++ @required_fields
  defp changeset(struct, params) do
    struct
    |> cast(params, @fields)
    |> validate_required(@required_fields)
    |> validate_inclusion(:title, ["MR", "MRS", "MS"])
    |> validate_inclusion(:gender, ["MALE", "FEMALE", "OTHER"])
  end

  @doc """
  Fetches basic info based on patient_id.
  If patient doesn't have one yet then returns empty one.
  """
  @spec fetch_by_patient_id(pos_integer) :: {:ok, %BasicInfo{}}
  def fetch_by_patient_id(patient_id) do
    BasicInfo
    |> where(patient_id: ^patient_id)
    |> Repo.fetch_one()
    |> case do
      {:ok, basic_info} ->
        {:ok, maybe_put_default_avatar(basic_info)}

      {:error, :not_found} ->
        {:ok,
         %BasicInfo{
           patient_id: patient_id,
           avatar_resource_path: default_avatar_resource_path("MALE", "ADULT")
         }}
    end
  end

  @spec fetch_by_patient_ids([pos_integer]) :: {:ok, [%__MODULE__{}]}
  def fetch_by_patient_ids(patient_ids) do
    {:ok, patients} =
      __MODULE__
      |> where([bi], bi.patient_id in ^patient_ids)
      |> Repo.fetch_all()

    {:ok, Enum.map(patients, &maybe_put_default_avatar/1)}
  end

  def fetch_by_email(email) do
    __MODULE__
    |> where(email: ^email)
    |> Repo.fetch_one()
    |> case do
      {:ok, basic_info} ->
        {:ok, maybe_put_default_avatar(basic_info)}
    end
  end

  @doc """
  Creates new basic info or updates existing one for given patient_id

  Doesn't override avatar_resource_path if avatar_resource_path provided in params is empty value
  """
  @spec update(map, pos_integer) :: {:ok, %BasicInfo{}} | {:error, Ecto.Changeset.t()}
  def update(params, patient_id) do
    basic_info =
      Repo.get_by(__MODULE__, patient_id: patient_id) || %__MODULE__{patient_id: patient_id}

    basic_info
    |> changeset(params)
    |> Repo.insert_or_update()
    |> case do
      {:ok, basic_info} ->
        {:ok, maybe_put_default_avatar(basic_info)}

      {:error, changeset} ->
        {:error, changeset}
    end
  end

  defp maybe_put_default_avatar(%BasicInfo{avatar_resource_path: nil} = basic_info) do
    %BasicInfo{basic_info | avatar_resource_path: default_avatar_resource_path(basic_info)}
  end

  defp maybe_put_default_avatar(%BasicInfo{} = basic_info) do
    basic_info
  end

  defp default_avatar_resource_path(basic_info) do
    age =
      cond do
        is_nil(basic_info.birth_date) -> "ADULT"
        is_adult?(basic_info.birth_date) -> "ADULT"
        true -> "CHILD"
      end

    gender =
      case basic_info.gender do
        nil -> "OTHER"
        gender -> gender
      end

    default_avatar_resource_path(gender, age)
  end

  def default_avatar_resource_path("MALE", "ADULT") do
    Application.get_env(:patient_profile, :default_man_avatar_path)
  end

  def default_avatar_resource_path("MALE", "CHILD") do
    Application.get_env(:patient_profile, :default_boy_avatar_path)
  end

  def default_avatar_resource_path("FEMALE", "ADULT") do
    Application.get_env(:patient_profile, :default_woman_avatar_path)
  end

  def default_avatar_resource_path("FEMALE", "CHILD") do
    Application.get_env(:patient_profile, :default_girl_avatar_path)
  end

  def default_avatar_resource_path("OTHER", _) do
    Application.get_env(:patient_profile, :default_other_avatar_path)
  end

  defp is_adult?(birth_date) do
    Date.compare(Timex.shift(birth_date, years: 18), Date.utc_today()) != :gt
  end
end
