defmodule Postgres.Seeds.MedicalTests do
  def seed do
    src = Application.app_dir(:postgres, "priv/repo/seeds/medical_tests.csv")

    list =
      src
      |> File.stream!()
      |> CSV.decode!(headers: true)
      |> Enum.map(fn %{
                       "id" => id,
                       "category_id" => category_id,
                       "name" => name,
                       "disabled" => disabled
                     } ->
        %{
          id: String.to_integer(id),
          category_id: String.to_integer(category_id),
          name: name,
          disabled: disabled == "yes"
        }
      end)

    "medical_tests"
    |> Postgres.Repo.insert_all(
      list,
      log: false,
      on_conflict: {:replace, [:name, :disabled]},
      conflict_target: :id
    )
  end
end
