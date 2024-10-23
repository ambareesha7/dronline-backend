defmodule SpecialistProfile.MedicalCredentials.Fetch do
  alias SpecialistProfile.Helper
  alias SpecialistProfile.MedicalCredentials

  def call(specialist_ids) when is_list(specialist_ids) do
    {:ok, medical_credentials} = MedicalCredentials.fetch_by_specialist_ids(specialist_ids)

    medical_credentials_by_specialist_id =
      Map.new(medical_credentials, &{&1.specialist_id, parse_medical_credentials(&1)})

    {:ok, medical_credentials_by_specialist_id}
  end

  def call(specialist_id) do
    {:ok, medical_credentials} = MedicalCredentials.fetch_by_specialist_id(specialist_id)

    {:ok, parse_medical_credentials(medical_credentials)}
  end

  defp parse_medical_credentials(medical_credentials) do
    %{
      dea_number_url: medical_credentials.dea_number_url,
      dea_number_expiry_date: medical_credentials.dea_number_expiry_date |> Helper.parse_date(),
      board_certification_url: medical_credentials.board_certification_url,
      board_certification_expiry_date:
        medical_credentials.board_certification_expiry_date |> Helper.parse_date(),
      current_state_license_number_url: medical_credentials.current_state_license_number_url,
      current_state_license_number_expiry_date:
        medical_credentials.current_state_license_number_expiry_date |> Helper.parse_date()
    }
  end
end
