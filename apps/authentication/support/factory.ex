defmodule Authentication.Factory do
  defp random_string, do: System.unique_integer() |> to_string()

  defp admin_default_params do
    %{
      email: random_string() <> "@example.com",
      password: "Password1!"
    }
  end

  defp specialist_default_params do
    %{
      type: "EXTERNAL",
      email: random_string() <> "@example.com",
      password: "Password1!"
    }
  end

  defp password_change_default_params do
    %{
      password: "NewPassword1!"
    }
  end

  def insert(kind, params \\ %{})

  def insert(:admin, params) do
    params = Map.merge(admin_default_params(), Enum.into(params, %{}))

    {:ok, admin} = Authentication.Admin.create(params)

    admin
  end

  def insert(:password_change, params) do
    params = Map.merge(password_change_default_params(), Enum.into(params, %{}))

    {:ok, password_change} =
      Authentication.Specialist.PasswordChange.create(params[:specialist_id], params[:password])

    password_change
  end

  def insert(:specialist, params) do
    params = Map.merge(specialist_default_params(), Enum.into(params, %{}))

    {:ok, specialist} = Authentication.Specialist.register(params)

    specialist
    |> Ecto.Changeset.change(%{onboarding_completed_at: NaiveDateTime.utc_now()})
    |> Postgres.Repo.update()

    :ok = SpecialistProfile.Status.handle_onboarding_status(specialist.id)

    {:ok, specialist} = Authentication.Specialist.fetch_by_id(specialist.id)
    set_package_type(specialist, params[:package_type])
  end

  def insert(:not_onboarded_specialist, params) do
    params = Map.merge(specialist_default_params(), Enum.into(params, %{}))

    {:ok, specialist} = Authentication.Specialist.register(params)

    set_package_type(specialist, params[:package_type])
  end

  def insert(:specialist_during_password_recovery, params) do
    verified_specialist = Authentication.Factory.insert(:verified_specialist, params)

    {:ok, specialist} =
      Authentication.Specialist.create_password_recovery_token(verified_specialist)

    specialist
  end

  def insert(:verified_specialist, params) do
    unverified_specialist = insert(:specialist, params)

    {:ok, specialist} = Authentication.Specialist.verify(unverified_specialist)

    specialist
  end

  def insert(:not_onboarded_verified_specialist, params) do
    unverified_specialist = insert(:not_onboarded_specialist, params)

    {:ok, specialist} = Authentication.Specialist.verify(unverified_specialist)

    specialist
  end

  def insert(:verified_and_rejected_external, params) do
    unverified_specialist = insert(:specialist, params)

    {:ok, auth_specialist} = Authentication.Specialist.verify(unverified_specialist)
    _ = SpecialistProfile.Factory.insert(:basic_info, specialist_id: auth_specialist.id)
    _ = SpecialistProfile.Factory.insert(:location, specialist_id: auth_specialist.id)
    medical_category = SpecialistProfile.Factory.insert(:medical_category)

    {:ok, [specialist_medical_category]} =
      SpecialistProfile.update_medical_categories([medical_category.id], auth_specialist.id)

    _ = SpecialistProfile.Factory.insert(:medical_credentials, specialist_id: auth_specialist.id)

    _ =
      SpecialistProfile.Factory.insert(:prices,
        specialist_id: auth_specialist.id,
        medical_category_id: specialist_medical_category.id
      )

    insurance_provider =
      Insurance.Providers.Provider |> Postgres.Repo.all() |> List.first() ||
        insert_insurance_provider()

    _ =
      SpecialistProfile.Specialist.update_insurance_providers(
        auth_specialist.id,
        [
          insurance_provider.id
        ]
      )

    {:ok, specialist} = auth_specialist.id |> Admin.verify_external_specialist("REJECTED")

    Map.merge(auth_specialist, specialist)
  end

  def insert(:verified_and_approved_external, params) do
    unverified_specialist = insert(:specialist, params)

    {:ok, auth_specialist} = Authentication.Specialist.verify(unverified_specialist)
    _ = SpecialistProfile.Factory.insert(:basic_info, specialist_id: auth_specialist.id)
    _ = SpecialistProfile.Factory.insert(:location, specialist_id: auth_specialist.id)
    medical_category = SpecialistProfile.Factory.insert(:medical_category)

    {:ok, [specialist_medical_category]} =
      SpecialistProfile.update_medical_categories([medical_category.id], auth_specialist.id)

    _ =
      SpecialistProfile.Factory.insert(:prices,
        specialist_id: auth_specialist.id,
        medical_category_id: specialist_medical_category.id
      )

    _ = SpecialistProfile.Factory.insert(:medical_credentials, specialist_id: auth_specialist.id)

    insurance_provider =
      Insurance.Providers.Provider |> Postgres.Repo.all() |> List.first() ||
        insert_insurance_provider()

    _ =
      SpecialistProfile.Specialist.update_insurance_providers(
        auth_specialist.id,
        [
          insurance_provider.id
        ]
      )

    {:ok, specialist} = auth_specialist.id |> Admin.verify_external_specialist("VERIFIED")

    Map.merge(auth_specialist, specialist)
  end

  def insert(:patient_account_deletion, %{patient_id: _} = params) do
    {:ok, account_deletion} = Authentication.Patient.AccountDeletion.create(params)

    account_deletion
  end

  def insert(:patient_account_deletion, _params) do
    patient = PatientProfile.Factory.insert(:patient)
    _patient_basic_info = PatientProfile.Factory.insert(:basic_info, %{patient_id: patient.id})

    params = %{patient_id: patient.id}

    {:ok, account_deletion} = Authentication.Patient.AccountDeletion.create(params)

    account_deletion
  end

  def insert(:specialist_account_deletion, %{specialist_id: _} = params) do
    {:ok, account_deletion} = Authentication.Specialist.AccountDeletion.create(params)

    account_deletion
  end

  def insert(:specialist_account_deletion, _params) do
    %{id: specialist_id} = insert(:verified_and_approved_external, %{})

    params = %{specialist_id: specialist_id}

    {:ok, account_deletion} = Authentication.Specialist.AccountDeletion.create(params)

    account_deletion
  end

  def set_package_type(specialist, nil),
    do: set_package_type(specialist, "BASIC")

  def set_package_type(specialist, package_type) do
    specialist
    |> Ecto.Changeset.change(package_type: package_type)
    |> Postgres.Repo.update!()
  end

  defp insert_insurance_provider do
    country =
      Postgres.Seeds.Country |> Postgres.Repo.all() |> List.first() ||
        Postgres.Factory.insert(:country, [])

    Insurance.Factory.insert(:provider, %{name: "auth_provider", country_id: country.id})
  end
end
