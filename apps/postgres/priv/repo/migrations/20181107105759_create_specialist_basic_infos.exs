defmodule Postgres.Repo.Migrations.CreateSpecialistBasicInfos do
  use Ecto.Migration

  def change do
    create table(:specialist_basic_infos) do
      add :title, :string
      add :first_name, :string
      add :last_name, :string
      add :birth_date, :date
      add :image_url, :string

      add :specialist_id, references(:specialists, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:specialist_basic_infos, [:specialist_id])
  end
end
