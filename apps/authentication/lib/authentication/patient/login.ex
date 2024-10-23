defmodule Authentication.Patient.Login do
  @spec call(String.t()) ::
          {:ok, %Authentication.Patient.AuthTokenEntry{}}
          | {:error, :unauthorized}
  def call(firebase_token) do
    firebase_token
    |> Firebase.validate_authentication_token()
    |> case do
      {:ok, %{"sub" => firebase_id, "phone_number" => phone_number}} ->
        account = get_or_create_account(firebase_id, phone_number)

        {:ok, _auth_token_entry} =
          Authentication.Patient.AuthTokenEntry.fetch_by_patient_id(account.main_patient_id)

      {:error, _reason} ->
        {:error, :unauthorized}
    end
  end

  defp get_or_create_account(firebase_id, phone_number) do
    case Authentication.Patient.Account.get_by_firebase_id(firebase_id) do
      %{} = account ->
        account

      nil ->
        {:ok, {:ok, account}} =
          Postgres.Repo.transaction(fn ->
            {:ok, patient} = PatientProfile.create_new_patient_profile(phone_number)
            {:ok, _auth_token} = Authentication.Patient.AuthTokenEntry.create(patient.id)

            {:ok, _account} =
              Authentication.Patient.Account.create(%{
                firebase_id: firebase_id,
                main_patient_id: patient.id,
                phone_number: phone_number
              })
          end)

        account
    end
  end
end
