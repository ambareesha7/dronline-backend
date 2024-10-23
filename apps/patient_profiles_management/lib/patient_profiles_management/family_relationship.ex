defmodule PatientProfilesManagement.FamilyRelationship do
  @moduledoc """
  Stores relationship between child profile and profile of its parent/guardian
  """

  use Postgres.Schema
  use Postgres.Service

  alias PatientProfilesManagement.Commands.RegisterFamilyRelationship

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "patients_family_relationship" do
    field :adult_patient_id, :integer
    field :child_patient_id, :integer

    timestamps()
  end

  @doc """
  Adds child patient profile for given adult patient

  1. Create new patient profile with phone number of adult (for search purposes)
  2. Add basic_info for child to avoid "nameless children" in children list
  3. Register relationship between adult and child

  We don't need transaction here because even if register_family_relationship fails
  a new profile from previous steps should not be visible due to not completed onboarding
  """
  @spec add_related_child_profile(map, pos_integer) ::
          {:ok, {%PatientProfile.Schema{}, %PatientProfile.BasicInfo{}}}
          | {:error, Ecto.Changeset.t()}
  def add_related_child_profile(child_basic_info_params, adult_patient_id) do
    with {:ok, adult_profile} <- PatientProfile.fetch_by_id(adult_patient_id),
         {:ok, child_profile} <-
           PatientProfile.create_new_patient_profile(adult_profile.phone_number),
         {:ok, basic_info} <-
           PatientProfile.update_basic_info(child_basic_info_params, child_profile.id),
         cmd = %RegisterFamilyRelationship{
           adult_patient_id: adult_profile.id,
           child_patient_id: child_profile.id
         },
         {:ok, _relationship} <- register_family_relationship(cmd) do
      {:ok, {child_profile, basic_info}}
    end
  end

  @doc false
  @spec register_family_relationship(%RegisterFamilyRelationship{}) :: {:ok, %__MODULE__{}}
  def register_family_relationship(cmd) do
    %__MODULE__{
      adult_patient_id: cmd.adult_patient_id,
      child_patient_id: cmd.child_patient_id
    }
    |> Repo.insert()
  end

  @doc """
  Returns list of child patient ids related to provided patient
  """
  @spec get_related_child_patient_ids(pos_integer) :: [pos_integer]
  def get_related_child_patient_ids(patient_id) do
    __MODULE__
    |> where(adult_patient_id: ^patient_id)
    |> order_by(asc: :child_patient_id)
    |> select([fr], fr.child_patient_id)
    |> Repo.all()
  end

  @doc """
  Determines to which patient a notification should be sent

  For adult patient it returns its own id
  For child patient it returns its related adult patient id
  """
  @spec who_should_be_notified(pos_integer) :: pos_integer
  def who_should_be_notified(patient_id) do
    get_related_adult_patient_id(patient_id) || patient_id
  end

  @doc """
  Returns id of adult patient related to provided patient or nil
  when provided patient is an adult himself
  """
  @spec get_related_adult_patient_id(pos_integer) :: pos_integer | nil
  def get_related_adult_patient_id(patient_id) do
    case Repo.get_by(__MODULE__, child_patient_id: patient_id) do
      nil ->
        nil

      relationship ->
        relationship.adult_patient_id
    end
  end

  @doc """
  Returns child_patient_id => adult_patient_id mapping for provided list of patient ids
  """
  @spec get_related_adult_patients_map([pos_integer]) :: %{optional(pos_integer) => pos_integer}
  def get_related_adult_patients_map(patients_ids) do
    __MODULE__
    |> where([fr], fr.child_patient_id in ^patients_ids)
    |> order_by(asc: :child_patient_id)
    |> Repo.all()
    |> Map.new(&{&1.child_patient_id, &1.adult_patient_id})
  end
end
