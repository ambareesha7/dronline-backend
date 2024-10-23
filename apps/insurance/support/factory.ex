defmodule Insurance.Factory do
  alias Postgres.Repo

  defp provider_default_params do
    %{
      name: "provider_name",
      logo_url: "provider_logo_url"
    }
  end

  defp patient_default_params do
    %{
      phone_number: random_string()
    }
  end

  defp account_default_params do
    %{
      member_id: random_string()
    }
  end

  def insert(:provider, params) do
    params =
      provider_default_params()
      |> Map.merge(Enum.into(params, %{}))

    %Insurance.Providers.Provider{}
    |> Ecto.Changeset.cast(params, [:name, :logo_url, :country_id])
    |> Repo.insert!()
  end

  def insert(:account, params) do
    params =
      account_default_params()
      |> Map.merge(Enum.into(params, %{}))

    %Insurance.Accounts.Account{}
    |> Ecto.Changeset.cast(params, [:patient_id, :member_id, :provider_id])
    |> Repo.insert!()
  end

  def insert(:patient, params) do
    params =
      patient_default_params()
      |> Map.merge(Enum.into(params, %{}))

    %Insurance.Accounts.Patient{}
    |> Ecto.Changeset.cast(params, [:phone_number, :insurance_account_id])
    |> Repo.insert!()
  end

  def insert(:patient_basic_info, params) do
    default = %{
      first_name: random_string()
    }

    params = Map.merge(default, Enum.into(params, %{}))

    basic_info =
      %Insurance.Accounts.PatientBasicInfo{}
      |> Ecto.Changeset.cast(params, [:patient_id])
      |> Repo.insert!()

    basic_info
  end

  defp random_string, do: System.unique_integer() |> to_string
end
