defmodule Postgres.Seeds.MedicalConditions do
  def seed do
    src = Application.app_dir(:postgres, "priv/repo/seeds/medical_conditions.csv")

    src
    |> File.stream!()
    |> CSV.decode!(headers: true)
    |> Stream.chunk_every(10_000)
    |> Enum.each(fn list_chunk ->
      "medical_conditions"
      |> Postgres.Repo.insert_all(
        list_chunk,
        log: false,
        on_conflict: :nothing,
        conflict_target: :id
      )
    end)
  end
end
