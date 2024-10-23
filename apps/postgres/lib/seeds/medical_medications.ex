defmodule Postgres.Seeds.MedicalMedications do
  def seed do
    src = Application.app_dir(:postgres, "priv/repo/seeds/medical_medications.csv")

    list =
      src
      |> File.stream!()
      |> CSV.decode!(headers: true)
      |> Enum.to_list()

    "medical_medications"
    |> Postgres.Repo.insert_all(
      list,
      log: false,
      on_conflict: :nothing,
      conflict_target: :name
    )
  end
end
