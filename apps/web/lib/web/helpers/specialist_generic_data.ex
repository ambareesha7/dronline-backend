defmodule Web.SpecialistGenericData do
  defstruct [:specialist, :basic_info, :deprecated, :medical_categories, :medical_credential]

  @spec get_by_ids([pos_integer]) :: [%__MODULE__{}]
  def get_by_ids(specialist_ids) when is_list(specialist_ids) do
    {:ok, specialists} = Authentication.fetch_specialists(specialist_ids)
    {:ok, basic_infos} = SpecialistProfile.fetch_basic_infos(specialist_ids)

    {:ok, medical_credential_by_specialist_id} =
      SpecialistProfile.fetch_medical_credentials(specialist_ids)

    specialists_map = Map.new(specialists, &{&1.id, &1})
    basic_infos_map = Map.new(basic_infos, &{&1.specialist_id, &1})

    medical_categories_map =
      SpecialistProfile.get_medical_categories_for_specialists(specialist_ids)

    for specialist_id <- specialist_ids, not is_nil(specialist_id) do
      %__MODULE__{
        specialist: Map.get(specialists_map, specialist_id),
        basic_info: Map.get(basic_infos_map, specialist_id),
        deprecated:
          medical_categories_map
          |> Map.get(specialist_id, [])
          |> Enum.map(& &1.name)
          |> Enum.reject(&is_nil/1),
        medical_categories: medical_categories_map |> Map.get(specialist_id, []),
        medical_credential:
          Map.get(
            medical_credential_by_specialist_id,
            specialist_id,
            %SpecialistProfile.MedicalCredentials{specialist_id: specialist_id}
          )
      }
    end
  end

  @spec get_by_id(pos_integer) :: %__MODULE__{}
  def get_by_id(specialist_id) when is_integer(specialist_id) do
    specialist_id
    |> List.wrap()
    |> get_by_ids()
    |> List.first()
  end
end
