defmodule Postgres.Repo.Migrations.DisableUsBoardMedicalCategory do
  use Ecto.Migration

  import Ecto.Query

  alias Postgres.Repo

  def up do
    Repo.update_all(query(), set: [disabled: true, updated_at: DateTime.utc_now()])
  end

  def down do
    Repo.update_all(query(), set: [disabled: false, updated_at: DateTime.utc_now()])
  end

  defp query do
    from mc in "medical_categories", where: mc.name == "U.S Board Second Opinion"
  end
end
