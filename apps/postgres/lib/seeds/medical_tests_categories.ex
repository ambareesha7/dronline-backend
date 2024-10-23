defmodule Postgres.Seeds.MedicalTestsCategories do
  def seed do
    src = Application.app_dir(:postgres, "priv/repo/seeds/medical_tests_categories.csv")

    list =
      src
      |> File.stream!()
      |> CSV.decode!(headers: true)
      |> Enum.map(fn %{
                       "id" => id,
                       "name" => name,
                       "disabled" => disabled
                     } ->
        %{
          id: String.to_integer(id),
          name: name,
          disabled: disabled == "yes"
        }
      end)

    "medical_tests_categories"
    |> Postgres.Repo.insert_all(
      list,
      log: false,
      on_conflict: {:replace, [:name, :disabled]},
      conflict_target: :id
    )
  end
end
