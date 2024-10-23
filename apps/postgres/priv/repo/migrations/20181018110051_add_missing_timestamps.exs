defmodule Postgres.Repo.Migrations.AddMissingTimestamps do
  use Ecto.Migration

  def change do
    alter table(:child_bmis) do
      add :inserted_at, :naive_datetime_usec
      add :updated_at, :naive_datetime_usec
    end

    alter table(:child_history_forms) do
      add :inserted_at, :naive_datetime_usec
      add :updated_at, :naive_datetime_usec
    end

    alter table(:children) do
      add :inserted_at, :naive_datetime_usec
      add :updated_at, :naive_datetime_usec
    end

    alter table(:specialists) do
      add :inserted_at, :naive_datetime_usec
      add :updated_at, :naive_datetime_usec
    end

    alter table(:user_addresses) do
      add :inserted_at, :naive_datetime_usec
      add :updated_at, :naive_datetime_usec
    end

    alter table(:user_basic_infos) do
      add :inserted_at, :naive_datetime_usec
      add :updated_at, :naive_datetime_usec
    end

    alter table(:user_blood_pressures) do
      add :inserted_at, :naive_datetime_usec
      add :updated_at, :naive_datetime_usec
    end

    alter table(:user_bmis) do
      add :inserted_at, :naive_datetime_usec
      add :updated_at, :naive_datetime_usec
    end

    alter table(:user_history_forms) do
      add :inserted_at, :naive_datetime_usec
      add :updated_at, :naive_datetime_usec
    end

    alter table(:user_hpis) do
      add :inserted_at, :naive_datetime_usec
      add :updated_at, :naive_datetime_usec
    end

    alter table(:users) do
      add :inserted_at, :naive_datetime_usec
      add :updated_at, :naive_datetime_usec
    end

    execute("UPDATE child_bmis SET inserted_at = NOW(), updated_at = NOW();")
    execute("UPDATE child_history_forms SET inserted_at = NOW(), updated_at = NOW();")
    execute("UPDATE children SET inserted_at = NOW(), updated_at = NOW();")
    execute("UPDATE specialists SET inserted_at = NOW(), updated_at = NOW();")
    execute("UPDATE user_addresses SET inserted_at = NOW(), updated_at = NOW();")
    execute("UPDATE user_basic_infos SET inserted_at = NOW(), updated_at = NOW();")
    execute("UPDATE user_blood_pressures SET inserted_at = NOW(), updated_at = NOW();")
    execute("UPDATE user_bmis SET inserted_at = NOW(), updated_at = NOW();")
    execute("UPDATE user_history_forms SET inserted_at = NOW(), updated_at = NOW();")
    execute("UPDATE user_hpis SET inserted_at = NOW(), updated_at = NOW();")
    execute("UPDATE users SET inserted_at = NOW(), updated_at = NOW();")

    alter table(:child_bmis) do
      modify :inserted_at, :naive_datetime_usec, null: false
      modify :updated_at, :naive_datetime_usec, null: false
    end

    alter table(:child_history_forms) do
      modify :inserted_at, :naive_datetime_usec, null: false
      modify :updated_at, :naive_datetime_usec, null: false
    end

    alter table(:children) do
      modify :inserted_at, :naive_datetime_usec, null: false
      modify :updated_at, :naive_datetime_usec, null: false
    end

    alter table(:specialists) do
      modify :inserted_at, :naive_datetime_usec, null: false
      modify :updated_at, :naive_datetime_usec, null: false
    end

    alter table(:user_addresses) do
      modify :inserted_at, :naive_datetime_usec, null: false
      modify :updated_at, :naive_datetime_usec, null: false
    end

    alter table(:user_basic_infos) do
      modify :inserted_at, :naive_datetime_usec, null: false
      modify :updated_at, :naive_datetime_usec, null: false
    end

    alter table(:user_blood_pressures) do
      modify :inserted_at, :naive_datetime_usec, null: false
      modify :updated_at, :naive_datetime_usec, null: false
    end

    alter table(:user_bmis) do
      modify :inserted_at, :naive_datetime_usec, null: false
      modify :updated_at, :naive_datetime_usec, null: false
    end

    alter table(:user_history_forms) do
      modify :inserted_at, :naive_datetime_usec, null: false
      modify :updated_at, :naive_datetime_usec, null: false
    end

    alter table(:user_hpis) do
      modify :inserted_at, :naive_datetime_usec, null: false
      modify :updated_at, :naive_datetime_usec, null: false
    end

    alter table(:users) do
      modify :inserted_at, :naive_datetime_usec, null: false
      modify :updated_at, :naive_datetime_usec, null: false
    end
  end
end
