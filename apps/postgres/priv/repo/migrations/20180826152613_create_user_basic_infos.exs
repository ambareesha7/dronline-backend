defmodule Postgres.Repo.Migrations.CreateUserBasicInfos do
  use Ecto.Migration

  def change do
    create table(:user_basic_infos) do
      add :title, :string
      add :first_name, :string
      add :last_name, :string
      add :birth_date, :date
      add :email, :string
      add :phone_code, :string
      add :phone_number, :string
      add :height, :integer
      add :weight, :integer

      add :user_id, references(:users, on_delete: :delete_all), null: false
    end

    create index(:user_basic_infos, [:user_id])
  end
end
