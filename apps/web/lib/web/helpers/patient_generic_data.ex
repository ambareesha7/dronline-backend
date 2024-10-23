defmodule Web.PatientGenericData do
  defstruct [:basic_info, :patient_id, :related_adult_patient_id]

  @spec get_by_ids([pos_integer]) :: [%__MODULE__{}]
  def get_by_ids(patient_ids) when is_list(patient_ids) do
    {:ok, basic_infos} = PatientProfile.fetch_basic_infos(patient_ids)
    basic_infos_map = Map.new(basic_infos, &{&1.patient_id, &1})

    relationship_map = PatientProfilesManagement.get_related_adult_patients_map(patient_ids)

    for patient_id <- patient_ids,
        not is_nil(patient_id),
        Map.has_key?(basic_infos_map, patient_id) do
      %__MODULE__{
        basic_info: Map.get(basic_infos_map, patient_id),
        patient_id: patient_id,
        related_adult_patient_id: Map.get(relationship_map, patient_id)
      }
    end
  end

  @spec get_by_id(pos_integer) :: %__MODULE__{}
  def get_by_id(patient_id) when is_integer(patient_id) do
    patient_id
    |> List.wrap()
    |> get_by_ids()
    |> List.first()
  end
end
