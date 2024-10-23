defmodule Postgres.Repo.Migrations.MedicalConditionsSearch do
  use Ecto.Migration

  def up do
    execute("CREATE EXTENSION pg_trgm")

    execute("""
      CREATE INDEX medical_conditions_trgm_idx ON medical_conditions 
        USING GIN (
          id gin_trgm_ops,
          name gin_trgm_ops
        )
    """)
  end

  def down do
    execute("DROP INDEX medical_conditions_trgm_idx")
    execute("DROP EXTENSION pg_trgm")
  end
end
