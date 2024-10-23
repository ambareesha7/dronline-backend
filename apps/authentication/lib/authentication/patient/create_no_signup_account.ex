defmodule Authentication.Patient.CreateNoSignUpAccount do
  @moduledoc """
  Create account automatically by the system, without patient signing up.
  Only phone number, email, first name and last name is required.
  No password needed. No more user's basic data (birthday, gender etc) needed.
  """
  alias Ecto.Multi

  use Postgres.Schema
  use Postgres.Service

  defmodule Params do
    @type t :: %__MODULE__{
            phone_number: String.t(),
            email: String.t(),
            first_name: String.t(),
            last_name: String.t()
          }
    defstruct [
      :phone_number,
      :email,
      :first_name,
      :last_name
    ]
  end

  def call(%{phone_number: phone_number} = params) do
    case Authentication.Patient.Account.get_by_phone_number(phone_number) do
      %{} = account ->
        {:ok,
         %{
           patient_account: account,
           auth_token: fetch_auth_token(account.main_patient_id)
         }}

      nil ->
        create_new_account(params)
    end
  end

  defp fetch_auth_token(patient_id) do
    {:ok, %Authentication.Patient.AuthTokenEntry{} = entry} =
      Authentication.Patient.AuthTokenEntry.fetch_by_patient_id(patient_id)

    entry.auth_token
  end

  defp create_new_account(params) do
    params =
      %__MODULE__.Params{
        phone_number: params.phone_number,
        email: params.email,
        first_name: params.first_name,
        last_name: params.last_name
      }

    Multi.new()
    |> Multi.run(:params, fn _, _ -> {:ok, params} end)
    |> Multi.run(:create_patient_profile, &create_patient_profile/2)
    |> Multi.run(:create_auth_token, &create_auth_token/2)
    |> Multi.run(:create_patient_account, &create_patient_account/2)
    |> Multi.run(:create_patient_basic_info, &create_patient_basic_info/2)
    |> Postgres.Repo.transaction()
    |> case do
      {:ok, changes} ->
        {:ok,
         %{
           patient_account: changes.create_patient_account,
           auth_token: changes.create_auth_token
         }}

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  defp create_patient_profile(_repo, %{params: params}) do
    PatientProfile.create_new_patient_profile(params.phone_number)
  end

  defp create_auth_token(_repo, %{create_patient_profile: patient}) do
    {:ok, %Authentication.Patient.AuthTokenEntry{} = entry} =
      Authentication.Patient.AuthTokenEntry.create(patient.id)

    {:ok, entry.auth_token}
  end

  defp create_patient_account(_repo, %{params: params, create_patient_profile: patient}) do
    Authentication.Patient.Account.create(%{
      firebase_id: nil,
      main_patient_id: patient.id,
      phone_number: params.phone_number,
      is_signed_up: false
    })
  end

  defp create_patient_basic_info(_repo, %{params: params, create_patient_profile: patient}) do
    PatientProfile.update_basic_info(
      %{first_name: params.first_name, last_name: params.last_name, email: params.email},
      patient.id
    )
  end
end
