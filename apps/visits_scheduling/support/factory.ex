defmodule VisitsScheduling.Factory do
  defp random_string, do: System.unique_integer() |> to_string()

  defp medical_category_default_params do
    %{
      name: random_string(),
      image_url: random_string(),
      what_we_treat_url: random_string()
    }
  end

  def insert(type, params \\ %{})

  def insert(:medical_category, params) do
    params = Map.merge(medical_category_default_params(), Enum.into(params, %{}))

    {:ok, category} =
      Postgres.Repo.insert(
        Map.merge(%VisitsScheduling.MedicalCategories.MedicalCategory{}, params)
      )

    category
  end
end
