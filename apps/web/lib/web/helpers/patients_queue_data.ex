defmodule Web.PatientsQueueData do
  defstruct [:patient, :record_id, :inserted_at]

  @spec get_by_gp_id(pos_integer) :: [%__MODULE__{}]
  def get_by_gp_id(gp_id) do
    with {:ok, patients_queue} <- UrgentCare.fetch_patients_queue(gp_id),
         patient_ids <- Enum.map(patients_queue, & &1.patient_id),
         {:ok, accounts} <- fetch_accounts(patient_ids),
         patients_generic_data <- Web.PatientGenericData.get_by_ids(patient_ids) do
      accounts_map = Map.new(accounts, &{&1.main_patient_id, &1})

      patients_data_map =
        patients_generic_data
        |> Enum.map(&Map.put(&1, :account, Map.get(accounts_map, &1.patient_id)))
        |> Map.new(fn data -> {data.patient_id, data} end)

      Enum.map(patients_queue, fn %{
                                    patient_id: patient_id,
                                    record_id: record_id,
                                    inserted_at: inserted_at
                                  } ->
        %__MODULE__{
          patient: patients_data_map[patient_id],
          record_id: record_id,
          inserted_at: inserted_at
        }
      end)
    end
  end

  defp fetch_accounts(patient_ids) do
    accounts = Authentication.fetch_patient_account_by_patient_ids(patient_ids)

    if Enum.count(accounts) == patient_ids |> Enum.uniq() |> Enum.count() do
      {:ok, accounts}
    else
      account_patient_ids = Enum.map(accounts, & &1.main_patient_id)

      {:error,
       "No account for patients with ids #{Kernel.inspect(patient_ids -- account_patient_ids)}"}
    end
  end
end
