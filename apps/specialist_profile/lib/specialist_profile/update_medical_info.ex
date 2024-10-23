defmodule SpecialistProfile.UpdateMedicalInfo do
  def call(specialist_id, medical_categories, medical_credentials) do
    Ecto.Multi.new()
    |> Ecto.Multi.run(
      :update_medical_categories,
      &update_medical_categories(&1, &2, specialist_id, medical_categories)
    )
    |> Ecto.Multi.run(
      :update_medical_credentials,
      &update_medical_credentials(&1, &2, specialist_id, medical_credentials)
    )
    |> Postgres.Repo.transaction()
    |> case do
      {:ok,
       %{
         update_medical_categories: medical_categories,
         update_medical_credentials: medical_credentials
       }} ->
        {:ok, %{medical_categories: medical_categories, medical_credentials: medical_credentials}}

      {:error, _failed_operation, changeset, _changes_so_far} ->
        {:error, changeset}
    end
  end

  def update_medical_categories(_repo, _multi, specialist_id, medical_categories) do
    categories_ids = medical_categories |> Enum.map(& &1.id)

    {:ok, _categories} =
      SpecialistProfile.update_medical_categories(categories_ids, specialist_id)
  end

  def update_medical_credentials(_repo, _multi, specialist_id, medical_credentials) do
    {:ok, _medical_credentials} =
      SpecialistProfile.update_medical_credentials(medical_credentials, specialist_id)

    {:ok, _fetched_medical_credentials} =
      SpecialistProfile.MedicalCredentials.Fetch.call(specialist_id)
  end
end
