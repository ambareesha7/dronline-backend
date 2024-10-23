defmodule Postgres.Repo.Migrations.CreateNewsletterSubscribersTable do
  use Ecto.Migration

  def change do
    create table(:newsletter_subscribers) do
      add :email, :string
      add :phone_number, :string

      timestamps()
    end

    create unique_index(:newsletter_subscribers, [:email])
    create unique_index(:newsletter_subscribers, [:phone_number])
  end
end
