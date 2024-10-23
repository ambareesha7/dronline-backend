defmodule Insurance.Accounts do
  use Postgres.Schema
  use Postgres.Service

  alias Ecto.Multi
  alias Insurance.Accounts.Account
  alias Insurance.Accounts.Patient
  alias Insurance.Accounts.PatientBasicInfo
  alias Insurance.Providers.Provider

  def set(params, patient_id) do
    insurance_provider = Repo.get_by(Provider, id: params.provider_id)

    Multi.new()
    |> Multi.insert_or_update(:insert_insurance_account, account_changeset(params, patient_id))
    |> Multi.run(:update_patient_insurance, fn _,
                                               %{insert_insurance_account: insurance_account} ->
      patient_id
      |> patient_changeset(insurance_account.id)
      |> Repo.update()
    end)
    |> Multi.run(:update_patient_basic_info, fn _,
                                                %{insert_insurance_account: insurance_account} ->
      patient_id
      |> patient_basic_info_changeset(insurance_account, insurance_provider)
      |> Repo.update()
    end)
    |> Repo.transaction()
    |> case do
      {:ok, %{insert_insurance_account: insurance_account}} ->
        {:ok, Repo.preload(insurance_account, [:insurance_provider])}

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  def get_for_patient(patient_id) do
    account_id =
      Patient
      |> Repo.get_by(id: patient_id)
      |> Map.get(:insurance_account_id)

    case account_id do
      nil ->
        {:ok, nil}

      id ->
        account =
          Account
          |> where(id: ^id)
          |> join(:inner, [a], p in assoc(a, :insurance_provider))
          |> preload([a, p], insurance_provider: p)
          |> Repo.one()

        {:ok, account}
    end
  end

  def remove_for_patient(patient_id) do
    Multi.new()
    |> Multi.update(:patient, patient_remove_changeset(patient_id))
    |> Multi.update(:patient_basic_infos, patient_basic_info_remove_changeset(patient_id))
    |> Repo.transaction()
    |> case do
      {:ok, _} ->
        {:ok, nil}

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  defp account_changeset(params, patient_id) do
    params = Map.merge(params, %{patient_id: patient_id})

    Account
    |> Repo.get_by(
      patient_id: patient_id,
      provider_id: params.provider_id,
      member_id: params.member_id
    )
    |> Kernel.||(%Account{})
    |> cast(params, [
      :patient_id,
      :provider_id,
      :member_id
    ])
    |> validate_required([:provider_id, :member_id])
  end

  defp patient_changeset(patient_id, account_id) do
    Patient
    |> Repo.get_by(id: patient_id)
    |> change(insurance_account_id: account_id)
  end

  defp patient_basic_info_changeset(
         patient_id,
         %Account{member_id: member_id},
         %Provider{name: provider_name}
       ) do
    PatientBasicInfo
    |> Repo.get_by(patient_id: patient_id)
    |> change(%{
      is_insured: true,
      insurance_member_id: member_id,
      insurance_provider_name: provider_name
    })
  end

  defp patient_remove_changeset(patient_id) do
    Patient
    |> Repo.get_by(id: patient_id)
    |> change(insurance_account_id: nil)
  end

  defp patient_basic_info_remove_changeset(patient_id) do
    PatientBasicInfo
    |> Repo.get_by(patient_id: patient_id)
    |> change(%{
      is_insured: false,
      insurance_member_id: nil,
      insurance_provider_name: nil
    })
  end
end
