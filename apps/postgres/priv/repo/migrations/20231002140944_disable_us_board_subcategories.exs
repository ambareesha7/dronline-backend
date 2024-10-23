defmodule Postgres.Repo.Migrations.DisableUsBoardSubcategories do
  use Ecto.Migration

  import Ecto.Query

  alias Postgres.Repo

  def up do
    if us_board_id = Repo.one(us_board_id_query()) do
      us_board_id
      |> us_board_subquery()
      |> Repo.update_all(set: [disabled: true, updated_at: DateTime.utc_now()])
    end
  end

  def down do
    if us_board_id = Repo.one(us_board_id_query()) do
      us_board_id
      |> us_board_subquery()
      |> Repo.update_all(set: [disabled: false, updated_at: DateTime.utc_now()])
    end
  end

  defp us_board_id_query do
    from mc in "medical_categories", where: mc.name == "U.S Board Second Opinion", select: mc.id
  end

  defp us_board_subquery(parent_id) do
    from mc in "medical_categories", where: mc.parent_category_id == ^parent_id
  end
end
