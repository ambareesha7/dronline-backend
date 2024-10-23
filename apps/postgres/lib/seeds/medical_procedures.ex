defmodule Postgres.Seeds.MedicalProcedures do
  def seed do
    src = Application.app_dir(:postgres, "priv/repo/seeds/medical_procedures.csv")

    list =
      src
      |> File.stream!()
      |> CSV.decode!(headers: true)
      |> Enum.to_list()

    "medical_procedures"
    |> Postgres.Repo.insert_all(
      list,
      log: false,
      on_conflict: :nothing,
      conflict_target: :id
    )
  end
end
