defmodule Web.AdminApi.AccountDeletionsController do
  use Web, :controller

  alias Authentication.Patient.AccountDeletion, as: PatientAccountDeletion
  alias Authentication.Specialist.AccountDeletion, as: SpecialistAccountDeletion
  alias PatientProfile.BasicInfo, as: PatientBasicInfo
  alias SpecialistProfile.BasicInfo, as: SpecialistBasicInfo

  action_fallback Web.FallbackController

  def index(conn, _params) do
    patient_account_deletions_with_info =
      fetch_patient_account_deletions_with_info()

    specialist_account_deletions_with_info =
      fetch_specialist_account_deletions_with_info()

    render(conn, "index.proto", %{
      patient_account_deletions_with_info: patient_account_deletions_with_info,
      specialist_account_deletions_with_info: specialist_account_deletions_with_info
    })
  end

  defp fetch_patient_account_deletions_with_info do
    {:ok, patient_account_deletions} = PatientAccountDeletion.fetch_all()

    patient_ids = Enum.map(patient_account_deletions, & &1.patient_id)

    {:ok, patient_basic_infos} = PatientBasicInfo.fetch_by_patient_ids(patient_ids)

    map_account_deletions_with_basic_info(
      patient_account_deletions,
      patient_basic_infos,
      :patient_id
    )
  end

  defp fetch_specialist_account_deletions_with_info do
    {:ok, specialist_account_deletions} =
      SpecialistAccountDeletion.fetch_all()

    specialist_ids = Enum.map(specialist_account_deletions, & &1.specialist_id)

    {:ok, specialist_basic_infos} =
      SpecialistBasicInfo.fetch_by_specialist_ids(specialist_ids)

    map_account_deletions_with_basic_info(
      specialist_account_deletions,
      specialist_basic_infos,
      :specialist_id
    )
  end

  defp map_account_deletions_with_basic_info(account_deletions, basic_infos, key) do
    Enum.map(account_deletions, fn account_deletion ->
      %{
        account_deletion: account_deletion,
        basic_info:
          Enum.find(basic_infos, fn basic_info ->
            get_by_key(account_deletion, key) == get_by_key(basic_info, key)
          end)
      }
    end)
  end

  defp get_by_key(struct, key), do: get_in(struct, [Access.key!(key)])
end
